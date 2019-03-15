OSG Software Container Base
===========================

This image serves as the base for images distributed by the OSG Software team.

Contents
--------

- EPEL and the latest OSG release series Yum repositories
- [Supervisor](http://supervisord.org/) for running multiple processes
- Cron
- `/usr/local/sbin/image_init.sh` - Sourced before supervisor startup
- `/usr/local/sbin/pod_init.sh` - Sourced after `image_init.sh` and before supervisor startup
