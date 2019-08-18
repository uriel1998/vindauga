#!/bin/bash

if [ -f /tmp/vindauga.pid ];then

    vindauga -k
else
    vindauga -y -z &
fi
