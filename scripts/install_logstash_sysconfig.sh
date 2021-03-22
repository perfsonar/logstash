#!/bin/bash

if [ ! -e /etc/sysconfig/logstash ]; then
    ln -s /etc/perfsonar/logstash/logstash_sysconfig /etc/sysconfig/logstash
fi