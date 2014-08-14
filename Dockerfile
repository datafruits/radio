FROM ubuntu:14.04

# locale
RUN locale-gen ja_JP.UTF-8 && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y --force-yes build-essential curl git
RUN apt-get install -y icecast2

RUN apt-get clean

# install liquidsoap from source
RUN git clone https://github.com/savonet/liquidsoap-full
ADD PACKAGES ./liquidsoap/PACKAGES
RUN cd liquidsoap; ./bootstrap; ./configure;\
  make; make install

USER icecast2

ENTRYPOINT ["exec", "icecast2", "-c", "/etc/icecast2/icecast.xml"]
EXPOSE 8000
CMD [""]
