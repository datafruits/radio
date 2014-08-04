FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y --force-yes build-essential curl git
RUN apt-get install -y icecast2

RUN apt-get clean

RUN useradd icecast

ENTRYPOINT ["icecast", "-c", "/etc/icecast.xml"]
EXPOSE 8000
CMD [""]
