%define install_base        /usr/lib/perfsonar
%define logstash_base       %{install_base}/logstash
%define ruby_base           %{logstash_base}/ruby
%define pipeline_base       %{logstash_base}/pipeline
%define scripts_base        %{logstash_base}/scripts
%define config_base         /etc/perfsonar/logstash

#Version variables set by automated scripts
%define perfsonar_auto_version 5.0.0
%define perfsonar_auto_relnum 0.b2.1

Name:			perfsonar-logstash
Version:		%{perfsonar_auto_version}
Release:		%{perfsonar_auto_relnum}%{?dist}
Summary:		perfSONAR Logstash Pipeline
License:		ASL 2.0
Group:			Development/Libraries
URL:			http://www.perfsonar.net
Source0:		perfsonar-logstash-%{version}.tar.gz
BuildRoot:		%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:		noarch
Requires:       logstash-oss
Requires:       perfsonar-logstash-output-plugin
Requires(post): python3
Requires(post): python36-PyYAML

%description
A package that installs the perfSONAR logstash pipeline for enriching measurements prior to storage.

%pre
/usr/sbin/groupadd -r perfsonar 2> /dev/null || :
/usr/sbin/useradd -g perfsonar -r -s /sbin/nologin -c "perfSONAR User" -d /tmp perfsonar 2> /dev/null || :

%prep
%setup -q -n perfsonar-logstash-%{version}

%build

%install
make ROOTPATH=%{buildroot}/%{logstash_base} CONFIGPATH=%{buildroot}/%{config_base} install

%clean
rm -rf %{buildroot}

%post
#update logstash pipelines.yml
%{scripts_base}/update_logstash_pipeline_yml.py

#Point at logstash settings
%{scripts_base}/install_logstash_sysconfig.sh

#Restart/enable logstash
%systemd_post logstash.service
if [ "$1" = "1" ]; then
    #if new install, then enable
    systemctl enable logstash.service
    systemctl start logstash.service
fi

%preun
%systemd_preun logstash.service

%postun
%systemd_postun_with_restart logstash.service

%files
%defattr(0644,perfsonar,perfsonar,0755)
%license LICENSE
%config(noreplace) %{pipeline_base}/01-inputs.conf
%config(noreplace) %{pipeline_base}/99-outputs.conf
%config(noreplace) %{config_base}/logstash_sysconfig
%attr(0755, perfsonar, perfsonar) %{scripts_base}/*
#Use globs so don't dupicate config files above
%{pipeline_base}/0[2-9]-*.conf
#Add below when the day comes we have something that doesn't start with 0 or 9
#%{pipeline_base}/[1-8][0-9]-*.conf
#{pipeline_base}/9[0-8]-*.conf
%{ruby_base}/*.rb

%changelog
* Sun Mar 21 2021 andy@es.net 4.4.0-0.0.a1
- Initial spec file created
