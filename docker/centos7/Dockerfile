FROM centos:7
ENV container docker

#cleanup to enable systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

#copy elastic yum repo
COPY ./docker/centos7/elastic.repo /etc/yum.repos.d/elastic.repo

#Install build environment dependencies
RUN yum update -y && \
    yum install -y epel-release make rpmbuild rpmdevtools && \
    yum clean all && \
    mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS} && \
    echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

# Copy code to /app
COPY . /app

#Build RPM
RUN cd /app && \
    make dist && \
    mv perfsonar-logstash-*.tar.gz ~/rpmbuild/SOURCES/ && \
    mv perfsonar-logstash-output-plugin-*.tar.gz ~/rpmbuild/SOURCES/ && \
    rpmbuild -bs perfsonar-logstash.spec && \
    rpmbuild -ba perfsonar-logstash.spec && \
    rpmbuild -bs perfsonar-logstash-output-plugin.spec && \
    rpmbuild -ba perfsonar-logstash-output-plugin.spec && \
    yum install -y ~/rpmbuild/RPMS/noarch/perfsonar-logstash-output-plugin*.rpm && \
    yum install -y ~/rpmbuild/RPMS/noarch/*.rpm

#This is docker specific stuff that is only needed here
RUN mkdir -p /var/lib/perfsonar/logstash/tmp && \
    echo "" >> /etc/logstash/jvm.options && \
    echo "-Djava.io.tmpdir=/var/lib/perfsonar/logstash/tmp" >> /etc/logstash/jvm.options && \
    chown -R logstash:logstash /var/lib/perfsonar/logstash

#shared volumes
VOLUME /sys/fs/cgroup

#Keep container running
#CMD tail -f /dev/null
CMD ["/usr/sbin/init"]
