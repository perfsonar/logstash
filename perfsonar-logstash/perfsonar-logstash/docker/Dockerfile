FROM docker.elastic.co/logstash/logstash-oss:8.17.3

# Switch to the root user to perform installations
USER root

## 1. Install dependencies for configuration scripts
RUN apt-get update && \
    apt-get install -y python3 python3-yaml && \
    rm -rf /var/lib/apt/lists/*

## 2. Install the perfSONAR Logstash output plugin
RUN /usr/share/logstash/bin/logstash-plugin install logstash-output-opensearch

## 3. Copy perfSONAR-specific files into the container
COPY pipeline /usr/lib/perfsonar/logstash/pipeline
COPY scripts /usr/lib/perfsonar/logstash/scripts
COPY ruby /usr/lib/perfsonar/logstash/ruby
COPY java /usr/lib/perfsonar/logstash/java

## 4. Create Logstash configuration directory and initialize pipelines.yml
RUN  mkdir /etc/logstash && \
     echo "[]" > /usr/share/logstash/config/pipelines.yml && \
     ln -s /usr/share/logstash/config/pipelines.yml /etc/logstash/pipelines.yml 

## 5. Set correct ownership and permissions
RUN chown -R logstash:logstash /usr/lib/perfsonar/logstash/ /etc/logstash

# Switch back to the logstash user
USER logstash

## 6. Configure Logstash to use the perfSONAR pipeline
RUN python3 /usr/lib/perfsonar/logstash/scripts/update_logstash_pipeline_yml.py