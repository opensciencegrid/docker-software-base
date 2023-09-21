# Default to EL8 builds
ARG IMAGE_BASE=quay.io/centos/centos:stream8

FROM $IMAGE_BASE

# "ARG IMAGE_BASE" needs to be here again because the previous instance has gone out of scope.
ARG IMAGE_BASE=quay.io/centos/centos:stream8
ARG BASE_YUM_REPO=testing
ARG OSG_RELEASE=3.6

LABEL maintainer OSG Software <help@opensciencegrid.org>

RUN \
    # Attempt to grab the major version from the tag
    DVER=$(egrep -o '[0-9][\.0-9]*$' <<< "$IMAGE_BASE" | cut -d. -f1); \
    if  [[ $DVER == 7 ]]; then \
       YUM_PKG_NAME="yum-plugin-priorities"; \
       yum-config-manager \
         --setopt=skip_missing_names_on_install=False \
         --setopt=skip_missing_names_on_update=False \
         --save > /dev/null; \
    else \
       YUM_PKG_NAME="yum-utils"; \
    fi && \
    yum distro-sync -y && \
    if [[ $OSG_RELEASE =~ ^[0-9][0-9]$ ]]; then \
       OSG_URL=https://repo.opensciencegrid.org/osg/${OSG_RELEASE}-main/osg-${OSG_RELEASE}-main-el${DVER}-release-latest.rpm; \
    else \
       OSG_URL=https://repo.opensciencegrid.org/osg/${OSG_RELEASE}/osg-${OSG_RELEASE}-el${DVER}-release-latest.rpm; \
    fi && \
    yum -y install $OSG_URL \
                   epel-release \
                   $YUM_PKG_NAME && \
    if [[ $DVER == 8 ]]; then \
        yum-config-manager --enable powertools && \
        yum-config-manager --setopt=install_weak_deps=False --save > /dev/null; \
    fi && \
    if [[ $DVER == 9 ]]; then \
        yum-config-manager --enable crb && \
        yum-config-manager --setopt=install_weak_deps=False --save > /dev/null; \
    fi && \
    if [[ $BASE_YUM_REPO != "release" ]]; then \
        yum-config-manager --enable osg-${BASE_YUM_REPO}; \
        yum-config-manager --enable osg-upcoming-${BASE_YUM_REPO}; else \
        yum-config-manager --enable osg-upcoming; \
    fi && \
    yum -y install supervisor \
                   cronie \
                   fetch-crl \
                   osg-ca-certs \
                   which \
                   less \
                   rpmdevtools \
                   fakeroot \
                   /usr/bin/ps \
                   && \
    if [[ $DVER == 8 ]]; then \
        yum -y install crypto-policies-scripts; \
    fi && \
    yum clean all && \
    rm -rf /var/cache/yum/ && \
    # Impatiently ignore the Yum mirrors
    sed -i 's/\#baseurl/baseurl/; s/mirrorlist/\#mirrorlist/' \
        /etc/yum.repos.d/osg*.repo && \
    # Disable gpgcheck for devops, till we get them rebuilt for SOFTWARE-5422
    if [[ $OSG_RELEASE == "3.6" ]]; then \
       sed -i 's/gpgcheck=1/gpgcheck=0/' \
              /etc/yum.repos.d/devops*.repo; \
    fi && \
    mkdir -p /etc/osg/image-{cleanup,init}.d/ && \
    # Support old init script dir name
    ln -s /etc/osg/image-{init,config}.d

COPY bin/* /usr/local/bin/
COPY supervisord_startup.sh /usr/local/sbin/
COPY crond_startup.sh /usr/local/sbin/
COPY container_cleanup.sh /usr/local/sbin/
COPY supervisord.conf /etc/
COPY 00-cleanup.conf /etc/supervisord.d/
COPY update-certs-rpms-if-present.sh /etc/cron.hourly/
COPY cron.d/* /etc/cron.d/
COPY image-init.d/* /etc/osg/image-init.d/
RUN chmod go-w /etc/supervisord.conf /usr/local/sbin/* /etc/cron.*/*
# For OKD, which runs as non-root user and root group
RUN chmod g+w /var/log /var/log/supervisor /var/run

# Allow use of SHA1 certificates.
# Accepted values are "YES" (enable them, even on EL9), "NO" (disable them, even on EL8), "DEFAULT" (use OS default).
# No effect on EL7.
ENV ENABLE_SHA1=DEFAULT

CMD ["/usr/local/sbin/supervisord_startup.sh"]
