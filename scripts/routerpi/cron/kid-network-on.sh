#!/bin/bash
set -e

if [ -f $HOME/skip-network.on ]; then
	rm $HOME/skip-network.on
	exit 0
fi

snmpget -v2c -c homeadmin sg2008 IF-MIB::ifAlias.49156
snmpset -v2c -c homeadmin sg2008 IF-MIB::ifAdminStatus.49156 i 1

snmpget -v2c -c homeadmin sg2008 IF-MIB::ifAlias.49157
snmpset -v2c -c homeadmin sg2008 IF-MIB::ifAdminStatus.49157 i 1

