curl -skL 'https://caddyserver.com/download/build?os=linux&arch=amd64&features=' | tar xvzf -   && rm README.txt LICENSES.txt CHANGES.txt
mv caddy /usr/local/bin/ && ln /usr/local/bin/caddy /usr/bin/caddy
apt-get install php5-fpm libfcgi-perl wget curl -y -f 

#install perl fcgi
wget http://nginxlibrary.com/downloads/perl-fcgi/fastcgi-wrapper -O /usr/bin/fastcgi-wrapper.pl
wget http://nginxlibrary.com/downloads/perl-fcgi/perl-fcgi -O /etc/init.d/perl-fcgi
chmod +x /usr/bin/fastcgi-wrapper.pl
chmod +x /etc/init.d/perl-fcgi
update-rc.d perl-fcgi defaults
insserv perl-fcgi || systemctl daemon-reload 
/etc/init.d/perl-fcgi start

cat > /etc/caddy.conf << EOF
    0.0.0.0:8443 {
        root /
        log /var/log/access.log
        errors /var/log/error.log
        basicauth / root haxxor
        gzip
        #templates / .html

        fastcgi /bin/ 127.0.0.1:8999  {
         ext   .pl .psgi
         split .pl
        }

        # PHP-FPM with Unix socket
        fastcgi / /var/run/php5-fpm.sock php

        #Example Reverse Proxy call
        proxy /api/ http://127.0.0.1:3388/api/ {
         without /api
         proxy_header Host {host}
        }

        #Example FileSearch
        #search /search {
        # -path dbiesecke
        #        -path .git
        #        -generated_site
        #        +path shells
        # +path logs
        # +path log
        # template inc/search.tpl
        #}

        #Example rewrite
        #rewrite /shells/ {
        #    regexp (.*)\.json
        #    to  /bin/shodan.pl?uri={uri}
        #}
    }
EOF
