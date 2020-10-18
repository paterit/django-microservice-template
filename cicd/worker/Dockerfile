FROM paterit/buildbot-worker-docker:2.8.4-docker18.06.3

USER root

LABEL "application"="{{ project_name }}-cicd-worker"

RUN mkdir certs
COPY certs ./certs
