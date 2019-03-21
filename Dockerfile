FROM centos:centos7

LABEL maintainer OSG Software <help@opensciencegrid.org>

RUN yum -y install http://repo.opensciencegrid.org/osg/3.4/osg-3.4-el7-release-latest.rpm \
                   epel-release \
                   yum-plugin-priorities && \
    yum -y install supervisor cronie && \
    yum clean all --enablerepo=* && rm -rf /var/cache/yum/

RUN mkdir -p /etc/osg/image-config.d/
ADD image-config.d/* /etc/osg/image-config.d/
ADD supervisord_startup.sh /usr/local/sbin/
ADD supervisord.conf /etc/

CMD ["/usr/local/sbin/supervisord_startup.sh"]

