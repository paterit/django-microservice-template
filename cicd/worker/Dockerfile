FROM buildbot/buildbot-worker:v0.9.4

LABEL "application"="{{ project_name }}-cicd-worker"

RUN mkdir certs
COPY certs ./certs

USER root

RUN apt-get update
RUN apt-get install -y apt-transport-https ca-certificates iputils-ping net-tools
#RUN apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
RUN apt-key adv \
               --keyserver hkp://ha.pool.sks-keyservers.net:80 \
               --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | tee /etc/apt/sources.list.d/docker.list
RUN apt-get update

RUN apt-get install -y docker-engine

RUN pip install --upgrade pip && \
    pip install docker-compose



