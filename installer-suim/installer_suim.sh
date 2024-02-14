#!/bin/bash
#
UMM=2
AET=SUIM2
STATE=puebla
PREFIX=PUE
VERSION="1.17"
DICOM_PORT=11112
BRANCH_OFFICE_NUMB=3
STATE_UPPER=${STATE^^}
STATE_LOWER=${STATE,,}
IP_SERVER=$(hostname -I | awk '{print $1}')                                 #Obtiene la dirección IP del servidor
HOST_CENTRAL="$STATE_LOWER.rispacsmx.com"
HOST_UMM="$STATE_LOWER$UMM.rispacsmx.com"
HOST_OLD=$(cat /etc/hosts | grep 127.0.0.1 | awk '{print $2}' | wc -l)      #Se cuentan el número de apariciones de 127.0.0.1, en el caso inicial sólo debería existir "127.0.0.1    localhost"

if [ $VERSION == "1.17.6" ]; then
    echo -e "Descarga y descompresión de los contenedores correspondientes a la versión 1.17.6\n"
    curl -L -o "Contenedores para UMM V1.17.6.zip" "https://www.dropbox.com/scl/fi/fv9b7yyf734e34lnu5aq5/Contenedores-para-UMM-V1.17.6.zip?rlkey=pnsb00emfb0b0zwak0swi6qxx&dl=0" && unzip -q "Contenedores para UMM V1.17.6.zip"
    mv "Contenedores para UMM V1.17.6"/* /home/pacs
    sleep 2
    rm -r "Contenedores para UMM V1.17.6" "Contenedores para UMM V1.17.6.zip"

elif [ $VERSION == "1.17.5" ]; then
    echo -e "Descarga y descompresi  n de los contenedores correspondientes a la version 1.17.5\n"
    curl -L -o "Contenedores para UMM V1.17.5.zip" "https://www.dropbox.com/scl/fi/gcxzqj0ye1aafp3mjrw5h/Contenedores-para-UMM-V1.17.5.zip?rlkey=5h7czir7bjjlnxuyye4cstxz6&dl=0" && unzip -q "Contenedores para UMM V1.17.5.zip"
    mv "Contenedores para UMM V1.17.5"/* /home/pacs
    sleep 2
    rm -r "Contenedores para UMM V1.17.5" "Contenedores para UMM V1.17.5.zip"

else
    echo -e "Descarga y descompresión de los contenedores correspondientes a la versión 1.17\n"
    curl -L -o "Contenedores para UMM V1.17.zip" "https://www.dropbox.com/scl/fi/z1ut7n8yiqw1ry9gn4z7x/Contenedores-para-UMM-V1.17.zip?rlkey=ggrm5yg6au6uyhcttlym8ysss&dl=0" && unzip -q "Contenedores para UMM V1.17.zip"
    mv "Contenedores para UMM V1.17"/* /home/pacs
    sleep 2
    rm -r "Contenedores para UMM V1.17" "Contenedores para UMM V1.17.zip"
fi

docker_compose_version=$(docker compose version | grep version | awk '{print $1}')          #Validación de instalación de Docker Compose v2
echo -e "\n$(docker compose version) detectada\n"
if [ $docker_compose_version == "Docker" ]; then
    echo "Se actualizan los scripts up/downDocker"
    sed -i 's/docker-compose \-f/docker compose \-f/g' /home/pacs/modality/upDocker.sh
    sed -i 's/docker-compose \-f/docker compose \-f/g' /home/pacs/modality/downDocker.sh
else
    echo -e "No es necesario actualizar los scripts up/downDocker"
fi

if [ $HOST_OLD -ge 2 ]; then
    echo -e "\nSe actualizan los host antiguos\n"
    sed -i '$d' /etc/hosts
    sed -i '$d' /etc/hosts
    if [ $UMM -ne 0 ]; then
        sed -i "$ a 127.0.0.1       $STATE_UPPER-0$UMM" /etc/hosts
        sed -i "$ a 127.0.0.1       $HOST_UMM" /etc/hosts
    else
        sed -i "$ a 127.0.0.1       $STATE_UPPER-CENTRAL" /etc/hosts
        sed -i "$ a 127.0.0.1       $HOST_CENTRAL" /etc/hosts
    fi
else
    echo -e "\nSe agregan los host nuevos\n"
    if [ $UMM -ne 0 ]; then
        sed -i "$ a 127.0.0.1       $STATE_UPPER-0$UMM" /etc/hosts
        sed -i "$ a 127.0.0.1       $HOST_UMM" /etc/hosts
    else
        sed -i "$ a 127.0.0.1       $STATE_UPPER-CENTRAL" /etc/hosts
        sed -i "$ a 127.0.0.1       $HOST_CENTRAL" /etc/hosts
    fi
fi

echo -e "Se realizan las actualizaciones de permisos y propiedades de los archivos del SUIM-PACS\n"
sleep 2
cp update_BD_SUIM.sh update_BD_SUIM.sh.bak

chmod 755 -R /home/pacs/docker-suim /home/pacs/docker-pacs /home/pacs/docker-cloudbeaver /home/pacs/docker-viewer /home/pacs/docker-unifi /home/pacs/modality
chown -R root:pacs /home/pacs/docker-suim/ /home/pacs/docker-pacs/ /home/pacs/modality/ /home/pacs/docker-cloudbeaver/ /home/pacs/docker-viewer/ /home/pacs/docker-unifi/

cp /home/pacs/docker-suim/docker-compose.yml /home/pacs/docker-suim/docker-compose.yml.bak
sed -i "s/HOST_IP_SUIM/$IP_SERVER/g" /home/pacs/docker-suim/docker-compose.yml

cp /home/pacs/docker-pacs/docker-compose.yml /home/pacs/docker-pacs/docker-compose.yml.bak
sed -i "s/HOST_IP_SUIM/$IP_SERVER/g" /home/pacs/docker-pacs/docker-compose.yml

cp /home/pacs/docker-suim/docker-compose.env /home/pacs/docker-suim/docker-compose.env.bak
sed -i 's/POSTGRES_USER=.*/POSTGRES_USER=suimAdmin/g' /home/pacs/docker-suim/docker-compose.env
sed -i 's/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=3r1ll4m2021/g' /home/pacs/docker-suim/docker-compose.env
sed -i 's/POSTGRES_DB=.*/POSTGRES_DB=suim/g' /home/pacs/docker-suim/docker-compose.env

cp /home/pacs/docker-pacs/docker-compose.env /home/pacs/docker-pacs/docker-compose.env.bak
sed -i "s/AE_TITLE=.*/AE_TITLE=$AET/g" /home/pacs/docker-pacs/docker-compose.env
sed -i "s/DICOM_PORT=.*/DICOM_PORT=$DICOM_PORT/g" /home/pacs/docker-pacs/docker-compose.env

cp /home/pacs/docker-pacs/wildfly/configuration/dicom-dcm4chee-arc.properties /home/pacs/docker-pacs/wildfly/configuration/dicom-dcm4chee-arc.properties.bak
sed -i "s/arc.aet=.*/arc.aet=$AET/g"  /home/pacs/docker-pacs/wildfly/configuration/dicom-dcm4chee-arc.properties
sed -i "s/arc.port=.*/arc.port=$DICOM_PORT/g" /home/pacs/docker-pacs/wildfly/configuration/dicom-dcm4chee-arc.properties
sed -i 's/arc.host=.*/arc.host=172.1.0.50/g' /home/pacs/docker-pacs/wildfly/configuration/dicom-dcm4chee-arc.properties

cp /home/pacs/modality/respaldoBD.sh /home/pacs/modality/respaldoBD.sh.bak

cp /home/pacs/docker-viewer/config/html/app-config.js /home/pacs/docker-viewer/config/html/app-config.js.bak
sed -i "s/VIEWER_NAME/$STATE/g" /home/pacs/docker-viewer/config/html/app-config.js
sed -i "s/CENTRAL_HOST/$HOST_CENTRAL/g" /home/pacs/docker-viewer/config/html/app-config.js

cp /home/pacs/modality/application.properties /home/pacs/modality/application.properties.bak
sed -i "s/spring.local.datasource.url=.*/spring.local.datasource.url=jdbc:postgresql:\/\/172.1.0.10:5432\/suim/g" /home/pacs/modality/application.properties
sed -i "s/spring.local.datasource.username=.*/spring.local.datasource.username=suimAdmin/g" /home/pacs/modality/application.properties
sed -i "s/spring.local.datasource.password=.*/spring.local.datasource.password=3r1ll4m2021/g" /home/pacs/modality/application.properties
sed -i "s/spring.central.datasource.username=.*/spring.central.datasource.username=suimAdmin/g" /home/pacs/modality/application.properties
sed -i "s/spring.central.datasource.password=.*/spring.central.datasource.password=3r1ll4m2021/g" /home/pacs/modality/application.properties
sed -i "s/idCentral=.*/idCentral=C-1/g" /home/pacs/modality/application.properties
sed -i "s/idLocal=.*/idLocal=C-$((1+$UMM))/g" /home/pacs/modality/application.properties
sed -i "s/prefix.central=.*/prefix.central=$PREFIX/g" /home/pacs/modality/application.properties
sed -i "s/idBranchOffice=.*/idBranchOffice=C-$((1+$UMM))/g" /home/pacs/modality/application.properties

sed -i "s/AET/$AET/g" /home/pacs/update_BD_SUIM.sh
sed -i "s/CENTRAL_HOST/$HOST_CENTRAL/g" /home/pacs/update_BD_SUIM.sh
sed -i "s/BRANCH_OFFICE_UMM/C-$((1+$UMM))/g" /home/pacs/update_BD_SUIM.sh
sed -i "s/CENTRAL_NAME/${STATE^} Central/g" /home/pacs/update_BD_SUIM.sh

cron=$(grep -q respaldoBD /var/spool/cron/crontabs/root >/dev/null && echo "exists" || echo "no_exist")
if [ $cron == "no_exist" ]; then
    sed -i '$ a #Ejecuta el respaldo de las bases de datos y carpeta del PACS' /var/spool/cron/crontabs/root
    sed -i '$ a */60 * * * *        /home/pacs/modality/respaldoBD.sh' /var/spool/cron/crontabs/root
    sed -i '$ G' /var/spool/cron/crontabs/root
fi

if [ $UMM -eq 0 ]; then
    echo -e "Se realizan las actualizaciones para el servidor de $STATE_UPPER CENTRAL\n"
    sleep 3
    sed -i "$ a $STATE_UPPER-CENTRAL" /etc/hostname
    sed -i "1d" /etc/hostname
    sed -i "s/HOST_SUIM/$HOST_CENTRAL/g" /home/pacs/docker-suim/docker-compose.yml
    sed -i "s/HOST_SUIM/$HOST_CENTRAL/g" /home/pacs/docker-pacs/docker-compose.yml
    sed -i "s/PACS_VOLUME/\/mnt\/PACS\/MOVILES Dropbox\/$STATE_UPPER\/CENTRAL\/ONLINE_STORAGE/g" /home/pacs/docker-pacs/docker-compose.yml
    sed -i "s/ARCHIVE_HOST=.*/ARCHIVE_HOST=$HOST_CENTRAL/g" /home/pacs/docker-pacs/docker-compose.env
    sed -i "s/AUTH_SERVER_URL=.*/AUTH_SERVER_URL=https:\/\/$HOST_CENTRAL:8843/g" /home/pacs/docker-pacs/docker-compose.env
    sed -i "s/KC_HOSTNAME=.*/KC_HOSTNAME=$HOST_CENTRAL/g" /home/pacs/docker-pacs/docker-compose.env
    sed -i "s/BD_BACKUP_VOLUME/\"\/mnt\/PACS\/MOVILES Dropbox\/$STATE_UPPER\/CENTRAL\/BD\"/g" /home/pacs/modality/respaldoBD.sh
    sed -i "s/spring.central.datasource.url=.*/spring.central.datasource.url=jdbc:postgresql:\/\/172.1.0.10:5432\/suim/g" /home/pacs/modality/application.properties
    sed -i "s/prefix.local=.*/prefix.local=$PREFIX/g" /home/pacs/modality/application.properties
    mv /home/pacs/modality/application.properties /home/pacs/modality/synchImage.properties
    sed -i "s/HOST_SUIM/$HOST_CENTRAL/g"  /home/pacs/update_BD_SUIM.sh
    sed -i "s/PREFIX_UMM/$PREFIX/g" /home/pacs/update_BD_SUIM.sh
    sed -i '16,17 s/^/#/' /home/pacs/modality/upDocker.sh
    sed -i '19,20 s/^/#/' /home/pacs/modality/upDocker.sh
    sed -i '34,35 s/^/#/' /home/pacs/modality/upDocker.sh
    sed -i '37,38 s/^/#/' /home/pacs/modality/upDocker.sh
    sed -i '16,17 s/^/#/' /home/pacs/modality/downDocker.sh
    sed -i 's/SUIM_SYNC_v1.27/SUIM_IMAGE_v1.0.2/g' /home/pacs/modality/synchSuim.sh
    sed -i 's/application.properties/synchImage.properties/g' /home/pacs/modality/synchSuim.sh
    mv /home/pacs/modality/synchSuim.sh /home/pacs/modality/synchImage.sh
    for ((i = 1 ; i <= $BRANCH_OFFICE_NUMB+1 ; i++)); do                                        #Estructura para generar los respectivos XCC.sh de acuerdo al número de sucursales del proyecto
        cp /home/pacs/modality/XCC.sh /home/pacs/modality/$i"CC".sh
        chmod +x /home/pacs/modality/$i"CC".sh
        sed -i "s/PACS_VOLUME/\/mnt\/PACS\/MOVILES Dropbox\/$STATE_UPPER\/CC$$i\/ONLINE_STORAGE/g" /home/pacs/modality/$i"CC".sh
        sed -i "s/AET/$AET/g" /home/pacs/modality/$i"CC".sh
        line=$(nl /home/pacs/modality/allCC.sh | grep /"$i"CC.sh | awk '{print $1}')
        next_line="$((line+1))"
        sed -i "$line,$next_line s/^#//" /home/pacs/modality/allCC.sh
    done
    mv /home/pacs/modality/allCC.sh /etc/init.d/allCC.sh
    sudo chmod +x /etc/init.d/allCC.sh
    sudo update-rc.d allCC.sh defaults
    cron=$(grep -q synchImage /var/spool/cron/crontabs/root >/dev/null && echo "exists" || echo "no_exist")
    if [ $cron == "no_exist" ]; then
        sed -i '$ a #Se ejectua la sincronizacion de imagenes' /var/spool/cron/crontabs/root
        sed -i '$ a *\/10 * * * *        \/home\/pacs\/modality\/synchImage.sh' /var/spool/cron/crontabs/root
        sed -i '$ G' /var/spool/cron/crontabs/root
    fi
    cron=$(grep -q allCC /var/spool/cron/crontabs/root >/dev/null && echo "exists" || echo "no_exist")
    if [ $cron == "no_exist" ]; then
        sed -i '$ a #Inicia el Cfilewatcher de cada unidad para la sincronizacion' /var/spool/cron/crontabs/root
        sed -i '$ a 1 00 * * *          /etc/init.d/allCC.sh' /var/spool/cron/crontabs/root
        sed -i '$ G' /var/spool/cron/crontabs/root
    fi
    cron=$(grep -q reboot /var/spool/cron/crontabs/root >/dev/null && echo "exists" || echo "no_exist")
    if [ $cron == "no_exist" ]; then
        sed -i '$ a #Reinicio semanal programado del servidor' /var/spool/cron/crontabs/root
        sed -i '$ a 35 9 * * 2         sudo reboot' /var/spool/cron/crontabs/root
        sed -i '$ G' /var/spool/cron/crontabs/root
    fi

else
    echo -e "Se realizan las actualizaciones para el servidor de $STATE_UPPER UMM0$UMM\n\n"
    sleep 3
    sed -i "$ a $STATE_UPPER-0$UMM" /etc/hostname
    sed -i "1d" /etc/hostname
    sed -i "s/HOST_SUIM/$HOST_UMM/g" /home/pacs/docker-suim/docker-compose.yml
    sed -i "s/HOST_SUIM/$HOST_UMM/g" /home/pacs/docker-pacs/docker-compose.yml
    sed -i "s/PACS_VOLUME/\/mnt\/PACS\/MOVILES Dropbox\/$STATE_UPPER\/CC$UMM\/ONLINE_STORAGE/g" /home/pacs/docker-pacs/docker-compose.yml
    sed -i "s/ARCHIVE_HOST=.*/ARCHIVE_HOST=$HOST_UMM/g" /home/pacs/docker-pacs/docker-compose.env
    sed -i "s/AUTH_SERVER_URL=.*/AUTH_SERVER_URL=https:\/\/$HOST_UMM:8843/g" /home/pacs/docker-pacs/docker-compose.env
    sed -i "s/KC_HOSTNAME=.*/KC_HOSTNAME=$HOST_UMM/g" /home/pacs/docker-pacs/docker-compose.env
    sed -i "s/BD_BACKUP_VOLUME/\"\/mnt\/PACS\/MOVILES Dropbox\/$STATE_UPPER\/CC$UMM\/BD\"/g" /home/pacs/modality/respaldoBD.sh
    sed -i "s/spring.central.datasource.url=.*/spring.central.datasource.url=jdbc:postgresql:\/\/$HOST_CENTRAL:5442\/suim/g" /home/pacs/modality/application.properties
    sed -i "s/prefix.local=.*/prefix.local=$PREFIX/g" /home/pacs/modality/application.properties
    sed -i "s/HOST_SUIM/$HOST_UMM/g"  /home/pacs/update_BD_SUIM.sh
    sed -i "s/PREFIX_UMM/$PREFIX$UMM/g" /home/pacs/update_BD_SUIM.sh
    cron=$(grep -q synchSuim /var/spool/cron/crontabs/root >/dev/null && echo "exists" || echo "no_exist")
    if [ $cron == "no_exist" ]; then
        sed -i '$ a #Se ejectua la sincronizacion del SUIM' /var/spool/cron/crontabs/root
        sed -i '$ a *\/30 * * * *        \/home\/pacs\/modality\/synchSuim.sh' /var/spool/cron/crontabs/root
        sed -i '$ G' /var/spool/cron/crontabs/root
    fi
fi

cp /home/pacs/modality/upDocker.sh /etc/init.d/
sudo update-rc.d upDocker.sh defaults
chmod +x /etc/init.d/upDocker.sh

echo -e "Se realiza el levantamiento de los contenedores del SUIM-PACS\n"           #El primer despliegue se realiza con la bandera --build, durante las pruebas no se deplegaba correctamente el SUIM sin ella
if [ $docker_compose_version == "Docker" ]; then
    echo -e "Docker Compose v2\n"
    docker compose -f /home/pacs/docker-suim/docker-compose.yml up -d --build
else
    echo -e "Docker-compose\n"
    docker-compose -f /home/pacs/docker-suim/docker-compose.yml up -d --build
fi
sh /home/pacs/modality/restoreBD_suim.sh
sh /home/pacs/modality/upDocker.sh

chmod +x /home/pacs/update_BD_SUIM.sh
sh /home/pacs/update_BD_SUIM.sh
cp update_BD_SUIM.sh update_BD_SUIM_edited.sh
mv update_BD_SUIM.sh.bak update_BD_SUIM.sh

sudo apt install dnsmasq -y
sudo cp dnsmasq_ConfigFile /etc/dnsmasq.conf
sudo systemctl restart dnsmasq                      #Es necesario asignar los DNS estáticos 127.0.0.1,172.X.X.1,1.1.1.1
