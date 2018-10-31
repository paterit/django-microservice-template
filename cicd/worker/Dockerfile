FROM paterit/buildbot-worker-docker:1.1.0-docker18.06.1

USER root

LABEL "application"="{{ project_name }}-cicd-worker"

RUN mkdir certs
COPY certs ./certs
