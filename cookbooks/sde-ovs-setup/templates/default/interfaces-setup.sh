 #! /bin/bash

if [ "$1" = "" ]
then
  echo "Usage: $0 <physical interface on this system, for example eth0>"
  exit
fi

export intfc=$1

echo "The physical inetrface is $intfc"

export DIR=/etc/sysconfig/network-scripts
#DIR=/tmp/ovs

if [ ! -d "$DIR/backup" ]; then
  mkdir -p $DIR/backup
fi

# Check whether bridge over this pysical interface already exists
export brdg=`cat ifcfg-$intfc | grep BRIDGE | cut -d= -f2 | awk '{print $1}'`


if [[ "$brdg" == "" ]] ; then
	#Use the physical interface to retrieve attributes
		export srcintfc=$intfc
	else
		echo "Bridge found in the $intfc configuration file. The bridge name is $brdg"
		export srcintfc=$brdg
fi

echo "The interface attributes are retrieved from $srcintfc"
# Extract the MAC address of the pysical interface
export MAC=`ifconfig $srcintfc | awk '/HWaddr/ {print $5}'`

echo "MAC is $MAC"

# Extract the IP address
export IP=`ifconfig $srcintfc | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

echo "The IP is $IP"
# Extract the Mask
export MASK=`ifconfig $srcintfc | grep 'Mask:' | cut -d: -f4 | awk '{ print $1}'`

echo "The MASK is $MASK"

mv -f $DIR/ifcfg-$intfc $DIR/backup/
mv -f $DIR/ifcfg-$brdg $DIR/backup/
mv -f $DIR/ifcfg-mgmt $DIR/backup/
mv -f $DIR/ifcfg-data $DIR/backup/

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
IPADDR=10.11.0.4
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
IPADDR=10.12.0.4
NETMASK=255.255.0.0
TYPE=OVSIntPort
DEVICETYPE="ovs"
OVS_BRIDGE=br-$intfc
IPV6INIT=no
USERCTL=no
EOF