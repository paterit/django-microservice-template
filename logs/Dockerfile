FROM sebp/elk:es500_l500_k500
# https://github.com/spujadas/elk-docker
LABEL "application"="{{ project_name }}-logs"
ADD ./logstash.conf/30-output.conf /etc/logstash/conf.d/30-output.conf
ADD ./logstash.conf/10-syslog.conf /etc/logstash/conf.d/10-syslog.conf
RUN echo "" > /etc/logstash/conf.d/02-beats-input.conf
COPY wait_for_elk.sh .
#TODO {project_name}
# run on dockeer host:
# sudo sysctl -w vm.max_map_count=262144
