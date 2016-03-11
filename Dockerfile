# This is a base container
FROM        ubuntu
MAINTAINER  Daniel Biesecke <dbiesecke@gmail.com>


RUN apt-get update
RUN apt-get -y upgrade
# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -fs /bin/true /sbin/initctl

##
# Base.
##

# APT.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install fail2ban vim git curl wget pwgen python-setuptools vim-tiny sudo python-software-properties cron unzip php5-fpm libfcgi-perl  -y -f 

##
# Users.
##
RUN mkdir -p /var/www/html /var/www/cgi-bin /var/www/bin 2>/dev/null  || true
RUN useradd --create-home --shell /bin/bash --user-group deployer


##
# Fail2ban.
##

RUN mkdir /var/run/fail2ban


##
# Startup scripts.
##

ADD start.sh /root/start.sh
RUN chmod 755 /root/start.sh

##
#  Run Installer script
##

ADD install.sh /root/install.sh
RUN chmod 755 /root/install.sh && /root/install.sh

##
#  Install Ubic Service Mgr
##
ADD ubic_1.52-2_all.deb /var/cache/apt/archives/ubic_1.52-2_all.deb
RUN  dpkg -i /var/cache/apt/archives/ubic_1.52-2_all.deb 2>/dev/null  || true
RUN apt-get install -y -f 

RUN mkdir -p /etc/ubic/service/caddy
ADD ubic-caddy /etc/ubic/service/caddy/server
ADD ubic-fastcgi /etc/ubic/service/caddy/fastcgi

##
# Give ubic full controll
##
EXPOSE 8443
#CMD ["start", "ubic", "caddy"]
ENTRYPOINT ["/root/start.sh"]

