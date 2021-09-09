#!/bin/bash

if [ ! -e /etc/default/logstash ]; then
    ln -s /etc/perfsonar/logstash/logstash_sysconfig /etc/default/logstash
fi
