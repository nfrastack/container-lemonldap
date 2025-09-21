# SPDX-FileCopyrightText: © 2025 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE
ARG DISTRO
ARG DISTRO_VARIANT

FROM ${BASE_IMAGE}:${DISTRO}_${DISTRO_VARIANT}

LABEL \
        org.opencontainers.image.title="LemonLDAP:NG" \
        org.opencontainers.image.description="Authentication and Authorization Platform" \
        org.opencontainers.image.url="https://hub.docker.com/r/nfrastack/lemonldap" \
        org.opencontainers.image.documentation="https://github.com/nfrastack/container-lemonldap/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/nfrastack/container-lemonldap.git" \
        org.opencontainers.image.authors="Nfrastack <code@nfrastack.com>" \
        org.opencontainers.image.vendor="Nfrastack <https://www.nfrastack.com>" \
        org.opencontainers.image.licenses="MIT"

ARG \
    LEMONLDAP_VERSION="2.21.3" \
    AUTHCAS_VERSION="1.7" \
    LASSO_VERSION="v2.9.0" \
    LIBU2F_VERSION="master" \
    LLNG_SESSION_BROWSEABLE_VERSION="v1.3.17" \
    LLNG_SESSION_LDAP_VERSION="v0.5" \
    LLNG_SESSION_MONGODB_VERSION="v0.21" \
    LLNG_SESSION_NOSQL_VERSION="05ec4253c3055c301d1e3fb0f722169fee294622" \
    AUTHCAS_REPO_URL="https://sourcesup.renater.fr/frs/download.php/file/5125" \
    LASSO_REPO_URL="https://git.entrouvert.org/entrouvert/lasso" \
    LEMONLDAP_REPO_URL="https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng" \
    LIBU2F_REPO_URL="https://github.com/Yubico/libu2f-server" \
    LLNG_SESSION_BROWSEABLE_REPO_URL="https://github.com/LemonLDAPNG/Apache-Session-Browseable" \
    LLNG_SESSION_LDAP_REPO_URL="https://github.com/LemonLDAPNG/Apache-Session-LDAP" \
    LLNG_SESSION_MONGODB_REPO_URL="https://github.com/LemonLDAPNG/apache-session-mongodb" \
    LLNG_SESSION_NOSQL_REPO_URL="https://github.com/LemonLDAPNG/Apache-Session-NoSQL"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    NGINX_APPLICATION_CONFIGURATION=FALSE \
    NGINX_LOG_ACCESS_FORMAT=llng_standard \
    NGINX_ENABLE_CREATE_SAMPLE_HTML=FALSE \
    NGINX_USER=llng \
    NGINX_GROUP=llng \
    NGINX_LOG_ACCESS_LOCATION=/logs/nginx/ \
    NGINX_LOG_ACCESS_FILE=access.log \
    NGINX_LOG_BLOCKED_LOCATION=/logs/nginx/ \
    NGINX_LOG_ERROR_FILE=error.log \
    NGINX_LOG_ERROR_LOCATION=/logs/nginx/ \
    NGINX_SITE_ENABLED=null \
    NGINX_WORKER_PROCESSES=1 \
    #NGINX_WEBROOT=/www/llng \
    PATH=/usr/share/lemonldap-ng/bin:${PATH} \
    IMAGE_NAME="nfrastack/lemonldap" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-lemonldap/"

RUN echo "" && \
    LLNG_BUILD_DEPS_ALPINE=" \
                                autoconf \
                                automake \
                                build-base \
                                check-dev \
                                coreutils \
                                expat-dev \
                                g++ \
                                gcc \
                                go \
                                git \
                                gd-dev \
                                gengetopt-dev \
                                glib-dev \
                                gmp-dev \
                                gtk-doc \
                                help2man \
                                imagemagick-dev \
                                json-c-dev \
                                openssl-dev \
                                libtool \
                                krb5-dev \
                                make \
                                nodejs \
                                npm \
                                musl-dev \
                                perl-dev \
                                py-pip \
                                py-six \
                                py3-sphinx \
                                sphinx \
                                wget \
                                xmlsec-dev \
                            " \
                                && \
    LLNG_RUN_DEPS_ALPINE=" \
                                gd \
                                ghostscript-fonts \
                                imagemagick \
                                imagemagick-libs \
                                imagemagick-perlmagick \
                                krb5-libs \
                                mariadb-client \
                                openssl \
                                perl \
                                perl-crypt-jwt \
                                perl-html-formattext-withlinks \
                                perl-apache-session \
                                perl-authen-radius \
                                perl-authen-sasl \
                                perl-cache-cache \
                                perl-clone \
                                perl-config-inifiles \
                                perl-convert-pem \
                                perl-cookie-baker \
                                perl-crypt-openssl-bignum \
                                perl-crypt-openssl-rsa \
                                perl-crypt-openssl-x509 \
                                perl-crypt-rijndael \
                                perl-crypt-urandom \
                                perl-crypt-x509 \
                                perl-dbd-mysql \
                                perl-dbd-sqlite \
                                perl-dbd-pg \
                                perl-dbi \
                                perl-digest-md5 \
                                perl-digest-sha1 \
                                perl-cgi-emulate-psgi \
                                perl-fcgi \
                                perl-fcgi-procmanager \
                                perl-glib \
                                perl-gssapi \
                                perl-http-headers-fast \
                                perl-http-entity-parser \
                                perl-html-template \
                                perl-io \
                                perl-io-socket-ssl \
                                perl-io-string \
                                perl-ipc-run \
                                perl-json \
                                perl-ldap \
                                perl-lwp-protocol-https \
                                perl-mime-lite \
                                perl-mime-tools \
                                perl-mouse \
                                perl-net-cidr \
                                perl-net-cidr-lite \
                                perl-net-ssleay \
                                perl-netaddr-ip \
                                perl-plack \
                                perl-regexp-common \
                                perl-redis \
                                perl-test-mockobject \
                                perl-test-output \
                                perl-test-pod \
                                perl-text-unidecode \
                                perl-unicode-string \
                                perl-uri \
                                perl-utils \
                                perl-xml-libxml \
                                perl-xml-libxml-simple \
                                perl-xml-libxslt \
                                perl-xml-sax \
                                postgresql-client \
                                rsyslog \
                                s6 \
                                xmlsec \
                                xmlsec-dev \
                            " \
                            && \
    source /container/base/functions/container/build && \
    container_build_log image && \
    create_user ${NGINX_USER} 2884 ${NGINX_GROUP} 2884 /data && \
    package update && \
    package upgrade && \
    package install \
                    LLNG_BUILD_DEPS \
                    LLNG_RUN_DEPS \
                    && \
    \
    pip install \
                    --break-system-packages \
                    sphinx_bootstrap_theme \
                    && \
    \
    ln -s /usr/bin/perl /usr/local/bin/perl && \
    curl -L http://cpanmin.us -o /usr/bin/cpanm && \
    chmod +x /usr/bin/cpanm && \
    cpanm -n Data::Validate::IP && \
    cpanm -n \
                Apache::Session::Generate::MD5 \
                Authen::Captcha \
                Authen::WebAuthn \
                Cache::Memcached \
                CGI::Compile \
                Convert::Base32 \
                Cookie::Baker::XS \
                Data::Password::zxcvbn \
                DateTime::Format::RFC3339 \
                DBD::Cassandra \
                Digest::HMAC_SHA1 \
                Digest::SHA \
                Email::Sender \
                GD::SecurityImage \
                GeoIP2 \
                HTTP::BrowserDetect \
                HTTP::Headers \
                HTTP::Request \
                LWP::Protocol::PSGI \
                LWP::UserAgent \
                Net::Facebook::Oauth2 \
                Net::LDAP \
                Net::OAuth \
                Net::OpenID::Common \
                Net::SMTP \
                Redis::Fast \
                Regexp::Assemble \
                Sentry::Raven \
                String::Random \
                Time::Fake \
                URI::Escape \
                Web::ID \
            && \
    \
    npm install -g \
                    uglify-js \
                    csso-cli && \
    \
    mkdir -p /usr/src/authcas && \
    curl ${AUTHCAS_REPO_URL}/AuthCAS-${AUTHCAS_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/authcas && \
    cd /usr/src/authcas && \
    perl Makefile.PL && \
    make -j$(nproc) && \
    make install && \
    container_build_log add "AuthCAS" "${AUTHCAS_VERSION}" "${AUTHCAS_REPO_URL}" && \
    \
    clone_git_repo "${LASSO_REPO_URL}" "${LASSO_VERSION}" /usr/src/lasso && \
    ./autogen.sh \
                 --prefix=/usr \
                 --disable-python \
                 --disable-tests \
                 && \
    make -j$(nproc) && \
    make check && \
    make install && \
    container_build_log add "LaSSO" "${LASSO_VERSION}" "${LASSO_REPO_URL}" && \
    \
    clone_git_repo "${LIBU2F_REPO_URL}" ${LIBU2F_VERSION} && \
    ./autogen.sh && \
    ./configure \
                --build=$CBUILD \
                --host=$CHOST \
                --prefix=/usr \
                --sysconfdir=/etc \
                --mandir=/usr/src/man \
                --localstatedir=/var \
                --enable-tests && \
    make -j$(nproc) && \
    make install && \
    container_build_log add "LIBU2F" "${LIBU2F_VERSION}" "${LIBU2F_REPO_URL}" && \
    \
    clone_git_repo "${LLNG_SESSION_NOSQL_REPO_URL}" "${LLNG_SESSION_NOSQL_VERSION}" && \
    perl Makefile.PL && \
    make -j$(nproc) && \
    make test && \
    make install && \
    container_build_log add "LLNG Session NoSQL module" "${LLNG_SESSION_NOSQL_VERSION}" "${LLNG_SESSION_NOSQL_REPO_URL}" && \
    \
    clone_git_repo "${LLNG_SESSION_LDAP_REPO_URL}" "${LLNG_SESSION_LDAP_VERSION}" && \
    perl Makefile.PL && \
    make -j$(nproc) && \
    make test && \
    make install && \
    container_build_log add "LLNG Session LDAP module" "${LLNG_SESSION_LDAP_VERSION}" "${LLNG_SESSION_LDAP_REPO_URL}" && \
    \
    clone_git_repo "${LLNG_SESSION_BROWSEABLE_REPO_URL}" "${LLNG_SESSION_BROWSEABLE_VERSION}" && \
    perl Build.PL && \
    ./Build && \
    ./Build test && \
    ./Build install && \
    container_build_log add "LLNG Session Browseable module" "${LLNG_SESSION_BROWSEABLE_VERSION}" "${LLNG_SESSION_BROESEABLE_REPO_URL}" && \
    \
    if [ "${LEMONLDAP_VERSION}" != "master" ] ; then LEMONLDAP_VERSION=v$LEMONLDAP_VERSION ; fi && \
    ## Changelog !!
    clone_git_repo "${LEMONLDAP_REPO_URL}" "${LEMONLDAP_VERSION}" && \
    sed -i \
                -e 's|@yui-compressor \$\*\.css > \$\*\.min\.css|csso \$*.css --output \$*.min.css|' \
                -e 's|yui-compressor|ccso|' \
            Makefile && \
    mkdir -p /usr/share/lemonldap-ng && \
    make documentation && \
    make \
            PREFIX=/usr \
            LMPREFIX=/usr/share/lemonldap-ng \
            SBINDIR=/usr/local/bin \
            INITDIR=/usr/src/llng/init.d \
            UNITDIR=/usr/src/llng/systemd \
            TMPFILESDIR=/usr/src/llng/tmpfiles.d \
            ETCDFEAULTDIR=/usr/src/llng/default \
            DATADIR=/var/lib/lemonldap-ng \
            MANDIR=/usr/share/man \
            DOCUMENTROOT=/usr/share/lemonldap-ng \
            PORTALSITEDIR=/usr/share/lemonldap-ng/portal \
            MANAGERSITEDIR=/usr/share/lemonldap-ng/manager \
            EXAMPLESDIR=/usr/src/llng/examples \
            CONFDIR=/etc/lemonldap-ng \
            CRONDIR=/usr/src/llng/cron.d \
            APACHEUSER=${NGINX_USER} \
            APACHEGROUP=${NGINX_GROUP} \
            FASTCGISOCKDIR=/var/run/llng-fastcgi-server \
            WITHRC=no \
            WITHSYSTEMD=no \
            PROD=yes \
            install \
            && \
    ##TODO Copy license to build_log?
    \
    mkdir -p /container/data/llng/conf && \
    mv /var/lib/lemonldap-ng/conf/* /container/data/llng/conf/ && \
    sed -i \
            -e "s|example.com|nfrastack.com|g" \
            /container/data/llng/conf/*.json && \
    mv /etc/lemonldap-ng/lemonldap-ng.ini /container/data/llng/conf/ && \
    mkdir -p /container/data/llng/assets && \
    cp -aR \
                /usr/share/lemonldap-ng/portal/static/common/apps \
                /usr/share/lemonldap-ng/portal/static/common/icons \
                /usr/share/lemonldap-ng/portal/static/common/logos \
                /usr/share/lemonldap-ng/portal/static/languages \
            /container/data/llng/assets/ && \
    \
    for asset in apps icons logos languages; do \
        echo "${LEMONLDAP_VERSION} $(TZ=${TIMEZONE} date +'%Y-%m-%dT%H:%M:%S %Z') " > /container/data/llng/assets/${asset}/.source; \
    done && \
    \
    mkdir -p /container/data/llng/htdocs && \
    mkdir -p /var/run/llng-fastcgi-server && \
    chown -R "${NGINX_USER}":"${NGINX_GROUP}" \
                    /container/data/llng \
                    /var/run/llng-fastcgi-server && \
    ln -s /usr/share/lemonldap-ng/doc /usr/share/lemonldap-ng/manager/doc && \
    ln -s /usr/share/lemonldap-ng/portal /usr/share/lemonldap-ng/portal/htdocs && \
    container_build_log add "LemonLDAP:NG" "${LEMONLDAP_VERSION}" "${LEMONLDAP_REPO_URL}" && \
    \
    npm uninstall -g \
                    uglify-js \
                    csso-cli && \
    \
    rm -rf \
            /etc/lemonldap-ng \
            /root/.cpanm \
            /usr/local/bin/minify \
            /usr/share/lemonldap-ng/etc \
            /usr/share/lemonldap-ng/examples \
            /var/lib/lemonldap-ng \
            && \
    deluser nginx && \
    package remove \
                    LLNG_BUILD_DEPS \
                    && \
    package cleanup

EXPOSE 2884

COPY rootfs /
