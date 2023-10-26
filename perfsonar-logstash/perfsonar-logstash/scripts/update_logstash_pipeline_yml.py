#!/usr/bin/env python3

import yaml

#initialize
pipelines_yml = []

#open the file
with open('/etc/logstash/pipelines.yml') as file:
    pipelines_yml = yaml.safe_load(file)
    pipeline_exists = False

#look for pscheduler pipeline
write_file = False
for pipeline in pipelines_yml:
    if pipeline is not None and pipeline.get("pipeline.id", None) == "pscheduler":
        if pipeline.get("pipeline.ecs_compatibility", "") != "disabled":
            pipeline["pipeline.ecs_compatibility"] = "disabled"
            write_file = True
        pipeline_exists = True
        break

#if not exists, then add it and output to file
if not pipeline_exists:
    write_file = True
    pipelines_yml.append({
        "pipeline.id": "pscheduler",
        "path.config": "/usr/lib/perfsonar/logstash/pipeline/*.conf",
        "pipeline.ecs_compatibility": "disabled"
    })

if write_file:
    with open('/etc/logstash/pipelines.yml', 'w') as file:
        file.write(yaml.dump(pipelines_yml, default_flow_style=False))
