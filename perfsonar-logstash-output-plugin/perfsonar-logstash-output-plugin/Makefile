# Makefile for perfSONAR Logstash Output Plugin
#

default:
	@true

install:
ifndef ROOTPATH
	@echo No ROOTPATH specified for installation
	@false
endif
	mkdir -p ${ROOTPATH}
	cp -r plugin/* ${ROOTPATH}
