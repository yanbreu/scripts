#!/bin/bash

TS3_USER="ts3"

OS_ARCH=$1
if [[ ${OS_ARCH} != "x86" && ${OS_ARCH} != "amd64" ]]; then
  echo "OS Arch is not valid."
  echo "Valid values: (x86|amd64)"
  exit 1
fi

DL_HOSTER=$2
if [[ ${DL_HOSTER} != "4players" && ${DL_HOSTER} != "gamed" ]]; then
  echo "Set download hoster to 4players."
  DL_HOSTER="4players"
fi

TS3_DL_LINK=`curl -s https://www.teamspeak.com/downloads.html\#server | egrep 'https?\:\/\/(.*)/releases/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/teamspeak3-server_linux_(x86|amd64)-([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\.tar\.bz2' -o | sort -u | egrep "${DL_HOSTER}(.*)${OS_ARCH}"`
TS3_DL_TARGET="teamspeak3-server_linux.tar.bz2"

TS3_USER_DIR="/home/${TS3_USER}"
TS3_SERVER_DIR="${TS3_USER_DIR}/ts3server"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

cd /tmp
curl -so ${TS3_DL_TARGET} ${TS3_DL_LINK}

useradd -s "/usr/sbin/nologin" -c "Teamspeak 3 Server" -m ${TS3_USER}
tar xfvj ${TS3_DL_TARGET} -C "${TS3_USER_DIR}" > /dev/null
cd ${TS3_USER_DIR}

mv "teamspeak3-server_linux_${OS_ARCH}" "${TS3_SERVER_DIR}"
chown -R ${TS3_USER}:${TS3_USER} ${TS3_USER_DIR}

timeout 5 su -s "${TS3_SERVER_DIR}/ts3server_minimal_runscript.sh" ${TS3_USER} > /dev/null 2> ~/.ts3server_access.txt

TS3_INITD_SCRIPT_NAME="ts3server"
TS3_INITD_SCRIPT_URL="https://raw.githubusercontent.com/yanbreu/scripts/master/install/teamspeak/init.d/ts3server"

cd /etc/init.d/
curl -so ${TS3_INITD_SCRIPT_NAME} ${TS3_INITD_SCRIPT_URL}

chmod +x ${TS3_INITD_SCRIPT_NAME}

update-rc.d ts3server defaults
