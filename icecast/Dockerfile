FROM ubuntu:15.04

# locale
RUN locale-gen ja_JP.UTF-8 && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y build-essential wget libxslt1-dev libvorbis-dev
RUN apt-get clean

RUN wget http://downloads.xiph.org/releases/icecast/icecast-2.4.1.tar.gz
RUN tar xvf icecast-2.4.1.tar.gz

RUN cd icecast-2.4.1; ./configure && make && make install

ADD icecast.xml /icecast.xml
RUN useradd --create-home -s /bin/bash icecast
RUN chown icecast:users /icecast.xml
RUN mkdir -p /usr/local/var/log/icecast/
RUN touch /usr/local/var/log/icecast/access.log
RUN chown icecast:users /usr/local/var/log/icecast/access.log
RUN touch /usr/local/var/log/icecast/error.log
RUN chown icecast:users /usr/local/var/log/icecast/error.log

USER icecast

EXPOSE 8000
CMD icecast -c /icecast.xml
