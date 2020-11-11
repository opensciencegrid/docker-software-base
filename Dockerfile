# Default to EL7 builds
ARG IMAGE_BASE_TAG=centos7

FROM centos:$IMAGE_BASE_TAG

# "ARG IMAGE_BASE_TAG" needs to be here again because the previous instance has gone out of scope.
ARG IMAGE_BASE_TAG=centos7

LABEL maintainer OSG Software <help@opensciencegrid.org>

RUN [[ $IMAGE_BASE_TAG == centos7 ]] && \
       YUM_PKG_NAME="yum-plugin-priorities" || \
       YUM_PKG_NAME="yum-utils" && \
    yum update -y && \
    yum -y install http://repo.opensciencegrid.org/osg/3.5/osg-3.5-el7-release-latest.rpm \
                   epel-release \
                   $YUM_PKG_NAME && \
    yum -y install supervisor cronie && \
    [[ $IMAGE_BASE_TAG == centos7 ]] || yum-config-manager --enable PowerTools && \
    [[ $IMAGE_BASE_TAG == centos7 ]] || yum-config-manager --enable osg-testing && \
    yum clean all && \
    rm -rf /var/cache/yum/

RUN mkdir -p /etc/osg/image-config.d/
ADD image-config.d/* /etc/osg/image-config.d/
ADD supervisord_startup.sh /usr/local/sbin/
ADD supervisord.conf /etc/

CMD ["/usr/local/sbin/supervisord_startup.sh"]

