OSG Software Container Base [![Build Status](https://travis-ci.org/opensciencegrid/docker-software-base.svg?branch=master)](https://travis-ci.org/opensciencegrid/docker-software-base)
===========================

This image serves as the base for images distributed by the OSG Software team.

Contents
--------

- EPEL and the latest OSG release series Yum repositories
- [Supervisor](http://supervisord.org/) for running multiple processes
- Cron

### Startup ###

The startup order of scripts in this image is as follows:

1. `/usr/local/sbin/image_init.sh` - To be replaced by descendant images, if necessary
1. `/usr/local/sbin/pod_init.sh` - To be replaced by descendant images, if necessary
1. `/usr/local/sbin/image_post_init.sh` - To be replaced by descendant images, if necessary
1. Supervisor
