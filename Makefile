prefix = /usr/local

all:
	$(CC) -o perfsonar-logstash perfsonar-logstash.c

install:
	install perfsonar-logstash $(DESTDIR)$(prefix)/bin
	install perfsonar-logstash.1 $(DESTDIR)$(prefix)/share/man/man1

clean:
	rm -f perfsonar-logstash
