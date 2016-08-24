# https://forum.sourcefabric.org/discussion/15711/liquidsoap-tunein-com-now-playing-implementation/p1

# Submit now playing metadata to tunein.com.
# usage:
#   %include "tunein.liq"
#   s = on_track(tunein.submit(partnerid="ppppid",partnerkey="ppppkey",stationid="s123456"), s)
# Requires parterId, partnerKey and stationId. See http://tunein.com/broadcasters/api/.
# @category Interaction
# @param ~partnerid Set to supplied parterId.
# @param ~partnerkey Set to supplied partnerKey.
# @param ~stationid Set to supplied stationId.
# @param ~commercial Set to true if track is a commercial.  Defaults to false.
def tunein.submit(~partnerid,~partnerkey,~stationid,~commercial=false,m) =
  artist = if m["artist"] == "" then "-" else m["artist"] end
  params = [
    "partnerId=" ^ url.encode(partnerid),
    "partnerKey=" ^ url.encode(partnerkey),
    "id=" ^ url.encode(stationid),
    "title=" ^ url.encode(m["title"]),
    "artist=" ^ url.encode(artist),
    "album=" ^ url.encode(m["album"]),
    "commercial=#{commercial}"
  ]
  log(level=3, "tunein.submit: title=#{m['title']}; artist=#{artist}; " ^
               "album=#{m['album']}; commercial=#{commercial}")
  url = "http://air.radiotime.com/Playing.ashx?" ^ string.concat(separator="&", params)
  log(level=4, "tunein.submit: url=" ^ url)
  answer = http.get(url)
  x = fst(answer)
  status = fst(x)
  y = fst(status)
  protocol = fst(y)
  code = snd(y)
  if code != 200 then
    desc = snd(status)
    headers = snd(x)
    data = snd(answer)
    log(level=3,"tunein.submit: Response status: #{protocol} #{code} #{desc}")
    log(level=4,"Response headers:")
    def log_arg(x) =
      label = fst(x)
      value = snd(x)
      log(level=4,"  #{label}: #{value}")
    end
    list.iter(log_arg,headers)
    log(level=4,"Response content: #{data}")
  end
end
