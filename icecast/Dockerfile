FROM ubuntu:14.04

# locale
RUN locale-gen ja_JP.UTF-8 && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y icecast2
RUN apt-get clean

ADD icecast.xml /icecast.xml
RUN chown icecast2:users /icecast.xml

USER icecast2

EXPOSE 8000
CMD icecast2 -c /icecast.xml
