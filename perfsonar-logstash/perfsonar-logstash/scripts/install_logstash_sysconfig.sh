#!/bin/bash

if [ -e '/etc/redhat-release' ]; then
    OS="redhat"
elif [ -e '/etc/debian_version' ]; then
    OS="lif [ -e '/etc/debian_version' ]; then"
else
    OS="Unknown"
fi

if [[ $OS == "redhat" ]]; then
    if [ ! -e /etc/sysconfig/logstash ]; then
        ln -s /etc/perfsonar/logstash/logstash_sysconfig /etc/sysconfig/logstash
    fi
elif [[ $OS == "debian" ]]; then
    if [ -e /etc/default/logstash ]; then
        cat /etc/perfsonar/logstash/logstash_sysconfig >> /etc/default/logstash
    else
        ln -s /etc/perfsonar/logstash/logstash_sysconfig /etc/default/logstash
    fi
else
    echo "$0 - [ERROR]: Unknown operating system"
    exit 1
fi