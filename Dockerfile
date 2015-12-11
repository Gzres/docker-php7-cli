FROM alpine:latest

MAINTAINER Luca Corbo <lu.corbo@gmail.com>

ENV PHP_VERSION 7.0.0
ENV PHP_INI_DIR /usr/local/etc/php
ENV PHP_SHA256 d6ae7b4a2e5c43a9945a97e83b6b3adfb7d0df0b91ef78b647a6dffefaa9c71b

# TODO: verify gpg, currently docker HUB gets error
# "can't connect to the agent: IPC connect call failed"
#ENV GPG_KEYS "1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3"
#RUN set -xe \
#	&& for key in $GPG_KEYS; do \
#		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
#	done
#	&& curl -sSL "http://php.net/get/php-$PHP_VERSION.tar.gz.asc/from/this/mirror" -o php.tar.gz.asc \
#	&& gpg --verify php.tar.gz.asc \

RUN mkdir -p $PHP_INI_DIR/conf.d

RUN apk --update add \
    curl \
    git \
    autoconf \
    make \
    g++ \
    gnupg \
    curl-dev \
    icu-dev \
    readline-dev \
    sqlite-dev \
    libmcrypt-dev \
    openssl-dev \
    libxml2-dev

RUN curl -SL "http://php.net/get/php-$PHP_VERSION.tar.gz/from/this/mirror" -o php.tar.gz \
    && [[ $PHP_SHA256 == "$(sha256sum php.tar.gz | awk '{print $1}')" ]] \
    && mkdir -p /usr/src \
    && tar -zxf php.tar.gz -C /usr/src \
    && rm -f php.tar.*
    && cd /usr/src/php-$PHP_VERSION \
    && ./configure \
        --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        --disable-cgi \
        --enable-intl \
        --enable-mbstring \
        --enable-mysqlnd \
        --with-curl \
        --with-mcrypt \
        --with-openssl \
        --with-readline \
        --with-zlib \
    && make -j"$(nproc)" \
    && make install \
    && make clean

RUN rm -rf /var/cache/apk/* \
  && rm -rf /tmp/php*
  && rm -rf /usr/src/php*

COPY docker-php-ext-* /usr/local/bin/

WORKDIR /app

CMD ["php", "-a"]
