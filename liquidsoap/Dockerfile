# FROM archlinux
#
# RUN pacman -Sy --noconfirm archlinux-keyring
#
# RUN pacman-key --init
# RUN pacman-key --populate archlinux
# RUN yes | pacman -Syu --noconfirm opam make m4 gcc patch diffutils gavl ffmpeg git automake autoconf pkg-config which taglib sudo glibc jq libffi pcre libmad
#

FROM savonet/liquidsoap:v2.4.x-latest
#RUN useradd liquidsoap && mkdir /home/liquidsoap && chown -R liquidsoap /home/liquidsoap
#RUN usermod -aG wheel liquidsoap
# RUN echo "Defaults    !requiretty" >> /etc/sudoers
# RUN echo "%wheel ALL=NOPASSWD: ALL" >> /etc/sudoers

ENV HOME=/home/liquidsoap

USER root

RUN apt-get update
RUN apt-get install -y --no-install-recommends curl jq


# RUN opam init --disable-sandboxing --yes

WORKDIR /home/liquidsoap

# add liquidsoap user
#RUN useradd --create-home -s /bin/bash liquidsoap
#   usermod -a -G sudo liquidsoap
# RUN echo "Defaults    !requiretty" >> /etc/sudoers
# RUN echo "%sudo ALL=NOPASSWD: ALL" >> /etc/sudoers
#RUN echo 'eval "$(opam config env)"' >> /home/liquidsoap/.bashrc

RUN touch /var/log/liquidsoap.log
RUN chown liquidsoap:users /var/log/liquidsoap.log

# RUN opam switch create 4.14.2
# RUN opam update
#
# depext no longer required to install, integrated with opam
# RUN opam install depext -y
# RUN opam depext taglib mad lame ogg vorbis cry samplerate liquidsoap -y
# RUN opam install taglib mad lame ogg vorbis cry samplerate ocurl liquidsoap -y
#RUN opam install ctypes-foreign metadata mad lame ogg vorbis cry samplerate ocurl gavl ffmpeg liquidsoap -y

# RUN for i in ocaml-gavl ocaml-ffmpeg ocaml-dtools ocaml-duppy ocaml-mm ocaml-cry ocaml-taglib ocaml-lame ocaml-mad ocaml-ogg ocaml-vorbis ocaml-samplerate; do \
#   cd /home/liquidsoap && git clone https://github.com/savonet/$i && cd $i && opam pin add --yes --no-action .; \
# done
# RUN cd /home/liquidsoap && git clone https://github.com/savonet/liquidsoap && cd liquidsoap && git checkout v2.0.0 && opam pin add --yes --no-action .
#RUN cd /home/liquidsoap && git clone https://github.com/savonet/liquidsoap && cd liquidsoap && opam pin add --yes --no-action .
# RUN opam install --yes liquidsoap ffmpeg cry taglib lame mad ogg vorbis samplerate
#
# RUN eval $(opam env) && liquidsoap --version
#
RUN mkdir /home/liquidsoap/radio
ADD ./ /home/liquidsoap/radio/

#RUN chown -R liquidsoap:liquidsoap /home/liquidsoap/radio/
RUN chmod +x /home/liquidsoap/radio/libStereoTool_64.so

RUN mkdir /home/liquidsoap/tracks
RUN chown liquidsoap:liquidsoap /home/liquidsoap/tracks
RUN mkdir /home/liquidsoap/recordings
RUN chown liquidsoap:liquidsoap /home/liquidsoap/recordings

RUN mkdir /home/liquidsoap/hls
RUN chown liquidsoap:liquidsoap /home/liquidsoap/hls

RUN chown -R liquidsoap:liquidsoap /home/liquidsoap/

WORKDIR /home/liquidsoap/radio
RUN liquidsoap --version
RUN liquidsoap --check radio.liq
# RUN chown 1000:1000 /home/liquidsoap/tracks
# RUN chown 1000:1000 /home/liquidsoap/recordings
#RUN chown liquidsoap:liquidsoap /home/liquidsoap/tracks
#RUN chown liquidsoap:liquidsoap /home/liquidsoap/recordings

RUN usermod -u 1000 liquidsoap
RUN groupmod -g 1000 liquidsoap

USER liquidsoap

RUN id

EXPOSE 9000
EXPOSE 9001
EXPOSE 1936
# CMD ["/bin/bash", "-c", "eval `opam config env`; liquidsoap radio.liq"]
CMD ["liquidsoap", "radio.liq"]
