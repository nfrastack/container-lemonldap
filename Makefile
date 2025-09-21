#!/usr/bin/make

# This Makefile contains 2 main sections
#  - Variables
#  - targets

# ---------
# VARIABLES
# ---------

# Prefix for packaging
DESTDIR=

# Flag for optimizations
USEDEBIANLIBS=no
PROD=$(USEDEBIANLIBS)
USEEXTERNALLIBS=no
PARA=$(shell perl -000 -e 'print ( "$(MAKEFLAGS)" =~ /-j(\d+)/ ? "j$$1:c" : "")')
PARAXARGS=$(shell perl -000 -e 'print ( "$(MAKEFLAGS)" =~ /-j(\d+)/ ? "-P $$1" : "")')

# Perl options
#PERLOPTIONS="INSTALLDIRS=vendor"
PERLOPTIONS=

# Compression
JSCOMPRESS=$(PROD)
CSSCOMPRESS=$(PROD)

# Perltidy version
PERLTIDY_VERSION=20220217

# External commands
PERL=$$(which perl)
PERLVERSION=`perl -e '$$version = $$^V; $$version =~ s/v//; print $$version'`
export PERL5LIB=$(CURDIR)/${SRCCOMMONDIR}/blib/lib:$(CURDIR)/${SRCHANDLERDIR}/blib/lib:$(CURDIR)/${SRCMANAGERDIR}/blib/lib/:$(CURDIR)/${SRCPORTALDIR}/blib/lib/
SU=su -c
COMPRESS=tar czf
UNCOMPRESS=tar xzf
LISTCOMPRESSED=tar tzf
COMPRESSSUFFIX=tar.gz
NGINX=/usr/sbin/nginx
UGLIFYJSVERSION:=$(shell uglifyjs --version|perl -pe 's/^[^\d]*(\d).*$$/$$1/')
CHOWN=chown
CHGRP=chgrp
CHMOD=chmod

# Default directories install
# ---------------------------

# Common dirs
PREFIX=/usr/local
LMPREFIX=$(PREFIX)/lemonldap-ng
# BIN dirs
BINDIR=$(LMPREFIX)/bin
SBINDIR=$(LMPREFIX)/sbin
INITDIR=$(LMPREFIX)/etc/init.d
UNITDIR=$(LMPREFIX)/usr/lib/systemd/system
TMPFILESDIR=$(LMPREFIX)/usr/lib/tmpfiles.d
ETCDEFAULTDIR=$(LMPREFIX)/etc/default
DATADIR=$(LMPREFIX)/data
MANDIR=$(LMPREFIX)/usr/share/man

# Document roots for Apache VirtualHosts
DOCUMENTROOT=$(LMPREFIX)/htdocs
PORTALDIR=$(DOCUMENTROOT)/portal
PORTALSITEDIR=$(PORTALDIR)/htdocs
PORTALSTATICDIR=$(PORTALSITEDIR)/static
PORTALRELATIVESTATICDIR=/static
PORTALTEMPLATESDIR=$(PORTALDIR)/templates

MANAGERDIR=$(DOCUMENTROOT)/manager
MANAGERSITEDIR=$(MANAGERDIR)/htdocs
MANAGERAPIDIR=$(MANAGERDIR)/api
MANAGERSTATICDIR=$(MANAGERSITEDIR)/static
MANAGERRELATIVESTATICDIR=/static
MANAGERRELATIVEDOCDIR=/doc
MANAGERTEMPLATESDIR=$(MANAGERSITEDIR)/templates
DOCDIR=$(DOCUMENTROOT)
DEFDOCDIR=$(DOCUMENTROOT)/doc
TESTDIR=$(DOCUMENTROOT)/test
EXAMPLESDIR=$(LMPREFIX)/examples
TOOLSDIR=$(LMPREFIX)/tools

# Handler dir
HANDLERDIR=$(LMPREFIX)/handler

# Configuration dir
CONFDIR=$(LMPREFIX)/etc
CRONDIR=$(LMPREFIX)/etc/cron.d
CONFFILENAME=lemonldap-ng.ini
STORAGECONFFILE=$(CONFDIR)/$(CONFFILENAME)

# LL::NG configuration storage dir
FILECONFIGDIR=$(DATADIR)/conf

# LL::NG sessions storage dir
APACHESESSIONFILEDIR=$(DATADIR)/sessions
APACHESESSIONFILELOCKDIR=$(APACHESESSIONFILEDIR)/lock

# LL::NG persistent sessions storage dir
APACHEPSESSIONFILEDIR=$(DATADIR)/psessions
APACHEPSESSIONFILELOCKDIR=$(APACHEPSESSIONFILEDIR)/lock

# LL::NG notifications storage dir
APACHEFILENOTIFDIR=$(DATADIR)/notifications

# LL::NG captcha dir
CAPTCHADIR=$(DATADIR)/captcha

# LL::NG cache dir
CACHEDIR=$(DATADIR)/cache

# Apache user/group
APACHEUSER=
APACHEGROUP=

# FastCGI
FASTCGISOCKDIR=$(PREFIX)/run
FASTCGIUSER=$(APACHEUSER)
FASTCGIGROUP=$(APACHEGROUP)

# uWSGI
UWSGIYAMLDIR=$(LMPREFIX)/uwsgi
LLNGAPPDIR=$(LMPREFIX)/llng-server
UWSGIUSER=$(APACHEUSER)
UWSGIGROUP=$(APACHEGROUP)

# RC/systemd
WITHRC=yes
WITHSYSTEMD=yes

# Apache version
APACHEVERSION=2.X

# Apache log dir
APACHELOGDIR=/var/log/apache2

# DNS Domain for cookie and virtual hosts
DNSDOMAIN=example.com

# Virtual Host Listen IP and Port (*, *:80, ...)
PORT=80
VHOSTLISTEN="*:$(PORT)"
TESTWEBSERVER=apache
TESTWEBSERVERPORT=19876
TESTUSESSL=0
E2E_TESTS='portal/*.js'

# LDAP backend test
LLNGTESTLDAP_SLAPD_BIN=/usr/sbin/slapd
LLNGTESTLDAP_SLAPADD_BIN=/usr/sbin/slapadd
LLNGTESTLDAP_SCHEMA_DIR=/etc/ldap/schema

# Default website destination
WEBSITE_DIR=doc/sources/admin/_build/html

# Other
SRCCOMMONDIR=lemonldap-ng-common
SRCHANDLERDIR=lemonldap-ng-handler
SRCPORTALDIR=lemonldap-ng-portal
SRCMANAGERDIR=lemonldap-ng-manager
ERASECONFIG=1 # Set to 0 if you do not want to replace your configuration

# INTERNAL VARIABLES

# Internal variables used to install in $(DESTDIR)
RLMPREFIX=$(DESTDIR)/$(LMPREFIX)
RBINDIR=$(DESTDIR)/$(BINDIR)
RSBINDIR=$(DESTDIR)/$(SBINDIR)
RUWSGIYAMLDIR=$(DESTDIR)/$(UWSGIYAMLDIR)
RLLNGAPPDIR=$(DESTDIR)/$(LLNGAPPDIR)
RINITDIR=$(DESTDIR)/$(INITDIR)
RUNITDIR=$(DESTDIR)/$(UNITDIR)
RTMPFILESDIR=$(DESTDIR)/$(TMPFILESDIR)
RETCDEFAULTDIR=$(DESTDIR)/$(ETCDEFAULTDIR)
RDATADIR=$(DESTDIR)/$(DATADIR)
RMANDIR=$(DESTDIR)/$(MANDIR)
RPORTALDIR=$(DESTDIR)/$(PORTALDIR)
RPORTALSITEDIR=$(DESTDIR)/$(PORTALSITEDIR)
RPORTALSTATICDIR=$(DESTDIR)/$(PORTALSTATICDIR)
RPORTALTEMPLATESDIR=$(DESTDIR)/$(PORTALTEMPLATESDIR)
RMANAGERDIR=$(DESTDIR)/$(MANAGERDIR)
RMANAGERSITEDIR=$(DESTDIR)/$(MANAGERSITEDIR)
RMANAGERAPIDIR=$(DESTDIR)/$(MANAGERAPIDIR)
RMANAGERSTATICDIR=$(DESTDIR)/$(MANAGERSTATICDIR)
RMANAGERTEMPLATESDIR=$(DESTDIR)/$(MANAGERTEMPLATESDIR)
RDOCDIR=$(DESTDIR)/$(DOCDIR)
RDEFDOCDIR=$(DESTDIR)/$(DEFDOCDIR)
RTESTDIR=$(DESTDIR)/$(TESTDIR)
REXAMPLESDIR=$(DESTDIR)/$(EXAMPLESDIR)
RTOOLSDIR=$(DESTDIR)/$(TOOLSDIR)
RHANDLERDIR=$(DESTDIR)/$(HANDLERDIR)
RCONFDIR=$(DESTDIR)/$(CONFDIR)
RCRONDIR=$(DESTDIR)/$(CRONDIR)
RFILECONFIGDIR=$(DESTDIR)/$(FILECONFIGDIR)
RAPACHESESSIONFILEDIR=$(DESTDIR)/$(APACHESESSIONFILEDIR)
RAPACHESESSIONFILELOCKDIR=$(DESTDIR)/$(APACHESESSIONFILELOCKDIR)
RAPACHEPSESSIONFILEDIR=$(DESTDIR)/$(APACHEPSESSIONFILEDIR)
RAPACHEPSESSIONFILELOCKDIR=$(DESTDIR)/$(APACHEPSESSIONFILELOCKDIR)
RFILENOTIFDIR=$(DESTDIR)/$(APACHEFILENOTIFDIR)
RCAPTCHADIR=$(DESTDIR)/$(CAPTCHADIR)
RCACHEDIR=$(DESTDIR)/$(CACHEDIR)
RFASTCGISOCKDIR=$(DESTDIR)/$(FASTCGISOCKDIR)

VERSION=`head -n1 changelog |sed -e 's/lemonldap-ng (//' -e 's/).*$$//'`
PORTALSKINS=`ls $(SRCPORTALDIR)/site/templates/`
DIFF=diff -aurN -x '*.tpl' -x '*.bak' -x .svn -x '*.map' -x '*.min.js' -x '*.min.css' -x '*.swp' --ignore-matching-lines='.*jquery.*' --ignore-matching-lines='.*lemonldap-ng\.ini.*'
DIFFPREFIX=


MANAGERLIBSTOREMOVEFORDEBIAN=$(RMANAGERSTATICDIR)/bwr/jquery/ \
			$(RMANAGERSTATICDIR)/bwr/angular/ \
			$(RMANAGERSTATICDIR)/bwr/angular-animate/ \
			$(RMANAGERSTATICDIR)/bwr/angular-cookie/ \
			$(RMANAGERSTATICDIR)/bwr/bootstrap/ \
			$(RMANAGERSTATICDIR)/bwr/es5-shim/
PORTALLIBSTOREMOVEFORDEBIAN=$(RPORTALSTATICDIR)/bwr/bootstrap/ \
			$(RPORTALSTATICDIR)/bwr/font-awesome \
			$(RPORTALSTATICDIR)/bwr/jquery-ui \
			$(RPORTALSTATICDIR)/bwr/jquery.cookie \
			$(RPORTALSTATICDIR)/bwr/jquery
DOCLIBSTOREMOVEFORDEBIAN=pages/documentation/current/lib/tpl/bootstrap3 \
			pages/documentation/current/lib/scripts/jquery-ui*.js \
			pages/documentation/current/bootswatch/3.3.4/flatly/bootstrap.min.css
DOCEXTERNALLIBS=$(DOCLIBSTOREMOVEFORDEBIAN)
MANAGEREXTERNALLIBS=$(RMANAGERSTATICDIR)/bwr/
PORTALEXTERNALLIBS=$(PORTALLIBSTOREMOVEFORDEBIAN)

# GENERATED SRC FILES
MANAGERJSONSRC= scripts/jsongenerator.pl \
		$(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager/Build.pm \
		$(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager/Build/Attributes.pm \
		$(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager/Build/Tree.pm \
		$(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager/Build/CTrees.pm \
		$(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager/Conf/Zero.pm \
		$(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager/Build/PortalConstants.pm
MANAGERJSONDST=$(SRCMANAGERDIR)/site/htdocs/static/struct.json \
		$(SRCMANAGERDIR)/site/htdocs/static/reverseTree.json \
		$(SRCMANAGERDIR)/site/htdocs/static/js/conftree.js \
		$(SRCMANAGERDIR)/lib/Lemonldap/NG/Manager/Attributes.pm \
		$(SRCCOMMONDIR)/lib/Lemonldap/NG/Common/Conf/ReConstants.pm \
		$(SRCCOMMONDIR)/lib/Lemonldap/NG/Common/Conf/DefaultValues.pm \
		$(SRCCOMMONDIR)/lib/Lemonldap/NG/Common/Conf/Constants.pm \
		$(SRCPORTALDIR)/lib/Lemonldap/NG/Portal/Main/Constants.pm \
		$(SRCHANDLERDIR)/lib/Lemonldap/NG/Handler/Lib/StatusConstants.pm \
		_example/conf/lmConf-1.json \
		doc/sources/admin/error_codes.rst



# Javascript and CSS to minify
JSSRCFILES=$(shell find */site/htdocs/static/js $(SRCPORTALDIR)/site/htdocs/static -type f -name '*.js' ! -name '*.min.js') \
		$(SRCMANAGERDIR)/site/htdocs/static/bwr/file-saver.js/FileSaver.js
CSSSRCFILES=$(shell find $(SRCMANAGERDIR)/site/htdocs/static  $(SRCPORTALDIR)/site/htdocs/static -type f -name '*.css' ! -name '*.min.css')

# JS source files
MANAGERJSSRCFILES=$(shell find lemonldap-ng-manager/site/js-src -type f -name '*.js')
PORTALJSSRCFILES=$(shell find lemonldap-ng-portal/site/js-src -type f -name '*.js')
MANAGERJSDSTFILES=$(subst js-src/,htdocs/static/js/,$(MANAGERJSSRCFILES:.js=.js))
PORTALJSDSTFILES=$(subst js-src/,htdocs/static/common/js/,$(PORTALJSSRCFILES:.js=.js))
JSDSTFILES=$(MANAGERJSDSTFILES) $(PORTALJSDSTFILES)

# Minified files
JSMINFILES=$(JSSRCFILES:.js=.min.js)
CSSMINFILES=$(CSSSRCFILES:.css=.min.css)

# -------
# TARGETS
# -------

# Targets section contains the following subsections:
#  - 'all' that must be defined at first
#  - configure targets
#  - make targets
#  - test targets
#  - end-to-end tests
#  - install targets
#  - cleaning targets
#  - Perl libraries uninstall targets
#  - packaging targets
#  - developper corner

all:	configure common handler manager portal documentation
	@echo
	@echo "Building succeed. Now run :"
	@echo " - 'make test' to verify your installation"
	@echo " - 'make install PROD=yes' to install all"
	@echo
	@echo "    MAKE INSTALL OPTIONS:"
	@echo "    - PROD=yes            : use js/css minified files"
	@echo "    - USEDEBIANLIBS=yes   : use some Debian shared js/css files"
	@echo "    - USEEXTERNALLIBS=yes : use external links for some js/css files"
	@echo
	@echo 'Other targets :'
	@echo " * Partial build :"
	@echo "   - portal, manager, handler"
	@echo
	@echo 'Other targets launched by "make install" :'
	@echo " * Perl libraries install :"
	@echo "   - install_libs           (all Perl libraries)"
	@echo "   - install_portal_libs"
	@echo "   - install_manager_libs"
	@echo "   - install_handler_libs"
	@echo " * Binaries install :"
	@echo "   - install_bin            ($(BINDIR))"
	@echo " * FastCGI (or uWSGI) server install (required for Nginx)"
	@echo "   - install_fastcgi_server ($(SBINDIR))"
	@echo "   - install_uwsgi_server   ($(UWSGIYAMLDIR))"
	@echo " * Web sites install :"
	@echo "   - install_site           (all sites including install_doc_site)"
	@echo "   - install_portal_site    ($(PORTALDIR))"
	@echo "   - install_manager_site   ($(MANAGERDIR))"
	@echo "   - install_handler_site   ($(HANDLERDIR))"
	@echo " * Documentation install :"
	@echo "   - install_doc_site       ($(DEFDOCDIR))"
	@echo "   - install_examples_site  ($(EXAMPLESDIR))"
	@echo

# Configure targets
# -----------------

configure:	common_conf handler_conf portal_conf manager_conf

js: $(JSDSTFILES)

.PHONY: minify force

minify: force $(JSDSTFILES) $(JSMINFILES) $(CSSMINFILES)

force:
	@echo "Forcing minification of all JS and CSS files"

_rollup_portal:
	@if which rollup >/dev/null; then \
		cd $(SRCPORTALDIR)/site/js-src && \
		rollup -c; \
	else \
		echo "Can't find rollup"; \
	fi

$(SRCPORTALDIR)/site/htdocs/static/common/js/%.js: $(SRCPORTALDIR)/site/js-src/%.js
	$(MAKE) _rollup_portal

_rollup_manager:
	@if which rollup >/dev/null; then \
		cd $(SRCMANAGERDIR)/site/js-src && \
		rollup -c; \
	else \
		echo "Can't find rollup"; \
	fi

$(SRCMANAGERDIR)/site/htdocs/static/js/%.js: $(SRCMANAGERDIR)/site/js-src/%.js
	@if test "$*" != "conftree"; then \
		$(MAKE) _rollup_manager; \
	fi

%.min.css: %.css
	@echo "Compressing $*.css"
	csso $*.css --output $*.min.css

%.min.js: %.js
	@echo "Compressing $*.js"
	@if test "$(UGLIFYJSVERSION)" = 2; then \
		cd `dirname $*`; \
		uglifyjs `basename $*`.js --compress --mangle --comments '/Copyr/i' --source-map `basename $*`.min.js.map -o `basename $*`.min.js; \
	else \
		cd `dirname $*`; \
		uglifyjs `basename $*`.js --compress --mangle --comments '/Copyr/i' --source-map -o `basename $*`.min.js; \
	fi

# Perl libraries configuration

json:	$(MANAGERJSONDST) debian/*cron*
	@if which ccso >/dev/null; then $(MAKE) minify; fi
	$(MAKE) minify

debian/liblemonldap-ng-handler-perl.cron.d: lemonldap-ng-handler/scripts/purgeLocalCache.cron.d
	@perl -pe 's/__APACHEUSER__/www-data/g;s@__BINDIR__@/usr/share/lemonldap-ng/bin@g' \
		lemonldap-ng-handler/scripts/purgeLocalCache.cron.d \
		> debian/liblemonldap-ng-handler-perl.cron.d

debian/liblemonldap-ng-portal-perl.cron.d: lemonldap-ng-portal/scripts/purgeCentralCache.cron.d
	@perl -pe 's/__APACHEUSER__/www-data/g;s@__BINDIR__@/usr/share/lemonldap-ng/bin@g' \
		lemonldap-ng-portal/scripts/purgeCentralCache.cron.d \
		> debian/liblemonldap-ng-portal-perl.cron.d

$(MANAGERJSONDST):	$(MANAGERJSONSRC)
	./scripts/jsongenerator.pl

common_conf:	${SRCCOMMONDIR}/Makefile

handler_conf:	${SRCHANDLERDIR}/Makefile

portal_conf:	${SRCPORTALDIR}/Makefile

manager_conf:	${SRCMANAGERDIR}/Makefile

${SRCCOMMONDIR}/Makefile:
	@cd ${SRCCOMMONDIR}; \
	LMNGCONFFILE=$(STORAGECONFFILE) \
	LMNGCONFDIR=$(FILECONFIGDIR) \
	$(PERL) Makefile.PL $(PERLOPTIONS)

${SRCHANDLERDIR}/Makefile:
	@cd ${SRCHANDLERDIR}; $(PERL) Makefile.PL $(PERLOPTIONS)

${SRCPORTALDIR}/Makefile:
	@cd ${SRCPORTALDIR}; $(PERL) Makefile.PL $(PERLOPTIONS)

${SRCMANAGERDIR}/Makefile:
	@cd ${SRCMANAGERDIR}; $(PERL) Makefile.PL $(PERLOPTIONS)

# Make targets
# ------------

common:		common_conf
	@$(MAKE) -C ${SRCCOMMONDIR}

handler:	handler_conf common
	@$(MAKE) -C ${SRCHANDLERDIR}

portal:		portal_conf handler
	@$(MAKE) -C ${SRCPORTALDIR}

manager:	manager_conf handler
	$(MAKE) -C ${SRCMANAGERDIR}

# Test targets
# ------------
test:		all common_test handler_test portal_test manager_test
	@echo
	@echo "All tests passed"

common_test:	common
	@HARNESS_OPTIONS=$(PARA) $(MAKE) -C ${SRCCOMMONDIR} test

handler_test:	handler
	@$(MAKE) -C ${SRCHANDLERDIR} test

portal_test:	portal
	@HARNESS_OPTIONS=$(PARA) $(MAKE) -C ${SRCPORTALDIR} test

manager_test:	manager
	@$(MAKE) -C ${SRCMANAGERDIR} test

autopkgtest: all autopkg_common autopkg_handler autopkg_portal autopkg_manager autopkg_runner

autopkg_%:
	./debian/tests/runner build-deps lemonldap-ng-$*

autopkg_runner:
	./debian/tests/runner runtime-deps

# End-to-end tests
# ----------------

e2e_test:	all prepare_test_server start_web_server launch_protractor stop_web_server

nox_e2e_test:
	xvfb-run -a -s "-screen 0 800x600x16" $(MAKE) e2e_test

prepare_test_server:
	-@mkdir -p e2e-tests/conf/sessions/lock e2e-tests/conf/persistents/lock
	-@mkdir e2e-tests/conf/manager e2e-tests/conf/portal e2e-tests/conf/api
	$(MAKE) install_webserver_conf install_test_site install_fastcgi_server \
		DNSDOMAIN=$(DNSDOMAIN) \
		CONFDIR=$(CURDIR)/e2e-tests/conf \
		RCONFDIR=e2e-tests/conf \
		ERASECONFIG=1 \
		VHOSTLISTEN='*:$(TESTWEBSERVERPORT)' \
		PORT=$(TESTWEBSERVERPORT) \
		FASTCGISOCKDIR=$(CURDIR)/e2e-tests/conf \
		PORTALSITEDIR=$(CURDIR)/e2e-tests/conf/portal \
		PORTALSTATICDIR=$(CURDIR)/$(SRCPORTALDIR)/site/htdocs/static \
		MANAGERSITEDIR=$(CURDIR)/e2e-tests/conf/manager \
		MANAGERSTATICDIR=$(CURDIR)/$(SRCMANAGERDIR)/site/htdocs/static \
		RUNITDIR=$(CURDIR)/e2e-tests/conf/run \
		RTMPFILESDIR=$(CURDIR)/e2e-tests/conf/tmp \
		TESTDIR=$(CURDIR)/e2e-tests/conf/site \
		DEFDOCDIR=$(CURDIR)/doc \
		SBINDIR=$(CURDIR)/e2e-tests/conf/sbin \
		MANDIR=$(CURDIR)/e2e-tests/conf/man \
		INITDIR=$(CURDIR)/e2e-tests/conf/init \
		ETCDEFAULTDIR=$(CURDIR)/e2e-tests/conf/def
	#@cp -f e2e-tests/index.* e2e-tests/conf/
	@cp -f $(SRCMANAGERDIR)/site/htdocs/manager* e2e-tests/conf/manager
	@cp -f $(SRCMANAGERDIR)/site/api/api* e2e-tests/conf/api
	@cp -f $(SRCPORTALDIR)/site/htdocs/index* e2e-tests/conf/portal
	@cp e2e-tests/persistent/5efe8af397fc3577e05b483aca964f1b e2e-tests/conf/persistents
	@cp e2e-tests/saml-sp.xml e2e-tests/conf/site/saml-sp.xml
	@cp e2e-tests/rules.json e2e-tests/conf/site/test.json
	@for f in $$(find e2e-tests/conf -name '*.fcgi'); do \
		perl -i -pe 'if($$.==2){print "BEGIN{\n"; print qq(use lib q('$(CURDIR)'/lemonldap-ng-$$_/blib/lib);\n) foreach qw(common handler portal manager); print "}\n"; }' $$f; \
	done
	@cp e2e-tests/lmConf-1.json e2e-tests/lemonldap-ng*.ini e2e-tests/env.conf e2e-tests/test-nginx.conf e2e-tests/conf/
	@cp e2e-tests/form.html e2e-tests/conf/site
	@perl -i -mCwd -pe 'BEGIN{$$p=Cwd::getcwd()}s#__pwd__#$$p#;s#__port__#$(TESTWEBSERVERPORT)#;s#__FASTCGISOCKDIR__#$(FASTCGISOCKDIR)#;s#__domain__#$(DNSDOMAIN)#g;' \
		e2e-tests/conf/lemonldap-ng*.ini \
		e2e-tests/conf/lmConf-1.json \
		e2e-tests/conf/env.conf \
		e2e-tests/conf/test-nginx.conf
	@perl -i -pe 's/#CustomLog.*$$/CustomLog conf\/apache2.log llng/' e2e-tests/conf/portal-apache2.X.conf e2e-tests/conf/manager-apache2.X.conf
	@if test "$(TESTUSESSL)" = "1"; then \
		perl -i -pe 's#http://(test|mana|auth)#https://$$1#' e2e-tests/conf/lmConf-1.json e2e-tests/conf/handler-apache2.X.conf e2e-tests/conf/site/index.pl; \
		perl -i -pe 's#"https": 0#"https": 1#' e2e-tests/conf/lmConf-1.json; \
	fi

e2e-tests/conf/apache2.pid: start_web_server

start_web_server:	all prepare_test_server
	# Clean old server if launched
	mkdir -p e2e-tests/conf
	@if test "$(TESTBACKEND)" = "DBI"; then \
		echo 'create table lmConfig (cfgNum int, data text);'|sqlite3 e2e-tests/conf/config.db; \
		echo 'create table sessions (id text, a_session text, LastUpdated int);'|sqlite3 e2e-tests/conf/sessions.db; \
		perl lemonldap-ng-common/scripts/convertConfig \
			--current=e2e-tests/conf/lemonldap-ng.ini \
			--new=e2e-tests/conf/lemonldap-ng-sql.ini; \
		mv e2e-tests/conf/lemonldap-ng-sql.ini e2e-tests/conf/lemonldap-ng.ini; \
		LLNG_DEFAULTCONFFILE=e2e-tests/conf/lemonldap-ng.ini \
			perl lemonldap-ng-common/scripts/lemonldap-ng-cli --yes 1 \
				set globalStorage Apache::Session::SQLite3; \
		LLNG_DEFAULTCONFFILE=e2e-tests/conf/lemonldap-ng.ini \
			perl lemonldap-ng-common/scripts/lemonldap-ng-cli --yes 1 \
				addKey globalStorageOptions DataSource 'dbi:SQLite:dbname='$(CURDIR)'/e2e-tests/conf/sessions.db'; \
	fi
	@# Debian: make start_web_server TESTBACKEND=LDAP LLNGTESTLDAP_SCHEMA_DIR=/etc/ldap/schema LLNGTESTLDAP_SLAPADD_BIN=/usr/sbin/slapadd
	@if test "$(TESTBACKEND)" = "LDAP"; then \
		cp lemonldap-ng-portal/t/testslapd/slapd.ldif e2e-tests/conf/; \
		mkdir e2e-tests/conf/slapd.d; \
		mkdir e2e-tests/conf/data; \
		sed -i 's:__SCHEMA_DIR__:${LLNGTESTLDAP_SCHEMA_DIR}:' e2e-tests/conf/slapd.ldif; \
		sed -i 's|olcDbDirectory.*|olcDbDirectory: e2e-tests/conf/data|' e2e-tests/conf/slapd.ldif; \
		sed -i 's|olcPidFile.*|olcPidFile: e2e-tests/conf/slapd.pid|' e2e-tests/conf/slapd.ldif; \
		${LLNGTESTLDAP_SLAPADD_BIN} -F e2e-tests/conf/slapd.d -n 0 -l e2e-tests/conf/slapd.ldif; \
		${LLNGTESTLDAP_SLAPADD_BIN} -F e2e-tests/conf/slapd.d -n 1 -l lemonldap-ng-portal/t/testslapd/users.ldif; \
		${LLNGTESTLDAP_SLAPADD_BIN} -F e2e-tests/conf/slapd.d -n 1 -l lemonldap-ng-portal/t/testslapd/confs-sessions.ldif; \
		${LLNGTESTLDAP_SLAPD_BIN} -s 511 -h "ldap://127.0.0.1:20389/" -F e2e-tests/conf/slapd.d; \
		perl ./lemonldap-ng-common/scripts/convertConfig \
			--current=e2e-tests/conf/lemonldap-ng.ini \
			--new=e2e-tests/conf/lemonldap-ng-ldap.ini; \
		mv e2e-tests/conf/lemonldap-ng-ldap.ini e2e-tests/conf/lemonldap-ng.ini; \
		LLNG_DEFAULTCONFFILE=e2e-tests/conf/lemonldap-ng.ini \
			perl lemonldap-ng-common/scripts/lemonldap-ng-cli --yes 1 \
				set globalStorage Apache::Session::LDAP; \
		LLNG_DEFAULTCONFFILE=e2e-tests/conf/lemonldap-ng.ini \
			perl lemonldap-ng-common/scripts/lemonldap-ng-cli --yes 1 \
				addKey globalStorageOptions ldapServer 'ldap://localhost:20389'; \
		LLNG_DEFAULTCONFFILE=e2e-tests/conf/lemonldap-ng.ini \
			perl lemonldap-ng-common/scripts/lemonldap-ng-cli --yes 1 \
				addKey globalStorageOptions ldapConfBase 'ou=configurations,dc=example,dc=com'; \
		LLNG_DEFAULTCONFFILE=e2e-tests/conf/lemonldap-ng.ini \
			perl lemonldap-ng-common/scripts/lemonldap-ng-cli --yes 1 \
				addKey globalStorageOptions ldapBindDN 'cn=admin,dc=example,dc=com'; \
		LLNG_DEFAULTCONFFILE=e2e-tests/conf/lemonldap-ng.ini \
			perl lemonldap-ng-common/scripts/lemonldap-ng-cli --yes 1 \
				addKey globalStorageOptions ldapBindPassword admin; \
	fi
	-@[ -e e2e-tests/conf/apache2.pid ] && kill `cat e2e-tests/conf/apache2.pid` || true
	-@[ -e e2e-tests/conf/nginx.pid ]   && kill `cat e2e-tests/conf/nginx.pid` || true
	-@[ -e e2e-tests/conf/llng-fastcgi.pid ] && kill `cat e2e-tests/conf/llng-fastcgi.pid` && rm -f e2e-tests/conf/llng-fastcgi.pid || true
	# Start web server (designed for Debian, path may be broken else)
	@if test "$(TESTWEBSERVER)" = "apache"; then \
		if test "$(TESTUSESSL)" = "1"; then \
			APACHEARGS=-DUseSSL; \
		else \
			APACHEARGS=; \
		fi; \
		LLNG_DEFAULTCONFFILE=$(CURDIR)/e2e-tests/conf/lemonldap-ng.ini /usr/sbin/apache2 -d $(CURDIR)/e2e-tests -f apache2.conf $$APACHEARGS -k start; \
	elif test "$(TESTWEBSERVER)" = "nginx"; then \
		echo "Testing nginx conf"; \
		$(NGINX) -t -p $(CURDIR)/e2e-tests \
			-g 'error_log '$(CURDIR)'/e2e-tests/conf/nginx.log;' \
			-c $(CURDIR)/e2e-tests/nginx.conf \
			2>&1 | grep -v 'Permission denied' || true; \
		echo "Launching nginx"; \
		$(NGINX) -p $(CURDIR)/e2e-tests \
			-g 'error_log '$(CURDIR)'/e2e-tests/conf/nginx.log;' \
			-c $(CURDIR)/e2e-tests/nginx.conf \
			2>&1 | grep -v 'Permission denied' || true; \
		echo "Launching plackup"; \
		$(MAKE) plackup; \
	elif test "$(TESTWEBSERVER)" = "starman"; then \
		if test "$(TESTUSESSL)" = "1"; then \
			ARGS="--ssl-cert-file e2e-tests/cert.pem --ssl-key-file e2e-tests/key.pem --enable-ssl"; \
		else \
			ARGS=; \
		fi; \
		echo "ARGS=$$ARGS"; \
		LLNG_DEFAULTCONFFILE=$(CURDIR)/e2e-tests/conf/lemonldap-ng.ini \
		/usr/bin/start_server \
			--log-file=e2e-tests/conf/starman.log \
			--pid-file=e2e-tests/conf/server.pid \
			--status-file=e2e-tests/conf/server-status.pid \
			--daemonize \
			-- starman \
			--port=$(TESTWEBSERVERPORT) \
			--workers 3 \
			$$ARGS \
			e2e-tests/llng.psgi; \
	else \
		echo "!!!!! Unknown test server: $(TESTWEBSERVER) !!!!!" >&2; \
		exit 1; \
	fi

reload_web_server:
	@if [ -e e2e-tests/conf/apache2.pid ]; then \
		LLNG_DEFAULTCONFFILE=$(CURDIR)/e2e-tests/conf/lemonldap-ng.ini \
		/usr/sbin/apache2 -d $(CURDIR)/e2e-tests -f apache2.conf -k graceful; \
	elif [ -e e2e-tests/conf/nginx.pid ]; then \
		$(NGINX) -p $(CURDIR)/e2e-tests \
			-g 'error_log '$(CURDIR)'/e2e-tests/conf/nginx.log;' \
			-c $(CURDIR)/e2e-tests/nginx.conf \
			-s reload \
			2>&1 | grep -v 'Permission denied' || true; \
		kill `cat e2e-tests/conf/llng-fastcgi.pid` || true; \
		$(MAKE) plackup; \
	elif [ -e e2e-tests/conf/server.pid ]; then \
		/usr/bin/start_server\
			--pid-file=e2e-tests/conf/server.pid \
			--status-file=e2e-tests/conf/server-status.pid \
			--restart; \
	else \
		$(MAKE) start_web_server; \
	fi

launch_protractor:
	# Start e2e tests
	# NB: you must have protractor installed (using npm install -g protractor)
	# and have run update-webdriver at least once and have a node.js > 4.0
	# Install test keys
	cp -f e2e-tests/persistent/5efe8af397fc3577e05b483aca964f1b.e2e-test e2e-tests/conf/persistents/5efe8af397fc3577e05b483aca964f1b
	@E2E_TESTS=$(E2E_TESTS) TESTWEBSERVERPORT=$(TESTWEBSERVERPORT) protractor e2e-tests/protractor-conf.js

stop_web_server:
	# Stop web server
	-@[ -e e2e-tests/conf/apache2.pid ] && kill `cat e2e-tests/conf/apache2.pid` || true
	-@[ -e e2e-tests/conf/nginx.pid ]   && kill `cat e2e-tests/conf/nginx.pid` ||true
	-@[ -e e2e-tests/conf/llng-fastcgi.pid ] && kill `cat e2e-tests/conf/llng-fastcgi.pid` && rm -f e2e-tests/conf/llng-fastcgi.pid || true
	-@[ -e e2e-tests/conf/slapd.pid ] && kill `cat e2e-tests/conf/slapd.pid` || true
	-@[ -e e2e-tests/conf/server.pid ] && kill `cat e2e-tests/conf/server.pid` || true
	# Clean
	@rm -rf e2e-tests/conf

restart_web_server: start_web_server

plackup:
	@LLNG_DEFAULTCONFFILE=$(CURDIR)/e2e-tests/conf/lemonldap-ng.ini \
	perl -I . e2e-tests/conf/sbin/llng-fastcgi-server \
		-F >e2e-tests/conf/fastcgi.log 2>&1 &

install_test:
	@E2E_TESTS=$(E2E_TESTS) TESTWEBSERVERPORT=$(PORT) protractor e2e-tests/protractor-conf.js

# Install targets
# ---------------
install:	install_libs install_bin install_fastcgi_server install_uwsgi_server install_site

# Perl libraires install

install_libs:	common_install_libs install_handler_libs install_portal_libs install_manager_libs

common_install_libs:		common
	@$(MAKE) -C ${SRCCOMMONDIR} install

install_handler_libs:	handler
	@$(MAKE) -C ${SRCHANDLERDIR} install

install_portal_libs:		portal
	@$(MAKE) -C ${SRCPORTALDIR} install

install_manager_libs:	manager
	@$(MAKE) -C ${SRCMANAGERDIR} install

install_bin:	install_conf_dir
	# Binary install
	@install -v -d $(RBINDIR)
	@cp -f\
		${SRCHANDLERDIR}/scripts/purgeLocalCache \
		${SRCPORTALDIR}/scripts/purgeCentralCache \
		${SRCPORTALDIR}/scripts/llngDeleteSession \
		${SRCPORTALDIR}/scripts/llngUserAttributes \
		${SRCPORTALDIR}/scripts/downloadSamlMetadata \
		${SRCCOMMONDIR}/scripts/convertConfig \
		${SRCCOMMONDIR}/scripts/convertSessions \
		${SRCCOMMONDIR}/scripts/convertToHashSessionStorage \
		${SRCCOMMONDIR}/scripts/encryptTotpSecrets \
		${SRCCOMMONDIR}/scripts/lmMigrateConfFiles2ini \
		${SRCCOMMONDIR}/scripts/rotateOidcKeys \
		${SRCMANAGERDIR}/scripts/lmConfigEditor \
		${SRCCOMMONDIR}/scripts/lemonldap-ng-cli \
		${SRCCOMMONDIR}/scripts/lemonldap-ng-sessions \
		${SRCCOMMONDIR}/scripts/importMetadata \
			$(RBINDIR)
	@if [ ! "$(APACHEUSER)" ]; then \
		$(PERL) -i -pe 's#__APACHEUSER__#nobody#g;' \
			$(RBINDIR)/lmConfigEditor \
			$(RBINDIR)/lemonldap-ng-cli \
			$(RBINDIR)/rotateOidcKeys \
			$(RBINDIR)/lemonldap-ng-sessions; \
	else \
		$(PERL) -i -pe 's#__APACHEUSER__#$(APACHEUSER)#g;' \
			$(RBINDIR)/lmConfigEditor \
			$(RBINDIR)/lemonldap-ng-cli \
			$(RBINDIR)/rotateOidcKeys \
			$(RBINDIR)/lemonldap-ng-sessions; \
	fi
	@if [ ! "$(APACHEGROUP)" ]; then \
		$(PERL) -i -pe 's#__APACHEGROUP__#nobody#g;' \
			$(RBINDIR)/lmConfigEditor \
			$(RBINDIR)/lemonldap-ng-cli \
			$(RBINDIR)/rotateOidcKeys \
			$(RBINDIR)/lemonldap-ng-sessions; \
	else \
		$(PERL) -i -pe 's#__APACHEGROUP__#$(APACHEGROUP)#g;' \
			$(RBINDIR)/lmConfigEditor \
			$(RBINDIR)/lemonldap-ng-cli \
			$(RBINDIR)/rotateOidcKeys \
			$(RBINDIR)/lemonldap-ng-sessions; \
	fi
	@$(CHMOD) +x $(RBINDIR)/*

install_fastcgi_server:
	@install -v -d \
		$(RSBINDIR) \
		$(RETCDEFAULTDIR) \
		$(RFASTCGISOCKDIR) \
		${RMANDIR}/man8
	@cp -f fastcgi-server/sbin/llng-fastcgi-server $(RSBINDIR)
	@$(CHMOD) +x $(RSBINDIR)/llng-fastcgi-server
	@pod2man -s 8 -name llng-fastcgi-server \
		fastcgi-server/sbin/llng-fastcgi-server \
		> ${RMANDIR}/man8/llng-fastcgi-server.8p
	# RC
	@if [ "x$(WITHRC)" = "xyes" ]; then \
		install -v -d $(RINITDIR); \
		cp -f fastcgi-server/rc/llng-fastcgi-server $(RINITDIR); \
		$(PERL) -pi \
			-e 's#__SBINDIR__#$(SBINDIR)#;' \
			-e 's#__DEFAULTDIR__#$(ETCDEFAULTDIR)#;' \
			-e 's#__FASTCGISOCKDIR__#$(FASTCGISOCKDIR)#g;' \
			$(RINITDIR)/llng-fastcgi-server; \
	fi
	# systemd
	@if [ "x$(WITHSYSTEMD)" = "xyes" ]; then \
		install -v -d $(RUNITDIR) $(RTMPFILESDIR); \
		cp -f fastcgi-server/systemd/llng-fastcgi-server.service $(RUNITDIR); \
		cp -f fastcgi-server/systemd/llng-fastcgi-server.tmpfile $(RTMPFILESDIR)/llng-fastcgi-server.conf; \
		$(PERL) -pi \
			-e 's#__SBINDIR__#$(SBINDIR)#;' \
			-e 's#__DEFAULTDIR__#$(ETCDEFAULTDIR)#;' \
			-e 's#__FASTCGISOCKDIR__#$(FASTCGISOCKDIR)#g;' \
			$(RUNITDIR)/llng-fastcgi-server.service \
			$(RTMPFILESDIR)/llng-fastcgi-server.conf; \
		if [ ! "$(FASTCGIUSER)" ]; then \
			$(PERL) -pi -e 's#__USER__#nobody#' \
				$(RTMPFILESDIR)/llng-fastcgi-server.conf;  \
		else \
			$(PERL) -pi -e 's#__USER__#$(FASTCGIUSER)#' \
				$(RTMPFILESDIR)/llng-fastcgi-server.conf; \
		fi; \
		if [ ! "$(FASTCGIGROUP)" ]; then \
			$(PERL) -pi -e 's#__GROUP__#nobody#' \
				$(RTMPFILESDIR)/llng-fastcgi-server.conf; \
		else \
			$(PERL) -pi -e 's#__GROUP__#$(FASTCGIGROUP)#' \
				$(RTMPFILESDIR)/llng-fastcgi-server.conf; \
		fi; \
	fi
	#
	@cp -f fastcgi-server/default/llng-fastcgi-server $(RETCDEFAULTDIR)
	@$(PERL) -pi \
		-e 's#__SBINDIR__#$(SBINDIR)#;' \
		-e 's#__DEFAULTDIR__#$(ETCDEFAULTDIR)#;' \
		-e 's#__FASTCGISOCKDIR__#$(FASTCGISOCKDIR)#g;' \
		$(RETCDEFAULTDIR)/llng-fastcgi-server \
		$(RSBINDIR)/llng-fastcgi-server
	@if [ ! "$(FASTCGIUSER)" ]; then \
		$(PERL) -pi -e 's#__USER__#nobody#' \
			$(RETCDEFAULTDIR)/llng-fastcgi-server; \
	else \
		$(PERL) -pi -e 's#__USER__#$(FASTCGIUSER)#' \
			$(RETCDEFAULTDIR)/llng-fastcgi-server; \
	fi
	@if [ ! "$(FASTCGIGROUP)" ]; then \
		$(PERL) -pi -e 's#__GROUP__#nobody#' \
			$(RETCDEFAULTDIR)/llng-fastcgi-server; \
	else \
		$(PERL) -pi -e 's#__GROUP__#$(FASTCGIGROUP)#' \
			$(RETCDEFAULTDIR)/llng-fastcgi-server; \
	fi
	@if [ "$(FASTCGIUSER)" != "" ]; then \
		$(CHOWN) $(FASTCGIUSER) $(RFASTCGISOCKDIR) || exit 1; \
		if [ "$(FASTCGIGROUP)" != "" ]; then \
			$(CHGRP) $(FASTCGIGROUP) $(RFASTCGISOCKDIR) || exit 1; \
		fi; \
		$(CHMOD) 770 $(RFASTCGISOCKDIR); \
	else \
		$(CHMOD) 777 $(RFASTCGISOCKDIR); \
	fi

install_uwsgi_server:
	@install -v -d $(RUWSGIYAMLDIR) $(RLLNGAPPDIR)
	@install -m 644 -v fastcgi-server/uwsgi/llng-server.yaml $(RUWSGIYAMLDIR)/llng-server.yaml
	@install -m 644 -v $(SRCHANDLERDIR)/eg/llng-server.psgi $(RLLNGAPPDIR)/llng-server.psgi
	$(PERL) -pi -e 's#__APPDIR__#$(LLNGAPPDIR)#;s#__UID__#$(UWSGIUSER)#;s#__GID__#$(UWSGIGROUP)#;' $(RUWSGIYAMLDIR)/llng-server.yaml

# Site install

install_site:	install_manager_site install_portal_site install_handler_site install_test_site install_examples_site install_doc_site install_webserver_conf
	# Site install
	@install -v -d $(RCONFDIR)
	# Check if erase is wanted
	@if [ "$(ERASECONFIG)" -eq "1" ]; then \
		cp -f _example/etc/for_etc_hosts $(RCONFDIR); \
	fi
	@$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g' $(RCONFDIR)/for_etc_hosts
	# Fix a lost of rights on the main directory
	@$(CHMOD) 755 $(RBINDIR) $(RDOCUMENTROOT) $(REXAMPLESDIR) $(RHANDLERDIR) $(RPORTALSTATICDIR) $(RMANAGERSITEDIR) $(RMANAGERAPIDIR) $(RTOOLSDIR) $(RCONFDIR) $(RDATADIR)
	@echo
	@echo "LemonLDAP::NG v${VERSION} is installed with these parameters:"
	@echo "  - System configuration: ${CONFDIR}"
	@echo "  - DNS domain (for cookies and virtual hosts): ${DNSDOMAIN}"
	@echo
	@echo "To finish configuration:"
	@echo
	@echo "1 - Add this in your Apache $(APACHEVERSION) configuration file:"
	@echo "      include ${CONFDIR}/portal-apache$(APACHEVERSION).conf"
	@echo "      include ${CONFDIR}/handler-apache$(APACHEVERSION).conf"
	@echo "      include ${CONFDIR}/manager-apache$(APACHEVERSION).conf"
	@echo "      include ${CONFDIR}/api-apache$(APACHEVERSION).conf"
	@echo "      include ${CONFDIR}/test-apache$(APACHEVERSION).conf"
	@echo
	@echo "2 - Restart Apache:"
	@echo "      apache$(APACHEVERSION)ctl restart"
	@echo
	@echo "3 - Run 'make postconf' as root to update /etc/hosts if your DNS service does not known auth.$(DNSDOMAIN) and manager.$(DNSDOMAIN)"
	@echo
	@echo "4 - Try to connect to http://test1.${DNSDOMAIN}/ or http://test2.${DNSDOMAIN}/ with demonstration accounts:"
	@echo "    - rtyler/rtyler"
	@echo "    - msmith/msmith"
	@echo "    - dwho/dwho"
	@echo
	@echo "5 - Connect to Manager at http://manager.${DNSDOMAIN}/ to edit configuration"
	@echo
	@if [ ! "$(APACHEUSER)" ]; then \
		echo;echo "    Warning, since APACHEUSER was not set, $(APACHESESSIONFILEDIR), $(APACHEPSESSIONFILEDIR), $(CAPTCHADIR), $(CACHEDIR) and $(CONFDIR) have permissive permissions."; \
		echo "    Fix them by yourself to restrict their view to apache process only"; \
	fi
	@echo

install_webserver_conf:
	@install -m 755 -v -d $(RCONFDIR)
	@if [ "$(ERASECONFIG)" -eq "1" ]; then \
		cp -f _example/etc/*-apache$(APACHEVERSION).conf $(RCONFDIR); \
		cp -f _example/etc/*nginx*.conf $(RCONFDIR); \
	fi
	@$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g; \
			s#__PORTALDIR__#$(PORTALDIR)/#g; \
			s#__PORTALSITEDIR__#$(PORTALSITEDIR)/#g; \
			s#__PORTALSTATICDIR__#$(PORTALSTATICDIR)/#g; \
			s#__MANAGERDIR__#$(MANAGERDIR)/#g; \
			s#__MANAGERAPIDIR__#$(MANAGERAPIDIR)/#g; \
			s#__MANAGERSITEDIR__#$(MANAGERSITEDIR)/#g; \
			s#__MANAGERSTATICDIR__#$(MANAGERSTATICDIR)/#g; \
			s#__TESTDIR__#$(TESTDIR)/#g; \
			s#__APACHELOGDIR__#$(APACHELOGDIR)#g; \
			s#__PORT__#$(PORT)#g; \
			s#__CONFDIR__#$(CONFDIR)#g; \
			s#__FASTCGISOCKDIR__#$(FASTCGISOCKDIR)#g; \
			s#__VHOSTLISTEN__#$(VHOSTLISTEN)#g; \
			s#__DEFDOCDIR__#$(DEFDOCDIR)/#g;' $(RCONFDIR)/*apache*.conf $(RCONFDIR)/*nginx*.conf

install_manager_site:	install_conf_dir
	# Manager install
	@install -v -d $(RMANAGERDIR) $(RMANAGERSTATICDIR) \
		$(RMANAGERTEMPLATESDIR) $(RMANAGERAPIDIR)
	@cp -pR -f $(SRCMANAGERDIR)/site/api/* $(RMANAGERAPIDIR)
	@cp -pR -f $(SRCMANAGERDIR)/site/htdocs/manager.* $(RMANAGERSITEDIR)
	@cp -pR $(SRCMANAGERDIR)/site/htdocs/static/* $(RMANAGERSTATICDIR)
	@for f in $(SRCMANAGERDIR)/site/templates/*.tpl; do \
		./scripts/transform-templates \
			usedebianlibs $(USEDEBIANLIBS) \
			useexternallibs $(USEEXTERNALLIBS) \
			jsminified $(JSCOMPRESS) \
			cssminified $(CSSCOMPRESS) <$$f \
			> $(RMANAGERTEMPLATESDIR)/`basename $$f`; \
	done
	@if test "$(USEEXTERNALLIBS)" = "yes"; then \
		rm -rvf $(MANAGEREXTERNALLIBS); \
	elif test "$(USEDEBIANLIBS)" = "yes"; then \
		rm -rvf $(MANAGERLIBSTOREMOVEFORDEBIAN); \
	fi
	@$(PERL) -i -pe 's#__MANAGERSTATICDIR__#$(MANAGERRELATIVESTATICDIR)#g' $(RCONFDIR)/$(CONFFILENAME)
	@$(PERL) -i -pe 's#__MANAGERDOCDIR__#$(MANAGERRELATIVEDOCDIR)#g' $(RCONFDIR)/$(CONFFILENAME)
	@$(PERL) -i -pe 's#__MANAGERTEMPLATESDIR__#$(MANAGERTEMPLATESDIR)#g' $(RCONFDIR)/$(CONFFILENAME)

install_portal_site:	install_conf_dir
	# Portal install
	@install -v -d $(RPORTALDIR) $(RPORTALSTATICDIR) \
		$(RPORTALTEMPLATESDIR) \
		$(RCRONDIR) $(RUNITDIR) $(RCONFDIR)
	@cp -pR -f $(SRCPORTALDIR)/site/htdocs/index.* $(RPORTALSITEDIR)
	@cp -pR -f $(SRCPORTALDIR)/site/htdocs/static/* $(RPORTALSTATICDIR)
	@cd $(SRCPORTALDIR)/site/templates; for f in `find * -type f -name '*.tpl'`; do \
		echo "$$f => $(RPORTALTEMPLATESDIR)/$$f"; \
		mkdir -p $(RPORTALTEMPLATESDIR)/`dirname $$f`; \
		../../../scripts/transform-templates \
			usedebianlibs $(USEDEBIANLIBS) \
			useexternallibs $(USEEXTERNALLIBS) \
			jsminified $(JSCOMPRESS) \
			cssminified $(CSSCOMPRESS) <$$f \
			>$(RPORTALTEMPLATESDIR)/$$f; \
	done; cd -
	@cd $(SRCPORTALDIR)/site/templates; for f in `find * -type f ! -name '*.tpl'`; do \
		mkdir -p $(RPORTALTEMPLATESDIR)/`dirname $$f`; \
		install -m 644 -v $$f $(RPORTALTEMPLATESDIR)/$$f; \
	done; cd -
	@cd $(SRCPORTALDIR)/site/templates; for l in `find * -type l`; do \
		echo link to do $$l `readlink $$l`; \
		target=`readlink $$l`; \
		cd $(RPORTALTEMPLATESDIR); \
		ln -s $$target $$l; \
		cd -; \
	done
	@if test "$(USEEXTERNALLIBS)" = "yes"; then \
		rm -rvf $(PORTALEXTERNALLIBS); \
	elif test "$(USEDEBIANLIBS)" = "yes"; then \
		rm -rvf $(PORTALLIBSTOREMOVEFORDEBIAN); \
	fi
	# Cron files
	@if [ "x$(WITHRC)" = "xyes" ]; then \
		cp -f $(SRCPORTALDIR)/scripts/purgeCentralCache.cron.d $(RCRONDIR)/lemonldap-ng-portal; \
		if [ ! "$(APACHEUSER)" ]; then \
			$(PERL) -i -pe 's#__APACHEUSER__#nobody#g;' $(RCRONDIR)/lemonldap-ng-portal; \
		else \
			$(PERL) -i -pe 's#__APACHEUSER__#$(APACHEUSER)#g;' $(RCRONDIR)/lemonldap-ng-portal; \
		fi; \
		$(PERL) -i -pe 's#__BINDIR__#$(BINDIR)#g;' $(RCRONDIR)/lemonldap-ng-portal; \
	fi
	# systemd files
	@if [ "x$(WITHSYSTEMD)" = "xyes" ]; then \
		cp -f $(SRCPORTALDIR)/scripts/lemonldap-ng-portal.service \
			$(SRCPORTALDIR)/scripts/lemonldap-ng-portal.timer \
			$(RUNITDIR)/; \
		if [ ! "$(APACHEUSER)" ]; then \
			$(PERL) -i -pe 's#__APACHEUSER__#nobody#g;' $(RUNITDIR)/lemonldap-ng-portal.service; \
		else \
			$(PERL) -i -pe 's#__APACHEUSER__#$(APACHEUSER)#g;' $(RUNITDIR)/lemonldap-ng-portal.service;  \
		fi; \
		$(PERL) -i -pe 's#__BINDIR__#$(BINDIR)#g;' $(RUNITDIR)/lemonldap-ng-portal.service; \
	fi
	#
	@$(PERL) -i -pe 's#__PORTALSTATICDIR__#$(PORTALRELATIVESTATICDIR)#g' $(RCONFDIR)/$(CONFFILENAME)
	@$(PERL) -i -pe 's#__PORTALTEMPLATESDIR__#$(PORTALTEMPLATESDIR)#g' $(RCONFDIR)/$(CONFFILENAME)

install_handler_site:	install_conf_dir
	# Handler install
	@install -v -d ${RHANDLERDIR}
	# Cron files
	@if [ "x$(WITHRC)" = "xyes" ]; then \
		install -v -d $(RCRONDIR); \
		cp -f $(SRCHANDLERDIR)/scripts/purgeLocalCache.cron.d $(RCRONDIR)/lemonldap-ng-handler; \
		if [ ! "$(APACHEUSER)" ]; then \
			$(PERL) -i -pe 's#__APACHEUSER__#nobody#g;' $(RCRONDIR)/lemonldap-ng-handler; \
		else \
			$(PERL) -i -pe 's#__APACHEUSER__#$(APACHEUSER)#g;' $(RCRONDIR)/lemonldap-ng-handler; \
		fi; \
		$(PERL) -i -pe 's#__BINDIR__#$(BINDIR)#g;' $(RCRONDIR)/lemonldap-ng-handler; \
	fi
	# systemd files
	@if [ "x$(WITHSYSTEMD)" = "xyes" ]; then \
		install -v -d $(RUNITDIR); \
		cp -f $(SRCHANDLERDIR)/scripts/lemonldap-ng-handler.service \
			$(SRCHANDLERDIR)/scripts/lemonldap-ng-handler.timer \
			$(RUNITDIR)/; \
		if [ ! "$(APACHEUSER)" ]; then \
			$(PERL) -i -pe 's#__APACHEUSER__#nobody#g;' $(RUNITDIR)/lemonldap-ng-handler.service; \
		else \
			$(PERL) -i -pe 's#__APACHEUSER__#$(APACHEUSER)#g;' $(RUNITDIR)/lemonldap-ng-handler.service; \
		fi; \
		$(PERL) -i -pe 's#__BINDIR__#$(BINDIR)#g;' $(RUNITDIR)/lemonldap-ng-handler.service; \
	fi

install_test_site:
	# Test site install
	@install -v -d $(RTESTDIR)
	@cp -pR -f _example/test/* $(RTESTDIR)
	@$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g' $(RTESTDIR)/index.pl

install_examples_site:
	# Examples install
	@install -v -d $(REXAMPLESDIR)
	@for i in portal manager handler; do \
		cp -a -f lemonldap-ng-$$i/eg $(REXAMPLESDIR)/$$i; \
	done
	@cp -a -f fastcgi-server/psgi/llngapp.psgi $(REXAMPLESDIR)/$$i
	@rm -rf $(REXAMPLESDIR)/portal/skins \
		$(REXAMPLESDIR)/manager/skins \

install_doc_site:
	# Offline documentation install
	@rm -rf $(RDEFDOCDIR)
	@install -v -d -m 755 $(RDEFDOCDIR)
	@cd doc && find index.html pages/* -type f ! -path '*/.*' -exec install -v -m 644 -D '{}' $(RDEFDOCDIR)/'{}' \; && cd -

	# Remove js
	@cd $(RDEFDOCDIR) && if test "$(USEEXTERNALLIBS)" = "yes"; then \
		rm -rvf $(DOCEXTERNALLIBS); \
	elif test "$(USEDEBIANLIBS)" = "yes"; then \
		rm -rvf $(DOCLIBSTOREMOVEFORDEBIAN); \
	fi && cd -

install_conf_dir:	install_sessions_dir install_notif_dir install_captcha_dir install_cache_dir
	# Configuration files install
	@install -v -d $(RCONFDIR) $(RFILECONFIGDIR) $(RTOOLSDIR)
	@if [ "$(ERASECONFIG)" -eq "1" ]; then \
		cp -f $(SRCCOMMONDIR)/$(CONFFILENAME) $(RCONFDIR); \
		$(PERL) -i -pe 's#^dirName\s*=\s*.*#dirName = $(FILECONFIGDIR)#g' $(RCONFDIR)/$(CONFFILENAME); \
	fi
	@cp _example/conf/lmConf-1.json $(RFILECONFIGDIR)
	@$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g;\
		s#__SESSIONDIR__#$(APACHESESSIONFILEDIR)#g;\
		s#__PSESSIONDIR__#$(APACHEPSESSIONFILEDIR)#g;\
		s#__NOTIFICATIONDIR__#$(APACHEFILENOTIFDIR)#g;\
		s#__CACHEDIR__#$(CACHEDIR)#g;' $(RFILECONFIGDIR)/lmConf-1.json
	@if [ "$(APACHEUSER)" != "" ]; then \
		$(CHOWN) $(APACHEUSER) $(RFILECONFIGDIR) || exit 1; \
		if [ "$(APACHEGROUP)" != "" ]; then \
			$(CHGRP) $(APACHEGROUP) $(RFILECONFIGDIR) || exit 1; \
		fi; \
		$(CHMOD) 770 $(RFILECONFIGDIR); \
	else \
		$(CHMOD) 777 $(RFILECONFIGDIR); \
	fi
	@cp $(SRCCOMMONDIR)/tools/*.sql $(RTOOLSDIR)
	@cp $(SRCCOMMONDIR)/tools/sso.schema $(RTOOLSDIR)
	$(PERL) -i -pe 's/__DNSDOMAIN__/$(DNSDOMAIN)/g; s#__CACHEDIR__#$(CACHEDIR)#g;' \
		$(RCONFDIR)/$(CONFFILENAME)

install_sessions_dir:
	@install -m 777 -v -d $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR) $(RAPACHEPSESSIONFILEDIR) $(RAPACHEPSESSIONFILELOCKDIR)
	# Fix Apache::Session directories permissions
	@if [ "$(APACHEUSER)" != "" ]; then \
		$(CHOWN) $(APACHEUSER) $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR) $(RAPACHEPSESSIONFILEDIR) $(RAPACHEPSESSIONFILELOCKDIR) || exit 1; \
		if [ "$(APACHEGROUP)" != "" ]; then \
			$(CHGRP) $(APACHEGROUP) $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR) $(RAPACHEPSESSIONFILEDIR) $(RAPACHEPSESSIONFILELOCKDIR) || exit 1; \
		fi; \
		$(CHMOD) 770 $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR) $(RAPACHEPSESSIONFILEDIR) $(RAPACHEPSESSIONFILELOCKDIR); \
	else \
		$(CHMOD) 777 $(RAPACHESESSIONFILEDIR) $(RAPACHESESSIONFILELOCKDIR) $(RAPACHEPSESSIONFILEDIR) $(RAPACHEPSESSIONFILELOCKDIR); \
	fi

install_notif_dir:
	@install -m 777 -v -d $(RFILENOTIFDIR)
	# Fix notifications directory permissions
	@if [ "$(APACHEUSER)" != "" ]; then \
		$(CHOWN) $(APACHEUSER) $(RFILENOTIFDIR) || exit 1; \
		if [ "$(APACHEGROUP)" != "" ]; then \
			$(CHGRP) $(APACHEGROUP) $(RFILENOTIFDIR) || exit 1; \
		fi; \
		$(CHMOD) 770 $(RFILENOTIFDIR); \
	else \
		$(CHMOD) 777 $(RFILENOTIFDIR); \
	fi

install_captcha_dir:
	@install -m 777 -v -d $(RCAPTCHADIR)
	# Fix captcha directory permissions
	@if [ "$(APACHEUSER)" != "" ]; then \
		$(CHOWN) $(APACHEUSER) $(RCAPTCHADIR) || exit 1; \
		if [ "$(APACHEGROUP)" != "" ]; then \
			$(CHGRP) $(APACHEGROUP) $(RCAPTCHADIR) || exit 1; \
		fi; \
		$(CHMOD) 770 $(RCAPTCHADIR); \
	else \
		$(CHMOD) 777 $(RCAPTCHADIR); \
	fi

install_cache_dir:
	@install -m 777 -v -d $(RCACHEDIR)
	# Fix captcha directory permissions
	@if [ "$(APACHEUSER)" != "" ]; then \
		$(CHOWN) $(APACHEUSER) $(RCACHEDIR) || exit 1; \
		if [ "$(APACHEGROUP)" != "" ]; then \
			$(CHGRP) $(APACHEGROUP) $(RCACHEDIR) || exit 1; \
		fi; \
		$(CHMOD) 770 $(RCACHEDIR); \
	else \
		$(CHMOD) 777 $(RCACHEDIR); \
	fi

postconf_hosts:
	@cat ${CONFDIR}/for_etc_hosts >> /etc/hosts
	@echo "/etc/hosts was updated"

postconf: postconf_hosts
	@echo "Post configuration done"

debian-install:
	@echo "You have now to choose between:"
	@echo " - make debian-install-for-apache"
	@echo " - make ubuntu-install-for-apache"
	@echo " - make debian-install-for-nginx"
	@echo " - make ubuntu-install-for-nginx"
	@echo
	@echo "All packages will be built in /tmp/ but only those needed by the"
	@echo "server you will choose will be installed"
	@exit 1

debian-install-for-apache: debian-packages
	perl -i -ne 'next if/(?:fastcgi|uwsgi).*deb$$/;s/lemonldap-ng-(?:fastcgi-server|uwsgi-app)//;print' /tmp/lemonldap-ng_$(VERSION)*.changes
	cd /tmp/lemonldap-ng-$(VERSION) && \
	$(SU) debi

debian-install-for-nginx: debian-packages
	perl -i -ne 'next if/(?:uwsgi).*deb$$/;s/lemonldap-ng-(?:uwsgi-app)//;print' /tmp/lemonldap-ng_$(VERSION)*.changes
	cd /tmp/lemonldap-ng-$(VERSION) && \
	$(SU) debi

debian-install-for-nginx-uwsgi: debian-packages
	perl -i -ne 'next if/(?:fastcgi).*deb$$/;s/lemonldap-ng-(?:fastcgi-server)//;print' /tmp/lemonldap-ng_$(VERSION)*.changes
	cd /tmp/lemonldap-ng-$(VERSION) && \
	$(SU) debi

ubuntu-install: debian-install

ubuntu-install-for-apache:
	$(MAKE) debian-install-for-apache SU=sudo

ubuntu-install-for-nginx:
	$(MAKE) debian-install-for-nginx SU=sudo

# Cleaning targets
# ----------------

distclean:	clean

clean:
	-@$(MAKE) common_clean handler_clean portal_clean manager_clean stop_web_server
	@rm -f $$(find */ -name '*bak' -delete)
	@rm -rf doc/devel
	@rm -rf doc/pages/documentation/current/*
	@rm -rf "$(WEBSITE_DIR)"
	@rm -vf *gz *zip
	@rm -rf lemonldap-ng-$(VERSION)
	@rm -rf lemonldap-ng-portal/t/sessions/tmpSession*
	@echo "Cleaned"

common_clean:
	-@if test -e ${SRCCOMMONDIR}/Makefile;then $(MAKE) -C ${SRCCOMMONDIR} distclean;fi
	@rm -vf common*

handler_clean:
	-@if test -e ${SRCHANDLERDIR}/Makefile;then $(MAKE) -C ${SRCHANDLERDIR} distclean;fi
	@rm -vf handler*

portal_clean:
	-@if test -e ${SRCPORTALDIR}/Makefile;then $(MAKE) -C ${SRCPORTALDIR} distclean;fi
	@rm -vf portal*

manager_clean:
	-@if test -e ${SRCMANAGERDIR}/Makefile;then $(MAKE) -C ${SRCMANAGERDIR} distclean;fi
	@rm -vf manager*

# Perl libraries uninstall targets
# --------------------------------

uninstall:	configure handler_uninstall portal_uninstall manager_uninstall

common_uninstall:	common
	@$(MAKE) -C ${SRCCOMMONDIR} uninstall
	@rm -vf common_uninstall

handler_uninstall:	handler
	@$(MAKE) -C ${SRCHANDLERDIR} uninstall
	@rm -vf handler_uninstall

portal_uninstall:		portal
	@$(MAKE) -C ${SRCPORTALDIR} uninstall
	@rm -vf portal_uninstall

manager_uninstall:	manager
	@$(MAKE) -C ${SRCMANAGERDIR} uninstall
	@rm -vf manager_uninstall

# Packaging target
# ----------------

dist:	clean
	@mkdir -p lemonldap-ng-$(VERSION)
	@cp -pRH $$(find * -maxdepth 0|grep -v -e "lemonldap-ng-$(VERSION)") lemonldap-ng-$(VERSION)
	@find $$dir -name '*.bak' -delete
	@rm -rf lemonldap-ng-$(VERSION)/lemonldap-ng-$(VERSION)
	@rm -rf lemonldap-ng-$(VERSION)/docker
	@rm -rf lemonldap-ng-$(VERSION)/Dockerfile
	@rm -rf lemonldap-ng-$(VERSION)/dev
	@find lemonldap-ng-$(VERSION)/ -name node_modules -exec rm -rf '{}' \;
	@$(COMPRESS) lemonldap-ng-$(VERSION).$(COMPRESSSUFFIX) lemonldap-ng-$(VERSION)
	@rm -rf lemonldap-ng-$(VERSION)

debian-dist:	clean
	@mkdir -p lemonldap-ng-$(VERSION)
	@cp -pRH $$(find * -maxdepth 0|grep -v -e "\(lemonldap-ng-$(VERSION)\|rpm\)") lemonldap-ng-$(VERSION)
	@find $$dir -name '*.bak' -delete
	@cp lemonldap-ng-$(VERSION)/_example/etc/handler-apache2.X.conf lemonldap-ng-$(VERSION)/_example/etc/handler-apache2.conf
	@cp lemonldap-ng-$(VERSION)/_example/etc/manager-apache2.X.conf lemonldap-ng-$(VERSION)/_example/etc/manager-apache2.conf
	@cp lemonldap-ng-$(VERSION)/_example/etc/portal-apache2.X.conf lemonldap-ng-$(VERSION)/_example/etc/portal-apache2.conf
	@cp lemonldap-ng-$(VERSION)/_example/etc/api-apache2.X.conf lemonldap-ng-$(VERSION)/_example/etc/api-apache2.conf
	@cp lemonldap-ng-$(VERSION)/_example/etc/test-apache2.X.conf lemonldap-ng-$(VERSION)/_example/etc/test-apache2.conf
	@rm -rf lemonldap-ng-$(VERSION)/lemonldap-ng-$(VERSION)
	@rm -rf lemonldap-ng-$(VERSION)/dev
	-@find lemonldap-ng-$(VERSION)/ -name node_modules -exec rm -rf '{}' \;
	@$(COMPRESS) lemonldap-ng_$(VERSION).orig.$(COMPRESSSUFFIX) lemonldap-ng-$(VERSION)
	@rm -rf lemonldap-ng-$(VERSION)

zip-dist:
	$(MAKE) dist "COMPRESS=zip -r" COMPRESSSUFFIX=zip

manifest:   configure
	@for i in ${SRCCOMMONDIR} ${SRCHANDLERDIR} ${SRCPORTALDIR} ${SRCMANAGERDIR}; do \
		cd $$i; \
		rm -vf MANIFEST MANIFEST*bak; \
		$(MAKE) manifest; \
		cd -; \
	done

cpan:	clean configure common_cpan handler_cpan portal_cpan manager_cpan
	for i in Common Portal Handler Manager; do \
		$(UNCOMPRESS) Lemonldap-NG-$$i-*.$(COMPRESSSUFFIX) \
			$$($(LISTCOMPRESSED) Lemonldap-NG-$$i-*.$(COMPRESSSUFFIX) |grep META.); \
		mv Lemonldap-NG-$$i-*/META.* lemonldap-ng-$$($(PERL) -e "print lc('$$i')")/; \
		rm -rf Lemonldap-NG-$$i*/; \
		done

debian-local-packages: debian-packages

debian-packages: debian-dist
	mv lemonldap-ng_$(VERSION).orig.$(COMPRESSSUFFIX) /tmp/
	version=$(VERSION) && \
	cd /tmp/ && \
	rm -rf lemonldap-ng-$$version && \
	$(UNCOMPRESS) lemonldap-ng_$$version.orig.$(COMPRESSSUFFIX) && \
	cd lemonldap-ng-$$version && \
	debuild -us -uc

# Developper corner
# -----------------

common_cpan:	common_conf
	@$(MAKE) -C ${SRCCOMMONDIR} dist
	@mv ${SRCCOMMONDIR}/Lemonldap*.gz .

handler_cpan:	handler_conf
	@$(MAKE) -C ${SRCHANDLERDIR} dist
	@mv ${SRCHANDLERDIR}/Lemonldap*.gz .

portal_cpan:		portal_conf
	@$(MAKE) -C ${SRCPORTALDIR} dist
	@mv ${SRCPORTALDIR}/Lemonldap*.gz .

manager_cpan:	manager_conf
	@$(MAKE) -C ${SRCMANAGERDIR} dist
	@mv ${SRCMANAGERDIR}/Lemonldap*.gz .

documentation:
	@if [ "$(SKIP_DOCUMENTATION)" ] ; then \
		echo "Skipped documentation building" ;\
	else \
		sphinx-build -b html -d /tmp/doctrees \
			-Dhtml_theme=bootstrap\
			doc/sources/admin/ doc/pages/documentation/current/ ;\
	fi
	#
	# For the record, to render doc build reproducible, Debian package
	# includes this:
	#
	# # Extract JSON from doc index
	# cat doc/pages/documentation/current/searchindex.js | perl -pe 's/^.*?(\{.*\}).*?$$/$$1/' >debian/index.json
	# # Sort JSON, including arrays
	# jq --compact-output 'walk(if type == "array" then sort else if type == "object" then to_entries | sort_by(.key) | from_entries else . end end)' > debian/searchindex.js <debian/index.json
	# # Insert new JSON in doc index
	# perl -000 -i -pe 'BEGIN{open F,"debian/searchindex.js";$$j=<F>;chomp $$j;close F}s/\{.*\}/$$j/' doc/pages/documentation/current/searchindex.js

website_documentation:
	LLNGSPHINXWEBSITE=1 sphinx-build -b html -d /tmp/doctrees \
		doc/sources/admin/ "$(WEBSITE_DIR)"

test-diff:
	@for file in `find lemonldap-ng-*/lib -type f`; do \
		$(DIFF) $$file `echo $$file|sed -e s/lib/blib\\\/lib/`; \
	done

tidyversion:
	@echo $(PERLTIDY_VERSION)

tidy: clean
	@if perltidy -v|grep "$(PERLTIDY_VERSION)" >/dev/null; then \
		find lemon*/ -type f \( -name '*.pm' -or -name '*.pl' -or -name '*.fcgi' -or -name '*.t' \) -print0 | xargs -t -0 $(PARAXARGS) -n10 perltidy -se -b -bext=/ ;\
	else echo "Wrong perltidy version, please install Perl::Tidy@$(PERLTIDY_VERSION)" ; exit 1 ;\
	fi
	$(MAKE) json

tidy-js: clean
	@find e2e-tests/ \
		 -type f \
		 -name '*.js' \
		! -name 'jq*' \
		! -name 'bootstrap*' \
		! -name '*.min.js' \
		! -name conftree.js \
		 -print \
		 -exec js_beautify -o -s=2 {} \;

html_spelling:
	@for i in $$(find doc/ -type f -name '*.html'); do \
		text=$$(html2text $$i|spellintian --picky); \
		if [ "$$text" != "" ]; then echo "### $$i ###"; echo $$text; fi \
	done

spelling:
	@for i in $$(find * -type f -name '*.pm'); do \
		if grep '=head1' $$i >/dev/null; then \
			text=$$(pod2text $$i|spellintian --picky); \
			if [ "$$text" != "" ]; then echo "### $$i ###"; echo $$text; fi \
		fi \
	done

e2e_cert:
	openssl req -x509 \
		-newkey rsa:2048 \
		-keyout e2e-tests/key.pem \
		-out e2e-tests/cert.pem \
		-days 3650 \
		-nodes \
		-subj "/C=PL/ST=Programming Republic of Perl/O=Security Dept/CN=auth.example.com" \
		-reqexts SAN \
		-extensions SAN \
		-config e2e-tests/openssl.cnf

api_doc: doc/sources/manager-api/config-codegen.json
	@env SWAGGER_CODEGEN=$(SWAGGER_CODEGEN) scripts/openapigenerator.pl