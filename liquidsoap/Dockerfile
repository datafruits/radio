FROM archlinux

RUN yes | pacman -Sy opam make m4 gcc patch diffutils ffmpeg git automake autoconf pkg-config which taglib

RUN useradd liquidsoap && mkdir /home/liquidsoap && chown -R liquidsoap /home/liquidsoap

ENV HOME=/home/liquidsoap

USER liquidsoap

RUN opam init --disable-sandboxing --yes

WORKDIR /home/liquidsoap

# add liquidsoap user
#RUN useradd --create-home -s /bin/bash liquidsoap
#   usermod -a -G sudo liquidsoap
# RUN echo "Defaults    !requiretty" >> /etc/sudoers
# RUN echo "%sudo ALL=NOPASSWD: ALL" >> /etc/sudoers
#RUN echo 'eval "$(opam config env)"' >> /home/liquidsoap/.bashrc

#RUN touch /var/log/liquidsoap.log
#RUN chown liquidsoap:users /var/log/liquidsoap.log

RUN for i in ocaml-ffmpeg ocaml-dtools ocaml-duppy ocaml-mm ocaml-cry ocaml-taglib liquidsoap; do \
      cd /home/liquidsoap && git clone https://github.com/savonet/$i && cd $i && opam pin add --yes --no-action .; \
    done
RUN opam install --yes liquidsoap ffmpeg cry taglib

RUN mkdir /home/liquidsoap/radio
ADD ./ /home/liquidsoap/radio/
RUN mkdir /home/liquidsoap/tracks
RUN chown liquidsoap:liquidsoap /home/liquidsoap/tracks
RUN mkdir /home/liquidsoap/recordings
RUN chown liquidsoap:liquidsoap /home/liquidsoap/recordings

WORKDIR /home/liquidsoap/radio
RUN chown 1000:1000 /home/liquidsoap/tracks
RUN chown 1000:1000 /home/liquidsoap/recordings

EXPOSE 9000
CMD ["/bin/bash", "-c", "eval `opam config env` && liquidsoap radio.liq"]
