FROM opensearchproject/logstash-oss-with-opensearch-output-plugin:8.9.0

#Copy files
COPY ./pipeline/* /usr/lib/perfsonar/logstash/pipeline/
COPY ./pipeline_etc/ /etc/perfsonar/logstash
COPY ./ruby/ /usr/lib/perfsonar/logstash/ruby
COPY ./scripts/ /usr/lib/perfsonar/logstash/scripts

#install dependencies
USER root
RUN apt-get update -y && apt-get install -y python3 python3-yaml
#make config look like non-docker so scripts work
RUN  mkdir /etc/logstash &&\
       echo "[]" > /usr/share/logstash/config/pipelines.yml &&\
       ln -s /usr/share/logstash/config/pipelines.yml /etc/logstash/pipelines.yml 
USER logstash

#Generate pipelines.yml
RUN python3 /usr/lib/perfsonar/logstash/scripts/update_logstash_pipeline_yml.py