#!/bin/bash

# Allow child images to add cleanup customizations
source_cleanup () {
    for x in /etc/osg/image-cleanup.d/*.sh; do source "$x"; done
}
trap source_cleanup EXIT TERM QUIT

sleep_forever () {
    /usr/libexec/platform-python -c '__import__("select").select([], [], [])'
} &> /dev/null

sleep_forever

