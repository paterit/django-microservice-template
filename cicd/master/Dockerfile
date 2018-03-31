FROM buildbot/buildbot-master:v1.1.0

LABEL "application"="{{ project_name }}-cicd-master"

# install some tools
RUN \
    apk add --no-cache \
        vim \
        bash

WORKDIR /var/lib/buildbot

COPY config/master.cfg /var/lib/buildbot/config/
COPY wait_for_master.sh /var/lib/buildbot

RUN ln -sf /var/lib/buildbot/config/master.cfg /var/lib/buildbot/master.cfg

CMD ["dumb-init", "/usr/src/buildbot/docker/start_buildbot.sh"]