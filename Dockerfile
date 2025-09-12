ARG DISTRO="alpine"
ARG DISTRO_VARIANT="3.21"

FROM docker.io/tiredofit/nginx:${DISTRO}-${DISTRO_VARIANT}-6.5.18
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

ARG LEMONLDAP_VERSION
ARG AUTHCAS_VERSION
ARG LASSO_VERSION

ENV LEMONLDAP_VERSION=${LEMONLDAP_VERSION:-"2.21.3"} \
    AUTHCAS_VERSION=${AUTHCAS_VERSION:-"1.7"} \
    LASSO_VERSION=${LASSO_VERSION:-"a58a535028882a92b76f3814f70803872ad5727e"} \
    MINIFY_VERSION=2.23.8 \
    DOMAIN_NAME=example.com \
    API_HOSTNAME=api.manager.sso.example.com \
    HANDLER_HOSTNAME=handler.sso.example.com \
    MANAGER_HOSTNAME=manager.sso.example.com \
    PORTAL_HOSTNAME=sso.example.com \
    TEST_HOSTNAME=test.sso.example.com \
    NGINX_APPLICATION_CONFIGURATION=FALSE \
    NGINX_AUTHENTICATION_TYPE=NONE \
    NGINX_LISTEN_PORT=80 \
    NGINX_LOG_ACCESS_FORMAT=llng_standard \
    NGINX_ENABLE_CREATE_SAMPLE_HTML=FALSE \
    NGINX_USER=llng \
    NGINX_GROUP=llng \
    NGINX_LOG_ACCESS_LOCATION=/www/logs/http \
    NGINX_LOG_ACCESS_FILE=access.log \
    NGINX_LOG_BLOCKED_LOCATION=/www/logs/http \
    NGINX_LOG_ERROR_FILE=error.log \
    NGINX_LOG_ERROR_LOCATION=/www/logs/http \
    NGINX_SITE_ENABLED=null \
    PATH=/usr/share/lemonldap-ng/bin:${PATH} \
    IMAGE_NAME="tiredofit/lemonldap" \
    IMAGE_REPO_URL="https://github.com/tiredofit/docker-lemonldap/"

RUN source /assets/functions/00-container && \
    set -x && \
    addgroup -g 2884 llng && \
    adduser -S -D -G llng -u 2884 -h /var/lib/lemonldap-ng/ llng && \
    \
# Build Dependencies
    package update && \
    package upgrade && \
    package install .lemonldap-build-deps \
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
                    mongo-c-driver-dev \
                    nodejs \
                    npm \
                    musl-dev \
                    perl-dev \
                    py-pip \
                    py-six \
                    py3-sphinx \
                    redis \
                    sphinx \
                    wget \
                    #xmlsec-dev \
                    && \
    \
    package install .lemonldap-run-deps \
                    gd \
                    ghostscript-fonts \
                    imagemagick \
                    imagemagick-libs \
                    imagemagick-perlmagick \
                    krb5-libs \
                    mariadb-client \
                    mongo-c-driver \
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
                    perl-json \
                    perl-ldap \
                    perl-lwp-protocol-https \
                    perl-mime-lite \
                    perl-mime-tools \
                    perl-mouse \
                    perl-net-cidr \
                    perl-net-cidr-lite \
                    perl-net-ssleay \
                    perl-plack \
                    perl-regexp-common \
                    perl-redis \
                    perl-test-mockobject \
                    perl-test-pod \
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
                    && \
    \
    ### Install Sphinx dependencies for Document Building for Manager
    pip install --break-system-packages sphinx_bootstrap_theme && \
    \
### Install Perl Modules Manually not available in Repository
    ln -s /usr/bin/perl /usr/local/bin/perl && \
    curl -L http://cpanmin.us -o /usr/bin/cpanm && \
    chmod +x /usr/bin/cpanm && \
    cpanm -n \
        #Auth::Yubikey_WebClient \
        #Authen::Radius \
        Authen::Captcha \
        Authen::WebAuthn \
        CGI::Compile \
        Convert::Base32 \
        #Cookie::Baker \
        Cookie::Baker::XS \
        #Crypt::OpenSSL::X509 \
        Crypt::URandom \
        Data::Password::zxcvbn \
    	DateTime::Format::RFC3339 \
        Digest::HMAC_SHA1 \
        Digest::SHA \
        Email::Sender \
        GD::SecurityImage \
        #GSSAPI \
        HTTP::Headers \
        HTTP::Request \
        LWP::UserAgent \
        #Mouse \
        #MongoDB \
        Net::Facebook::Oauth2 \
        Net::LDAP \
        Net::OAuth \
        Net::OpenID::Common \
        Net::SMTP \
        Regexp::Assemble \
        #Redis \
        Sentry::Raven \
        String::Random \
        Text::Unidecode \
        Time::Fake \
        URI::Escape \
        Web::ID \
        && \
### Install various GO, NodeJS Packages for Optimization and adjust temporary symlinks
    cd /usr/src && \
    npm install coffeescript && \
    mkdir -p /usr/src/minify && \
    curl -sSL https://github.com/tdewolff/minify/releases/download/v${MINIFY_VERSION}/minify_linux_amd64.tar.gz | tar xvfz - --strip 1 -C /usr/src/minify && \
    mv /usr/src/minify /usr/bin/ && \
    chmod +x /usr/bin/minify && \
    npm install -g uglify-js && \
    ln -s /usr/src/.node_modules/coffeescript/bin/coffee /usr/bin/ && \
    ln -s /usr/bin/yuicompressor /usr/bin/yui-compressor && \
    \
### Install Lasso
    clone_git_repo https://git.entrouvert.org/entrouvert/lasso "${LASSO_VERSION}" /usr/src/lasso && \
    cd /usr/src/lasso && \
    git checkout "${LASSO_VERSION}" && \
    echo "2.9.0-dev" > .version && \
    echo "2.9.0-dev" > .tarball-version && \
    ./autogen.sh \
                 --prefix=/usr \
                 --disable-python \
                 --disable-tests \
                 && \
    make -j$(nproc) && \
    make check && \
    make install && \
    \
### Install AuthCAS
    mkdir -p /usr/src/authcas && \
    curl https://sourcesup.renater.fr/frs/download.php/file/5125/AuthCAS-${AUTHCAS_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/authcas && \
    cd /usr/src/authcas && \
    perl Makefile.PL && \
    make -j$(nproc) && \
    make install && \
    \
### Checkout and Install LemonLDAP
    cd /usr/src && \
    if [ "${LEMONLDAP_VERSION}" != "master" ] ; then LEMONLDAP_VERSION=v$LEMONLDAP_VERSION ; fi && \
    clone_git_repo https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng $LEMONLDAP_VERSION && \
    make dist && \
    make documentation && \
    make PREFIX=/usr \
         LMPREFIX=/usr/share/lemonldap-ng \
         SBINDIR=/usr/sbin \
         INITDIR=/etc/init.d \
         ETCDFEAULTDIR=/etc/default \
         DATADIR=/var/lib/lemonldap-ng \
         DOCUMENTROOT=/usr/share/lemonldap-ng \
         PORTALSITEDIR=/usr/share/lemonldap-ng/portal \
         MANAGERSITEDIR=/usr/share/lemonldap-ng/manager \
         CONFDIR=/etc/lemonldap-ng \
         CRONDIR=/etc/cron.d \
         APACHEUSER=llng \
         APACHEGROUP=llng \
         FASTCGISOCKDIR=/var/run/llng-fastcgi-server \
         PROD=yes \
         install && \
    \
### Compile Various Apache::Session Modules
    clone_git_repo https://github.com/LemonLDAPNG/Apache-Session-NoSQL && \
    perl Makefile.PL && \
    make -j$(nproc) && \
    make test && \
    make install && \
    \
    clone_git_repo https://github.com/LemonLDAPNG/Apache-Session-LDAP && \
    perl Makefile.PL && \
    make -j$(nproc) && \
    make test && \
    make install && \
    \
    clone_git_repo https://github.com/LemonLDAPNG/Apache-Session-Browseable && \
    perl Build.PL && \
    ./Build && \
    ./Build test && \
    ./Build install && \
    \
    mkdir -p /var/run/llng-fastcgi-server && \
    chown -R llng /var/run/llng-fastcgi-server && \
    \
    # Shuffle some Files around
    mkdir -p /assets/llng/conf && \
    mv /var/lib/lemonldap-ng/conf/* /assets/llng/conf/ && \
    mv /etc/lemonldap-ng/lemonldap-ng.ini /assets/llng/conf/ && \
    mkdir -p /var/run/llng-fastcgi-server && \
    chown -R llng /var/run/llng-fastcgi-server && \
    ln -s /usr/share/lemonldap-ng/doc /usr/share/lemonldap-ng/manager/doc && \
    ln -s /usr/share/lemonldap-ng/portal /usr/share/lemonldap-ng/portal/htdocs && \
# Cleanup
    rm -rf \
            /etc/lemonldap-ng/* \
            /root/.bash_history \
            /root/.cache \
            /root/.config \
            /root/.cpanm \
            /root/.npm \
            /root/go \
            /usr/bin/coffee \
            /usr/bin/minify \
            /usr/bin/yui-compressor \
            /usr/bin/yuicompressor \
            /usr/src/* \
            /var/lib/lemonldap-ng/conf/* \
            /etc/fail2ban/jail.d/* \
            /tmp/* \
            && \
    package remove .lemonldap-build-deps && \
    package cleanup && \
    deluser nginx && \
    deluser redis

EXPOSE 2884
COPY install /
