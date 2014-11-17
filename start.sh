#!/bin/bash

icecast2 -b -c /icecast.xml
liquidsoap /radio.liq
