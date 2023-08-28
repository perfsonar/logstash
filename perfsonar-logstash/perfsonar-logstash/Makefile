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
	mkdir -p ${ROOTPATH}/prometheus_pipeline
	mkdir -p ${ROOTPATH}/ruby
	mkdir -p ${ROOTPATH}/java/maven
	mkdir -p ${ROOTPATH}/scripts
	mkdir -p ${CONFIGPATH}
	mkdir -p ${SYSTEMDPATH}/logstash.service.d
	cp -r pipeline/* ${ROOTPATH}/pipeline
	cp -r prometheus_pipeline/* ${ROOTPATH}/prometheus_pipeline
	cp -r ruby/* ${ROOTPATH}/ruby
	cp -r java/* ${ROOTPATH}/java
	cp -r scripts/* ${ROOTPATH}/scripts
	cp -r pipeline_etc/* ${CONFIGPATH}
	cp -r systemd/* ${SYSTEMDPATH}/logstash.service.d/
	mvn -Dmaven.repo.local=${ROOTPATH}/java/maven -f ${ROOTPATH}/java/pom.xml dependency:resolve
