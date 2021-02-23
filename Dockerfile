# Default to EL7 builds
ARG IMAGE_BASE_TAG=centos7

FROM centos:$IMAGE_BASE_TAG

# "ARG IMAGE_BASE_TAG" needs to be here again because the previous instance has gone out of scope.
ARG IMAGE_BASE_TAG=centos7
ARG BASE_YUM_REPO=testing
ARG OSG_RELEASE=3.5

LABEL maintainer OSG Software <help@opensciencegrid.org>

RUN \
    if  [[ $IMAGE_BASE_TAG == centos7 ]]; then \
       YUM_PKG_NAME="yum-plugin-priorities"; \
       yum-config-manager \
         --setopt=skip_missing_names_on_install=False \
         --setopt=skip_missing_names_on_update=False \
         --save > /dev/null; \
    else \
       YUM_PKG_NAME="yum-utils"; \
    fi && \
    yum update -y && \
    yum -y install http://repo.opensciencegrid.org/osg/${OSG_RELEASE}/osg-${OSG_RELEASE}-el${IMAGE_BASE_TAG#centos}-release-latest.rpm \
                   epel-release \
                   $YUM_PKG_NAME && \
    yum -y install supervisor cronie && \
    if [[ $IMAGE_BASE_TAG != centos7 ]]; then \
        yum-config-manager --enable powertools; \
    fi && \
    if [[ $BASE_YUM_REPO != "release" ]]; then \
        yum-config-manager --enable osg-${BASE_YUM_REPO}; \
    fi && \
    yum clean all && \
    rm -rf /var/cache/yum/

# Impatiently ignore the Yum mirrors
RUN sed -i 's/\#baseurl/baseurl/; s/mirrorlist/\#mirrorlist/' \
        /etc/yum.repos.d/osg{,-upcoming}-testing.repo

RUN mkdir -p /etc/osg/image-config.d/
COPY image-config.d/* /etc/osg/image-config.d/

RUN mkdir -p /etc/osg/image-cleanup.d/

COPY supervisord_startup.sh /usr/local/sbin/
COPY supervisord.conf /etc/
COPY update-certs-rpms-if-present.sh /etc/cron.hourly/

CMD ["/usr/local/sbin/supervisord_startup.sh"]
