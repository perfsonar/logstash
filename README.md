# perfSONAR Logstash Pipeline


**UNDER CONSTRUCTION: NOT FOR PRODUCTION USE**

## Build and use Docker image for development

```
make local # only need to do this first time to copy config in place
make #run this everytime you make change to pipeline
docker-compose up -d
```

## RPMS for centos7
```
#Build rpm and test install in a container
make centos7

##verify RPM install
docker-compose -f docker-compose.qa.yml up -d centos7
docker-compose -f docker-compose.qa.yml exec centos7 bash
tail -f /var/log/logstash/logstash-plain.log 
```

## Debian package
```
#Build logstash .deb and test it with perfsonar-testpoint
make release
make build
docker-compose -f docker-compose.debian.yml build
docker-compose -f docker-compose.debian.yml up -d
docker-compose -f docker-compose.debian.yml exec debian bash
apt install perfsonar-testpoint
dpkg -i perfsonar-logstash_1.0-1_all.deb
apt install -f
pscheduler task --archive '{"archiver":"http","data":{"schema":2,"_url":"http://localhost:11283","op":"put","_headers":{"content-type":"application/json"}}}' rtt --dest localhost
```
