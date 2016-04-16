FROM ubuntu:14.04

# locale
RUN locale-gen ja_JP.UTF-8 && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:avsm/ppa
RUN apt-get update && apt-get upgrade -y

# for libfaac etc
RUN apt-add-repository multiverse && sudo apt-get update

# for liquidsoap
RUN apt-get install -y --force-yes build-essential autoconf curl git ocaml ocaml-native-compilers camlp4-extra opam \
  libmad0-dev libtag1-dev libmp3lame-dev libogg-dev libvorbis-dev libfaac-dev libfaad-dev libfdk-aac-dev libflac-dev \
  pkg-config \
  wget telnet
# for ruby
RUN apt-get install -y --force-yes libssl-dev libreadline-dev
# sox
RUN apt-get install -y --force-yes sox libsox-fmt-mp3

RUN apt-get clean

# Install rbenv and ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
RUN /usr/local/rbenv/plugins/ruby-build/install.sh
ENV RBENV_ROOT /usr/local/rbenv
ENV PATH /usr/local/rbenv/bin:$PATH
ADD rbenv.sh /etc/profile.d/rbenv.sh

ENV CONFIGURE_OPTS --disable-install-doc

RUN rbenv install 2.3.0
RUN rbenv global 2.3.0
RUN rbenv exec gem install bundler

# add liquidsoap user for compilation
RUN useradd --create-home -s /bin/bash liquidsoap ;\
  adduser liquidsoap sudo
RUN echo "Defaults    !requiretty" >> /etc/sudoers
RUN echo "%sudo ALL=NOPASSWD: ALL" >> /etc/sudoers
RUN echo 'eval "$(rbenv init -)"' >> /home/liquidsoap/.bashrc
#RUN echo '. /home/liquidsoap/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true' >> /home/liquidsoap/.bashrc
RUN echo 'eval "$(opam config env)"' >> /home/liquidsoap/.bashrc
RUN echo 'gem: --no-rdoc --no-ri' >> /home/liquidsoap/.gemrc

RUN touch /var/log/liquidsoap.log
RUN chown liquidsoap:users /var/log/liquidsoap.log

RUN apt-get install -y libpcre3-dev

# install liquidsoap from source
USER liquidsoap
RUN cd ~; opam init -y
RUN cd ~; opam install -y base-bytes pcre camomile
RUN cd /home/liquidsoap; git clone https://github.com/savonet/liquidsoap-full
ADD PACKAGES /home/liquidsoap/liquidsoap-full/PACKAGES
RUN ["/bin/bash", "-c", "ls -lha ~"]
RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full; ./bootstrap;"]
RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full; eval `opam config env`; ./configure;"]
RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full; eval `opam config env`; make;"]
RUN ["/bin/bash", "-c", "cd /home/liquidsoap/liquidsoap-full; eval `opam config env`; sudo make install"]

RUN mkdir /home/liquidsoap/radio
ADD ./ /home/liquidsoap/radio/

WORKDIR /home/liquidsoap/radio
RUN rbenv exec bundle install

EXPOSE 9000
CMD liquidsoap radio.liq
