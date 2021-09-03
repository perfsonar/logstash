FROM logstash:7.11.2

COPY ./pipeline/* /usr/share/logstash/pipeline/
COPY ./pipeline_etc/ /etc/perfsonar/logstash
COPY ./ruby/ /usr/lib/perfsonar/logstash/ruby