#!/usr/local/bin/liquidsoap

set("log.file",true)
set("log.file.path","/var/log/liquidsoap.log")
set("log.stdout",true)
set("log.level",3)

set("harbor.bind_addr","0.0.0.0")
# needs these env variables
radio_name = getenv("RADIO_NAME")

# refs
title_prefix = ref ""

def my_request_function () =
  result = get_process_lines("bundle exec ./next_song.rb")
  log("next song: #{result}")
  request.create(list.hd(result))
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
  ret = get_process_lines("bundle exec ./dj_auth.rb #{u} #{p} #{radio_name}")
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

backup_playlist = request.dynamic(my_request_function)
output.dummy(fallible=true,backup_playlist)
live_dj = input.harbor("#{radio_name}",port=9000,auth=dj_auth,on_disconnect=on_disconnect)

def new_meta(m) =
  if "#{title_prefix}" == "" then
    title = m["title"]
    [("title","#{title}")]
  else
    [("title","#{!title_prefix}")]
  end
end

live_dj = map_metadata(new_meta, live_dj,update=false)
on_fail = single("./emergency_broadcast.wav")

source = fallback(track_sensitive=false,
                  [live_dj,backup_playlist,on_fail])

output.icecast(%vorbis,id="icecast",
               mount="#{radio_name}.ogg",
               host="localhost", password="hackme",
               icy_metadata="true",description="",
               url="",
               source)
output.icecast(%mp3,id="icecast",
               mount="#{radio_name}.mp3",
               host="localhost", password="hackme",
               icy_metadata="true",description="",
               url="",
               source)
