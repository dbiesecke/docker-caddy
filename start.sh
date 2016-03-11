#!/bin/bash
/etc/init.d/perl-fcgi start
touch /var/log/http-caddy.log
ubic start ubic caddy
tail -f /var/log/http-caddy.log

