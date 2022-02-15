# Makefile for perfSONAR Logstash pipeline
#
PACKAGE=perfsonar-logstash
PLUGIN_PACKAGE=perfsonar-logstash-output-plugin
ROOTPATH=/usr/lib/perfsonar/logstash
CONFIGPATH=/etc/perfsonar/logstash
PERFSONAR_AUTO_VERSION=4.4.0
PERFSONAR_AUTO_RELNUM=0.0.a1
VERSION=${PERFSONAR_AUTO_VERSION}
RELEASE=${PERFSONAR_AUTO_RELNUM}

default: centos7

centos7: dc_clean
	mkdir -p ./artifacts/centos7
	docker-compose -f docker-compose.qa.yml up --build --no-start centos7
	docker cp logstash_centos7_1:/root/rpmbuild/SRPMS ./artifacts/centos7/srpms
	docker cp logstash_centos7_1:/root/rpmbuild/RPMS/noarch ./artifacts/centos7/rpms

dist:
	mkdir /tmp/$(PACKAGE)-$(VERSION).$(RELEASE)
	cp -rf . /tmp/$(PACKAGE)-$(VERSION).$(RELEASE)
	tar czf $(PACKAGE)-$(VERSION).$(RELEASE).tar.gz -C /tmp $(PACKAGE)-$(VERSION).$(RELEASE)
	rm -rf /tmp/$(PACKAGE)-$(VERSION).$(RELEASE)
	mkdir /tmp/$(PLUGIN_PACKAGE)-$(VERSION).$(RELEASE)
	cp -rf . /tmp/$(PLUGIN_PACKAGE)-$(VERSION).$(RELEASE)
	tar czf $(PLUGIN_PACKAGE)-$(VERSION).$(RELEASE).tar.gz -C /tmp $(PLUGIN_PACKAGE)-$(VERSION).$(RELEASE)
	rm -rf /tmp/$(PLUGIN_PACKAGE)-$(VERSION).$(RELEASE)

install:
	mkdir -p ${ROOTPATH}/pipeline
	mkdir -p ${ROOTPATH}/ruby
	mkdir -p ${ROOTPATH}/scripts
	mkdir -p ${CONFIGPATH}
	cp -r pipeline/* ${ROOTPATH}/pipeline
	cp -r ruby/* ${ROOTPATH}/ruby
	cp -r scripts/* ${ROOTPATH}/scripts
	cp -r pipeline_etc/* ${CONFIGPATH}

plugin_install:
	mkdir -p ${ROOTPATH}
	cp -r output_gem/* ${ROOTPATH}

dc_clean:
	docker-compose -f docker-compose.qa.yml down -v

clean:
	rm -rf artifacts/
