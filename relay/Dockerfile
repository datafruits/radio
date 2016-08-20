FROM mcfiredrill/icecast:latest

ADD icecast.xml /icecast.xml
USER root
RUN chown icecast:users /icecast.xml

USER icecast
EXPOSE 8000
CMD icecast -c /icecast.xml
