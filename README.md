# nfrastack/container-lemonldap

## About

This repository will build a container with [LemonLDAP::NG](https://lemonldap-ng.org/), an authorization anc access manager supporting multiple protocols and standards. (SAML, OpenID Connect, CAS) served by Nginx.

* Sane defaults to have a working solution by just running the image
* Automatically generates configuration files on startup, or option to use your own
* Option to just use image as a Handler for external servers
* Handler Option to use file base socket or listen on TCP
* Fail2ban Included for blocking brute force attacks.
* Ready to work out the box for SAML, OpenID, 2FA/2OTP
* Additional modules compiled for Redis, Mysql, Postgres, LDAP Session/Config Storage
* Choice of Logging (Console, File, Syslog)

*This is an incredibly complex piece of software and this image tries to get you up and running with sane defaults, you will need to switch eventually over to manually configuring the configuration file when depending on your usage case*

## Maintainer

* [Nfrastack](https://www.nfrastack.com)

## Table of Contents

* [About](#about)
* [Maintainer](#maintainer)
* [Table of Contents](#table-of-contents)
* [Installation](#installation)
  * [Prebuilt Images](#prebuilt-images)
  * [Quick Start](#quick-start)
  * [Persistent Storage](#persistent-storage)
* [Configuration](#configuration)
  * [Environment Variables](#environment-variables)
    * [Base Images used](#base-images-used)
    * [Core Configuration](#core-configuration)
  * [Users and Groups](#users-and-groups)
  * [Networking](#networking)
* [Maintenance](#maintenance)
  * [Shell Access](#shell-access)
* [Support & Maintenance](#support--maintenance)
* [License](#license)

## Prerequisites and Assumptions

* Assumes you are using some sort of SSL terminating reverse proxy such as:
  * [Traefik](https://github.com/tiredofit/docker-traefik)
  * [Nginx](https://github.com/jc21/nginx-proxy-manager)
  * [Caddy](https://github.com/caddyserver/caddy)
* You must have access to create records on your DNS server to be able to setup the demo installation before configuration.

## Installation

### Prebuilt Images

Feature limited builds of the image are available on the [Github Container Registry](https://github.com/nfrastack/container-lemonldap/pkgs/container/container-lemonldap) and [Docker Hub](https://hub.docker.com/r/nfrastack/lemonldap).

To unlock advanced features, one must provide a code to be able to change specific environment variables from defaults. Support the development to gain access to a code.

To get access to the image use your container orchestrator to pull from the following locations:

```
ghcr.io/nfrastack/container-lemonldap:(image_tag)
docker.io/nfrastack/lemonldap:(image_tag)
```

Image tag syntax is:

`<image>:<optional tag>`

Example:

`ghcr.io/nfrastack/container-lemonldap:latest` or

`ghcr.io/nfrastack/container-lemonldap:1.0` or

* `latest` will be the most recent commit
* An otpional `tag` may exist that matches the [CHANGELOG](CHANGELOG.md) - These are the safest
* If there are multiple distribution variations it may include a version - see the registry for availability

Have a look at the container registries and see what tags are available.

#### Multi-Architecture Support

Images are built for `amd64` by default, with optional support for `arm64` and other architectures.

### Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [compose.yml](examples/compose.yml) that can be modified for your use.

* Map persistent storage for access to configuration and data files for backup.
* Set various environment variables to understand the capabilities of this image.

### Persistent Storage

The following directories are used for configuration and can be mapped for persistent storage.

| Directory                         | Description                                                                          |
| --------------------------------- | ------------------------------------------------------------------------------------ |
| `/etc/lemonldap-ng/`              | (Optional) - LemonLDAP core configuration files. Auto Generates on Container startup |
| `/var/lib/lemonldap-ng/conf`      | Actual Configuration of LemonLDAP (lmConf-X.js files)                                |
| `/var/lib/lemonldap-ng/sessions`  | (Optional) - Storage of Sessions of users                                            |
| `/var/lib/lemonldap-ng/psessions` | (Optional) - Storage of Sessions of users                                            |
| `/assets/custom`                  | Ability to overwrite themes/inject into image upon bootup for theming /etc.          |
| `/www/logs`                       | Log files for individual services                                                    |

## Configuration

### Environment Variables

#### Base Images used

This image relies on a customized base image in order to work.
Be sure to view the following repositories to understand all the customizable options:

| Image                                                   | Description      |
| ------------------------------------------------------- | ---------------- |
| [OS Base](https://github.com/nfrastack/container-base/) | Base Image       |
| [Nginx](https://github.com/nfrastack/container-nginx/)  | Web Server Image |

Below is the complete list of available options that can be used to customize your installation.

* Variables showing an 'x' under the `Advanced` column can only be set if the containers advanced functionality is enabled.

There are a huge amount of configuration variables and it is recommended that you get comfortable for a few hours with the [LemonLDAP::NG Documentation](https://lemonldap-ng.org/documentation/2.0/start)

You will eventually based on your usage case switch over to `SETUP_TYPE=MANUAL` and edit your own `lemonldap-ng.ini`. While I've tried to make this as easy to use as possible, once in production you'll find much better success with large implementations with this approach.

By Default this image is ready to run out of the box, without having to alter any of the settings with the exception of the `_HOSTNAME` vars. You can also change the majority of these settings from within the Manager. There are instances where these variables would want to be set if you are running multiple handlers or need to enforce a Global Setting for one specific installation.

| Parameter          | Description                                                                                    | Default               |
| ------------------ | ---------------------------------------------------------------------------------------------- | --------------------- |
| `SETUP_TYPE`       | `AUTO` to auto generate lemonldap-ng.ini on bootup, otherwise let admin control configuration. | `AUTO`                |
| `MODE`             | Type of Install - `HANDLER` for handler duties only, `MASTER` for Portal, Manager, Handler     | `MASTER`              |
|                    | Or any combo of `API`, `HANDLER`, `MANAGER`, `PORTAL`, `TEST`                                  |                       |
| `CONFIG_TYPE`      | Configuration type (`FILE`, `REST`) -                                                          | `FILE`                |
| `DOMAIN_NAME`      | Your domain name e.g. `example.org`                                                            |                       |
| `API_HOSTNAME`     | FQDN for Manager API e.g. `api.manager.sso.example.org`                                        |                       |
| `MANAGER_HOSTNAME` | FQDN for Manager e.g. `manager.sso.example.org`                                                |                       |
| `PORTAL_HOSTNAME`  | FQDN for public portal/main URL e.g. `sso.example.org`                                         |                       |
| `HANDLER_HOSTNAME` | FQDN for Configuration reload URL e.g. `handler.sso.example.org`                               |                       |
| `TEST_HOSTNAME`    | FQDN for test URL to prove that LemonLDAP works e.g. `test.sso.example.org`                    |                       |
| `LOG_FILE`         | LL:NG main log file                                                                            | `lemonldap.log`       |
| `LOG_FILE_USER`    | LL:NG User log file                                                                            | `lemonldap-user.log`  |
| `LOG_PATH`         | Log Path                                                                                       | `/www/logs/lemonldap` |
| `LOG_TYPE`         | How to Log - Options `CONSOLE` or `FILE`                                                       | `CONSOLE`             |
| `LOG_LEVEL`        | LogLevel - Options `warn, notice, info, error, debug`                                          | `info`                |
| `USER_LOG_TYPE`    | How to Log User actions - Options `CONSOLE, FILE, SYSLOG`                                      | `CONSOLE`             |

#### REST Settings

Depending if `REST` was chosen for `CONFIG_TYPE`, these variables would be used.

| Parameter   | Description                                                                      | Default | `_FILE` |
| ----------- | -------------------------------------------------------------------------------- | ------- | ------- |
| `REST_HOST` | Hostname of Master REST Server e.g. `https://sso.example.com/index.psgi/config/` |         | x       |
| `REST_USER` | Username to fetch Configuration Information                                      |         | x       |
| `REST_PASS` | Password to fetch Configuration Information                                      |         | x       |

#### Portal Settings

| Parameter                    | Description                                                                                         | Default                                    | `_FILE` |
| ---------------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------ | ------- |
| `PORTAL_CACHE_TYPE`          | Only Cache Type available for now -                                                                 | `FILE`                                     |         |
| `PORTAL_TEMPLATE_DIR`        |                                                                                                     | `/usr/share/lemonldap-ng/portal/templates` |         |
| `PORTAL_LOG_TYPE`            | Override Portal Log - Options `CONSOLE` or `FILE`                                                   | `CONSOLE`                                  |         |
| `PORTAL_LOG_LEVEL`           | Override Portal LogLevel - Options `warn, notice, info, error, debug`                               | `info`                                     |         |
| `PORTAL_USER_LOG_TYPE`       | Override Portal Log User actions - Options `CONSOLE` or `FILE`                                      | `CONSOLE`                                  |         |
| `PORTAL_ENABLE_GITLAB_OAUTH` | Redirect requests from Gitlab to support OAuth for Mattermost Authentication                        | `FALSE`                                    |         |
| `PORTAL_ENABLE_REST`         | Allow REST access to the Portal -                                                                   | `FALSE`                                    |         |
| `PORTAL_REST_ALLOWED_IPS`    | If above options enabled, provide comma seperated list of IP/Network to allow access                | `0.0.0.0/0`                                |         |
| `PORTAL_REST_AUTH_FILE`      | Populate this file manually or with environment variables for REST authentication (htpasswd format) | `/etc/lemonldap-ng/portal-rest.htpasswd`   |         |
| `PORTAL_REST_USER01`         | Username for REST Authentication                                                                    |                                            | x       |
| `PORTAL_REST_PASS01`         | Password for REST Authentication                                                                    |                                            | x       |
| `PORTAL_REST_USER02`         | Username for REST Authentication                                                                    |                                            | x       |
| `PORTAL_REST_PASS02`         | Password for REST Authentication                                                                    |                                            | x       |
| `PORTAL_REST_USER...`        | Username for REST Authentication                                                                    |                                            | x       |
| `PORTAL_REST_PASS...`        | Password for REST Authentication                                                                    |                                            | x       |
| `PORTAL_ENABLE_STATUS`       | Configure nginx to serve status page                                                                | `FALSE`                                    |         |
| `PORTAL_STATUS_ALLOWED_IPS`  | If above options enabled, provide comma seperated list of IP/Network to allow access                | `0.0.0.0/0`                                |         |
| `ENABLE_IMPERSONATION`       | If you wish to allow impersonation using a seperate theme set to `TRUE`                             | `FALSE`                                    |         |
| `IMPERSONATE_HOSTNAME`       | Hostname to use to load the custom impersonation theme                                              |                                            |         |
| `IMPERSONATE_THEME`          | Theme to use to load the impersonation theme                                                        |                                            |         |

* With impersonation, if you enable it, it will add a new field to your login screen, which may not be what you want if this is a production system. You will need to create two custom themes (one as a replica of bootstrap, and one for impersonation). In the custom theme, make modifications to `login.tpl` to stop it from loading impersonation.tpl, yet in your impersonation theme, leave it in there. Then, when one of your admin/support team visits the custom `IMPERSONATE_HOSTNAME` you have defined it will load the full theme with allows to impersonate, where as the default theme will not show this.

#### Handler Settings

| Parameter                           | Description                                                                                                                                            | Default                 |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------- |
| `CACHE_TYPE`                        | Session Cache type (`FILE` only available for now) -                                                                                                   | `FILE`                  |
| `CACHE_TYPE_FILE_NAMESPACE`         |                                                                                                                                                        | `lemonldap-ng-config`   |
| `CACHE_TYPE_FILE_EXPIRY`            |                                                                                                                                                        | `600`                   |
| `CACHE_TYPE_FILE_DIR_MASK`          |                                                                                                                                                        | `007`                   |
| `CACHE_TYPE_FILE_PATH`              |                                                                                                                                                        | `/tmp`                  |
| `CACHE_TYPE_FILE_DEPTH`             |                                                                                                                                                        | `0`                     |
| `HANDLER_ALLOWED_IPS`               | If you need to access access to `/reload` other than localhost add a comma seperated list or hosts or networks here e.g. `172.16.0.0/12,192.168.0.253` |
| `HANDLER_CACHE_TYPE`                |                                                                                                                                                        | `FILE`                  |
| `HANDLER_CACHE_TYPE_FILE_NAMESPACE` |                                                                                                                                                        | `lemonldap-ng-sessions` |
| `HANDLER_CACHE_TYPE_FILE_EXPIRY`    |                                                                                                                                                        | `600`                   |
| `HANDLER_CACHE_TYPE_FILE_DIR_MASK`  |                                                                                                                                                        | `007`                   |
| `HANDLER_CACHE_TYPE_FILE_PATH`      |                                                                                                                                                        | `/tmp`                  |
| `HANDLER_CACHE_TYPE_FILE_DEPTH`     |                                                                                                                                                        | `3`                     |
| `HANDLER_SOCKET_TCP_ENABLE`         | Enable TCP Connections to socket instead of /var/run/llng-fastcgi-server/llng-fastcgi.sock -                                                           | `TRUE`                  |
| `HANDLER_SOCKET_TCP_PORT`           | Port to listen on for Handler                                                                                                                          | `2884`                  |
| `HANDLER_STATUS`                    | Allow Status on Handler                                                                                                                                | `TRUE`                  |
| `HANDLER_REDIRECT_ON_ERROR`         |                                                                                                                                                        | `TRUE`                  |
| `HANDLER_LOG_TYPE`                  | Override Handler Log - Options `CONSOLE, FILE, SYSLOG`                                                                                                 | `CONSOLE`               |
| `HANDLER_LOG_LEVEL`                 | Override Handler LogLevel - Options `warn, notice, info, error, debug`                                                                                 | `info`                  |
| `HANDLER_PROCESSES`                 | Amount of LLNG Handler processes to spawn                                                                                                              | `7`                     |
| `HANDLER_USER_LOG_TYPE`             | Override Handler Log User actions - Options `CONSOLE` or `FILE`                                                                                        | `CONSOLE`               |

#### Manager Options

| Parameter                 | Description                                                                                                                                      | Default                                     |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------- |
| `MANAGER_PROTECTION`      |                                                                                                                                                  | `manager`                                   |
| `MANAGER_LOG_LEVEL`       |                                                                                                                                                  | `warn`                                      |
| `MANAGER_STATIC_PREFIX`   |                                                                                                                                                  | `/static`                                   |
| `MANAGER_TEMPLATE_DIR`    |                                                                                                                                                  | `/usr/share/lemonldap-ng/manager/templates` |
| `MANAGER_LANGUAGE`        |                                                                                                                                                  | `en`                                        |
| `MANAGER_ENABLE_API`      | Enable Manager API -                                                                                                                             | `FALSE`                                     |
| `MANAGER_ALLOWED_IPS`     | If you need to access access to API other than localhost add a comma seperated list or hosts or networks here e.g. `172.16.0.0/12,192.168.0.253` |
| `MANAGER_ENABLED_MODULES` |                                                                                                                                                  | `"conf, sessions, notifications, 2ndFA"`    |
| `MANAGER_LOG_TYPE`        | Override Manager Log - Options `CONSOLE` or `FILE`                                                                                               | `CONSOLE`                                   |
| `MANAGER_LOG_LEVEL`       | Override Manager LogLevel - Options `warn, notice, info, error, debug`                                                                           | `info`                                      |
| `MANAGER_USER_LOG_TYPE`   | Override Manager Log User actions - Options `CONSOLE` or `FILE`                                                                                  | `CONSOLE`                                   |

## Users and Groups

| Type  | Name   | ID   |
| ----- | ------ | ---- |
| User  | `llng` | 2884 |
| Group | `llng` | 2884 |

### Networking

| Port   | Protocol | Description  |
| ------ | -------- | ------------ |
| `80`   | tcp      | HTTP (Nginx) |
| `2884` | tcp      | LLNG Handler |

* * *

## Maintenance

### Shell Access

For debugging and maintenance, `bash` and `sh` are available in the container.

## Support & Maintenance

* For community help, tips, and community discussions, visit the Discussions board.
* For personalized support or a support agreement, see Nfrastack Support.
* To report bugs, submit a Bug Report. Usage questions will be closed as not-a-bug.
* Feature requests are welcome, but not guaranteed. For prioritized development, consider a support agreement.
* Updates are best-effort, with priority given to active production use and support agreements.

## References

* <https://lemonldap-ng.org>

## License

This project is licensed under the MIT License - see the LICENSE file for details.
