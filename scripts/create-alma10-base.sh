#!/bin/bash
__SUMMARY__=$(cat <<__end__
create-alma10-base

Create and push the Almalinux 10 image that will be used as a base for
EL 10 builds.  We need a single manifest that contains both an
ARM image and an x86-64 image but the x86-64 image should be
x86-64-v2-compatible.

This script should be run on an x86-64 host.

This script uses podman because docker's manifest manipulation commands
aren't as good (for example, 'docker manifest add' is missing).

We go through some hoops to keep podman from sneakily downloading an
image with the platform of the host system instead of the one we're
trying to include in the manifest.
__end__
)


REGISTRY=hub.opensciencegrid.org
BASE_IMAGE=docker.io/almalinux/10-base:10
ARM_IMAGE=alma10-arm.${RANDOM}
X86_64_IMAGE=alma10-v2.${RANDOM}
COMBINED_MANIFEST=${REGISTRY}/osg-htc/alma10-base:combo


Prog=${0##*/}


ask_yn () {
    while read -rn1 -p "$* (y/n) "
    do
        case $REPLY in
            [Yy]) return 0;;
            [Nn]) return 1;;
            *) echo >&2 "Enter y or n";;
        esac
    done
    return 2  # EOF
}


fail () {
    set +exu
    local ret=${1}
    shift
    echo -e "$Prog:" "$@" >&2
    exit "$ret"
}


warn () {
    local ret=${1}
    shift
    echo -e "$Prog:" "$@" >&2
    return "$ret"
}


usage () {
    echo >&2 "$__SUMMARY__"
    echo >&2
    echo >&2 "Usage: $Prog"
    exit "$1"
}


require_program () {
    command -v "$1" &>/dev/null ||
        fail 127 "Required program '$1' not found in PATH"
}

if [[ $* == -h || $* == --help ]]; then
    usage 0
fi

require_program podman


set -o nounset


on_exit () {
    if podman image exists ${BASE_IMAGE}.bak
    then
        podman untag ${BASE_IMAGE}
        podman tag ${BASE_IMAGE}.bak ${BASE_IMAGE} || warn "Unable to restore old ${BASE_IMAGE}"
    fi
    if podman image exists ${X86_64_IMAGE}
    then
        podman untag ${X86_64_IMAGE}
    fi
    if podman image exists ${ARM_IMAGE}
    then
        podman untag ${ARM_IMAGE}
    fi
}


# If the user has an existing base image, back it up
if podman image exists ${BASE_IMAGE}
then
    podman untag ${BASE_IMAGE}.bak &>/dev/null || :
    podman tag ${BASE_IMAGE} ${BASE_IMAGE}.bak || fail 3 "Unable to back up old ${BASE_IMAGE}"
fi

trap on_exit EXIT

# Build the x86-64 image (based on the x86-64-v2 image from Docker Hub)
podman build -t ${X86_64_IMAGE} -f- <<__end__
# Copies all of the x86-64-v2 almalinux/10-base image into a new linux/amd64 image,
# changing the platform docker thinks the image is (to avoid a platform mismatch
# warning every time we try to run the image).

FROM --platform=linux/amd64/v2 ${BASE_IMAGE} AS alma10base

FROM --platform=linux/amd64 scratch
COPY --from=alma10base / /
CMD ["/bin/bash"]
__end__
# shellcheck disable=SC2181
if [[ $? != 0 ]]
then
    fail 4 "Unable to build x86_64 image"
fi

# Untag the image we downloaded as part of the build and replace it with the ARM image
podman untag ${BASE_IMAGE} || fail 5 "Unable to untag old ${BASE_IMAGE}"
podman pull --platform=linux/arm64 ${BASE_IMAGE} || fail 6 "Unable to pull ARM image"
# Rename the ARM image (otherwise podman will replace it with an x86-64 image when we try to add it to the manifest)
podman tag ${BASE_IMAGE} ${ARM_IMAGE}
 # Create a new, empty manifest
podman manifest rm ${COMBINED_MANIFEST} &>/dev/null || :
(
    set -e
    podman manifest create ${COMBINED_MANIFEST}
    # Add the images for our two platforms.
    podman manifest add ${COMBINED_MANIFEST} ${X86_64_IMAGE}
    podman manifest add ${COMBINED_MANIFEST} ${ARM_IMAGE}
) || fail 5 "Unable to create manifest"

echo "Manifest created: ${COMBINED_MANIFEST}"
if ask_yn "Log in and push to ${REGISTRY}?"
then
    podman login ${REGISTRY}
    podman manifest push ${COMBINED_MANIFEST} || fail 6 "Unable to push manifest;\n" \
        "once you have resolved the problem, you may push manually by running\n" \
        "\n" \
        "podman manifest push ${COMBINED_MANIFEST}"
else
    echo "Not pushing. You may push manually by running"
    echo
    echo "podman manifest push ${COMBINED_MANIFEST}"
fi


# vim:et:sw=4:sts=4:ts=8
