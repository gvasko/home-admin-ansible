#!/bin/bash
set -e

if [ -f $HOME/skip-network.off ]; then
	rm $HOME/skip-network.off
	exit 0
fi

snmpget -v2c -c homeadmin sg2008 IF-MIB::ifAlias.49156
snmpset -v2c -c homeadmin sg2008 IF-MIB::ifAdminStatus.49156 i 2

snmpget -v2c -c homeadmin sg2008 IF-MIB::ifAlias.49157
snmpset -v2c -c homeadmin sg2008 IF-MIB::ifAdminStatus.49157 i 2

