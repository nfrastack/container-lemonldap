# nfrastack/container-lemonldap

## About

This repository will build a container for [LemonLDAP::NG](https://lemonldap-ng.org/), an authorization and access manager supporting multiple protocols and standard (SAML, OpenID Connect, CAS) served by Nginx.

* Sane defaults to have a working solution by just running the image
* Automatically generates configuration files on startup, or option to use your own
* Option to just use image as a Handler for external servers
* Handler Option to use file base socket or listen on TCP
* Fail2ban Included for blocking brute force attacks.
* Ready to work out the box for SAML, OpenID, 2FA/2OTP
* Additional modules compiled for Redis, Mysql, Postgres, LDAP Session/Config Storage
* Choice of Logging (Console, File, Syslog)

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
    * [Core Variables](#core-variables)
    * [Configuration Variables](#configuration-variables)
    * [Socket & Networking Variables](#socket--networking-variables)
    * [Logging Variables](#logging-variables)
    * [Handler Variables](#handler-variables)
    * [Manager Variables](#manager-variables)
    * [Manager API Variables](#manager-api-variables)
    * [Portal Variables](#portal-variables)
    * [Test Site Variables](#test-site-variables)
    * [Session Backends](#session-backends)
  * [Users and Groups](#users-and-groups)
  * [Networking](#networking)
* [Maintenance](#maintenance)
  * [Shell Access](#shell-access)
* [Support & Maintenance](#support--maintenance)
* [References](#references)
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

```bash
ghcr.io/nfrastack/container-lemonldap:(image_tag)
docker.io/nfrastack/lemonldap:(image_tag)
```

Image tag syntax is:

`<image>:<optional tag>`

Example:

`ghcr.io/nfrastack/container-lemonldap:latest` or

`ghcr.io/nfrastack/container-lemonldap:1.0` or

* `latest` will be the most recent commit
* An optional `tag` may exist that matches the [CHANGELOG](CHANGELOG.md) - These are the safest
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

| Directory  | Description                                                                              |
| ---------- | ---------------------------------------------------------------------------------------- |
| `/cache/`  | (Optional) - Optional Cache folder                                                       |
| `/config/` | (Optional) - LemonLDAP instance configuration files. Auto Generates on Container startup |
| `/data/`   | Global configuration, Portal sessions, Portal Notifications, other volatile storage      |

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

You will eventually based on your usage case switch over to `SETUP_TYPE=MANUAL` and edit your own `lemonldap-ng.ini`/`instance.cfg`. While I've tried to make this as easy to use as possible, once in production you'll find much better success with large implementations with this approach.

By Default this image is ready to run out of the box, without having to alter any of the settings with the exception of the `_HOSTNAME` vars. You can also change the majority of these settings from within the Manager. There are instances where these variables would want to be set if you are running multiple handlers or need to enforce a Global Setting for one specific installation.

#### Core Variables

| Parameter     | Description                                                                              | Default  | `_FILE` |
| ------------- | ---------------------------------------------------------------------------------------- | -------- | ------- |
| `SETUP_TYPE`  | `AUTO` to auto generate lemonldap-ng.ini on bootup, manually control configuration files | `AUTO`   |         |
| `MODE`        | Install mode comma seperated  `AIO` = all                                                | `AIO`    | x       |
|               | Options: `API` `HANDLER` `HANDLER` `MANAGER` `TEST`                                      |          |         |
| `DATA_PATH`   | Data path                                                                                | `/data/` |         |
| `DOMAIN_NAME` | Your domain name eg `example.com`                                                        |          | x       |
| `LLNG_USER`   | User to run operations as                                                                | `llng`   |         |
| `LLNG_GROUP`  | Group for `LLNG_USER`                                                                    | `llng`   |         |

#### Configuration Variables

| Parameter                                    | Description                                                                    | Default                  | `_FILE` |
| -------------------------------------------- | ------------------------------------------------------------------------------ | ------------------------ | ------- |
| `CONFIG_CHECK_INTERVAL`                      | Interval for config checks in seconds                                          | `1`                      |         |
| `CONFIG_INSTANCE_PATH`                       | Instance config path                                                           | `/config/`               |         |
| `CONFIG_INSTANCE_FILE`                       | Instance config file                                                           | `instance.cfg`           |         |
| `CONFIG_GLOBAL_TYPE`                         | Global config type `FILE` or `REST`                                            | `FILE`                   |         |
| `CONFIG_GLOBAL_CONFIG_TIMEOUT`               | Global config timeout in seconds                                               | `10`                     |         |
| `CONFIG_GLOBAL_FILE_PATH`                    | Global file path                                                               | `${DATA_PATH}/conf`      |         |
| `CONFIG_GLOBAL_FILE_PRETTY_PRINT`            | Pretty print config file                                                       | `TRUE`                   |         |
| `CONFIG_GLOBAL_ENABLE_SECRETS`               | Enable Secrets / Overlay mode                                                  | `TRUE`                   |         |
| `CONFIG_GLOBAL_SECRETS_PATH`                 | Path name to store file per parameter (filename == keyname)                    | `/var/run/secrets/llng/` | x       |
| `CONFIG_GLOBAL_SECRETS_READONLY`             | Allow configuration to write to secrets parameters                             | `FALSE`                  |         |
| `CONFIG_GLOBAL_SECRETS_REAL_TYPE`            | The real configuration backend used to support secrets/overlay                 | `${CONFIG_GLOBAL_TYPE}`  |         |
| `CONFIG_GLOBAL_REST_HOST`                    | Hostname of Portal REST Server eg `https://sso.example.com/index.psgi/config/` |                          | x       |
| `CONFIG_GLOBAL_REST_USER`                    | Username to fetch Configuration Information                                    |                          | x       |
| `CONFIG_GLOBAL_REST_PASS`                    | Password to fetch Configuration Information                                    |                          | x       |
| `CONFIG_GLOBAL_CACHE_TYPE`                   | Global cache type `FILE` `NONE`                                                | `FILE`                   |         |
| `CONFIG_GLOBAL_CACHE_FILE_PATH`              | Global cache file path                                                         | `/cache/`                |         |
| `CONFIG_GLOBAL_CACHE_FILE_NAMESPACE`         | Global cache file namespace                                                    | `config`                 |         |
| `CONFIG_GLOBAL_CACHE_FILE_DEPTH`             | Global cache file depth                                                        | `0`                      |         |
| `CONFIG_GLOBAL_CACHE_FILE_DIR_MASK`          | Global cache file dir mask                                                     | `007`                    |         |
| `CONFIG_GLOBAL_CACHE_FILE_EXPIRY`            | Global cache file expiry                                                       | `600`                    |         |
| `CONFIG_GLOBAL_SCHEDULE_PURGE_CENTRAL_CACHE` | Cron expression to purge central cache (or `FALSE` to disable)                 | `*/10 * * * *`           |         |
| `CONFIG_GLOBAL_SCHEDULE_ROTATE_OIDC_KEYS`    | Cron expresstion to rotate OIDC keys (or `FALSE` to disable)                   | `5 5 * * 6`              |         |
| `CONFIG_GLOBAL_SCHEDULE_PURGE_LOCAL_CACHE`   | Cron expression to purge local cache (or `FALSE` to disable)                   | `1 * * * *`              |         |
| `CONFIG_ENABLE_CROSS_DOMAIN`                 | (instance) Enable Cross Domain Access (CDA) `TRUE`/`FALSE`                     |                          |         |
| `CONFIG_USE_SAFE_JAIL`                       | (instance) Use safe jail                                                       | `TRUE`                   |         |

#### Socket & Networking Variables

| Parameter                 | Description                                          | Default                                          |
| ------------------------- | ---------------------------------------------------- | ------------------------------------------------ |
| `DEFAULT_SOCKET_TYPE`     | Default socket type (`tcp`, `path`/`unix` or `both`) | `tcp`                                            |
| `DEFAULT_SOCKET_PATH`     | Default UNIX socket path                             | `/var/run/llng-fastcgi-server/llng-fastcgi.sock` |
| `DEFAULT_SOCKET_TCP_HOST` | Default TCP socket host                              | `127.0.0.1`                                      |
| `DEFAULT_SOCKET_TCP_PORT` | Default TCP socket port                              | `2884`                                           |

>> If `API`, `HANDLER`, `MANAGER`, `PORTAL`, `TEST` `_SOCKET` not set these values will be used.
>> If you wish to override use the appropriate variables with the values of either
>> `unix://path.sock` or `ip:port`

#### Logging Variables

| Parameter       | Description                                                   | Default              |
| --------------- | ------------------------------------------------------------- | -------------------- |
| `LOG_PATH`      | Logfile path                                                  | `/logs/lemonldap/`   |
| `LOG_LEVEL`     | Global log level (`warn`, `notice`, `info`, `error`, `debug`) | `notice`             |
| `LOG_TYPE`      | Global log type (`CONSOLE`, `FILE`, `SYSLOG`)                 | `CONSOLE`            |
| `LOG_FILE`      | Main log file name                                            | `lemonldap.log`      |
| `LOG_USER_TYPE` | User log type (`CONSOLE`, `FILE`, `SYSLOG`)                   | `CONSOLE`            |
| `LOG_USER_FILE` | User log file name                                            | `lemonldap-user.log` |

#### Instance Settings

| Parameter                                | Description                                                                 | Default                            | `_FILE` |
| ---------------------------------------- | --------------------------------------------------------------------------- | ---------------------------------- | ------- |
| `INSTANCE_SESSIONS_ACTIVE_TYPE`          | Instance active session type. See [Session Backends](#session-backends)     | `FILE`                             |         |
| `INSTANCE_SESSIONS_ACTIVE_FILE_PATH`     | Instance active session path                                                | `${DATA_PATH}/sessions/active`     |         |
| `INSTANCE_SESSIONS_PERSISTENT_TYPE`      | Instance persistent session type. See [Session Backends](#session-backends) | `NONE`                             |         |
| `INSTANCE_SESSIONS_PERSISTENT_FILE_PATH` | Instance persistent session path                                            | `${DATA_PATH}/sessions/persistent` |         |
| `INSTANCE_SESSIONS_CACHE_TYPE`           | Instance sessions cache type `FILE` `NONE`                                  | `FILE`                             |         |
| `INSTANCE_SESSIONS_CACHE_FILE_PATH`      | Instance sessions cache file path                                           | `/cache/`                          |         |
| `INSTANCE_SESSIONS_CACHE_FILE_NAMESPACE` | Instance sessions cache file namespace                                      | `sessions`                         |         |
| `INSTANCE_SESSIONS_CACHE_FILE_DEPTH`     | Instance sessions cache file depth                                          | `3`                                |         |
| `INSTANCE_SESSIONS_CACHE_FILE_DIR_MASK`  | Instance sessions cache file dir mask                                       | `007`                              |         |
| `INSTANCE_SESSIONS_CACHE_FILE_EXPIRY`    | Instance sessions cache file expiry                                         | `600`                              |         |

>> These options affect both HANDLER and PORTAL configuration. If you wish to override them specifically then use the specific `HANDLER_SESSIONS..` or `PORTAL_SESSIONS..` overrides

#### Handler Variables

For usage with `MODE=HANDLER`

| Parameter                               | Description                                                                                                   | Default                                     | `_FILE` |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ------------------------------------------- | ------- |
| `HANDLER_LISTEN_SOCKET_TYPE`            | Handler socket type (`tcp`, `path`/`unix` or `both`)                                                          | `tcp`                                       |         |
| `HANDLER_LISTEN_SOCKET_PATH`            | Handler Listen UNIX socket path                                                                               | `${DEFAULT_SOCKET_PATH}`                    | x       |
| `HANDLER_LISTEN_SOCKET_TCP_PORT`        | Handler Listen TCP port port                                                                                  | `${DEFAULT_SOCKET_TCP_PORT}`                | x       |
| `HANDLER_PROCESSES`                     | Amount of LLNG Handler processes to spawn `auto` for the amount of CPU                                        | `2`                                         |         |
| `HANDLER_ENABLE_NGINX`                  | Enable Nginx Proxying support                                                                                 | `TRUE`                                      |         |
| `HANDLER_LOG_TYPE`                      | Override Log type (`CONSOLE`, `FILE`, `SYSLOG`)                                                               |                                             |         |
| `HANDLER_LOG_LEVEL`                     | Override Log level (`warn`, `notice`, `info`, `error`, `debug`)                                               |                                             |         |
| `HANDLER_ALLOWED_IPS`                   | Comma seperated list or IP or networks - localhost is already allowed                                         |                                             | x       |
| `HANDLER_REDIRECT_ON_ERROR`             | Handler redirect on error                                                                                     | `TRUE`                                      |         |
| `HANDLER_STATUS`                        | Handler status reporting                                                                                      | `TRUE`                                      |         |
| `HANDLER_SESSIONS_CACHE_TYPE`           | Override Instance or Global Config Handler sessions cache type `FILE` `NONE`                                  | `NONE`                                      |         |
| `HANDLER_SESSIONS_CACHE_FILE_PATH`      | Override Instance or Global Config Handler sessions cache file path                                           | `${INSTANCE_SESSIONS_CACHE_FILE_PATH}`      |         |
| `HANDLER_SESSIONS_CACHE_FILE_NAMESPACE` | Override Instance or Global Config Handler sessions cache file namespace                                      | `${INSTANCE_SESSIONS_CACHE_FILE_NAMESPACE}` |         |
| `HANDLER_SESSIONS_CACHE_FILE_DEPTH`     | Override Instance or Global Config Handler sessions cache file depth                                          | `${INSTANCE_SESSIONS_CACHE_FILE_DEPTH}`     |         |
| `HANDLER_SESSIONS_CACHE_FILE_DIR_MASK`  | Override Instance or Global Config Handler sessions cache file dir mask                                       | `${INSTANCE_SESSIONS_CACHE_FILE_DIR_MASK}`  |         |
| `HANDLER_SESSIONS_CACHE_FILE_EXPIRY`    | Override Instance or Global Config Handler sessions cache file expiry                                         | `${INSTANCE_SESSIONS_CACHE_FILE_EXPIRY}`    |         |
| `HANDLER_SESSIONS_ACTIVE_TYPE`          | Override Instance or Global Config Handler active session type. See [Session Backends](#session-backends)     | `NONE`                                      |         |
| `HANDLER_SESSIONS_ACTIVE_FILE_PATH`     | Override Instance or Global Config Handler active session path                                                | `${INSTANCE_SESSIONS_ACTIVE_FILE_PATH}`     |         |
| `HANDLER_SESSIONS_PERSISTENT_TYPE`      | Override Instance or Global Config Handler persistent session type. See [Session Backends](#session-backends) | `NONE`                                      |         |
| `HANDLER_SESSIONS_PERSISTENT_FILE_PATH` | Override Instance or Global Config Handler persistent session path                                            | `${INSTANCE_SESSIONS_PERSISTENT_FILE_PATH}` |         |

#### Manager Variables

For usage with `MODE=MANAGER`

| Parameter                     | Description                                                     | Default                                            | `_FILE` |
| ----------------------------- | --------------------------------------------------------------- | -------------------------------------------------- | ------- |
| `MANAGER_HOSTNAME`            | Manager Hostname eg manager.sso.example.com                     |                                                    | x       |
| `MANAGER_PROTECTION`          | Manager protection Options:                                     | `manager`                                          | x       |
|                               | `authenticate` `manager` `<rule>` `none`                        |                                                    |         |
| `MANAGER_SOCKET`              | Manager socket override                                         |                                                    | x       |
| `MANAGER_ENABLED_MODULES`     | Enabled modules comma seperated: Options: `conf`                | `conf, sessions, notifications, 2ndFA, viewer`     | x       |
|                               | `sessions` `notifications` `2ndFA` `viewer`                     |                                                    |         |
| `MANAGER_LANGUAGE`            | Manager language comma seperated - Options:  `en` `fr` `it`     | `en`                                               |         |
|                               | `vi` `ar` `tr` `pl` `zh_TW` `es` `he` `pt_BR` `ru`              |                                                    |         |
| `MANAGER_LOG_TYPE`            | Override Log type (`CONSOLE`, `FILE`, `SYSLOG`)                 |                                                    |         |
| `MANAGER_LOG_LEVEL`           | Override Log level (`warn`, `notice`, `info`, `error`, `debug`) |                                                    |         |
| `MANAGER_VIEWER_ALLOW_BROWSE` | Allow rule for browsing in viewer module                        | `0`                                                | x       |
| `MANAGER_VIEWER_ALLOW_DIFF`   | Allow rule for diff review  in viewer module                    | `0`                                                | x       |
| `MANAGER_VIEWER_HIDDEN_KEYS`  | Hidden keys in viewer module                                    | `samlIDPMetaDataNodes samlSPMetaDataNodes`         | x       |
|                               |                                                                 | `managerPassword ManagerDn`                        |         |
|                               |                                                                 | `globalStorageOptions persistentStorageOptions`    |         |
| `MANAGER_INSTANCE_NAME`       | Instance Name eg 'llng' to display in manager                   |                                                    | x       |
| `MANAGER_CUSTOM_PORTAL_URL`   | Custom Portal URL in Manager header                             |                                                    | x       |
| `MANAGER_STATIC_PREFIX`       | Manager static prefix                                           | `/static`                                          |         |
| `MANAGER_CSS_PATH`            | Manager CSS path                                                | `/usr/share/lemonldap-ng/manager/static/css`       |         |
| `MANAGER_CUSTOM_CSS_FILE`     | Custom Manager CSS path+file to use                             |                                                    |         |
| `MANAGER_LANGUAGE_PATH`       | Manager Language path                                           | `/usr/share/lemonldap-ng/manager/static/languages` |         |
| `MANAGER_LOGOS_PATH`          | Manager Logos path                                              | `/usr/share/lemonldap-ng/manager/static/logos`     |         |
| `MANAGER_TEMPLATE_PATH`       | Manager Template path                                           | `/usr/share/lemonldap-ng/manager/templates`        |         |

#### Manager API Variables

For usage with `MODE=API`

| Parameter         | Description                                    | Default | `_FILE` |
| ----------------- | ---------------------------------------------- | ------- | ------- |
| `API_HOSTNAME`    | API Hostname eg manager.api.sso.example.com    |         | x       |
| `API_SOCKET`      | API socket override                            |         | x       |
| `API_ALLOWED_IPS` | Comma seperated list of IPs, networks or hosts |         | x       |
|                   | eg `172.16.0.0/12,192.168.0.253`               |         |         |

#### Portal Variables

For usage with `MODE=PORTAL`

| Parameter                                    | Description                                                                                           | Default                                                    | `_FILE` |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- | ------- |
| `PORTAL_HOSTNAME`                            | Portal Hostname eg sso.example.com                                                                    |                                                            | x       |
| `CONTAINER_ENABLE_FIREWALL`                  | Enable Firewall Features for Fail2Ban                                                                 | `FALSE`                                                    |         |
| `CONTAINER_ENABLE_FAIL2BAN`                  | Enable Fail2Ban for Portal                                                                            | `FALSE`                                                    |         |
| `PORTAL_SOCKET`                              | Portal socket override                                                                                |                                                            | x       |
| `PORTAL_LOG_TYPE`                            | Override Log type (`CONSOLE`, `FILE`, `SYSLOG`)                                                       |                                                            |         |
| `PORTAL_LOG_LEVEL`                           | Override Log level (`warn`, `notice`, `info`, `error`, `debug`)                                       |                                                            |         |
| `PORTAL_LANGUAGE`                            | Portal language Options: `en` `fr` `it` `vi`                                                          | `en`                                                       |         |
|                                              | `ar` `tr` `pl` `zh_TW` `es` `he` `pt_BR` `ru`                                                         |                                                            |         |
| `PORTAL_CAPTCHA_PATH`                        | Portal captcha path                                                                                   | `${DATA_PATH}/captcha`                                     |         |
| `PORTAL_ICONS_PATH`                          | Portal icons path                                                                                     | `/usr/share/lemonldap-ng/portal/static/common/icons`       |         |
| `PORTAL_APPS_PATH`                           | Portal App Icons path                                                                                 | `/usr/share/lemonldap-ng/portal/static/common/apps`        |         |
| `PORTAL_BACKGROUNDS_PATH`                    | Portal Backgrounds                                                                                    | `/usr/share/lemonldap-ng/portal/static/common/backgrounds` |
|                                              |
| `PORTAL_LOGOS_PATH`                          | Portal Logos path                                                                                     | `/usr/share/lemonldap-ng/portal/static/common/logos`       |         |
| `PORTAL_LANGUAGE_PATH`                       | Portal Language path                                                                                  | `/usr/share/lemonldap-ng/portal/static/languages`          |         |
| `PORTAL_LANGUAGE_<LANG>_FILE`                | Path to individual language file for override                                                         |                                                            |         |
| `PORTAL_TEMPLATES_PATH`                      | Portal Templates path                                                                                 | `/usr/share/lemonldap-ng/portal/templates`                 |         |
| `PORTAL_STATIC_PATH`                         | Portal static path                                                                                    | `/usr/share/lemonldap-ng/portal/static`                    |         |
| `PORTAL_STATIC_PREFIX`                       | Portal static prefix                                                                                  | `/static`                                                  |         |
| `PORTAL_TEMPLATE_BOOTSTRAP_PATH`             | Portal Bootstrap template path                                                                        | `/usr/share/lemonldap-ng/portal/templates/bootstrap`       |         |
| `PORTAL_TEMPLATE_BOOTSTRAP_STATIC_PATH`      | Portal Bootstrap static path                                                                          | `/usr/share/lemonldap-ng/portal/static/bootstrap`          |         |
| `PORTAL_TEMPLATE_COMMON_PATH`                | Portal Common template path                                                                           | `/usr/share/lemonldap-ng/portal/templates/common`          |         |
| `PORTAL_TEMPLATE_COMMON_STATIC_PATH`         | Portal Common static path                                                                             | `/usr/share/lemonldap-ng/portal/templates/static/common`   |         |
| `PORTAL_TEMPLATE_CUSTOM_PATH`                | Replace `_CUSTOM_` with the name of your template. This will create a                                 |                                                            |         |
|                                              | symbolic lowercase link of the name in your `PORTAL_TEMPLATES_PATH`                                   |                                                            |         |
|                                              | that can be referenced for use withihn the manager or config                                          |                                                            |         |
| `PORTAL_TEMPLATE_CUSTOM_STATIC_PATH`         | As above, the location of static folder                                                               |                                                            |         |
| `PORTAL_ENABLE_GITLAB_OAUTH`                 | Enable Gitlab OAuth for portal                                                                        | `FALSE`                                                    |         |
| `PORTAL_SESSIONS_ACTIVE_TYPE`                | Override Instance or Global Config active session type. See [Session Backends](#session-backends)     | `NONE`                                                     |         |
| `PORTAL_SESSIONS_ACTIVE_FILE_PATH`           | Active session path (when `TYPE=FILE`)                                                                | `${INSTANCE_SESSIONS_ACTIVE_FILE_PATH}`                    |         |
| `PORTAL_SESSIONS_ACTIVE_DB_HOST`             | Database / Redis server hostname or IP (SQL and Redis backends)                                       |                                                            | x       |
| `PORTAL_SESSIONS_ACTIVE_DB_PORT`             | Server port - optional, driver/Redis default used if unset                                            |                                                            | x       |
| `PORTAL_SESSIONS_ACTIVE_DB_NAME`             | Database name (SQL backends) or Redis database number (Redis backend)                                 |                                                            | x       |
| `PORTAL_SESSIONS_ACTIVE_DB_USER`             | Username - not used for `SQLITE` or `REDIS` (SQL backends)                                            |                                                            | x       |
| `PORTAL_SESSIONS_ACTIVE_DB_PASS`             | Password (SQL and Redis backends)                                                                     |                                                            | x       |
| `PORTAL_SESSIONS_ACTIVE_DB_INDEX`            | Fields to index (SQL Browseable and Redis backends)                                                   |                                                            |         |
| `PORTAL_SESSIONS_ACTIVE_DB_DSN`              | Full DSN string - overrides `DB_HOST`/`DB_PORT`/`DB_NAME` if set (SQL backends)                       |                                                            | x       |
| `PORTAL_SESSIONS_ACTIVE_DB_TABLE`            | Table name (SQL backends)                                                                             | `sessions`                                                 |         |
| `PORTAL_SESSIONS_ACTIVE_DB_COMMIT`           | Commit flag - mandatory for Postgres backends                                                         | `1`                                                        |         |
| `PORTAL_SESSIONS_ACTIVE_REDIS_SOCK`          | Redis UNIX socket path - alternative to `DB_HOST` (Redis backend)                                     |                                                            | x       |
| `PORTAL_SESSIONS_ACTIVE_REDIS_SENTINELS`     | Comma-separated Sentinel list (Redis backend)                                                         |                                                            |         |
| `PORTAL_SESSIONS_ACTIVE_REDIS_SERVICE`       | Sentinel service name (Redis backend)                                                                 |                                                            |         |
| `PORTAL_SESSIONS_ACTIVE_LDAP_SERVER`         | LDAP server URI (LDAP backend)                                                                        |                                                            | x       |
| `PORTAL_SESSIONS_ACTIVE_LDAP_BASE`           | LDAP sessions base DN (LDAP backend)                                                                  |                                                            | x       |
| `PORTAL_SESSIONS_ACTIVE_LDAP_BIND_DN`        | LDAP bind DN (LDAP backend)                                                                           |                                                            | x       |
| `PORTAL_SESSIONS_ACTIVE_LDAP_BIND_PASS`      | LDAP bind password (LDAP backend)                                                                     |                                                            | x       |
| `PORTAL_SESSIONS_ACTIVE_LDAP_RAW`            | Binary attribute regex (LDAP backend)                                                                 |                                                            |         |
| `PORTAL_SESSIONS_ACTIVE_LDAP_INDEX`          | Fields to index (LDAP backend)                                                                        |                                                            |         |
| `PORTAL_SESSIONS_ACTIVE_CLASS`               | Full Perl class name (when `TYPE=custom`)                                                             |                                                            |         |
| `PORTAL_SESSIONS_ACTIVE_CUSTOM_OPTIONS`      | Raw options hash string (when `TYPE=custom`)                                                          |                                                            |         |
| `PORTAL_SESSIONS_PERSISTENT_TYPE`            | Override Instance or Global Config persistent session type. See [Session Backends](#session-backends) | `NONE`                                                     |         |
| `PORTAL_SESSIONS_PERSISTENT_FILE_PATH`       | Persistent session path (when `TYPE=FILE`)                                                            | `${INSTANCE_SESSIONS_PERSISTENT_FILE_PATH}`                |         |
| `PORTAL_SESSIONS_PERSISTENT_DB_HOST`         | Database / Redis server hostname or IP (SQL and Redis backends)                                       |                                                            | x       |
| `PORTAL_SESSIONS_PERSISTENT_DB_PORT`         | Server port - optional, driver/Redis default used if unset                                            |                                                            | x       |
| `PORTAL_SESSIONS_PERSISTENT_DB_NAME`         | Database name (SQL backends) or Redis database number (Redis backend)                                 |                                                            | x       |
| `PORTAL_SESSIONS_PERSISTENT_DB_USER`         | Username - not used for `SQLITE` or `REDIS` (SQL backends)                                            |                                                            | x       |
| `PORTAL_SESSIONS_PERSISTENT_DB_PASS`         | Password (SQL and Redis backends)                                                                     |                                                            | x       |
| `PORTAL_SESSIONS_PERSISTENT_DB_INDEX`        | Fields to index (SQL Browseable and Redis backends)                                                   |                                                            |         |
| `PORTAL_SESSIONS_PERSISTENT_DB_DSN`          | Full DSN string - overrides `DB_HOST`/`DB_PORT`/`DB_NAME` if set (SQL backends)                       |                                                            | x       |
| `PORTAL_SESSIONS_PERSISTENT_DB_TABLE`        | Table name (SQL backends)                                                                             | `sessions`                                                 |         |
| `PORTAL_SESSIONS_PERSISTENT_DB_COMMIT`       | Commit flag - mandatory for Posgres backends                                                          | `1`                                                        |         |
| `PORTAL_SESSIONS_PERSISTENT_REDIS_SOCK`      | Redis UNIX socket path - alternative to `DB_HOST` (Redis backend)                                     |                                                            | x       |
| `PORTAL_SESSIONS_PERSISTENT_REDIS_SENTINELS` | Comma-separated Sentinel list (Redis backend)                                                         |                                                            |         |
| `PORTAL_SESSIONS_PERSISTENT_REDIS_SERVICE`   | Sentinel service name (Redis backend)                                                                 |                                                            |         |
| `PORTAL_SESSIONS_PERSISTENT_LDAP_SERVER`     | LDAP server URI (LDAP backend)                                                                        |                                                            | x       |
| `PORTAL_SESSIONS_PERSISTENT_LDAP_BASE`       | LDAP sessions base DN (LDAP backend)                                                                  |                                                            | x       |
| `PORTAL_SESSIONS_PERSISTENT_LDAP_BIND_DN`    | LDAP bind DN (LDAP backend)                                                                           |                                                            | x       |
| `PORTAL_SESSIONS_PERSISTENT_LDAP_BIND_PASS`  | LDAP bind password (LDAP backend)                                                                     |                                                            | x       |
| `PORTAL_SESSIONS_PERSISTENT_LDAP_RAW`        | Binary attribute regex (LDAP backend)                                                                 |                                                            |         |
| `PORTAL_SESSIONS_PERSISTENT_LDAP_INDEX`      | Fields to index (LDAP backend)                                                                        |                                                            |         |
| `PORTAL_SESSIONS_PERSISTENT_CLASS`           | Full Perl class name (when `TYPE=custom`)                                                             |                                                            |         |
| `PORTAL_SESSIONS_PERSISTENT_CUSTOM_OPTIONS`  | Raw options hash string (when `TYPE=custom`)                                                          |                                                            |         |
| `PORTAL_CUSTOM_CSS_FILE`                     | Custom Portal CSS path+file to use                                                                    |                                                            |         |
| `PORTAL_CUSTOM_JS_FILE`                      | Custom Portal JS path+file to use                                                                     |                                                            |         |
| `PORTAL_CUSTOM_ERROR_<N>`                    | Override portal error message number `<N>` (e.g. `PORTAL_CUSTOM_ERROR_0`)                             |                                                            |         |
|                                              | Override error message - Writes `error_<N> = <value>` config                                          |                                                            |         |
| `PORTAL_CUSTOM_MSG_<N>`                      | Override portal message number `<N>`                                                                  |                                                            |         |
|                                              |                                                                                                       |                                                            |         |
| `PORTAL_ENABLE_CAPTCHA`                      | Enable Captcha Plugin `TRUE`/`FALSE`                                                                  |                                                            |         |
| `PORTAL_CAPTCHA_PATH`                        | Path for storing captchas                                                                             | `${DATA_PATH}/captcha`                                     |         |
| `PORTAL_ENABLE_NOTIFICATIONS`                | Enable notifications in portal                                                                        | `TRUE`                                                     |         |
| `PORTAL_GEOIP_PATH`                          | Path for GeoIP Database if used                                                                       |                                                            |         |
| `PORTAL_SKIN`                                | Override Portal Skin Name                                                                             |                                                            |         |
| `PORTAL_SKIN_BACKGROUND`                     | Filename of skin background Name                                                                      |                                                            |         |
| `PORTAL_NOTIFICATIONS_TYPE`                  | Portal notifications type                                                                             | `FILE`                                                     |         |
| `PORTAL_NOTIFICATIONS_FILE_PATH`             | Portal notifications file path                                                                        | `${DATA_PATH}/notifications`                               |         |
| `PORTAL_NOTIFICATIONS_FILE_SEPERATOR`        | Portal notifications file separator                                                                   | `_`                                                        |         |
| `PORTAL_NOTIFICATIONS_ENABLE_EXPLORER`       | Enable notifications explorer                                                                         | `TRUE`                                                     |         |
| `PORTAL_NOTIFICATIONS_ENABLE_PUBLIC`         | Enable public notifications                                                                           | `TRUE`                                                     |         |
| `PORTAL_NOTIFICATIONS_EXPLORER_MAX_RETRIEVE` | Max notifications to retrieve                                                                         | `3`                                                        |         |
| `PORTAL_ENABLE_REST`                         | Enable REST webserver config                                                                          | `FALSE`                                                    |         |
| `PORTAL_REST_ALLOWED_IPS`                    | Comma seperated list of IP/Network to allow access                                                    |                                                            |         |
|                                              | eg `172.16.0.0/12,192.168.0.253`                                                                      |                                                            | x       |
| `PORTAL_REST_AUTH_FILE`                      | Populate this file manually or with environment variables                                             |                                                            |         |
|                                              | for REST authentication (htpasswd format)                                                             | `${DATA_PATH}/portal-rest.htpasswd`                        | x       |
| `PORTAL_REST_USER01`                         | Username for REST Authentication                                                                      |                                                            | x       |
| `PORTAL_REST_PASS01`                         | Password for REST Authentication                                                                      |                                                            | x       |
| `PORTAL_REST_USER02`                         | Username for REST Authentication                                                                      |                                                            | x       |
| `PORTAL_REST_PASS02`                         | Password for REST Authentication                                                                      |                                                            | x       |
| `PORTAL_REST_USER...`                        | Username for REST Authentication                                                                      |                                                            | x       |
| `PORTAL_REST_PASS...`                        | Password for REST Authentication                                                                      |                                                            | x       |
| `PORTAL_STATUS_ALLOWED_IPS`                  | Comma seperated list of IP/Network to allow access to /status                                         |                                                            |         |
|                                              | eg `172.16.0.0/12,192.168.0.253`                                                                      |                                                            | x       |
| `PORTAL_ENABLE_IMPERSONATION`                | Allow impersonation using a seperate theme `TRUE`                                                     | `FALSE`                                                    |         |
| `PORTAL_IMPERSONATE_HOSTNAME`                | Hostname to use to load the custom impersonation theme                                                |                                                            | x       |
| `PORTAL_IMPERSONATE_THEME`                   | Theme to use to load the impersonation theme                                                          |                                                            | x       |

>> With impersonation, if you enable it, it will add a new field to your login screen, which may not be what you want if this is a production system. You will need to create two custom themes (one as a replica of bootstrap, and one for impersonation). In the custom theme, make modifications to `login.tpl` to stop it from loading impersonation.tpl, yet in your impersonation theme, leave it in there. Then, when one of your admin/support team visits the custom `IMPERSONATE_HOSTNAME` you have defined it will load the full theme with allows to impersonate, where as the default theme will not show this.

>> When changing the path of `PORTAL_` `APPS` `ICONS` `LOGOS` `LANGUAGES` path if the destination path is empty it will make a copy of the original vendor supplied content in your folder. There is an additional file `.source` which will detail the version of LemonLDAP:NG and the date that the content was copied. It is important that you watch the vendor supplied folders in later images to ensure that you are being kept up to date with the appropriate assets.

>> If wishing to use Fail2Ban to lock out problematic hosts - you must enable `CONTAINER_ENABLE_FIREWALL=TRUE` AND `CONTAINER_ENABLE_FAIL2BAN=TRUE`

#### Test Site Variables

For usage with `MODE=TEST`

| Parameter       | Description                           | Default | `_FILE` |
| --------------- | ------------------------------------- | ------- | ------- |
| `TEST_SOCKET`   | Test socket override                  |         | x       |
| `TEST_HOSTNAME` | Test Hostname eg test.sso.example.com |         | x       |

### Session Backends

The `*_SESSIONS_ACTIVE_TYPE` and `*_SESSIONS_PERSISTENT_TYPE` variables (`INSTANCE_`, `HANDLER_`, and `PORTAL_` prefixes) accept the following values:

| Value       | Backend                                  | Notes                                                                                         |
| ----------- | ---------------------------------------- | --------------------------------------------------------------------------------------------- |
| `NONE`      | Disabled / inherit from instance config  | Default for handler and portal overrides                                                      |
| `FILE`      | `Apache::Session::File`                  | Flat-file sessions; uses `*_FILE_PATH`                                                        |
| `MYSQL`     | `Apache::Session::Browseable::MySQL`     | Requires `*_DB_HOST`, `*_DB_NAME`, `*_DB_USER`, `*_DB_PASS`, `*_DB_INDEX`                     |
| `MYSQLJSON` | `Apache::Session::Browseable::MySQLJSON` | As `MYSQL` but stores session data as JSON                                                    |
| `POSTGRES`  | `Apache::Session::Browseable::Postgres`  | Requires `*_DB_HOST`, `*_DB_NAME`, `*_DB_USER`, `*_DB_PASS`; `*_DB_COMMIT` mandatory          |
| `PGJSON`    | `Apache::Session::Browseable::PgJSON`    | As `POSTGRES` but data stored as JSONB; index not required                                    |
| `PGHSTORE`  | `Apache::Session::Browseable::PgHstore`  | As `POSTGRES` but data stored as hstore                                                       |
| `SQLITE`    | `Apache::Session::Browseable::SQLite`    | Requires `*_DB_NAME` only; no host, user, pass, or `Commit`                                   |
| `REDIS`     | `Apache::Session::Browseable::Redis`     | Uses `*_DB_HOST`/`*_DB_PORT` (default 6379); `*_DB_NAME` = database number; or `*_REDIS_SOCK` |
| `LDAP`      | `Apache::Session::Browseable::LDAP`      | Requires `*_LDAP_SERVER/BASE/BIND_DN/BIND_PASS`                                               |
| `CUSTOM`    | Custom Supplied perl class               | Requires `*_CLASS` and optionally `*_CUSTOM_OPTIONS`                                          |

>> For DB including redis backends, set the `_DB_HOST`/`_DB_NAME`/`_DB_USER`/`_DB_PASS` component vars and the DSN is built automatically.
>> A full `_DB_DSN` override is also accepted for advanced SQL connection strings.

#### Session Examples

PostgreSQL (PgJSON):

```
PORTAL_SESSIONS_ACTIVE_TYPE=pgjson
PORTAL_SESSIONS_ACTIVE_DB_HOST=postgres
PORTAL_SESSIONS_ACTIVE_DB_NAME=llng
PORTAL_SESSIONS_ACTIVE_DB_USER=llng
PORTAL_SESSIONS_ACTIVE_DB_PASS_FILE=/run/secrets/db_password
PORTAL_SESSIONS_ACTIVE_DB_TABLE=sessions
```

MySQL with a non-default port:

```
PORTAL_SESSIONS_ACTIVE_TYPE=mysqljson
PORTAL_SESSIONS_ACTIVE_DB_HOST=mysql
PORTAL_SESSIONS_ACTIVE_DB_PORT=3307
PORTAL_SESSIONS_ACTIVE_DB_NAME=llng
PORTAL_SESSIONS_ACTIVE_DB_USER=llng
PORTAL_SESSIONS_ACTIVE_DB_PASS_FILE=/run/secrets/db_password
PORTAL_SESSIONS_ACTIVE_DB_INDEX=_session_id,_utime
```

SQLite (no host, user, or password needed):

```
PORTAL_SESSIONS_ACTIVE_TYPE=sqlite
PORTAL_SESSIONS_ACTIVE_DB_NAME=/data/sessions/active.db
```

Redis (`_DB_NAME` is the Redis database number):

```
PORTAL_SESSIONS_ACTIVE_TYPE=redis
PORTAL_SESSIONS_ACTIVE_DB_HOST=redis
PORTAL_SESSIONS_ACTIVE_DB_PORT=6379
PORTAL_SESSIONS_ACTIVE_DB_NAME=0
PORTAL_SESSIONS_ACTIVE_DB_PASS_FILE=/run/secrets/redis_pass
```

Redis via UNIX socket (Redis-specific):

```
PORTAL_SESSIONS_ACTIVE_TYPE=redis
PORTAL_SESSIONS_ACTIVE_REDIS_SOCK=/run/redis/redis.sock
PORTAL_SESSIONS_ACTIVE_DB_PASS_FILE=/run/secrets/redis_pass
```

Or with a manually specified DSN for advanced SQL connection options:

```
PORTAL_SESSIONS_ACTIVE_TYPE=pgjson
PORTAL_SESSIONS_ACTIVE_DB_DSN=dbi:Pg:dbname=llng;host=postgres-db;port=5432;sslmode=require
PORTAL_SESSIONS_ACTIVE_DB_USER=llng
PORTAL_SESSIONS_ACTIVE_DB_PASS_FILE=/run/secrets/db_password
```

For LDAP:

```
PORTAL_SESSIONS_ACTIVE_TYPE=LDAP
PORTAL_SESSIONS_ACTIVE_LDAP_SERVER=ldap://openldap-app:389
PORTAL_SESSIONS_ACTIVE_LDAP_BASE=ou=sessions,dc=example,dc=com
PORTAL_SESSIONS_ACTIVE_LDAP_BIND_DN=cn=llng,dc=example,dc=com
PORTAL_SESSIONS_ACTIVE_LDAP_BIND_PASS_FILE=/run/secrets/ldap_password
```

> The same `_DB_*`, `_REDIS_*`, and `_LDAP_*` sub-variables apply to `INSTANCE_SESSIONS_*`, `HANDLER_SESSIONS_*`, and `PORTAL_SESSIONS_*` with their respective prefixes.


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
