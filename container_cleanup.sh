#!/bin/bash

# Allow child images to add cleanup customizations
source_cleanup () {
    for x in /etc/osg/image-cleanup.d/*.sh; do source "$x"; done
}
trap source_cleanup EXIT TERM QUIT

sleep_forever () {
    # NB: this does what it says on the can, unlike "sleep infinity", which
    #     is not documented in sleep(1) and strace tells me actually does
    #     a nanosleep of 2073600.999999999s, ie 24d + 1s - 1ns.  Weird, ey?
    #     Anyway "sleep infinity" is not documented, not portable, and
    #     doesn't actually sleep forever; so think twice before using it!
    /usr/libexec/platform-python -c '__import__("select").select([], [], [])'
} &> /dev/null

sleep_forever

