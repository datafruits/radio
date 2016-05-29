#!/usr/local/bin/liquidsoap

set("log.file",true)
set("log.file.path","/var/log/liquidsoap.log")
set("log.stdout",true)
set("log.level",3)

set("server.telnet",true)
set("server.socket",true)
set("server.socket.path","/home/liquidsoap/tracks/liquidsoap.sock")

set("harbor.bind_addr","0.0.0.0")
# needs these env variables
radio_name = getenv("RADIO_NAME")
icecast_host = "#{radio_name}_icecast"
icecast_port = "8000"
crossfade_enabled = getenv("CROSSFADE")

def icy_update(v) =
  # Parse the argument
  l = string.split(separator=",",v)
  def split(l,v) =
    v = string.split(separator="=",v)
    if list.length(v) >= 2 then
      list.append(l,[(list.nth(v,0),list.nth(v,1))])
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

def save_recording(filename) =
  result = get_process_lines("rbenv exec bundle exec ruby ./save_recording.rb \"#{filename}\" #{radio_name}")
  log("save_recording: #{result}")
end

def get_user(user,password) =
  if user == "source" then
    x = string.split(separator=';',password)
    list.nth(x,0)
  else
    user
  end
end

def get_password(user,password) =
  if user == "source" then
    x = string.split(separator=';',password)
    list.nth(x,1)
  else
    password
  end
end

#auth function
def dj_auth(user,password) =
  u = get_user(user,password)
  p = get_password(user,password)
  #get the output of the php script
  ret = get_process_lines("rbenv exec bundle exec ruby ./dj_auth.rb #{u} #{p} #{radio_name}")
  #ret has now the value of the live client (dj1,dj2, or djx), or "ERROR"/"unknown"
  ret = list.hd(ret)
  #return true to let the client transmit data, or false to tell harbor to decline
  if ret == "true" then
    title_prefix := "LIVE -- #{u}"
    true
  else
    false
  end
end

def on_disconnect() =
  title_prefix := ""
end

def my_request_function () =
  result = list.hd(get_process_lines("rbenv exec bundle exec ruby ./next_song.rb"))
  log("result: #{result}")
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
    annotate_line = "annotate:liq_fade_in=#{fade_in},liq_fade_out=#{fade_out},liq_cue_in=#{cue_in}:/home/liquidsoap/tracks/#{track}"
    log("annotate_line: #{annotate_line}")
    request.create(annotate_line)
  else
    annotate_line = "annotate:liq_fade_in=#{fade_in},liq_fade_out=#{fade_out},liq_cue_in=#{cue_in},liq_cue_out=#{cue_out}:/home/liquidsoap/tracks/#{track}"
    log("annotate_line: #{annotate_line}")
    request.create(annotate_line)
  end
end

backup_playlist = cue_cut(request.dynamic(id="requests", my_request_function))

if crossfade_enabled == "true" then
  output.dummy(fallible=true,smart_crossfade(backup_playlist))
else
  output.dummy(fallible=true,backup_playlist)
end
live_dj = audio_to_stereo(input.harbor("#{radio_name}",id="live_dj",port=9000,auth=dj_auth,on_disconnect=on_disconnect,logfile="/tmp/liquidsoap_harbor.log",buffer=15.0,max=30.0))

def new_meta(m) =
  if "#{title_prefix}" == "" then
    title = m["title"]
    [("title","#{title}")]
  else
    [("title","#{!title_prefix}")]
  end
end

live_dj = map_metadata(new_meta, live_dj,update=false)

source = fallback(id="fallback",track_sensitive=false,
                  [clock(live_dj),mksafe(backup_playlist)])

source = server.insert_metadata(id="fallback", source)

title = '$(if $(title),"$(title)",\
         "Emission inconnue")$(if $(artist), \
         " par  $(artist)") - %m-%d-%Y, %H:%M:%S'
output.file(%mp3, "/home/liquidsoap/tracks/#{radio_name}-#{title}.mp3", live_dj, fallible=true, reopen_on_metadata=true)
clock.assign_new(id="vorbis_icecast", [output.icecast(%vorbis,id="icecast",
                                       mount="#{radio_name}.ogg",
                                       host=icecast_host, port=int_of_string(icecast_port), password="hackme",
                                       icy_metadata="true",description="",
                                       url="",
                                       mksafe(buffer(source)))])
clock.assign_new(id="mp3_icecast", [output.icecast(%mp3,id="icecast",
                                    mount="#{radio_name}.mp3",
                                    host=icecast_host, port=int_of_string(icecast_port), password="hackme",
                                    icy_metadata="true",description="",
                                    url="",
                                    mksafe(buffer(source)))])
