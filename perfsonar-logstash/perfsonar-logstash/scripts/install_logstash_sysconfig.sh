#!/bin/bash

if command -v lsb_release &> /dev/null; then 
    OS=$(lsb_release -si)
elif [ -f /etc/os-release ]; then
    OS=$(awk -F= '/^PLATFORM_ID/{print $2}' /etc/os-release)
else
    OS="Unknown"
fi

if [[ $OS == *"platform:el"* ]]; then
    if [ ! -e /etc/sysconfig/logstash ]; then
        ln -s /etc/perfsonar/logstash/logstash_sysconfig /etc/sysconfig/logstash
    fi
elif [[ $OS == *"Debian"* ]] || [[ $OS == *"Ubuntu"* ]]; then
    if [ -e /etc/default/logstash ]; then
        cat /etc/perfsonar/logstash/logstash_sysconfig >> /etc/default/logstash
    else
        ln -s /etc/perfsonar/logstash/logstash_sysconfig /etc/default/logstash
    fi
else
    echo "$0 - [ERROR]: Unknown operating system"
    exit 1
fi