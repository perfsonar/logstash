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
    mv perfsonar-logstash-output-plugin-*.tar.gz ~/rpmbuild/SOURCES/ && \
    mv perfsonar-logstash-*.tar.gz ~/rpmbuild/SOURCES/ && \
    rpmbuild -bs perfsonar-logstash-output-plugin.spec && \
    rpmbuild -ba perfsonar-logstash-output-plugin.spec && \
    rpmbuild -bs perfsonar-logstash.spec && \
    rpmbuild -ba perfsonar-logstash.spec

#shared volumes
VOLUME /sys/fs/cgroup

#Keep container running
CMD ["/usr/sbin/init"]
