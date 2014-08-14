#!/bin/sh

echo "in system."

. /vagrant/provision/shell/common.sh
getConfig common

#--------------------------------------------------
echo " - hostname."

if [ ! -z "${hostname}" -a "${hostname}" != "off" ] ;  then
	sed -i -e "s/^\(HOSTNAME=\).*/\1${hostname}/g" /etc/sysconfig/network
	hostname ${hostname}
fi

#--------------------------------------------------
echo " - service stop."

service iptables stop
service postfix stop

#--------------------------------------------------
echo " - check localtime."

ZONEFILE=/usr/share/zoneinfo/Asia/Tokyo

NOW=`md5sum /etc/localtime | cut -d " " -f 1`
JST=`md5sum ${ZONEFILE} | cut -d " " -f 1`

if [ "${NOW}" != "${JST}" ] ; then
	echo " -- change zoneinfo."
	sudo mv /etc/localtime{,.old}
	sudo cp ${ZONEFILE} /etc/localtime
else
	echo " -- OK"
fi
#--------------------------------------------------

# check
check=`grep -e '^*.*nofile' /etc/security/limits.conf | wc -l`

if [ ${check} -ne 0 ] ; then
	exit
fi

# nofile, proc
echo "*    soft    nofile    32768" >> /etc/security/limits.conf
echo "*    hard    nofile    32768" >> /etc/security/limits.conf

sed -i -e 's/^\(\*.*\)/#\1\n\*\tsoft\tnproc\t63228\n\*\thard\tnproc\t63228/g' /etc/security/limits.d/90-nproc.conf

#--------------------------------------------------
echo " - install git."
yum install -y git > /dev/null 2>&1
#EOF
