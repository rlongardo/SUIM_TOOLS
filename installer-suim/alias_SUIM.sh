#!/bin/bash
#
sed -i '$ a \#logs"' ~/.bashrc
sed -i "$ a alias lsync='tail \-f \/home\/pacs\/modality\/logs\/SUIM_SYNC.log'" ~/.bashrc
sed -i "$ a alias lsuim='docker exec \-i suim_wildfly tail \-f wildfly\/standalone\/log\/ris\.log'" ~/.bashrc
sed -i "$ a alias larc='docker exec \-i pacs_arc tail \-f \/opt\/wildfly\/standalone\/log\/server.log'" ~/.bashrc
sed -i '$ a \#Sincronizacion' ~/.bashrc
sed -i "$ a alias slocal='\/home\/pacs\/modality\/synchSuim.sh'" ~/.bashrc
sed -i "$ a alias scentral='\/home\/pacs\/modality\/synchImage.sh'" ~/.bashrc
sed -i "$ a alias ksync='/home/pacs/modality/KIllSynch.sh'" ~/.bashrc
sed -i '$ a \#Contenedores' ~/.bashrc
sed -i "$ a alias upDocker='/home/pacs/modality/upDocker.sh'" ~/.bashrc
sed -i "$ a alias downDocker='/home/pacs/modality/downDocker.sh'" ~/.bashrc
sed -i '$ a \#Dropbox' ~/.bashrc
sed -i "$ a alias kdrop='kill \-9 \$\(ps aux \| grep dropbox \| awk \"\{print \$2\}\"\)'" ~/.bashrc
sed -i "$ a alias stdrop='watch \-n 1 dropbox status'" ~/.bashrc
sed -i '$ a \#Bases de datos' ~/.bashrc
sed -i "$ a alias bkpacs='docker exec \-i pacs_arc pg_dump \-U pacs \-Fc pacsdb \>\/home\/pacs\/pacs.backup'" ~/.bashrc
sed -i "$ a alias bksuim='docker exec \-i suim_postgres pg_dump \-U suimAdmin \-Fc suim \>\/home\/pacs\/suim.backup'" ~/.bashrc
sed -i "$ a alias logs='docker exec \-i suim_postgres psql \-U suimAdmin \-d suim \-c \"SELECT COUNT \(\*\), CURRENT_TIME FROM log WHERE status = 0\;\"'" ~/.bashrc
sed -i "$ a alias verif_unidad='docker exec \-i suim_postgres psql \-U suimAdmin \-d suim \-c \"SELECT study.id_study\, study.status\, study.registration_date\, interpretation.\* FROM study LEFT JOIN interpretation ON interpretation.fk_study_id = study.id_study where study.status IN \(14,6\) AND interpretation ISNULL AND study.registration_date \<= CURRENT_TIMESTAMP\;\"'" ~/.bashrc
