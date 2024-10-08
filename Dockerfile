# Default to EL9 builds
ARG IMAGE_BASE=quay.io/almalinux/almalinux:9

FROM $IMAGE_BASE

# "ARG IMAGE_BASE" needs to be here again because the previous instance has gone out of scope.
ARG IMAGE_BASE=quay.io/almalinux/almalinux:9
ARG BASE_YUM_REPO=testing
ARG OSG_RELEASE=23

LABEL maintainer OSG Software <help@osg-htc.org>

RUN \
    log () { printf "\n%s\t%s\n\n" "$(date '+%F %X %z')" "$*" ; } ; \
    # Attempt to grab the major version from the tag \
    DVER=$(egrep -o '[0-9][\.0-9]*$' <<< "$IMAGE_BASE" | cut -d. -f1); \
    log "Updating OS YUM cache" && time \
    yum makecache && \
    log "Updating OS" && time \
    yum distro-sync -y && \
    OSG_URL=https://repo.osg-htc.org/osg/${OSG_RELEASE}-main/osg-${OSG_RELEASE}-main-el${DVER}-release-latest.rpm && \
    log "Installing EPEL/OSG repo packages" && time \
    yum -y install $OSG_URL \
                   epel-release \
                   yum-utils && \
    yum-config-manager --setopt=install_weak_deps=False --save > /dev/null && \
    /usr/bin/crb enable && \
    if [[ $BASE_YUM_REPO != "release" ]]; then \
        yum-config-manager --enable osg-${BASE_YUM_REPO}; \
        yum-config-manager --enable osg-upcoming-${BASE_YUM_REPO}; else \
        yum-config-manager --enable osg-upcoming; \
    fi && \
    log "Updating EPEL/OSG YUM cache" && time \
    yum makecache && \
    log "Installing common software" && time \
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
        log "Installing crypto-policies-scripts (EL8)" && time \
        yum -y install crypto-policies-scripts; \
    fi && \
    log "Cleaning up YUM metadata" && time \
    yum clean all && \
    rm -rf /var/cache/yum/ && \
    # Impatiently ignore the Yum mirrors
    sed -i 's/\#baseurl/baseurl/; s/mirrorlist/\#mirrorlist/' \
        /etc/yum.repos.d/osg*.repo && \
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
ENV ENABLE_SHA1=DEFAULT

CMD ["/usr/local/sbin/supervisord_startup.sh"]
