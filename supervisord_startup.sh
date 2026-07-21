#!/bin/bash

# Allow the derived images to run any additional runtime customizations
shopt -s nullglob
for x in /etc/osg/image-init.d/*.sh; do source "$x"; done
shopt -u nullglob

chmod go-w /etc/cron.*/* 2>/dev/null || :

# If we don't have any cleanup scripts, don't start the cleanup service.
if [[ -z $(shopt -s nullglob && echo /etc/osg/image-cleanup.d/*.sh) ]]; then
    rm -f /etc/supervisord.d/00-cleanup.conf || :
fi


# Now we can actually start the supervisor
# Use whatever user id this container as run as
exec /usr/bin/supervisord -c /etc/supervisord.conf -u $(id -u)

