#!/usr/bin/env bash
rsync -avz ~postgres/.ssh/authorized_keys nodeb:~postgres/.ssh/
rsync -avz ~postgres/.ssh/authorized_keys nodec:~postgres/.ssh/
rsync -avz ~postgres/.ssh/id_rsa* nodeb:~postgres/.ssh/
rsync -avz ~postgres/.ssh/id_rsa* nodec:~postgres/.ssh/

systemctl restart postgresql-9.4
/usr/pgsql-9.4/bin/repmgr -f /etc/repmgr/9.4/repmgr.conf master register
su - postgres -c '/usr/pgsql-9.4/bin/repmgrd -f /etc/repmgr/9.4/repmgr.conf --daemonize'
