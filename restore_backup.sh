#!/usr/bin/env bash
set -euo pipefail
 
DBNAME=${1:?DB name}
BACKUP_FILE=${2:?Backup file}
 
if systemctl is-active --quiet odoo; then
    sudo systemctl stop odoo
fi
 
sudo -u postgres psql -c "DROP DATABASE IF EXISTS \"${DBNAME}\";"
sudo -u postgres pg_restore -C -d postgres ${BACKUP_FILE}
 
sudo systemctl start odoo
echo "Database ${DBNAME} restored from ${BACKUP_FILE}"
