# Makefile for perfSONAR Logstash
#

default:
	@true

install:
ifndef ROOTPATH
	@echo No ROOTPATH specified for installation
	@false
endif
ifndef CONFIGPATH
	@echo No CONFIGPATH specified for installation
	@false
endif
ifndef SYSTEMDPATH
	@echo No SYSTEMDPATH specified for installation
	@false
endif
	mkdir -p ${ROOTPATH}/pipeline
	mkdir -p ${ROOTPATH}/ruby
	mkdir -p ${ROOTPATH}/scripts
	mkdir -p ${CONFIGPATH}
	mkdir -p ${SYSTEMDPATH}/logstash.service.d
	cp -r pipeline/* ${ROOTPATH}/pipeline
	cp -r ruby/* ${ROOTPATH}/ruby
	cp -r scripts/* ${ROOTPATH}/scripts
	cp -r systemd/* ${SYSTEMDPATH}/logstash.service.d/
