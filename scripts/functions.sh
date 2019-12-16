#!/usr/bin/env bash

source ./scripts/environmets.sh > /dev/null 2>&1 || source environmets.sh > /dev/null 2>&1

# Global functions
function Done () {
    echo -e '... \E[32m'"\033\done\033[0m"
}

function Skip () {
    echo -e '... \E[32m'"\033\skipped\033[0m"
}

function Failed () {
    echo -e '... \E[91m'"\033\ failed\033[0m"
}

function GetConfirmation() {
    while true
    do
    echo -e '\E[96m'"\033\ Do you want to continue (Yes or No): \033[0m \c"
    read  CONFIRMATION
    case $CONFIRMATION in
    Yes|yes|YES|YeS|yeS|yEs) break ;;
    No|no|NO|nO)
    echo "Exiting..."
    sleep 1
    exit
    ;;
    *) echo "" && echo -e '\E[91m'"\033\Please type Yes or No \033[0m"
    esac
    done
    echo "Continue..."
    sleep 1
}

function EchoDash() {
echo "----------------------------------------------------------------"
}

function CheckZabbix {
    cd $BASEDIR
    status=$(docker-compose ps |egrep zabbix-server |egrep " Up " || echo "Not deployed")
    }

function GetZabbixAuthToken () {
    ZBX_AUTH_TOKEN=$(curl --insecure -s \
    -H "Accept: application/json" \
    -H "Content-Type:application/json" \
     -X POST -d \
     '{"jsonrpc":"2.0",
     "method":"user.login",
     "params":
     {"user":"Admin",
     "password":"zabbix"},
     "auth":null,"id":0}' \
     $ZBX_SERVER_URL/api_jsonrpc.php |jq .result |tr -d '"')
    }

# Create a host group for Windows servers
function CreateHostGroups() {

for i in "${HOST_GROUPS[@]}"
do
PD=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "hostgroup.create",
    "params": {
        "name": "$i"
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
)

POST=$(curl -s --insecure \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-X POST --data "$PD" "$ZBX_SERVER_URL/api_jsonrpc.php"  |jq .)

if [[ "$POST" == *"error"* ]]; then
    if [[ "$POST" == *"already exists"* ]]; then
        echo -n "$i already exists." && \
        echo -ne "\t\t\t" && Skip
    else
        echo -n "An error occured. Please check the error output." && \
        echo $POST |jq .
        echo -ne "\t\t" && Failed
    fi
else
echo -n "$i:" && \
echo -ne "\t\t\t\t\t" && Done
sleep 1
fi
done
}

# Create Auto Registration for Linux hosts
function AutoRegisterLinuxPD() {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "action.create",
    "params": {
        "name": "Linux Servers",
        "eventsource": 2,
        "status": 0,
        "esc_period": "1h",
        "def_shortdata": "Auto registration: {HOST.HOST}",
        "def_longdata": "Host name: {HOST.HOST}\r\nHost IP: {HOST.IP}\r\nAgent port: {HOST.PORT}",
    "r_shortdata": "",
        "r_longdata": "",
    "ack_shortdata": "",
        "ack_longdata": "",
        "filter": {
            "evaltype": 0,
            "formula": "",
            "conditions": [
                {
                    "conditiontype": "24",
                    "operator": "2",
                    "value": "Linux",
                    "formulaid": "A"
                }
            ]
        },
            "operations": [
                {
                    "actionid": "8",
                    "operationtype": "2",
                    "esc_period": "0",
                    "esc_step_from": "1",
                    "esc_step_to": "1",
                    "evaltype": "0",
                    "opconditions": []
                },
              {
                    "actionid": "8",
                    "operationtype": "4",
                    "esc_period": "0",
                    "esc_step_from": "1",
                    "esc_step_to": "1",
                    "evaltype": "0",
                    "opconditions": [],
                    "opgroup": [
                        {
                            "operationid": "16",
                            "groupid": "2"
                        }
                    ]
                },
                {
                    "actionid": "10",
                    "operationtype": "6",
                    "esc_period": "0",
                    "esc_step_from": "1",
                    "esc_step_to": "1",
                    "evaltype": "0",
                    "opconditions": [],
                    "optemplate": [
                        {
                            "operationid": "19",
                            "templateid": "10001"
                        }
                    ]
                }
            ]
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Get win host group id
function WinHostGroupIDPD() {
cat <<EOF
{ "jsonrpc": "2.0",
          "method": "hostgroup.get",
          "params": {
            "output": "extend",
            "filter": {
                "name": [
                    "Windows servers"
                ]
            }
          },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Get host group ids
function HostGroupIDSPD() {
cat <<EOF
{ "jsonrpc": "2.0",
          "method": "hostgroup.get",
          "params": {
            "output": "extend",
            "filter": {
                "name": [
                    "${HOST_GROUPS[0]}",
                    "${HOST_GROUPS[1]}",
                    "${HOST_GROUPS[2]}",
                    "${HOST_GROUPS[3]}",
                    "${HOST_GROUPS[4]}",
                    "${HOST_GROUPS[5]}",
                    "${HOST_GROUPS[6]}",
                    "${HOST_GROUPS[7]}",
                    "${HOST_GROUPS[8]}"
                ]
            }
          },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Create Auto Registration for Windows hosts
function AutoRegisterWinPD() {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "action.create",
    "params": {
        "name": "Windows Servers",
        "eventsource": 2,
        "status": 0,
        "esc_period": "1h",
        "def_shortdata": "Auto registration: {HOST.HOST}",
        "def_longdata": "Host name: {HOST.HOST}\r\nHost IP: {HOST.IP}\r\nAgent port: {HOST.PORT}",
    "r_shortdata": "",
        "r_longdata": "",
    "ack_shortdata": "",
        "ack_longdata": "",
        "filter": {
            "evaltype": 0,
            "formula": "",
            "conditions": [
                {
                    "conditiontype": "24",
                    "operator": "2",
                    "value": "Windows",
                    "formulaid": "A"
                }
            ]
        },
            "operations": [
                {
                    "actionid": "8",
                    "operationtype": "2",
                    "esc_period": "0",
                    "esc_step_from": "1",
                    "esc_step_to": "1",
                    "evaltype": "0",
                    "opconditions": []
                },
              {
                    "actionid": "8",
                    "operationtype": "4",
                    "esc_period": "0",
                    "esc_step_from": "1",
                    "esc_step_to": "1",
                    "evaltype": "0",
                    "opconditions": [],
                    "opgroup": [
                        {
                            "operationid": "16",
                            "groupid": "$WGROUPID"
                        }
                    ]
                },
                {
                    "actionid": "10",
                    "operationtype": "6",
                    "esc_period": "0",
                    "esc_step_from": "1",
                    "esc_step_to": "1",
                    "evaltype": "0",
                    "opconditions": [],
                    "optemplate": [
                        {
                            "operationid": "19",
                            "templateid": "10081"
                        }
                    ]
                }
            ]
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

########## ITEM AND TRIGGER CONFIGURATIONS ##########
function DiskUsedPercentLinuxPD {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "itemprototype.create",
    "params": {
        "name": "Used disk space on \$1 (percentage)",
        "key_": "vfs.fs.size[{#FSNAME},pused]",
    "value_type": "0",
        "units": "%",
        "hostid": "10001",
        "ruleid": "22450",
        "type": 0,
        "delay": "1m",
        "history": "1w",
        "trends": "365d",
        "status": "0",
        "interfaceid": "0",
        "applications": [5]
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

function CreateLinuxCPULoadAllCoreItems {
GetZabbixAuthToken
INTERVAL="1 5 15"
for i in $INTERVAL
do
LinuxCPULoadAllCorePD=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "item.create",
    "params": {
        "name": "Processor load ($i min average all core)",
        "key_": "system.cpu.load[all,avg$i]",
        "hostid": "10001",
        "type": 0,
        "value_type": 0,
        "interfaceid": "0",
        "applications": ["13"],
        "delay": "1m",
    "history": "1w",
        "trends": "365d",
    "description": "The processor load is cumulative system CPU load.",
        "status": "0"
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
)

POST=$(curl -s --insecure \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-X POST --data "$LinuxCPULoadAllCorePD" "$ZBX_SERVER_URL/api_jsonrpc.php"  |jq .)

if [[ "$POST" == *"error"* ]]; then
    if [[ "$POST" == *"already exists"* ]]; then
        echo -n "Item $i min CPU load is already exists"
        echo -ne "\t\t" && Skip
    else
        echo ""
        echo -n "Create item for $i min CPU load on all cores:"
        echo -ne "\t" && Failed
        echo -n "An error occured. Please check the error output"
        echo $POST |jq .
        sleep 1
    fi
else
    echo -n "Create item for $i min CPU load on all cores:"
    echo -ne "\t\t" && Done
    sleep 1
fi
done
}

# Create total cpu count item for Linux
function AvailMemoryPercentLinuxItemPD {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "item.create",
    "params": {
        "name": "Available memory in %",
        "key_": "vm.memory.size[pavailable]",
    "value_type": "0",
        "units": "%",
        "hostid": "10001",
        "type": 0,
        "delay": "1m",
        "history": "1w",
        "trends": "365d",
        "status": "0",
        "interfaceid": "0",
        "applications": [15]
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Total cpu count item for Linux
function NumOfCPULinuxItemPD {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "item.create",
    "params": {
        "name": "Number of CPU",
        "key_": "system.cpu.num[online]",
    "value_type": "0",
        "units": "",
        "hostid": "10001",
        "type": 0,
        "delay": "1m",
        "history": "1w",
        "trends": "365d",
        "status": "0",
        "interfaceid": "0",
        "applications": [13]
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Set interval to 5m for FS discovery in linux template
function LLDFSRuleLinuxPD {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "discoveryrule.update",
    "params": {
      "hostid": "10001",
        "itemid": "22450",
        "delay": "5m"
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Set interval to 5m for network interface discovery in linux template
function LLDNetIfRuleLinuxPD {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "discoveryrule.update",
    "params": {
      "hostid": "10001",
        "itemid": "22444",
        "delay": "5m"
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Set interval to 10m for total memory check in linux template
function TotalMemoryCheckIntervalPD {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "item.update",
    "params": {
      "hostid": "10001",
        "itemid": "10026",
        "delay": "10m"
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Set interval to 10m for total swap check in linux template
function TotalSwapCheckIntervalPD {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "item.update",
    "params": {
      "hostid": "10001",
        "itemid": "10030",
        "delay": "10m"
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Create total cpu count item for Windows
function CreateNumOfCPUWinItemPD {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "item.create",
    "params": {
        "name": "Number of CPU",
        "key_": "system.cpu.num[online]",
    "value_type": "0",
        "units": "",
        "hostid": "10081",
        "type": 0,
        "delay": "1m",
        "history": "1w",
        "trends": "365d",
        "status": "0",
        "interfaceid": "0",
        "applications": [325]
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}


# Set interval to 5m for FS discovery for Windows template
function LLDFSRuleWinPD {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "discoveryrule.update",
    "params": {
      "hostid": "10081",
        "itemid": "23162",
        "delay": "5m"
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Set interval to 5m for network interface discovery for Windows template
function LLDNetIfRuleWinPD {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "discoveryrule.update",
    "params": {
      "hostid": "10081",
        "itemid": "23163",
        "delay": "5m"
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Create total cpu count item for Windows
function CPUUtilWinPD {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "item.create",
    "params": {
        "name": "CPU Utilization",
        "key_": "system.cpu.util",
    "value_type": "0",
        "units": "%",
        "hostid": "10081",
        "type": 0,
        "delay": "1m",
        "history": "1w",
        "trends": "365d",
        "status": "0",
        "interfaceid": "0",
        "applications": [325]
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Update free memory user as percent for Windows
function FreeMemPercentWinPD {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "item.update",
    "params": {
      "hostid": "10081",
        "itemid": "23158",
        "name": "Free memory in %",
        "key_": "vm.memory.size[pavailable]",
    "value_type": 0,
        "units": "%"
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Delete free memory trigger for Windows
function ExistingFreeMemTriggerWinPD {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "trigger.delete",
    "params": [
        "13433"
    ],
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Delete free memory trigger for Windows
function NewFreeMemTriggerWinPD {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "trigger.create",
    "params": {
    "description": "Lack of free memory on server {HOST.NAME}",
        "expression": "{Template OS Windows:vm.memory.size[pavailable].last(0)}<10",
        "expression_constructor": "0",
        "recovery_expression_constructor": "0",
        "status": "0",
        "priority": "3",
        "type": "0"
        },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

function DisableAnnoyingWinServiceDiscovery {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "discoveryrule.update",
    "params": {
    "hostid": "10081",
        "itemid": "23665",
        "status": "1"
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

##########  NOTIFICATIOS CONFIGURATIONS ##########

# Email related functions
function GetSMTPNotifAnswer(){
    while true
        do
        echo -e '\E[96m'"\033\ Do you want to enable email notification ? (Yes or No): \033[0m \c"
        read  SMTPEnable
        case $SMTPEnable in
        Yes|yes|YES|YeS|yeS|yEs) break ;;
        No|no|NO|nO) break ;;
        *) echo -e '\E[91m'"\033\ Please type Yes or No \033[0m"
        esac
        done
        if [[ "$SMTPEnable" =~ $yesPattern ]]; then

            # SMTP server configuration to send notifications
            echo -e ""
            echo -e '\E[96m'"\033\- Zabbix SMTP settings. \033[0m"
            echo -e '\E[1m'"\033\ SMTP server settings will be configured to send notifications emails.\033[0m"
            echo -e '\E[1m'"\033\ Please provide your SMTP server IP( or host), Port, sender email\033[0m"
            echo -e '\E[1m'"\033\ security prefrence and auth credentials\033[0m"
            sleep 1
            echo ""
            echo -e '\E[96m'"\033\ Enter SMTP Server Address: \033[0m \c"
            read SMTPServer

            echo -e '\E[96m'"\033\ Enter  SMTP Server Port:\033[0m \c"
            read SMTPServerPort
            Integer='^[0-9]+$'
            if ! [[ $SMTPServerPort =~ $Integer ]] ; then
                while ! [[ "$SMTPServerPort" =~ $Integer ]]
                do
                    echo -e '\E[91m'"\033\ Port number should be a number! Please re-enter: \033[0m \c"
                    read SMTPServerPort
                done
            fi

            echo -e '\E[96m'"\033\ Enter SMTP Hello: \033[0m \c"
            read SMTPHello

            echo -e '\E[96m'"\033\ Enter Sender Email: \033[0m \c"
            read SMTPEmail

            while true
                do
                echo -e '\E[96m'"\033\ Enable connection security ? (Yes or No): \033[0m \c"
                read  SecureConnection
                case $SecureConnection in
                Yes|yes|YES|YeS|yeS|yEs) break ;;
                No|no|NO|nO) break ;;
                *) echo -e '\E[91m'"\033\ Please type Yes or No \033[0m"
                esac
                done
            if [ "$SecureConnection" == "No" ] || [  "$SecureConnection" == "no" ] || [  "$SecureConnection" == "NO" ] || [  "$SecureConnection" == "nO" ]; then
                SecureConnection=0
            else
                while true
                do
                echo -e '\E[96m'"\033\ Enter connection security type? (STARTTLS or SSL/TLS): \033[0m \c"
                read SecurityType
                case $SecurityType in
                STARTTLS) break ;;
                SSL/TLS|SSL|TLS) break ;;
                *) echo -e '\E[91m'"\033\Invalid connection security type. Please type STARTTLS or SSL/TLS.\033[0m"
                esac
                done

                if [ "$SecurityType" == "STARTTLS" ]; then
                    SecureConnection=1
                else
                    SecureConnection=2
                fi
            fi

            while true
            do
            echo -e '\E[96m'"\033\ Enable authentication ? (Yes or No): \033[0m \c"
            read  Authentication
            case $Authentication in
            Yes|yes|YES|YeS|yeS|yEs) break ;;
            No|no|NO|nO) break ;;
            *) echo -e '\E[91m'"\033\Please type Yes or No \033[0m"
            esac
            done

            if [ "$Authentication" == "No" ] || [  "$Authentication" == "no" ] || [  "$Authentication" == "NO" ] || [  "$Authentication" == "nO" ]; then
                Authentication=0
            else
                Authentication=1
                echo -e '\E[96m'"\033\ Enter username for SMTP Auth: \033[0m \c"
                read SMTPUsername
                if [[ -z "$SMTPUsername" ]] ; then
                    while [ -z "$SMTPUsername" ]
                    do
                        echo -e '\E[91m'"\033\ Username required! Please enter the username:\033[0m \c"
                        read SMTPUsername
                    done
                fi

                echo -e '\E[96m'"\033\ Enter password for SMTP Auth: \033[0m \c"
                read SMTPPassword
                if [[ -z "$SMTPPassword" ]] ; then
                    while [ -z "$SMTPPassword" ]
                    do
                        echo -e '\E[91m'"\033\ Password required! Please enter the password: \033[0m \c"
                        read SMTPPassword
                    done
                fi
            fi

            # Set admin email to get notifications
            echo -e ""
            echo -e '\E[96m'"\033\- Admin email notification settings. \033[0m"
            echo -e '\E[1m'"\033\ This will set the admin email address to get zabbix alerts,\033[0m"
            echo -e '\E[1m'"\033\ and enable the trigger action for the notifications...\033[0m"
            echo ""
            echo -e '\E[96m'"\033\ Enter an email address for admin user: \033[0m \c"
            read SentTo

            if [[ -z "$SentTo" ]] ; then
                while [ -z "$SentTo" ]
                do
                    echo -e '\E[91m'"\033\ Email address is required!\033[0m"
                    echo -e '\E[91m'"\033\ Please enter an email:\033[0m \c"
                    read SentTo
                done
            fi
        else
            echo -n "Email notification configuration:" && \
            echo -ne "\t\t" && Skip
            sleep 1
        fi
}

function SMTPConfigPD() {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "mediatype.update",
    "params": {
        "mediatypeid": "1",
        "status": 0,
        "smtp_server": "$SMTPServer",
        "smtp_port": "$SMTPServerPort",
        "smtp_helo": "$SMTPHello",
        "smtp_email": "$SMTPEmail",
        "smtp_security": $SecureConnection,
        "smtp_authentication": $Authentication,
        "username": "$SMTPUsername",
        "passwd": "$SMTPPassword"
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

function AdminEmailPD() {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "user.update",
    "params": {
        "userid": "1",
        "user_medias": [
            {
                "mediatypeid": "1",
                "sendto": "$SentTo",
                "active": 0,
                "severity": 63,
                "period": "1-7,00:00-24:00"
            }
        ]
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Enable notification trigger action for administrators
function NotifTriggerPD() {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "action.update",
    "params": {
        "actionid": 3,
        "status": 0,
        "def_shortdata": "PROBLEM: {TRIGGER.NAME}",
        "def_longdata": "\n\nStarted: {EVENT.TIME} - {EVENT.DATE} \nHost: {HOST.NAME} - {HOST.IP1} \nLatest Value: {ITEM.LASTVALUE1} \nSeverity: {TRIGGER.SEVERITY} \n\nEvent Details: https://$ZBX_PUBLIC_IP:8443/tr_events.php?triggerid={TRIGGER.ID}&eventid={EVENT.ID} \nAcknowledge: https://$ZBX_PUBLIC_IP:8443/zabbix.php?action=acknowledge.edit&eventids[]={EVENT.ID}",
        "r_shortdata": "RESOLVED: {TRIGGER.NAME}",
        "r_longdata": "\n\nResolved: {EVENT.RECOVERY.TIME} - {EVENT.RECOVERY.DATE} \nHost: {HOST.NAME} - {HOST.IP1} \nLatest Value: {ITEM.LASTVALUE1} \nProblem Duration: {EVENT.AGE} \nSeverity: {TRIGGER.SEVERITY} \n\nEvent Details: https://$ZBX_PUBLIC_IP:8443/tr_events.php?triggerid={TRIGGER.ID}&eventid={EVENT.ID}"
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Slack related functions
function GetSlackNotifAnswer(){
    while true
    do
        echo -e '\E[96m'"\033\ Do you want to enable slack notifications ? (Yes or No): \033[0m \c"
        read  SlackEnable
        case $SlackEnable in
        Yes|yes|YES|YeS|yeS|yEs) break ;;
        No|no|NO|nO) break ;;
        *) echo -e '\E[91m'"\033\ Please type Yes or No \033[0m"
        esac
    done
    if [[ "$SlackEnable" =~ $yesPattern ]]; then
        echo -e ""
        echo -e '\E[96m'"\033\- Slack settings. \033[0m"
        echo -e '\E[1m'"\033\This section, deploys slack notification script that placed at \033[0m"
        echo -e '\E[1m'"\033\https://github.com/ericoc/zabbix-slack-alertscript \033[0m"
        echo -e '\E[1m'"\033\Also curl and curl-dev pkgs will be installed on the zabbix server container. \033[0m"

        echo -e '\E[1m'"\033\An incoming web-hook integration must be created within your Slack.com account \033[0m"
        echo -e '\E[1m'"\033\which can be done at https://my.slack.com/services/new/incoming-webhook \033[0m"
        echo -e '\E[1m'"\033\Please create the webhook now and provide it.\033[0m"
        echo ""
        sleep 1

        # Get slack webhook URL
        echo -e '\E[96m'"\033\ Enter your slack webhook uri: \033[0m \c"
        read SlackWebHook
        while [[ -z $SlackWebHook ]]
        do
          echo -e '\E[91m'"\033\ Please enter your webhook uri:\033[0m \c"
          read SlackWebHook
        done

        # Get slack channel name to send notifications
        echo -e '\E[96m'"\033\ Enter your slack channel: \033[0m \c"
        read SlackChannel
        while [[ -z $SlackChannel ]]
        do
          echo -e '\E[91m'"\033\ Please enter your channel:\033[0m \c"
          read SlackChannel
        done
        SlackChannel="#$SlackChannel"
    else
        echo -n "Slack notification configuration:" && \
        echo -ne "\t\t" && Skip
        sleep 1
    fi
}

function CreateSlackMediaTypePD () {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "mediatype.create",
    "params": {
        "description": "Slack",
        "type": 1,
        "exec_path": "slack.sh",
        "exec_params": "{ALERT.SENDTO}\n{ALERT.SUBJECT}\n{ALERT.MESSAGE}\n"
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

function AddSlackMediatoAdminPD() {
if [[ "$SMTPEnable" =~ $yesPattern ]]; then
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "user.update",
    "params": {
        "userid": "1",
        "user_medias": [
            {
                "mediatypeid": "1",
                "sendto": "$SentTo",
                "active": 0,
                "severity": 63,
                "period": "1-7,00:00-24:00"
            },
            {
                "mediatypeid": "4",
                "sendto": "$SlackChannel",
                "active": 0,
                "severity": 63,
                "period": "1-7,00:00-24:00"
            }
        ]
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
else
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "user.update",
    "params": {
        "userid": "1",
        "user_medias": [
            {
                "mediatypeid": "4",
                "sendto": "$SlackChannel",
                "active": 0,
                "severity": 63,
                "period": "1-7,00:00-24:00"
            }
        ]
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
fi
}

# API related
function GetAPIUserGroupIDPD () {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "usergroup.get",
    "params": {
        "output": "extend",
        "status": 0
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 1
}
EOF
}

# Add user group for zabbix api user
function CreateAPIUserGroupPD () {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "usergroup.create",
    "params": {
        "name": "API Users",
        "gui_access": 3,
    "users_status": 0,
    "rights": [
      {
        "permission": 2,
          "id": "4"
        },
      {
        "permission": 2,
          "id": "5"
        },
      {
        "permission": 2,
          "id": "6"
        },
        {
        "permission": 2,
          "id": "7"
        },
      {
        "permission": 2,
          "id": "8"
        },        
        {
          "permission": 2,
          "id": "${GRP_IDS_ARRAY[0]}"
        },
        {
          "permission": 2,
          "id": "${GRP_IDS_ARRAY[1]}"
        },
        {
          "permission": 2,
          "id": "${GRP_IDS_ARRAY[2]}"
        },
        {
          "permission": 2,
          "id": "${GRP_IDS_ARRAY[3]}"
        },
        {
          "permission": 2,
          "id": "${GRP_IDS_ARRAY[4]}"
        },
        {
          "permission": 2,
          "id": "${GRP_IDS_ARRAY[5]}"
        },
        {
          "permission": 2,
          "id": "${GRP_IDS_ARRAY[6]}"
        },
        {
          "permission": 2,
          "id": "${GRP_IDS_ARRAY[7]}"
        },
        {
          "permission": 2,
          "id": "${GRP_IDS_ARRAY[8]}"
        }
    ]
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

function CreateAPIUserPD () {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "user.create",
    "params": {
        "alias": "apiuser",
        "passwd": "zabbix",
        "usrgrps": [
            {
                "usrgrpid": "$API_USERS_GROUP_ID"
            }
        ]
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

# Zabbix server Host ID
function GetHostIDPD () {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "host.get",
    "params": {
        "output": "extend"
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}


function UpdateHostInterfacePD () {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "hostinterface.update",
    "params": {
        "interfaceid": "1",
        "hostids": "$ZBX_AGENT_HOST_ID",
        "type": 1,
        "useip": 0,
        "dns": "zabbix-agent",
        "port": 10050,
        "main": 1
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

function EnableZbxAgentonServerPD () {
cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "host.update",
    "params": {
        "hostid": "$ZBX_AGENT_HOST_ID",
        "host": "$ZBX_AGENT_CONTAINER_ID",
        "name": "Zabbix server",
        "status": 0
    },
    "auth": "$ZBX_AUTH_TOKEN",
    "id": 0
}
EOF
}

function CreateGRFAPIKey () {
    GRF_API_KEY=$(curl --insecure -s \
    -H "Accept: application/json" \
    -H "Content-Type:application/json" \
    -X POST -d \
     '{
      "name":"zabbix-api-key",
      "role": "Admin"
      }' \
     $GRF_SERVER_URL/api/auth/keys |jq .key |tr -d '"')
}

function CreateZbxDataSourcePD () {
cat <<EOF
{
        "orgId": 1,
        "name": "zabbix",
        "type": "alexanderzobnin-zabbix-datasource",
        "typeLogoUrl": "public/plugins/alexanderzobnin-zabbix-datasource/img/zabbix_app_logo.svg",
        "access": "proxy",
        "url": "http://zabbix-web-nginx-mysql/api_jsonrpc.php",
        "password": "zabbix",
        "user": "apiuser",
        "database": "",
        "basicAuth": false,
        "isDefault": true,
        "jsonData": {
            "dbConnection": {
                "enable": false
            },
            "keepCookies": [],
            "password": "zabbix",
            "tlsSkipVerify": true,
            "username": "apiuser"
        },
        "readOnly": false
}
EOF
}


