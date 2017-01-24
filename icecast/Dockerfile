FROM ubuntu:14.04

# locale
RUN locale-gen ja_JP.UTF-8 && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y build-essential wget libxslt1-dev libvorbis-dev git
RUN apt-get clean

RUN git clone https://github.com/karlheyes/icecast-kh.git

RUN cd icecast-kh; ./configure && make && make install

ADD icecast.xml /icecast.xml
RUN useradd --create-home -s /bin/bash icecast
RUN chown icecast:users /icecast.xml

RUN mkdir -p /usr/local/share/icecast/
RUN mkdir -p /usr/local/share/icecast/logs
RUN mkdir -p /usr/local/share/icecast/web
RUN mkdir -p /usr/local/share/icecast/admin

RUN touch /usr/local/share/icecast/logs/access.log
RUN touch /usr/local/share/icecast/logs/error.log

RUN chown -R icecast:users /usr/local/share/icecast

USER icecast

EXPOSE 8000
CMD icecast -c /icecast.xml
