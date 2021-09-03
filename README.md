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
#Compile and build .deb
make deb
