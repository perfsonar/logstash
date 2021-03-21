# Makefile for perfSONAR Logstash pipeline
#

default: build

local:
	touch .env
	cp -f ./ansible/vars/env.local.yml ./ansible/vars/env.yml

release:
	touch .env
	cp -f ./ansible/vars/env.release.yml ./ansible/vars/env.yml

build:
	docker-compose -f docker-compose.yml -f docker-compose.make.yml down -v
	docker-compose -f docker-compose.make.yml up ansible_runner
	docker-compose -f docker-compose.make.yml down -v

native_build:
	ansible-playbook playbook.yml

clean:
	docker-compose -f docker-compose.yml -f docker-compose.make.yml down -v