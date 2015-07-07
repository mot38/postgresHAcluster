#!/bin/bash
echo "Promoting Standby at `date '+%Y-%m-%d %H:%M:%S'`" >>/tmp/repsetup.log
chmod 666 /tmp/repsetup.log
/usr/pgsql-9.4/bin/repmgr -f /etc/repmgr/9.4/repmgr.conf --verbose standby promote >>/tmp/repsetup.log
