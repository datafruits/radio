FROM archlinux

RUN yes | pacman -Sy archlinux-keyring
RUN pacman-key --init
RUN pacman-key --populate archlinux
RUN yes | pacman -Syu --noconfirm opam make m4 gcc patch diffutils ffmpeg git automake autoconf pkg-config which taglib sudo glibc jq libffi pcre libmad

RUN useradd liquidsoap && mkdir /home/liquidsoap && chown -R liquidsoap /home/liquidsoap
RUN usermod -aG wheel liquidsoap
RUN echo "Defaults    !requiretty" >> /etc/sudoers
RUN echo "%wheel ALL=NOPASSWD: ALL" >> /etc/sudoers

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

RUN sudo touch /var/log/liquidsoap.log
RUN sudo chown liquidsoap:users /var/log/liquidsoap.log

RUN opam switch create 4.13.1
RUN opam update

# depext no longer required to install, integrated with opam
# RUN opam install depext -y
# RUN opam depext taglib mad lame ogg vorbis cry samplerate liquidsoap -y
RUN opam install taglib mad lame ogg vorbis cry samplerate liquidsoap -y

# RUN for i in ocaml-gavl ocaml-ffmpeg ocaml-dtools ocaml-duppy ocaml-mm ocaml-cry ocaml-taglib ocaml-lame ocaml-mad ocaml-ogg ocaml-vorbis ocaml-samplerate; do \
#   cd /home/liquidsoap && git clone https://github.com/savonet/$i && cd $i && opam pin add --yes --no-action .; \
# done
# RUN cd /home/liquidsoap && git clone https://github.com/savonet/liquidsoap && cd liquidsoap && git checkout v2.0.0 && opam pin add --yes --no-action .
#RUN cd /home/liquidsoap && git clone https://github.com/savonet/liquidsoap && cd liquidsoap && opam pin add --yes --no-action .
# RUN opam install --yes liquidsoap ffmpeg cry taglib lame mad ogg vorbis samplerate
#
RUN eval $(opam env) && liquidsoap --version

RUN mkdir /home/liquidsoap/radio
ADD ./ /home/liquidsoap/radio/
RUN mkdir /home/liquidsoap/tracks
RUN chown liquidsoap:liquidsoap /home/liquidsoap/tracks
RUN mkdir /home/liquidsoap/recordings
RUN chown liquidsoap:liquidsoap /home/liquidsoap/recordings

WORKDIR /home/liquidsoap/radio
RUN eval $(opam env) && liquidsoap --check radio.liq
RUN chown 1000:1000 /home/liquidsoap/tracks
RUN chown 1000:1000 /home/liquidsoap/recordings

EXPOSE 9000
CMD ["/bin/bash", "-c", "eval `opam config env`; liquidsoap radio.liq"]
