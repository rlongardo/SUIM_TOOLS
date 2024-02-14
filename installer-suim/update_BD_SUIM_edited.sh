#!/bin/bash
#
echo -e "\nSe realiza la actualización de los registros dentro del SUIM\n"

docker exec -i suim_postgres psql -U suimAdmin -d suim -c """CREATE OR REPLACE FUNCTION "public"."prefijo"()
  RETURNS "pg_catalog"."varchar" AS $(echo '$BODY$' "begin return 'PREFIX_UMM-'; end;" '$BODY$') LANGUAGE plpgsql VOLATILE COST 100"""
docker exec -i suim_postgres psql -U suimAdmin -d suim -c "update "configuration" set value = 'AET' WHERE id_configuration = 'C-5';"
docker exec -i suim_postgres psql -U suimAdmin -d suim -c "update "configuration" set value = 'HOST_SUIM' WHERE id_configuration = 'C-6';"
docker exec -i suim_postgres psql -U suimAdmin -d suim -c "update "configuration" set value = 'dcm4chee-arc/aets/AET' WHERE id_configuration = 'C-14';"
docker exec -i suim_postgres psql -U suimAdmin -d suim -c "update "configuration" set value = 'https://CENTRAL_HOST:3000/viewer?StudyInstanceUIDs=' WHERE id_configuration = 'C-17';"
docker exec -i suim_postgres psql -U suimAdmin -d suim -c "update "configuration" set value = 'https://CENTRAL_HOST:8091/miestudio/#/login?p=' WHERE id_configuration = 'C-21';"
docker exec -i suim_postgres psql -U suimAdmin -d suim -c "update "configuration" set value = 'https://CENTRAL_HOST:8091/' WHERE id_configuration = 'C-24';"
docker exec -i suim_postgres psql -U suimAdmin -d suim -c "update "configuration" set fk_branch_office_id = 'BRANCH_OFFICE_UMM';"
docker exec -i suim_postgres psql -U suimAdmin -d suim -c "update "branch_office_person" set fk_branch_office_id = 'BRANCH_OFFICE_UMM' WHERE id_branch_office_person = 'C-2';"
docker exec -i suim_postgres psql -U suimAdmin -d suim -c "update "branch_office" set principal = 0;"
docker exec -i suim_postgres psql -U suimAdmin -d suim -c "update "branch_office" set name = 'CENTRAL_NAME' WHERE id_branch_office = 'C-1';"
docker exec -i suim_postgres psql -U suimAdmin -d suim -c "update "branch_office" set principal = 1 WHERE id_branch_office = 'BRANCH_OFFICE_UMM';"