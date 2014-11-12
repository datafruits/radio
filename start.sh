#!/bin/bash

icecast2 -b -c /etc/icecast2/icecast.xml
liquidsoap /radio.liq
