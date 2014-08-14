#!/bin/bash

docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter
docker build -t radio /vagrant
