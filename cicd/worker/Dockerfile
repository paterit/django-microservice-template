FROM buildbot/buildbot-worker:v1.1.0

LABEL "application"="{{ project_name }}-cicd-worker"

RUN mkdir certs
COPY certs ./certs

USER root

RUN apt-get update
RUN apt-get install -y apt-transport-https ca-certificates iputils-ping net-tools curl software-properties-common lsb-release vim
#RUN apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

RUN apt-get update

RUN apt-get install -y docker-ce

RUN pip install --upgrade pip && \
    pip install docker-compose



