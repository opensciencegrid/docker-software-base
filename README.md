OSG Software Container Base [![build-docker-image](https://github.com/opensciencegrid/docker-software-base/workflows/build-docker-image/badge.svg)](https://github.com/opensciencegrid/docker-software-base/actions?query=workflow%3Abuild-docker-image)
===========================

This image serves as the base for images distributed by the OSG Software team.

Contents
--------

- EPEL and the latest OSG release series Yum repositories
- [Supervisor](http://supervisord.org/) for running multiple processes
- Cron

### Startup ###

Any shell files matching `/etc/osg/image-init.d/*.sh` will be sourced
on startup, in lexicographic order, before starting Supervisor.
Descendant images should add files there to perform runtime initialization tasks.
