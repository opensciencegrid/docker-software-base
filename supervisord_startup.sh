#!/bin/bash

# Allow the derived images to run any additional runtime customizations
shopt -s nullglob
for x in /etc/osg/image-init.d/*.sh; do source "$x"; done
shopt -u nullglob

# Allow child images to add cleanup customizations
function source_cleanup {
    for x in /etc/osg/image-cleanup.d/*.sh; do source "$x"; done
}
trap source_cleanup EXIT TERM QUIT

chmod go-w /etc/cron.*/* 2>/dev/null || :

# Now we can actually start the supervisor
exec /usr/bin/supervisord -c /etc/supervisord.conf

