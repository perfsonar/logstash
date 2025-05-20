%define install_base        /usr/lib/perfsonar/
%define logstash_base       %{install_base}/logstash
%define plugin_base         %{logstash_base}/plugin
%define plugin_version      8.10.4

#Version variables set by automated scripts
%define perfsonar_auto_version 5.2.0
%define perfsonar_auto_relnum 0.3.b1

Name:			perfsonar-logstash-output-plugin
Version:		%{perfsonar_auto_version}
Release:		%{perfsonar_auto_relnum}%{?dist}
Summary:		perfSONAR Logstash Opensearch Output
License:		ASL 2.0
Group:			Development/Libraries
URL:			http://www.perfsonar.net
Source0:		perfsonar-logstash-output-plugin-%{version}.tar.gz
BuildRoot:		%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:		noarch
Requires:		logstash-oss

%description
A package that installs the perfSONAR logstash pipeline output plugin for opensearch.

%pre
/usr/sbin/groupadd -r perfsonar 2> /dev/null || :
/usr/sbin/useradd -g perfsonar -r -s /sbin/nologin -c "perfSONAR User" -d /tmp perfsonar 2> /dev/null || :

%prep
%setup -q -n perfsonar-logstash-output-plugin-%{version}

%build

%install
make ROOTPATH=%{buildroot}/%{plugin_base} install

%clean
rm -rf %{buildroot}

%post
if [ "$1" = "1" ]; then
    #if new install, add plugin to logstash
    /usr/share/logstash/bin/logstash-plugin install file:%{plugin_base}/logstash-output-plugin-offline-%{plugin_version}.zip
else
    #if upgrade, safely remove old plugin before adding new
    systemctl stop logstash.service
    /usr/share/logstash/bin/logstash-plugin remove logstash-output-opensearch
    /usr/share/logstash/bin/logstash-plugin install file:%{plugin_base}/logstash-output-plugin-offline-%{plugin_version}.zip
    systemctl start logstash.service
fi

%preun
if [ "$1" = "0" ] ; then
    #if uninstall, then remove plugin from logstash
    /usr/share/logstash/bin/logstash-plugin remove logstash-output-opensearch
fi

%postun

%files
%defattr(0644,perfsonar,perfsonar,0755)
%license LICENSE
%attr(0755, logstash, logstash) %{plugin_base}/logstash-output-plugin-offline-%{plugin_version}.zip

%changelog
* Sun Mar 21 2021 andy@es.net 4.4.0-0.0.a1
- Initial spec file created
