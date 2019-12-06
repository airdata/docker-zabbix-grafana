# Dockerized Zabbix Server 4.0 Installation Script


This script, installs and configures a dockerized zabbix 4.0 server in a fully automated way on CentOS 7 platforms.

Here's the summary:

- Enables Epel repo.
- Installs docker (ce), docker compose and jq.
- Creates self signed SSL certificates for zabbix and grafana frontends.
- Deploys zabbix services via docker compose.
- Invokes the zabbix API to do following configurations.
    - Creates a bunch of hosts group.
    - Creates auto registration actions for Linux and Windows hosts.
    - Adds some new items to Linux / Windows Templates: 
        - Disk usage in percentage for Linux hosts.
        - Creates additional CPU load checks to get cumulative CPU load as 1, 5 and 15 minutes avg. (The default template checks calculate the load as per core) for Linux hosts.
        - Available memory in percentage for Linux and Windows hosts.
        - Adds CPU count item for Linux and Windows hosts.
        - CPU utilization check for Windows
    - Changes filesystem and netif LLD rules intervals to 10 minutes for Linux and Windows hosts.
    - Disables annoying Windows service items LLD rule:
    - Adds alexanderzobnin-zabbix-app datasource plugin to grafana.
    - Adds briangann-gauge-panel, btplc-trend-box-panel and jdbranham-diagram-panel plugins to grafana.
    - Invokes the grafana API to add custom Linux / Windows dashboards as well as Zabbix overall system status dashboard.
    - Sets email notification for admin user. (Optional)
    - Sets slack notification for admin user. (Optional)
    - Changes the default notification messages in a more informative manner.

## Usage

To invoke zabbix server installation, execute the "zabbix-server" script with "init" parameter and follow the instructions.

```
# bash scripts/zabbix-server.sh install
```

You can find an complete example output at the end of the page.

## Accessing Zabbix and Grafana UIs

Zabbix ui is accessible on port 8443 with the credentials listed below:

```
URL: https://host-ip:8443
Username: Admin
Password: zabbix
```

and grafana is on port 3000:

```
URL: https://host-ip:3000
Username: admin
Password: zabbix
```

Note: Both services are served over https by using a self-signed certificate.

## Screenshots

### Insight Panel:
![alt text](https://bitbucket.org/secopstech/zabbix-server/raw/cd3b78150db35a6de1fbd4c1fdcc000c65d15373/screenshots/linux-insight.png "Insight")

### CPU and Memory Graphs
![alt text](https://bitbucket.org/secopstech/zabbix-server/raw/cd3b78150db35a6de1fbd4c1fdcc000c65d15373/screenshots/linux-cpu-mem.png "CPU and Memory Graphs")

### Filesystem and Network Interfaces Graphs
![alt text](https://bitbucket.org/secopstech/zabbix-server/raw/cd3b78150db35a6de1fbd4c1fdcc000c65d15373/screenshots/linux-fs-netif.png "Filesystem and Network Interfaces Graph")

### Overall system status dashboard
![alt text](https://bitbucket.org/secopstech/zabbix-server/raw/cd3b78150db35a6de1fbd4c1fdcc000c65d15373/screenshots/overall-system-status.png "Overall system status")

### Example slack alert for a problem notification
![alt text](https://bitbucket.org/secopstech/zabbix-server/raw/cd3b78150db35a6de1fbd4c1fdcc000c65d15373/screenshots/slack-notification1.png "Slack notification - problem")

### Example slack alert for a resolve notification
![alt text](https://bitbucket.org/secopstech/zabbix-server/raw/cd3b78150db35a6de1fbd4c1fdcc000c65d15373/screenshots/slack-notification2.png "Slack notification - resolved")

## Example output

```
# bash scripts/zabbix-server.sh init

DOCKERIZED ZABBIX DEPLOYMENT AND CONFIGURATION SCRIPT
Version: 1.0.0

By this script, the steps listed below will be done:

- Latest Docker(CE) engine and docker-compose installation.
- Dockerized zabbix server deployment by using the official zabbix docker images and compose file.
- Required packages installation like epel-repo and jq.
- Creating auto registration actions for Linux & Windows hosts.
- Creating some additional check items/triggers for Linux & Windows templates.
- Grafana integration and deployment of some useful custom dashboards.
- SMTP settings and admin email configurations. (Optional)
- Slack integration. (Optional)

NOTE: Any deployed zabbix server containers will be taken down and re-created.
 Do you want to continue (Yes or No):  yes
Continue...

- Install epel repo and jq packages.
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.radoreservers.com
 * extras: ftp.linux.org.tr
 * updates: mirror.saglayici.com
Resolving Dependencies
--> Running transaction check
---> Package epel-release.noarch 0:7-11 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

============================================================================================================================================================================================================
 Package                                               Arch                                            Version                                        Repository                                       Size
============================================================================================================================================================================================================
Installing:
 epel-release                                          noarch                                          7-11                                           extras                                           15 k

Transaction Summary
============================================================================================================================================================================================================
Install  1 Package

Total download size: 15 k
Installed size: 24 k
Downloading packages:
epel-release-7-11.noarch.rpm                                                                                                                                                         |  15 kB  00:00:00
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : epel-release-7-11.noarch                                                                                                                                                                 1/1
  Verifying  : epel-release-7-11.noarch                                                                                                                                                                 1/1

Installed:
  epel-release.noarch 0:7-11

Complete!
Enable epel repo:				... done
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
epel/x86_64/metalink                                                                                                                                                                 |  32 kB  00:00:00
 * base: mirror.radoreservers.com
 * epel: ftp.linux.org.tr
 * extras: ftp.linux.org.tr
 * updates: mirror.saglayici.com
epel                                                                                                                                                                                 | 3.2 kB  00:00:00
(1/3): epel/x86_64/group_gz                                                                                                                                                          |  88 kB  00:00:00
(2/3): epel/x86_64/updateinfo                                                                                                                                                        | 933 kB  00:00:01
(3/3): epel/x86_64/primary                                                                                                                                                           | 3.6 MB  00:00:06
epel                                                                                                                                                                                            12756/12756
Resolving Dependencies
--> Running transaction check
---> Package jq.x86_64 0:1.5-1.el7 will be installed
--> Processing Dependency: libonig.so.2()(64bit) for package: jq-1.5-1.el7.x86_64
--> Running transaction check
---> Package oniguruma.x86_64 0:5.9.5-3.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

============================================================================================================================================================================================================
 Package                                           Arch                                           Version                                                Repository                                    Size
============================================================================================================================================================================================================
Installing:
 jq                                                x86_64                                         1.5-1.el7                                              epel                                         153 k
Installing for dependencies:
 oniguruma                                         x86_64                                         5.9.5-3.el7                                            epel                                         129 k

Transaction Summary
============================================================================================================================================================================================================
Install  1 Package (+1 Dependent package)

Total download size: 282 k
Installed size: 906 k
Downloading packages:
warning: /var/cache/yum/x86_64/7/epel/packages/oniguruma-5.9.5-3.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID 352c64e5: NOKEY                                   ]  0.0 B/s | 106 kB  --:--:-- ETA
Public key for oniguruma-5.9.5-3.el7.x86_64.rpm is not installed
(1/2): oniguruma-5.9.5-3.el7.x86_64.rpm                                                                                                                                              | 129 kB  00:00:00
(2/2): jq-1.5-1.el7.x86_64.rpm                                                                                                                                                       | 153 kB  00:00:00
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                                                       369 kB/s | 282 kB  00:00:00
Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
Importing GPG key 0x352C64E5:
 Userid     : "Fedora EPEL (7) <epel@fedoraproject.org>"
 Fingerprint: 91e9 7d7c 4a5e 96f1 7f3e 888f 6a2f aea2 352c 64e5
 Package    : epel-release-7-11.noarch (@extras)
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : oniguruma-5.9.5-3.el7.x86_64                                                                                                                                                             1/2
  Installing : jq-1.5-1.el7.x86_64                                                                                                                                                                      2/2
  Verifying  : oniguruma-5.9.5-3.el7.x86_64                                                                                                                                                             1/2
  Verifying  : jq-1.5-1.el7.x86_64                                                                                                                                                                      2/2

Installed:
  jq.x86_64 0:1.5-1.el7

Dependency Installed:
  oniguruma.x86_64 0:5.9.5-3.el7

Complete!
Install jq:				... done
----------------------------------------------------------------

- Install Docker CE.
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.radoreservers.com
 * epel: ftp.linux.org.tr
 * extras: ftp.linux.org.tr
 * updates: mirror.saglayici.com
Package device-mapper-persistent-data-0.7.3-3.el7.x86_64 already installed and latest version
Package 7:lvm2-2.02.177-4.el7.x86_64 already installed and latest version
Resolving Dependencies
--> Running transaction check
---> Package yum-utils.noarch 0:1.1.31-46.el7_5 will be installed
--> Processing Dependency: python-kitchen for package: yum-utils-1.1.31-46.el7_5.noarch
--> Processing Dependency: libxml2-python for package: yum-utils-1.1.31-46.el7_5.noarch
--> Running transaction check
---> Package libxml2-python.x86_64 0:2.9.1-6.el7_2.3 will be installed
---> Package python-kitchen.noarch 0:1.1.1-5.el7 will be installed
--> Processing Dependency: python-chardet for package: python-kitchen-1.1.1-5.el7.noarch
--> Running transaction check
---> Package python-chardet.noarch 0:2.2.1-1.el7_1 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

============================================================================================================================================================================================================
 Package                                             Arch                                        Version                                                 Repository                                    Size
============================================================================================================================================================================================================
Installing:
 yum-utils                                           noarch                                      1.1.31-46.el7_5                                         updates                                      120 k
Installing for dependencies:
 libxml2-python                                      x86_64                                      2.9.1-6.el7_2.3                                         base                                         247 k
 python-chardet                                      noarch                                      2.2.1-1.el7_1                                           base                                         227 k
 python-kitchen                                      noarch                                      1.1.1-5.el7                                             base                                         267 k

Transaction Summary
============================================================================================================================================================================================================
Install  1 Package (+3 Dependent packages)

Total download size: 860 k
Installed size: 4.3 M
Downloading packages:
(1/4): yum-utils-1.1.31-46.el7_5.noarch.rpm                                                                                                                                          | 120 kB  00:00:00
(2/4): libxml2-python-2.9.1-6.el7_2.3.x86_64.rpm                                                                                                                                     | 247 kB  00:00:00
(3/4): python-chardet-2.2.1-1.el7_1.noarch.rpm                                                                                                                                       | 227 kB  00:00:00
(4/4): python-kitchen-1.1.1-5.el7.noarch.rpm                                                                                                                                         | 267 kB  00:00:00
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                                                       1.0 MB/s | 860 kB  00:00:00
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : python-chardet-2.2.1-1.el7_1.noarch                                                                                                                                                      1/4
  Installing : python-kitchen-1.1.1-5.el7.noarch                                                                                                                                                        2/4
  Installing : libxml2-python-2.9.1-6.el7_2.3.x86_64                                                                                                                                                    3/4
  Installing : yum-utils-1.1.31-46.el7_5.noarch                                                                                                                                                         4/4
  Verifying  : libxml2-python-2.9.1-6.el7_2.3.x86_64                                                                                                                                                    1/4
  Verifying  : python-kitchen-1.1.1-5.el7.noarch                                                                                                                                                        2/4
  Verifying  : yum-utils-1.1.31-46.el7_5.noarch                                                                                                                                                         3/4
  Verifying  : python-chardet-2.2.1-1.el7_1.noarch                                                                                                                                                      4/4

Installed:
  yum-utils.noarch 0:1.1.31-46.el7_5

Dependency Installed:
  libxml2-python.x86_64 0:2.9.1-6.el7_2.3                              python-chardet.noarch 0:2.2.1-1.el7_1                              python-kitchen.noarch 0:1.1.1-5.el7

Complete!
Loaded plugins: fastestmirror
adding repo from: https://download.docker.com/linux/centos/docker-ce.repo
grabbing file https://download.docker.com/linux/centos/docker-ce.repo to /etc/yum.repos.d/docker-ce.repo
repo saved to /etc/yum.repos.d/docker-ce.repo
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.radoreservers.com
 * epel: ftp.linux.org.tr
 * extras: ftp.linux.org.tr
 * updates: mirror.saglayici.com
docker-ce-stable                                                                                                                                                                     | 2.9 kB  00:00:00
docker-ce-stable/x86_64/primary_db                                                                                                                                                   |  17 kB  00:00:00
Resolving Dependencies
--> Running transaction check
---> Package docker-ce.x86_64 0:18.06.1.ce-3.el7 will be installed
--> Processing Dependency: container-selinux >= 2.9 for package: docker-ce-18.06.1.ce-3.el7.x86_64
--> Processing Dependency: libcgroup for package: docker-ce-18.06.1.ce-3.el7.x86_64
--> Processing Dependency: libltdl.so.7()(64bit) for package: docker-ce-18.06.1.ce-3.el7.x86_64
--> Running transaction check
---> Package container-selinux.noarch 2:2.68-1.el7 will be installed
--> Processing Dependency: policycoreutils-python for package: 2:container-selinux-2.68-1.el7.noarch
---> Package libcgroup.x86_64 0:0.41-15.el7 will be installed
---> Package libtool-ltdl.x86_64 0:2.4.2-22.el7_3 will be installed
--> Running transaction check
---> Package policycoreutils-python.x86_64 0:2.5-22.el7 will be installed
--> Processing Dependency: setools-libs >= 3.3.8-2 for package: policycoreutils-python-2.5-22.el7.x86_64
--> Processing Dependency: libsemanage-python >= 2.5-9 for package: policycoreutils-python-2.5-22.el7.x86_64
--> Processing Dependency: audit-libs-python >= 2.1.3-4 for package: policycoreutils-python-2.5-22.el7.x86_64
--> Processing Dependency: python-IPy for package: policycoreutils-python-2.5-22.el7.x86_64
--> Processing Dependency: libqpol.so.1(VERS_1.4)(64bit) for package: policycoreutils-python-2.5-22.el7.x86_64
--> Processing Dependency: libqpol.so.1(VERS_1.2)(64bit) for package: policycoreutils-python-2.5-22.el7.x86_64
--> Processing Dependency: libapol.so.4(VERS_4.0)(64bit) for package: policycoreutils-python-2.5-22.el7.x86_64
--> Processing Dependency: checkpolicy for package: policycoreutils-python-2.5-22.el7.x86_64
--> Processing Dependency: libqpol.so.1()(64bit) for package: policycoreutils-python-2.5-22.el7.x86_64
--> Processing Dependency: libapol.so.4()(64bit) for package: policycoreutils-python-2.5-22.el7.x86_64
--> Running transaction check
---> Package audit-libs-python.x86_64 0:2.8.1-3.el7_5.1 will be installed
---> Package checkpolicy.x86_64 0:2.5-6.el7 will be installed
---> Package libsemanage-python.x86_64 0:2.5-11.el7 will be installed
---> Package python-IPy.noarch 0:0.75-6.el7 will be installed
---> Package setools-libs.x86_64 0:3.3.8-2.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

============================================================================================================================================================================================================
 Package                                                 Arch                                    Version                                            Repository                                         Size
============================================================================================================================================================================================================
Installing:
 docker-ce                                               x86_64                                  18.06.1.ce-3.el7                                   docker-ce-stable                                   41 M
Installing for dependencies:
 audit-libs-python                                       x86_64                                  2.8.1-3.el7_5.1                                    updates                                            75 k
 checkpolicy                                             x86_64                                  2.5-6.el7                                          base                                              294 k
 container-selinux                                       noarch                                  2:2.68-1.el7                                       extras                                             36 k
 libcgroup                                               x86_64                                  0.41-15.el7                                        base                                               65 k
 libsemanage-python                                      x86_64                                  2.5-11.el7                                         base                                              112 k
 libtool-ltdl                                            x86_64                                  2.4.2-22.el7_3                                     base                                               49 k
 policycoreutils-python                                  x86_64                                  2.5-22.el7                                         base                                              454 k
 python-IPy                                              noarch                                  0.75-6.el7                                         base                                               32 k
 setools-libs                                            x86_64                                  3.3.8-2.el7                                        base                                              619 k

Transaction Summary
============================================================================================================================================================================================================
Install  1 Package (+9 Dependent packages)

Total download size: 42 M
Installed size: 46 M
Downloading packages:
(1/10): audit-libs-python-2.8.1-3.el7_5.1.x86_64.rpm                                                                                                                                 |  75 kB  00:00:00
(2/10): container-selinux-2.68-1.el7.noarch.rpm                                                                                                                                      |  36 kB  00:00:00
(3/10): libcgroup-0.41-15.el7.x86_64.rpm                                                                                                                                             |  65 kB  00:00:00
(4/10): checkpolicy-2.5-6.el7.x86_64.rpm                                                                                                                                             | 294 kB  00:00:00
(5/10): python-IPy-0.75-6.el7.noarch.rpm                                                                                                                                             |  32 kB  00:00:00
(6/10): libtool-ltdl-2.4.2-22.el7_3.x86_64.rpm                                                                                                                                       |  49 kB  00:00:00
(7/10): libsemanage-python-2.5-11.el7.x86_64.rpm                                                                                                                                     | 112 kB  00:00:00
(8/10): policycoreutils-python-2.5-22.el7.x86_64.rpm                                                                                                                                 | 454 kB  00:00:00
(9/10): setools-libs-3.3.8-2.el7.x86_64.rpm                                                                                                                                          | 619 kB  00:00:00
warning: /var/cache/yum/x86_64/7/docker-ce-stable/packages/docker-ce-18.06.1.ce-3.el7.x86_64.rpm: Header V4 RSA/SHA512 Signature, key ID 621e9f35: NOKEY================- ] 1.7 MB/s |  42 MB  00:00:00 ETA
Public key for docker-ce-18.06.1.ce-3.el7.x86_64.rpm is not installed
(10/10): docker-ce-18.06.1.ce-3.el7.x86_64.rpm                                                                                                                                       |  41 MB  00:00:23
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                                                       1.8 MB/s |  42 MB  00:00:23
Retrieving key from https://download.docker.com/linux/centos/gpg
Importing GPG key 0x621E9F35:
 Userid     : "Docker Release (CE rpm) <docker@docker.com>"
 Fingerprint: 060a 61c5 1b55 8a7f 742b 77aa c52f eb6b 621e 9f35
 From       : https://download.docker.com/linux/centos/gpg
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : libcgroup-0.41-15.el7.x86_64                                                                                                                                                            1/10
  Installing : audit-libs-python-2.8.1-3.el7_5.1.x86_64                                                                                                                                                2/10
  Installing : setools-libs-3.3.8-2.el7.x86_64                                                                                                                                                         3/10
  Installing : libtool-ltdl-2.4.2-22.el7_3.x86_64                                                                                                                                                      4/10
  Installing : python-IPy-0.75-6.el7.noarch                                                                                                                                                            5/10
  Installing : checkpolicy-2.5-6.el7.x86_64                                                                                                                                                            6/10
  Installing : libsemanage-python-2.5-11.el7.x86_64                                                                                                                                                    7/10
  Installing : policycoreutils-python-2.5-22.el7.x86_64                                                                                                                                                8/10
  Installing : 2:container-selinux-2.68-1.el7.noarch                                                                                                                                                   9/10
  Installing : docker-ce-18.06.1.ce-3.el7.x86_64                                                                                                                                                      10/10
  Verifying  : libcgroup-0.41-15.el7.x86_64                                                                                                                                                            1/10
  Verifying  : docker-ce-18.06.1.ce-3.el7.x86_64                                                                                                                                                       2/10
  Verifying  : policycoreutils-python-2.5-22.el7.x86_64                                                                                                                                                3/10
  Verifying  : libsemanage-python-2.5-11.el7.x86_64                                                                                                                                                    4/10
  Verifying  : 2:container-selinux-2.68-1.el7.noarch                                                                                                                                                   5/10
  Verifying  : checkpolicy-2.5-6.el7.x86_64                                                                                                                                                            6/10
  Verifying  : python-IPy-0.75-6.el7.noarch                                                                                                                                                            7/10
  Verifying  : libtool-ltdl-2.4.2-22.el7_3.x86_64                                                                                                                                                      8/10
  Verifying  : setools-libs-3.3.8-2.el7.x86_64                                                                                                                                                         9/10
  Verifying  : audit-libs-python-2.8.1-3.el7_5.1.x86_64                                                                                                                                               10/10

Installed:
  docker-ce.x86_64 0:18.06.1.ce-3.el7

Dependency Installed:
  audit-libs-python.x86_64 0:2.8.1-3.el7_5.1  checkpolicy.x86_64 0:2.5-6.el7              container-selinux.noarch 2:2.68-1.el7  libcgroup.x86_64 0:0.41-15.el7     libsemanage-python.x86_64 0:2.5-11.el7
  libtool-ltdl.x86_64 0:2.4.2-22.el7_3        policycoreutils-python.x86_64 0:2.5-22.el7  python-IPy.noarch 0:0.75-6.el7         setools-libs.x86_64 0:3.3.8-2.el7

Complete!
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service.
Docker installation:			... done
----------------------------------------------------------------

- Install Docker Compose.
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   617    0   617    0     0    698      0 --:--:-- --:--:-- --:--:--   698
100 11.2M  100 11.2M    0     0   417k      0  0:00:27  0:00:27 --:--:--  512k
Docker Compose installation:			... done
----------------------------------------------------------------

- Deploy self signed SSL cert for Zabbix UI.
Generating a 2048 bit RSA private key
........................+++
........+++
writing new private key to '/root/zabbix-server/scripts/../zbx_env/etc/ssl/nginx/ssl.key'
-----
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time
..............................................................................................................................................................+........+................................................................................................................................................................................................................+................+.....................................................................................................................................................................................................................................................................................+...+...................................................+......................................................................................................+.....+.............................................................................................+..........+............................+........................................................................................................................................+.....................................................................................................................+.....................................................................................................................+.........+..+........................................................................................................................+..................................................................................................................................................................+....................................+.........................................................................................................................................................................................................................................................................................................................................................................................................................+........+...................................................................................+........................+...............................................................................................+............................................+................................................+......................................................................................................................................................+.................................................................................................................................................................................................+..............+............+.....................................................................................................+.......................................+.....................................................+........................+.....................................................................................................................................+................................................................................................+............................................................+.........................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................++*++*
Self signed SSL deployment for zabbix:			... done
----------------------------------------------------------------

- Deploy self signed SSL cert for Grafana UI.
Generating a 2048 bit RSA private key
........................................+++
.........................................+++
writing new private key to '/root/zabbix-server/scripts/../zbx_env/etc/ssl/grafana/ssl.key'
-----
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time
.................+...............................................+......................................................+.............+..............+............................................................................................................................................................................+..............................................................+..........................+.............................+..........................................................+.................................................................................................................+.................................................................................................................................+...............................................................................................+....................................................................................................................................................................................................................................+.....................................................................................................................................................................................+...............................+............+................................................................................................................................................................................+.........................+......................+.........+................................................................+.....................................................................................+...........................................................+....+...............+.......................................................................................................................................................................................................................................................................................+.................................+...........+....................................................................................................................................+..+.......................................................................................................................................++*++*
Self signed SSL deployment for grafana:			... done
----------------------------------------------------------------

- Dockerized zabbix server deployment.
----------------------------------------------------------------
Creating network "zabbix-server_zbx_net" with driver "bridge"
Creating network "zabbix-server_default" with the default driver
Creating volume "zabbix-server_zabbix-db-data" with default driver
Creating volume "zabbix-server_grafana-data" with default driver
Pulling zabbix-java-gateway (zabbix/zabbix-java-gateway:alpine-4.0.0)...
alpine-4.0.0: Pulling from zabbix/zabbix-java-gateway
c67f3896b22c: Pull complete
c1558a16d921: Pull complete
27655c385e03: Pull complete
e22ef898bc90: Pull complete
f5ad13d25342: Pull complete
9ae333385282: Pull complete
Digest: sha256:7f2960f5f2259b4878f8060e07a031a99af281584a59005bd60398ea4d11678d
Status: Downloaded newer image for zabbix/zabbix-java-gateway:alpine-4.0.0
Pulling zabbix-snmptraps (zabbix/zabbix-snmptraps:alpine-4.0.0)...
alpine-4.0.0: Pulling from zabbix/zabbix-snmptraps
c67f3896b22c: Already exists
5b0db4061ed0: Pull complete
5e74ab534e66: Pull complete
caf91f450bd9: Pull complete
4678420317b7: Pull complete
Digest: sha256:80b8cbad16e391c5e7442f6455e88b4dc9aea40b0b021936cb893c1a5316cbd9
Status: Downloaded newer image for zabbix/zabbix-snmptraps:alpine-4.0.0
Pulling db_data_mysql (busybox:)...
latest: Pulling from library/busybox
90e01955edcd: Pull complete
Digest: sha256:2a03a6059f21e150ae84b0973863609494aad70f0a80eaeb64bddd8d92465812
Status: Downloaded newer image for busybox:latest
Pulling mysql-server (mysql:5.7)...
5.7: Pulling from library/mysql
f17d81b4b692: Pull complete
c691115e6ae9: Pull complete
41544cb19235: Pull complete
254d04f5f66d: Pull complete
4fe240edfdc9: Pull complete
0cd4fcc94b67: Pull complete
8df36ec4b34a: Pull complete
b8edeb9ec9e2: Pull complete
2b5adb9b92bf: Pull complete
5358eb71259b: Pull complete
e8d149f0c48f: Pull complete
Digest: sha256:42bab37eda993e417c5e7d751f1008b653c3fd85ad6aa416a519f1616c27e4a8
Status: Downloaded newer image for mysql:5.7
Pulling zabbix-server (zabbix/zabbix-server-mysql:alpine-4.0.0)...
alpine-4.0.0: Pulling from zabbix/zabbix-server-mysql
d6a5679aa3cf: Pull complete
ebe85b3518cd: Pull complete
9a3e8101f2d7: Pull complete
843372e56a3c: Pull complete
Digest: sha256:70c6b9cdb7f5d72a61355340bb5f4c219f29476b864b92f67728f2ae8af4c704
Status: Downloaded newer image for zabbix/zabbix-server-mysql:alpine-4.0.0
Pulling zabbix-agent (zabbix/zabbix-agent:alpine-4.0.0)...
alpine-4.0.0: Pulling from zabbix/zabbix-agent
d6a5679aa3cf: Already exists
8e38f9b23f9b: Pull complete
9df8ff15d613: Pull complete
4e9761c8934a: Pull complete
d6a1a91c195b: Pull complete
211958306629: Pull complete
c3863117d270: Pull complete
Digest: sha256:9e487173c7a9f53aeb1ab234123afd626b1232a8919beb0c04bb8240096a2c02
Status: Downloaded newer image for zabbix/zabbix-agent:alpine-4.0.0
Pulling zabbix-web-nginx-mysql (zabbix/zabbix-web-nginx-mysql:alpine-4.0.0)...
alpine-4.0.0: Pulling from zabbix/zabbix-web-nginx-mysql
c67f3896b22c: Already exists
322d600f624b: Pull complete
4bbe4ac1dc97: Pull complete
8ad0b97ef8ca: Pull complete
bc091ed4f95d: Pull complete
36cfc9bc0d04: Pull complete
6c1cffb39c48: Pull complete
e7276322b127: Pull complete
e6ec7437601c: Pull complete
ab60839e3468: Pull complete
af32eff4803c: Pull complete
b2f584e78ff5: Pull complete
Digest: sha256:05d67d506b7d08b147ff3b4fa4bfdfdf82e23b1d16dd3f17e8b33f8d51b66a49
Status: Downloaded newer image for zabbix/zabbix-web-nginx-mysql:alpine-4.0.0
Pulling grafana-server (grafana/grafana:latest)...
latest: Pulling from grafana/grafana
f17d81b4b692: Already exists
67045cbd3856: Pull complete
b98206f48e21: Pull complete
2c3c2911b755: Pull complete
219c99904db5: Pull complete
6efa0f52a8aa: Pull complete
Digest: sha256:214d44aa104b26c36b235da13c0b5ca9baa75057bcd14edcea58bbbe8b596792
Status: Downloaded newer image for grafana/grafana:latest
Creating zabbix-server_grafana-server_1      ... done
Creating zabbix-server_db_data_mysql_1       ... done
Creating zabbix-server_zabbix-java-gateway_1 ... done
Creating zabbix-server_zabbix-snmptraps_1    ... done
Creating zabbix-server_mysql-server_1        ... done
Creating zabbix-server_zabbix-server_1       ... done
Creating zabbix-server_zabbix-web-nginx-mysql_1 ... done
Creating zabbix-server_zabbix-agent_1           ... done
- Waiting for Zabbix server getting ready...
- Waiting for Zabbix server getting ready...
- Waiting for Zabbix server getting ready...
- Waiting for Zabbix server getting ready...
- Waiting for Zabbix server getting ready...
- Waiting for Zabbix server getting ready...
- Waiting for Zabbix server getting ready...
- Waiting for Zabbix server getting ready...

Zabbix deployment:				... done
----------------------------------------------------------------

- Create hosts groups.
BSD servers:					... done
Windows servers:					... done
Firewalls:					... done
Routers:					... done
Switches:					... done
Netscalers:					... done
Nginx servers:					... done
Apache servers:					... done
Litespeed servers:					... done
Haproxy servers:					... done
Tomcat servers:					... done
NodeJS servers:					... done
JVM servers:					... done
IIS servers:					... done
MySQL servers:					... done
PostgreSQL servers:					... done
MongoDB servers:					... done
Oracle servers:					... done
MSSQL servers:					... done
RabbitMQ servers:					... done
Couchbase servers:					... done
Redis servers:					... done
Kafka servers:					... done
Docker servers:					... done
Kubernetes servers:					... done
Openshift servers:					... done
Mesos servers:					... done
----------------------------------------------------------------

- Create auto registration actions.
Linux auto registration action:				... done
Win auto registration action:				... done
----------------------------------------------------------------

- Tune Linux OS Template.
Create itemprototype for disk usage in %:		... done
Create item for 1 min CPU load on all cores:		... done
Create item for 5 min CPU load on all cores:		... done
Create item for 15 min CPU load on all cores:		... done
Create available memory in % item for Linux:		... done
Create CPU count item for Linux:			... done
Set filesystem discovery LLD interval to 5m:		... done
Set netif discovery LLD interval to 5m:			... done
Set total memory check interval to 10m:			... done
Set total swap check interval to 10m:			... done
----------------------------------------------------------------

- Tune Windows OS Template.
Create CPU count item for Windows:			... done
Create CPU utilization item for Windows:		... done
Disable annoying Windows service items LLD rule:	... done
Set filesystem discovery LLD interval to 5m:		... done
Set netif discovery LLD interval to 5m:			... done
Update fee mem item as percentage:			... done
Delete existing trigger for free mem:			... done
Create trigger for free mem in %:			... done
----------------------------------------------------------------

- Create a read-only user for Zabbix API.
Create API user group:				... done
Create API user:				... done
----------------------------------------------------------------

- Monitor Zabbix Server itself.
Update Zabbix host interface:			... done
Enable Zabbix agent:				... done
----------------------------------------------------------------

- Grafana configurations.
Enable grafana zabbix plugin:			... done
Create a grafana API key:			... done
Create Grafana datasource for zabbix:		... done
Delete default zabbix dashboard:		... done
Import zabbix server dashboard:			... done
Import Linux servers dashboard:			... done
Import Windows servers dashboard:		... done
Import Zabbix system status dashboard:		... done
----------------------------------------------------------------

- NOTIFICATION CONFIGURATIONS.

 Do you want to enable email notification ? (Yes or No):  yes

- Zabbix SMTP settings.
 SMTP server settings will be configured to send notifications emails.
 Please provide your SMTP server IP( or host), Port, sender email
 security prefrence and auth credentials

 Enter SMTP Server Address:  1.1.1.1
 Enter  SMTP Server Port: 25
 Enter SMTP Hello:  zabbix
 Enter Sender Email:  zabbix@test.com
 Enable connection security ? (Yes or No):  yes
 Enter connection security type? (STARTTLS or SSL/TLS):  TLS
 Enable authentication ? (Yes or No):  yes
 Enter username for SMTP Auth:  user
 Enter password for SMTP Auth:  pass

- Admin email notification settings.
 This will set the admin email address to get zabbix alerts,
 and enable the trigger action for the notifications...

 Enter an email address for admin user:  monitoring@zabbix.com
SMTP notification configuration:		... done
Set admin's email address:			... done
Enable notifications for admin group:		... done
----------------------------------------------------------------

 Do you want to enable slack notifications ? (Yes or No):  yes

- Slack settings.
This section, deploys slack notification script that placed at
https://github.com/ericoc/zabbix-slack-alertscript
Also curl and curl-dev pkgs will be installed on the zabbix server container.
An incoming web-hook integration must be created within your Slack.com account
which can be done at https://my.slack.com/services/new/incoming-webhook
Please create the webhook now and provide it.

 Enter your slack webhook uri:  https://hooks.slack.com/services/Z2SS51XLR/ZZ1AYPRDM/9P8GvImq99ytTJcmxIa0AEfQ
 Enter your slack channel:  zabbix
Slack dependency installation:			... done
Create slack mediatype :			... done
Assign slack mediatype to Admin user:		... done

Zabbix deployment finished!
```