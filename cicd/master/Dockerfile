FROM buildbot/buildbot-master:v0.9.4

LABEL "application"="{{ project_name }}-cicd-master"

 RUN \
#     echo @testing http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
#     echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
    apk add --no-cache \
        vim \
        bash

WORKDIR /var/lib/buildbot

COPY config/master.cfg /var/lib/buildbot/config/
COPY wait_for_master.sh /var/lib/buildbot

RUN ln -sf /var/lib/buildbot/config/master.cfg /var/lib/buildbot/master.cfg

CMD ["dumb-init", "/usr/src/buildbot/contrib/docker/master/start_buildbot.sh"]