# perfSONAR Logstash Pipeline

This contains a set of Logstash pipelines used by the perfSONAR project to process data and store in OpenSearch. It contains the following pipelines:

- **perfSONAR Pipeline**: This pipeline runs an HTTP listener that accepts measurement results being archived by pscheduler.

- **Prometheus Pipeline**: This is a pipeline for reading generic Prometheus Metrics and storing them in OpenSearch. 

# Docker Images

Each pipeline is built as a separate docker image. Both having a number of customization options:

## Docker Environment Variables

- **opensearch_output_host** - The hostname of the OpenSearch instance
- **opensearch_output_user** - The username used to authenticate to OpenSearch
- **opensearch_output_password** - The password used to authenticate to OpenSearch


## Docker Volumes

### perfSONAR 
- **/usr/lib/perfsonar/logstash/pipeline/99-outputs.conf** - Override this to define a custom output filter if you do not want to use the default output.

### Prometheus
- **/usr/lib/perfsonar/logstash/prometheus_pipeline/<YOU-FILENAME-HERE>.conf** - Override any file in the .conf directory. You will want to add at least one input filter likely an HTTP poller to grab the data. You can override *99-outputs.conf* if you want a custom output filter. 

# OS Packages

A full compliment of OS packages can be built using [unibuild](https://github.com/perfsonar/unibuild). They consist of the following:

- **perfsonar-logstash** - This package contains both pipelines but only the perfSONAR pipeline is enabled by default. The Prometheus pipeline needs inputs defined which is generally handled by other perfSONAR packages (like perfsonar-archive) or auto-generated. You can enable manually with the script `/usr/lib/perfsonar/logstash/scripts/enable_prometheus_pipeline.py`

- **perfsonar-logstash-output-plugin** - Install the OpenSearch output plugin since not included by default with logstash. 
