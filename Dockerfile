FROM ubuntu:14.04

# locale
RUN locale-gen ja_JP.UTF-8 && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y
# for liquidsoap/icecast
RUN apt-get install -y --force-yes build-essential autoconf curl git ocaml \
  libmad0-dev libtag1-dev libmp3lame-dev libogg-dev libvorbis-dev libpcre-ocaml-dev \
  libcamomile-ocaml-dev pkg-config
# for ruby
RUN apt-get install -y --force-yes libssl-dev
RUN apt-get install -y icecast2

RUN apt-get clean

# Install rbenv and ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
RUN /usr/local/rbenv/plugins/ruby-build/install.sh
ENV RBENV_ROOT /usr/local/rbenv
ENV PATH /usr/local/rbenv/bin:$PATH
ADD rbenv.sh /etc/profile.d/rbenv.sh

ENV CONFIGURE_OPTS --disable-install-doc

RUN rbenv install 2.1.5
RUN rbenv global 2.1.5
RUN rbenv exec gem install bundler

# add liquidsoap user for compilation
RUN useradd --create-home -s /bin/bash liquidsoap ;\
  adduser liquidsoap sudo
RUN echo "Defaults    !requiretty" >> /etc/sudoers
RUN echo "%sudo ALL=NOPASSWD: ALL" >> /etc/sudoers
RUN echo 'eval "$(rbenv init -)"' >> /home/liquidsoap/.bashrc
RUN echo 'gem: --no-rdoc --no-ri' >> /home/liquidsoap/.gemrc

ADD radio.liq /radio.liq
ADD start.sh /start.sh
ADD icecast.xml /icecast.xml
ADD emergency_broadcast.wav /emergency_broadcast.wav

RUN chown icecast2:users /icecast.xml
RUN chown liquidsoap:users /radio.liq
RUN touch /var/log/liquidsoap.log
RUN chown liquidsoap:users /var/log/liquidsoap.log
RUN adduser icecast2 sudo

# install liquidsoap from source
USER liquidsoap
RUN cd /home/liquidsoap; git clone https://github.com/savonet/liquidsoap-full
ADD PACKAGES /home/liquidsoap/liquidsoap-full/PACKAGES
RUN cd /home/liquidsoap/liquidsoap-full; ./bootstrap;
RUN cd /home/liquidsoap/liquidsoap-full; ./configure;
RUN cd /home/liquidsoap/liquidsoap-full; make;
RUN cd /home/liquidsoap/liquidsoap-full; sudo make install

USER root

EXPOSE 8000
CMD /start.sh
