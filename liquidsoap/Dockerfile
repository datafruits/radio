FROM ubuntu:14.04

# locale
RUN locale-gen ja_JP.UTF-8 && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y
# for liquidsoap
RUN apt-get install -y --force-yes build-essential autoconf curl git ocaml \
  libmad0-dev libtag1-dev libmp3lame-dev libogg-dev libvorbis-dev libpcre-ocaml-dev \
  libcamomile-ocaml-dev pkg-config
# for ruby
RUN apt-get install -y --force-yes libssl-dev

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

RUN touch /var/log/liquidsoap.log
RUN chown liquidsoap:users /var/log/liquidsoap.log

# install liquidsoap from source
USER liquidsoap
RUN cd /home/liquidsoap; git clone https://github.com/savonet/liquidsoap-full
ADD PACKAGES /home/liquidsoap/liquidsoap-full/PACKAGES
RUN cd /home/liquidsoap/liquidsoap-full; ./bootstrap;
RUN cd /home/liquidsoap/liquidsoap-full; ./configure;
RUN cd /home/liquidsoap/liquidsoap-full; make;
RUN cd /home/liquidsoap/liquidsoap-full; sudo make install

RUN mkdir /home/liquidsoap/radio
ADD radio.liq /home/liquidsoap/radio/radio.liq
ADD emergency_broadcast.wav /home/liquidsoap/radio/emergency_broadcast.wav
ADD Gemfile /home/liquidsoap/radio/Gemfile
ADD dj_auth.rb /home/liquidsoap/radio/dj_auth.rb
ADD next_song.rb /home/liquidsoap/radio/next_song.rb

WORKDIR /home/liquidsoap/radio
RUN rbenv exec bundle install

EXPOSE 9000
CMD liquidsoap radio.liq
