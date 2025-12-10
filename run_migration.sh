#!/usr/bin/env bash
set -euo pipefail
 
DBNAME=${1:?Provide DB name}
INSTALL_ROOT=/opt/odoo
VENV=${INSTALL_ROOT}/venv
LOGDIR=${INSTALL_ROOT}/log
BACKDIR=${INSTALL_ROOT}/backups
ODOO_SRC=${INSTALL_ROOT}/sources/odoo-18
OPENUPGRADE_PATH=${INSTALL_ROOT}/openupgrade/OpenUpgrade-18.0/openupgrade_scripts/scripts
DATESTR=$(date +%Y%m%d_%H%M%S)
LOGFILE=${LOGDIR}/migration_${DBNAME}_${DATESTR}.log
BACKUP_FILE=${BACKDIR}/${DBNAME}_pre_mig_${DATESTR}.dump
 
mkdir -p ${LOGDIR} ${BACKDIR}
 
echo "Backing up ${DBNAME}..."
sudo -u postgres pg_dump -Fc -f ${BACKUP_FILE} ${DBNAME}
 
if systemctl is-active --quiet odoo; then
    sudo systemctl stop odoo
fi
 
echo "Migrating DB from Odoo 17 → 18..."
sudo -u odoo -H bash -c "source ${VENV}/bin/activate; cd ${ODOO_SRC}; \
python odoo-bin -c ${INSTALL_ROOT}/config/odoo.conf -d ${DBNAME} --upgrade-path=${OPENUPGRADE_PATH} --update all --stop-after-init --load=base,web,openupgrade_framework 2>&1 | tee ${LOGFILE}; deactivate"
 
sudo systemctl start odoo
echo "Migration complete. Log: ${LOGFILE}"
