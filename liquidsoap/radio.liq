#!/usr/local/bin/liquidsoap
%include "tunein.liq"

set("sandbox.tool","disabled")
set("log.file",true)
set("log.file.path","/var/log/liquidsoap.log")
set("log.stdout",true)
set("log.level",4)

set("server.telnet",true)
set("server.socket",true)
set("server.socket.path","/home/liquidsoap/tracks/liquidsoap.sock")

set("harbor.bind_addrs",["0.0.0.0"])

# needs these env variables
radio_name = getenv("RADIO_NAME")
icecast_host = "icecast"
icecast_port = "8000"
crossfade_enabled = getenv("CROSSFADE")

tunein_partner_id = getenv("TUNEIN_PARTNER_ID")
tunein_partner_key = getenv("TUNEIN_PARTNER_KEY")
tunein_station_id = getenv("TUNEIN_STATION_ID")
tunein_metadata_updates_enabled = getenv("TUNEIN_METADATA_UPDATES_ENABLED")

# liq_secret = getenv("LIQ_SECRET")

def icy_update(v) =
  # Parse the argument
  l = string.split(separator=",",v)
  def split(l,v) =
    v = string.split(separator="=",v)
    if list.length(v) >= 2 then
      list.append(l,[(list.nth(v,0,default=""),list.nth(v,1,default=""))])
    else
      l
    end
  end
  meta = list.fold(split,[],l)

  # Update metadata
  icy.update_metadata(mount="#{radio_name}.ogg",password="hackme",
                      host=icecast_host,meta)
  icy.update_metadata(mount="#{radio_name}.mp3",password="hackme",
                      host=icecast_host,meta)
  "Done !"
end

server.register("update",namespace="metadata",
                 description="Update metadata",
                 usage="update title=foo,album=bar,..",
                 icy_update)


# refs
title_prefix = ref ""

current_dj = ref ""
last_dj_disconnected = ref ""
current_dj_connected_at = ref 0.0
last_dj_disconnected_at = ref 0.0
current_dump_filename = ref ""

stop_dump_f = ref (fun () -> ())

live_dj = ref empty()

def get_user(user,password) =
  if user == "source" then
    x = string.split(separator=';',password)
    list.nth(x,0,default="")
  else
    user
  end
end

def get_password(user,password) =
  if user == "source" then
    x = string.split(separator=';',password)
    list.nth(x,1,default="")
  else
    password
  end
end

#auth function
def dj_auth(user,password) =
  log("dj auth")
  u = get_user(user,password)
  p = get_password(user,password)
  ret = get_process_lines("./dj_auth.sh '#{u}' '#{p}' '#{radio_name}'")
  #ret has now the value of the live client (dj1,dj2, or djx), or "ERROR"/"unknown"
  ret = list.hd(default="",ret)
  #return true to let the client transmit data, or false to tell harbor to decline
  if ret == "true" then
    title_prefix := "LIVE -- #{u}"
    current_dj := "#{u}"
    current_dj_connected_at := gettimeofday()
    log("dj auth succeeded")
    log("#{current_dj}")
    log("#{current_dj_connected_at}")
    true
  else
    false
  end
end


def my_request_function () =
  lines = get_process_lines("./next_song.sh")
  result = list.hd(default="", lines)
  log("result: #{result}")
  log("lines: #{lines}")
  json = of_json(default=[("error","fail")], result)
  log("json: #{json}")
  track = json["track"]
  cue_in = int_of_string(json["cue_in"])
  cue_out = int_of_string(json["cue_out"])
  log("cue_out: #{cue_out}")
  fade_in = int_of_string(json["fade_in"])
  fade_out = int_of_string(json["fade_out"])
  if cue_out == 0 then
    # don't set cue out if its 0
    annotate_line = "annotate:liq_fade_in=#{fade_in},liq_fade_out=#{fade_out},liq_cue_in=#{cue_in}:#{track}"
    log("annotate_line: #{annotate_line}")
    request.create(annotate_line)
  else
    annotate_line = "annotate:liq_fade_in=#{fade_in},liq_fade_out=#{fade_out},liq_cue_in=#{cue_in},liq_cue_out=#{cue_out}:#{track}"
    log("annotate_line: #{annotate_line}")
    request.create(annotate_line)
  end
end

backup_playlist = cue_cut(audio_to_stereo(request.dynamic(id="requests", timeout=60.0, my_request_function)))

def format_time(~sec,~min,~hour,~mday,~mon,~year,
                ~wday,~yday,~isdst) =
  "#{1900+year}-#{mon+1}-#{mday}-#{hour}:#{min}:#{sec}"
end

def on_connect(headers) =
  log("on_connect")
  list.iter(fun(header)-> log("#{fst(header)}: #{snd(header)}"), headers)
  # if they disconnected over 60 seconds ago, use new filename
  log("current_dj_connected_at: #{!current_dj_connected_at}")
  log("last_dj_disconnected_at: #{!last_dj_disconnected_at}")
  if (!last_dj_disconnected_at == 0.0) then
    log("*****************************************CREATING NEW DUMP, last_dj_disconnected_at is null***************************************************")
    current_dump_filename := "#{!current_dj}-#{localtime(!current_dj_connected_at, format_time)}"
    log("sending live notification")
    ret = get_process_lines("./live_notification.sh 'LIVE - #{!current_dj}'")
    ret = list.hd(default="",ret)
    log(ret)
  elsif (((!current_dj_connected_at - !last_dj_disconnected_at) > 60.0) or (!current_dj != !last_dj_disconnected)) then
    log("*****************************************CREATING NEW DUMP***************************************************")
    current_dump_filename := "#{!current_dj}-#{localtime(!current_dj_connected_at, format_time)}"
    log("sending live notification")
    ret = get_process_lines("./live_notification.sh 'LIVE - #{!current_dj}'")
    ret = list.hd(default="",ret)
    log(ret)
  else
    log("*****************************************APPENDING TO PREVIOUS DUMP***************************************************")
  end
  # else append to the old file (dont change the current_dump_filename)
  s = output.file(%mp3, "/home/liquidsoap/recordings/#{radio_name}-#{!current_dump_filename}.mp3", !live_dj, fallible=true, append=true)
  stop_dump_f := fun () -> source.shutdown(s)
end

def on_disconnect() =
  log("disconnected")
  last_dj_disconnected_at := gettimeofday()
  # shutdown source
  title_prefix := ""
  last_dj_disconnected := !current_dj
  current_dj := ""
  sleep(60.0)
  f = !stop_dump_f
  f ()
end

if crossfade_enabled == "true" then
  output.dummy(fallible=true,crossfade(backup_playlist))
else
  output.dummy(fallible=true,backup_playlist)
end

live_dj := audio_to_stereo(input.harbor("#{radio_name}",id="live_dj",port=9000,auth=dj_auth,on_connect=on_connect,on_disconnect=on_disconnect,logfile="/tmp/liquidsoap_harbor.log",buffer=15.0,max=40.0))

def new_meta(m) =
  if "#{title_prefix}" == "" then
    title = m["title"]
    [("title","#{title}")]
  else
    [("title","#{!title_prefix}")]
  end
end

def pub_metadata(m) =
  log("on_track");
  title = m["title"]
  ret = get_process_lines("./pub_metadata.sh '#{title}'")
  ret = list.hd(default="",ret)
  log(ret)
  #url = "https://#{radio_name}.streampusher.com/publish_metadata.json"
  #log("url: #{url}")
  # headers = [("Content-Type","application/json"), ("Accept", "application/json"), ("liq-secret", liq_secret)]
  # let (status, headers, data) = https.post(headers=headers,data="{\"metadata\": \"#{title}\"}", url)
  # log("status: #{status}");
  # log("headers: #{headers}");
  # log("data: #{data}");
  # let (protocol, code, desc) = status;
  # log("protocol: #{protocol}");
  # log("response code: #{code}");
  # log("desc: #{desc}");
end

live_dj := map_metadata(new_meta, !live_dj,update=false)

live_dj := pipe(process='./stereo_tool_cmd_64 - - -s ./stereotool.sts', buffer=10.0, !live_dj)

source = fallback(id="fallback",track_sensitive=false,
                  [!live_dj,mksafe(backup_playlist)])

source = if tunein_metadata_updates_enabled == "true" then on_track(tunein.submit(partnerid=tunein_partner_id,partnerkey=tunein_partner_key,stationid=tunein_station_id), source) else source end

source = on_track(pub_metadata, source)

source = server.insert_metadata(id="fallback", source)

clock.assign_new(id="vorbis_icecast", [output.icecast(%vorbis,id="icecast",
                                       mount="#{radio_name}.ogg",
                                       host=icecast_host, port=int_of_string(icecast_port), password="hackme",
                                       icy_metadata="true",description="",
                                       url="", encoding="UTF-8",
                                       mksafe(buffer(source)))])
clock.assign_new(id="mp3_icecast", [output.icecast(%mp3,id="icecast",
                                    mount="#{radio_name}.mp3",
                                    host=icecast_host, port=int_of_string(icecast_port), password="hackme",
                                    icy_metadata="true",description="",
                                    url="", encoding="UTF-8",
                                    mksafe(buffer(source)))])
