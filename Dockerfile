FROM ubuntu:20.04
LABEL Description="LAMP stack based on Ubuntu 20.04 LTS. Includes CertBot to automatically obtains certificate." \
    License="MIT" \
    Usage="docker run -dit --network=host -v \"$PWD\www\":/var/www -v \"$PWD\db\":/var/lib/mysql sandhiya78/uampc" \
    Version="1.0"

ARG DEBIAN_FRONTEND=noninteractive

COPY selections /tmp/
RUN debconf-set-selections /tmp/selections

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y apache2 libapache2-mod-php7.4 mysql-common mysql-server postfix unzip zip
RUN apt-get install -y \
    php7.4 \
    php7.4-bz2 \
    php7.4-cgi \
    php7.4-common \
    php7.4-curl \
    php7.4-fpm \
    php7.4-gd \
    php7.4-gmp \
    php7.4-intl \
    php7.4-json \
    php7.4-ldap \
    php7.4-mbstring \
    php7.4-mysql \
    php7.4-opcache \
    php7.4-phpdbg \
    php7.4-pspell \
    php7.4-readline \
    php7.4-snmp \
    php7.4-tidy \
    php7.4-xmlrpc \
    php7.4-xsl \
    php7.4-zip

RUN sed -i "s/short_open_tag\ \=\ Off/short_open_tag\ \=\ On/g" /etc/php/7.4/apache2/php.ini
RUN sed -i "s/bind-address[[:space:]]*= 127.0.0.1/bind-address = 0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "[mysqld]" > /etc/mysql/mysql.conf.d/docker.cnf && \
    echo "skip-host-cache" >> /etc/mysql/mysql.conf.d/docker.cnf && \
    echo "skip-name-resolve" >> /etc/mysql/mysql.conf.d/docker.cnf
RUN a2enmod rewrite
RUN a2enmod ssl
RUN mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld && rm -rf /var/lib/mysql/* /var/log/mysql/*

COPY run.sh /usr/bin/
RUN chmod +x /usr/bin/run.sh

ENV MYSQL_ROOT_PASSWORD Iam_Root
ENV TZ UTC

VOLUME /etc/apache2/sites-available
VOLUME /var/www
VOLUME /var/lib/mysql

EXPOSE 80
EXPOSE 443
EXPOSE 3306

CMD ["/usr/bin/run.sh"]
