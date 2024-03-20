FROM          python:3.12-bookworm

SHELL         ["/bin/bash", "-o", "errexit", "-o", "errtrace", "-o", "functrace", "-o", "nounset", "-o", "pipefail", "-c"]

ENV           DEBIAN_FRONTEND="noninteractive"
ENV           TERM="xterm"
ENV           LANG="C.UTF-8"
ENV           LC_ALL="C.UTF-8"
ENV           TZ="America/Los_Angeles"

ENV           GNUTLS_FORCE_FIPS_MODE=1

ENV           XDG_DATA_HOME=/magnetar/user/data
ENV           XDG_DATA_DIRS=/magnetar/system/data
ENV           XDG_CONFIG_HOME=/magnetar/user/config
ENV           XDG_CONFIG_DIRS=/magnetar/system/config
ENV           XDG_RUNTIME_DIR=/magnetar/runtime
ENV           XDG_STATE_HOME=/magnetar/state
ENV           XDG_CACHE_HOME=/magnetar/cache

RUN apt-get update -qq && apt-get install --no-install-recommends -y bluez
RUN python3 -m venv /boot && \
    . /boot/bin/activate && \
    pip install TheengsGateway==1.4.0
#	  pip install --upgrade --extra-index-url=https://www.piwheels.org/simple pip TheengsGateway==1.4.0

COPY entrypoint.sh /boot

ENTRYPOINT ["/boot/entrypoint.sh"]
