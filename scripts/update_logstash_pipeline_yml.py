#!/usr/bin/env python3

import yaml

#initialize
pipelines_yml = []

#open the file
with open('/etc/logstash/pipelines.yml') as file:
    pipelines_yml = yaml.safe_load(file)
    pipeline_exists = False

#look for pscheduler pipeline
for pipeline in pipelines_yml:
    if pipeline is not None and pipeline.get("pipeline.id", None) == "pscheduler":
            pipeline_exists = True
            break

#if not exists, then add it and output to file
if not pipeline_exists:
    pipelines_yml.append({
        "pipeline.id": "pscheduler",
        "path.config": "/usr/lib/perfsonar/logstash/pipeline/*.conf"
    })
    with open('/etc/logstash/pipelines.yml', 'w') as file:
        file.write(yaml.dump(pipelines_yml, default_flow_style=False))
