# Dockerized Zabbix Server 4.0 Installation Script


This script, installs and configures a dockerized zabbix 4.0 server in a fully automated way on CentOS 7 platforms.

## Usage

To invoke zabbix server installation, execute the "zabbix-server" script with "install" parameter and follow the instructions.

### Install
```
# bash scripts/zabbix-server.sh install
```

### Uninstall 

```
# bash scripts/zabbix-server.sh uninstall
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

Here's the summary:

- Installs Epel repo, docker(ce), docker compose, openssl and jq.
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
    - 
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
