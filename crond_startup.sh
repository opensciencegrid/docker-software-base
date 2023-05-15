#!/bin/bash

if [ $(id -u) != 0 ]; then
    exec /usr/bin/fakeroot-sysv /usr/sbin/crond -n
fi
exec /usr/sbin/crond -n
