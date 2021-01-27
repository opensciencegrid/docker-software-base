#!/bin/sh
if rpm -q osg-ca-certs >/dev/null 2>&1; then
	exec /usr/bin/timeout --kill-after 35m  30m  yum update -y --disablerepo=* --enablerepo=osg osg-ca-certs
elif rpm -q igtf-ca-certs >/dev/null 2>&1; then
	exec /usr/bin/timeout --kill-after 35m  30m  yum update -y --disablerepo=* --enablerepo=osg igtf-ca-certs
fi
