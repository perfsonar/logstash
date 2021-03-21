# Makefile for perfSONAR Logstash pipeline
#

default: build

local:
	touch .env
	cp -f ./ansible/vars/env.local.yml ./ansible/vars/env.yml

release:
	touch .env
	cp -f ./ansible/vars/env.release.yml ./ansible/vars/env.yml

build: dc_clean
	docker-compose -f docker-compose.make.yml up ansible_runner
	docker-compose build logstash
	docker-compose -f docker-compose.make.yml down -v

native_build:
	ansible-playbook playbook.yml

# Some of the jobs require the containers to be down. Detects if we have 
# already generated a docker-compose.yml and stops containers accordingly
dc_clean:
ifneq ("$(wildcard ./docker-compose.yml)","")
	docker-compose -f docker-compose.yml -f docker-compose.make.yml down -v
else
	docker-compose -f docker-compose.make.yml down -v
endif

clean: dc_clean
	rm -f docker-compose.yml .env pipeline/01-inputs.conf pipeline/99-outputs.conf