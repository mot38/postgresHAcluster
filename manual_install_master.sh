#!/usr/bin/env bash
su - postgres -c "ssh -o StrictHostKeyChecking=no postgres@node2  exit"
su - postgres -c "ssh -o StrictHostKeyChecking=no postgres@node3  exit"

rsync -avz ~postgres/.ssh/authorized_keys node2:~postgres/.ssh/
rsync -avz ~postgres/.ssh/authorized_keys node3:~postgres/.ssh/
rsync -avz ~postgres/.ssh/id_rsa* node2:~postgres/.ssh/
rsync -avz ~postgres/.ssh/id_rsa* node3:~postgres/.ssh/

systemctl restart postgresql-9.4
/usr/pgsql-9.4/bin/repmgr -f /etc/repmgr/9.4/repmgr.conf master register
