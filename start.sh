#!/bin/bash

sudo -u icecast2 icecast2 -b -c /icecast.xml
sudo -u liquidsoap liquidsoap /radio.liq
