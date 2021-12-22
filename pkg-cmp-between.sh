#!/bin/bash

# Bash script that checks if the given RPM version is newer/equal to EVR1 and older/equal to EVR2
# Exits 0 if RPM is newer/equal to EVR1 and older/equal to EVR2, 1 otherwise

USAGE="Usage: pkg-cmp-between.sh <RPM> <EVR1> <EVR2>"

RPM=$1
EVR1=$2
EVR2=$3

if [[ $# -ne 3 ]]; then
    echo "Expected 3 args, got $#" >&2
    echo "$USAGE" >&2
    exit 2
fi

RPM_EVR=$(rpm -q --queryformat '%{EPOCH}:%{VERSION}-%{RELEASE}\n' $RPM) # get EVR of the RPM
RPM_EVR=${RPM_EVR/(none)/0} # no epoch will print (none) for the epoch field so we change it to 0

rpmdev-vercmp RPM_EVR EVR1 # check if RPM is newer/equal to EVR1 and store the return val
RET1=$?
rpmdev-vercmp RPM_EVR EVR2 # check if RPM is older/equal to EVR2 and store the return val
RET2=$?
if [[ ($RET1 == 11 || $RET1 == 0) && ($RET2 == 12 || $RET2 == 0) ]]; then
    exit 0
else
    exit 1
fi
