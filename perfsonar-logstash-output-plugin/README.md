# How to build logstash offline plugin pack

## Download logstash-oss

**for latest version:**

https://www.elastic.co/downloads/logstash-oss

**for version 7.17.9 (currently used):**

**RPM:**
```sh
curl https://artifacts.elastic.co/downloads/logstash/logstash-oss-7.17.9-x86_64.rpm --output logstash-oss-7.17.9-x86_64.rpm
```

or 

**DEB:**
```sh
curl https://artifacts.elastic.co/downloads/logstash/logstash-oss-7.17.9-amd64.deb --output logstash-oss-7.17.9-amd64.deb
```

## Install logstash-oss

**RPM:**
```sh
sudo yum install -y logstash-oss-7.17.9-x86_64.rpm
```

or 

**DEB:**
```sh
sudo apt install -y $PWD/logstash-oss-7.17.9-amd64.deb
```

## Download opensearch output plugin

**for latest version:**

https://rubygems.org/gems/logstash-output-opensearch

**for version 1.2.0 (currently used):**

```sh
curl https://rubygems.org/downloads/logstash-output-opensearch-1.2.0-java.gem --output logstash-output-opensearch-1.2.0-java.gem
```

## Install opensearch output plugin

```sh
/usr/share/logstash/bin/logstash-plugin install $PWD/logstash-output-opensearch-1.2.0-java.gem
```

## Build offline plugin pack

Run the `bin/logstash-plugin prepare-offline-pack` subcommand to package the plugins and dependencies:

```sh
/usr/share/logstash/bin/logstash-plugin prepare-offline-pack --output $PWD/logstash-output-plugin-offline-7.17.9.zip logstash-output-opensearch
```

## Install the created offline plugin pack (optional)

Run the `bin/logstash-plugin install` subcommand and pass in the file URI of the offline plugin pack.

```sh
/usr/share/logstash/bin/logstash-plugin install file:$PWD/logstash-output-plugin-offline-7.17.9.zip
```