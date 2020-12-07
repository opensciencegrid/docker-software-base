# Default to EL7 builds
ARG IMAGE_BASE_TAG=centos7

FROM centos:$IMAGE_BASE_TAG

# "ARG IMAGE_BASE_TAG" needs to be here again because the previous instance has gone out of scope.
ARG IMAGE_BASE_TAG=centos7

LABEL maintainer OSG Software <help@opensciencegrid.org>

RUN \
    if  [[ $IMAGE_BASE_TAG == centos7 ]]; then \
       YUM_PKG_NAME="yum-plugin-priorities"; \
    else \
       YUM_PKG_NAME="yum-utils"; \
    fi && \
    yum update -y && \
    yum -y install http://repo.opensciencegrid.org/osg/3.5/osg-3.5-el${IMAGE_BASE_TAG#centos}-release-latest.rpm \
                   epel-release \
                   $YUM_PKG_NAME && \
    yum -y install supervisor cronie && \
    if [[ $IMAGE_BASE_TAG != centos7 ]]; then \
        yum-config-manager --enable powertools && \
        yum-config-manager --enable osg-testing; \
    fi && \
    yum clean all && \
    rm -rf /var/cache/yum/

# Impatiently ignore the Yum mirrors
RUN sed -i 's/\#baseurl/baseurl/; s/mirrorlist/\#mirrorlist/' \
        /etc/yum.repos.d/osg{,-upcoming}-testing.repo

RUN mkdir -p /etc/osg/image-config.d/
ADD image-config.d/* /etc/osg/image-config.d/
ADD supervisord_startup.sh /usr/local/sbin/
ADD supervisord.conf /etc/

CMD ["/usr/local/sbin/supervisord_startup.sh"]
