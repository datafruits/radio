#!/usr/local/bin/liquidsoap

set("log.file",true)
set("log.file.path","./log/liquidsoap.log")
set("log.stdout",true)
set("log.level",3)

set("harbor.bind_addr","0.0.0.0")
live_dj = input.harbor("live",port=9000)

# stream variables
mount_name = getenv("MOUNT_NAME")

output.icecast(%vorbis,id="icecast",
               mount="#{mount_name}.ogg",
               host="localhost", password="hackme",
               icy_metadata="true",description="",
               url="",
               source)
output.icecast(%mp3,id="icecast",
               mount="#{mount_name}.mp3",
               host="localhost", password="hackme",
               icy_metadata="true",description="",
               url="",
               source)
