#!/bin/bash

# Bash script that checks if the given RPM version is newer than the EVR
# Exits 0 if RPM is newer than the EVR, 1 otherwise

USAGE="Usage: pkg-cmp-gt.sh <RPM> <EVR>"

RPM=$1
EVR=$2

if [[ $# -ne 2 ]]; then
    echo "Expected 2 args, got $#"
    echo "$USAGE"
    exit
fi

RPM_EVR=$(rpm -q --queryformat '%{EPOCH}:%{VERSION}-%{RELEASE}\n' $RPM) # get EVR of the RPM
RPM_EVR=${RPM_EVR/(none)/0} # no epoch will print (none) for the epoch field so we change it to 0

rpmdev-vercmp RPM_EVR EVR # check if RPM is newer than the EVR
if [[ $? == 11 ]]; then
    exit 0
else
    exit 1
fi
