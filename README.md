# radio
liquidsoap and icecast configuration for streampusher

You can build these images with docker.

The main configuration for Streampusher's liquidsoap containers is in liquidsoap/radio.liq.

## building images to use with streampusher

Streampusher will boot liquidsoap using the image `mcfiredrill/liquidsoap:latest` by default.

If you'd like to customize that image to develop locally, you can build the image from source using this repo.

`docker build -t mcfiredrill/liquidsoap:latest ./liquidsoap`

Streampusher should use your new image next time you boot your radio in your development environment.
