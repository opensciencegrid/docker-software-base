FROM centos:centos8

LABEL maintainer OSG Software <help@opensciencegrid.org>

RUN yum update -y && \
    yum -y install https://repo.opensciencegrid.org/osg/3.5/osg-3.5-el8-release-latest.rpm \
                   yum-utils \
                   epel-release && \
    yum -y install supervisor cronie && \
    yum-config-manager --enable PowerTools && \
    yum-config-manager --enable osg-testing && \
    yum clean all && \
    rm -rf /var/cache/yum/

RUN mkdir -p /etc/osg/image-config.d/
ADD image-config.d/* /etc/osg/image-config.d/
ADD supervisord_startup.sh /usr/local/sbin/
ADD supervisord.conf /etc/

CMD ["/usr/local/sbin/supervisord_startup.sh"]

