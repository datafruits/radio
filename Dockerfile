FROM ubuntu:14.04

# locale
RUN locale-gen ja_JP.UTF-8 && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --force-yes build-essential autoconf curl git ocaml \
  libmad0-dev libtag1-dev libmp3lame-dev libogg-dev libvorbis-dev libpcre-ocaml-dev \
  libcamomile-ocaml-dev pkg-config
RUN apt-get install -y icecast2

RUN apt-get clean

# add liquidsoap user for compilation
RUN useradd --create-home -s /bin/bash liquidsoap ;\
  adduser liquidsoap sudo
RUN echo "Defaults    !requiretty" >> /etc/sudoers
RUN echo "%sudo ALL=NOPASSWD: ALL" >> /etc/sudoers

ADD radio.liq /radio.liq
ADD start.sh /start.sh
ADD icecast.xml /icecast.xml
ADD emergency_broadcast.wav /emergency_broadcast.wav

RUN chown icecast2:users /icecast.xml
RUN chown icecast2:users /radio.liq
RUN touch /var/log/liquidsoap.log
RUN chown icecast2:users /var/log/liquidsoap.log

# install liquidsoap from source
USER liquidsoap
RUN cd /home/liquidsoap; git clone https://github.com/savonet/liquidsoap-full
ADD PACKAGES /home/liquidsoap/liquidsoap-full/PACKAGES
RUN cd /home/liquidsoap/liquidsoap-full; ./bootstrap;
RUN cd /home/liquidsoap/liquidsoap-full; ./configure;
RUN cd /home/liquidsoap/liquidsoap-full; make;
RUN cd /home/liquidsoap/liquidsoap-full; sudo make install

USER icecast2

EXPOSE 8000
CMD /start.sh
