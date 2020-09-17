FROM ubuntu:latest

RUN rm -rf /etc/apt/sources.list
RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb-src mirror://mirrors.ubuntu.com/mirrors.txt bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get clean
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:avsm/ppa
RUN apt-get update && apt-get upgrade -y

# for liquidsoap
RUN apt-get install -y --allow-unauthenticated build-essential autoconf curl git ocaml ocaml-native-compilers camlp4-extra opam \
  libmad0-dev libtag1-dev libmp3lame-dev libogg-dev libvorbis-dev libfaac-dev libfaad-dev libfdk-aac-dev libflac-dev ffmpeg \
  libmagic-dev \
  pkg-config \
  wget telnet \
  mccs sudo
# for ruby
RUN apt-get install -y --force-yes libssl-dev libreadline-dev

# jq
RUN apt-get install -y --force-yes jq

RUN apt-get clean

# add liquidsoap user
RUN useradd --create-home -s /bin/bash liquidsoap ;\
  adduser liquidsoap sudo
RUN echo "Defaults    !requiretty" >> /etc/sudoers
RUN echo "%sudo ALL=NOPASSWD: ALL" >> /etc/sudoers
RUN echo 'eval "$(opam config env)"' >> /home/liquidsoap/.bashrc

RUN touch /var/log/liquidsoap.log
RUN chown liquidsoap:users /var/log/liquidsoap.log

RUN apt-get install -y libpcre3-dev
RUN apt-get install -y gdb

USER liquidsoap
RUN opam init -y --disable-sandboxing --solver=mccs
RUN opam switch create new 4.08.0
RUN opam update -y
RUN opam install depext -y

RUN eval `opam config env`
RUN sudo opam depext taglib mad lame ogg vorbis cry samplerate ffmpeg gavl gstreamer liquidsoap -y
RUN opam install taglib mad lame ogg vorbis cry samplerate ffmpeg gavl gstreamer liquidsoap -y
RUN eval `opam config env` && liquidsoap --version

#RUN ["/bin/bash", "-c", "ls -lha ~"]
# RUN cd /home/liquidsoap; git clone https://github.com/savonet/liquidsoap-full
# ADD PACKAGES /home/liquidsoap/liquidsoap-full/PACKAGES
# RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full/; git rev-parse HEAD;"]
# RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full/; make init && make update;"]
# RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full/liquidsoap; git rev-parse HEAD;"]
#RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full/ocaml-mm; git rev-parse HEAD;"]
#RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full/ocaml-mm; eval `opam config env`; opam pin add . -y;"]
#ADD protocols.liq /home/liquidsoap/liquidsoap-full/liquidsoap/libs/protocols.liq
#RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full/liquidsoap; eval `opam config env`; opam pin add . -y;"]
# RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full; ./bootstrap;"]
# #RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full; ls -lha; cat configure"]
# RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full; eval `opam config env`; ./configure;"]
# RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full; eval `opam config env`; make;"]
# RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full; eval `opam config env`; sudo make install"]

RUN mkdir /home/liquidsoap/radio
ADD ./ /home/liquidsoap/radio/
RUN mkdir /home/liquidsoap/tracks
RUN chown liquidsoap:liquidsoap /home/liquidsoap/tracks
RUN mkdir /home/liquidsoap/recordings
RUN chown liquidsoap:liquidsoap /home/liquidsoap/recordings

WORKDIR /home/liquidsoap/radio
RUN chown 1000:1000 /home/liquidsoap/tracks
RUN chown 1000:1000 /home/liquidsoap/recordings

EXPOSE 9000
CMD ["/bin/bash", "-c", "eval `opam config env` && liquidsoap radio.liq"]
