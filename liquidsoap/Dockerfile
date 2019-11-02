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
  libmad0-dev libtag1-dev libmp3lame-dev libogg-dev libvorbis-dev libfaac-dev libfaad-dev libfdk-aac-dev libflac-dev \
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
RUN opam switch create new 4.09.0
RUN opam update -y
RUN opam install depext -y

RUN eval `opam config env`
RUN sudo opam depext taglib mad lame ogg vorbis cry samplerate liquidsoap -y
RUN opam install taglib mad lame ogg vorbis cry samplerate liquidsoap -y

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
CMD ["/bin/bash", "-c", "eval `opam config env`; liquidsoap radio.liq"]
