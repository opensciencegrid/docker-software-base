#!/bin/bash

# Allow the derived images to run any additional runtime customizations
for x in /etc/osg/image-config.d/*.sh; do source "$x"; done > /var/log/supervisord_startup.out 2> /var/log/supervisord_startup.err

# Now we can actually start the supervisor
exec /usr/bin/supervisord -c /etc/supervisord.conf

