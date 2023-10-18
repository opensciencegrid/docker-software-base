#!/bin/bash

if [[ $(id -u) = 0 ]]; then  # only root can update crypto policies
    # Set system crypto policies based on the ENABLE_SHA1 environment variable.
    if grep -q '^VERSION_ID=["]8' /etc/os-release; then
        is_el8=true
    else
        is_el8=false
    fi

    if command -v update-crypto-policies &>/dev/null; then
        # The output of `update-crypto-policies --set` is noisy; silence it
        # but print the result ourselves.
        case ${ENABLE_SHA1^^} in
            YES)
                if $is_el8; then
                    update-crypto-policies --set DEFAULT >/dev/null
                else
                    update-crypto-policies --set DEFAULT:SHA1 >/dev/null
                fi
                ;;
            NO)
                if $is_el8; then
                    update-crypto-policies --set DEFAULT:NO-SHA1 >/dev/null
                else
                    update-crypto-policies --set DEFAULT >/dev/null
                fi
                ;;
            DEFAULT)
                update-crypto-policies --set DEFAULT >/dev/null
                ;;
        esac
        echo -n "System crypto policies are: "
        update-crypto-policies --show
    fi
fi

