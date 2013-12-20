 #! /bin/bash

if [ "$1" = "" ]
then
  echo "Usage: $0 <physical interface on this system, for example eth0>"
  exit
fi

intfc=$1
DIR=/etc/sysconfig/network-scripts
#DIR=/tmp/ovs

if [ ! -d "$DIR" ]; then
  mkdir -p $DIR/backup
fi

mv $DIR/ifcfg-$intfc $DIR/backup
mv $DIR/ifcfg-br* $DIR/backup
mv $DIR/ifcfg-mgmt $DIR/backup
mv $DIR/ifcfg-data $DIR/backup

# Extract the MAC address of the pysical interface
export MAC=`ifconfig $intfc | awk '/HWaddr/ {print $5}'`

# Extract the IP address
export IP=`ifconfig $intfc | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

# Extract the Mask
export MASK=`ifconfig $intfc | grep 'Mask:' | cut -d: -f4 | awk '{ print $1}'`

# Create the pysical interface config file
tee -a $DIR/ifcfg-$intfc <<EOF
DEVICE=$intfc
BOOTPROTO=none
HWADDR=$MAC
NM_CONTROLLED=no
ONBOOT=yes
TYPE=OVSPort
DEVICETYPE="ovs"
OVS_BRIDGE=br-$intfc
IPV6INIT=no
USERCTL=no
EOF

# Create the OVS bridge config file
tee -a $DIR/ifcfg-br-$intfc <<EOF
DEVICE=br-$intfc
ONBOOT=yes
BOOTPROTO=static
IPADDR=$IP
NETMASK=$MASK
STP=off
NM_CONTROLLED=no
HOTPLUG=no
DEVICETYPE=ovs
TYPE=OVSBridge
EOF

#Create the internal OVS bridge
tee -a $DIR/ifcfg-br-int <<EOF
DEVICE=br-int
ONBOOT=yes
BOOTPROTO=none
STP=off
NM_CONTROLLED=no
HOTPLUG=no
DEVICETYPE=ovs
TYPE=OVSBridge
EOF



#Add a new internal interface mgmt that  will serve as a management interface
tee -a $DIR/ifcfg-mgmt <<EOF
DEVICE="mgmt"
BOOTPROTO=static
NM_CONTROLLED=no
ONBOOT=yes
IPADDR=10.11.0.2
NETMASK=255.255.0.0
TYPE=OVSIntPort
DEVICETYPE="ovs"
OVS_BRIDGE=br-$intfc
IPV6INIT=no
USERCTL=no
HOTPLUG=no
EOF


#Add a new internal interface data that  will serve as a data interface
tee -a $DIR/ifcfg-data <<EOF
DEVICE="data"
BOOTPROTO=static
NM_CONTROLLED=no
ONBOOT=yes
IPADDR=10.12.0.2
NETMASK=255.255.0.0
TYPE=OVSIntPort
DEVICETYPE="ovs"
OVS_BRIDGE=br-$intfc
IPV6INIT=no
USERCTL=no
EOF