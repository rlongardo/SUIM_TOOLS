BRANCH_OFFICE = {
    "BAJA CALIFORNIA" : ['01','02','03'],
    "CHIHUAHUA" : ['Central','01','02'],
    "GUERRERO" : ['Central','01','02'],
    "TLANEPANTLA" : ['01'],
    "QROO" : ['001','002','003'],
    "CHIAPAS" : ['01','02','03','04','05','06','07','08','09','10'],
    #"CHIAPAS" : ['01'],
    "JALISCO" : ['Central','01','02','03','04','05','06','07','08','09','10','11','12','13','14'],
    "MORELOS" : ['Central','01','02', '03'],
    "DEMO" : ['06']
}

DB_CONNECTIONS = {
    "BAJA CALIFORNIA" : "dbname='suim' user='suimAdmin' password='3r1ll4m2021' host='192.168.100.110' port='5442'",
    "CHIHUAHUA" : "dbname='suim' user='suimAdmin' password='3r1ll4m2021' host='192.168.100.40' port='5442'",
    "GUERRERO" : "dbname='suim' user='suimAdmin' password='3r1ll4m2021' host='192.168.100.140' port='5442'",
    "TLANEPANTLA" : "dbname='suim' user='suimAdmin' password='3r1ll4m2021' host='192.168.100.130' port='5442'",
    "QROO" : "dbname='suim' user='suimAdmin' password='3r1ll4m2021' host='192.168.100.60' port='5442'",
    "CHIAPAS" :  "dbname='suim' user='suimAdmin' password='3r1ll4m2021' host='192.168.100.100' port='5442'",
    "JALISCO" : "dbname='suim' user='suimAdmin' password='3r1ll4m2021' host='192.168.100.30' port='5442'",
    "MORELOS" : "dbname='suim' user='suimAdmin' password='3r1ll4m2021' host='192.168.100.200' port='5442'",
    "VITALMEX" : "dbname='sitdris1' user='root' password='3r1ll4mSqlP4ssw0rd' host='192.168.0.103' port='3306'",
    "ARC" : "dbname='pacsdb' user='pacs' password='pacs' host='{HOST}' port='5432'"
}

TOKEN = '''select jwt from "user" where username = %s'''

PARAMETERS_TYPE={
    "IMAGE" : ["Interpretación de imagen","rp01"],
    "LABORATORIO" : ["Resultado de laboratorio","rp13"],
    "CONSULTA EXTERNA" : ["Nota médica","rp02"],
    "CONSULTA EXTERNA 2" : ["Receta médica","rp05"],
    "CONSULTA EXTERNA 3" : ["Receta médica","rp19"],
    "CONSULTA EXTERNA 4" : ["Historia clínica","rp30"],
    "CONSULTA DENTAL" : ["Consulta dental","rp14"],
    "PSICOLOGÍA" : ["Consulta psicología","rp32"],
    "OPTOMETRÍA " : ["Consulta optometría","rp35"]
}

PARAMETERS_JSON={
    "VALUES":{
        "IMAGE": {"idInterpretation": "","interpretationText": "","fileName": "","withImages" :True},
        "LABORATORIO": {"idStudy": "","interpretationText": "","fileName": ""},
        "CONSULTA EXTERNA(NOTA)": {"idConsultation": "","idDiagnostic": "","fileName":""},
        "CONSULTA EXTERNA(RECETA)": {"idPrescription":"","url":"","fileName":""},
        "CONSULTA EXTERNA(ORDEN)": {"idConsultation":"","idDiagnostic":"","fileName":""},
        "CONSULTA EXTERNA(HISTORIA)": {"idConsultation":"","idDiagnostic":"","fileName":""},
        "CONSULTA DENTAL": {"idConsultation":"","idDiagnostic":"","fileName":""},
        "PSICOLOGÍA": {"idMedicalPractice":"","fileName":"","idBranchOffice":"","idPatient":""},
        "OPTOMETRÍA": {"idMedicalPractice":"","fileName":"","idBranchOffice":"","idPatient":""}
    }
}

SUIM_TEMPLATE="""SELECT 
        study.accession_number AS an,
        concat(person."name",' ',person.first_lastname,' ', person.second_lastname ) as PACIENTE,
        patient.id_patient as ID_PACIENTE,
    	study_modality.acronym as modalidad,
    	study.quantity_images as imagenes,
    	study.registration_date as FECHA_DE_ESTUDIO,
        CASE 
        	WHEN person.fk_branch_office_id = 'C-2' THEN 'Unidad_1'
        	WHEN person.fk_branch_office_id = 'C-3' THEN 'Unidad_2'
        	WHEN person.fk_branch_office_id = 'C-4' THEN 'Unidad_3'
        	WHEN person.fk_branch_office_id = 'C-5' THEN 'Unidad_4'
        	WHEN person.fk_branch_office_id = 'C-6' THEN 'Unidad_5'
        	WHEN person.fk_branch_office_id = 'C-7' THEN' Unidad_6'
        	WHEN person.fk_branch_office_id = 'C-8' THEN 'Unidad_7'
        	WHEN person.fk_branch_office_id = 'C-9' THEN 'Unidad_8'
        	WHEN person.fk_branch_office_id = 'C-10' THEN 'Unidad_9'
            WHEN person.fk_branch_office_id = 'C-11' THEN 'Unidad_10'
        	WHEN person.fk_branch_office_id = 'C-12' THEN 'Unidad_11'
        	WHEN person.fk_branch_office_id = 'C-13' THEN 'Unidad_12'
        	WHEN person.fk_branch_office_id = 'C-14' THEN 'Unidad_13'
            WHEN person.fk_branch_office_id = 'C-1' THEN 'Central'
        END AS unidad
    
        FROM person
        INNER JOIN patient ON patient.fk_person_id = person.id_person
        INNER JOIN clinical_event ON clinical_event.fk_patient_id = patient.id_patient
        INNER JOIN appointment ON appointment.fk_clinical_event_id = clinical_event.id_clinical_event
        INNER JOIN consulting_room ON consulting_room.id_consulting_room = appointment.fk_consulting_room_origin
        INNER JOIN branch_office ON branch_office.id_branch_office = consulting_room.fk_branch_office_id
        INNER JOIN study ON study.fk_appointment_id  = appointment.id_appointment
        INNER JOIN study_modality ON study_modality.id_study_modality = study.fk_study_modality_id 
        INNER JOIN modality	ON modality.id_modality = study_modality.fk_modality_id
    
        WHERE study.status IN (5,6)
        AND study.registration_date >= '{start_date}'
        AND study.registration_date <= '{end_date}'
        AND branch_office.budget_key = '{branch_office}'
        --AND study_modality.acronym = 'DXA'
        --AND study.accession_number = 'ANC5-73329'
        ORDER BY branch_office.id_branch_office,study.registration_date ASC"""

SITDRIS_TEMPLATE="""SELECT
    bcp.accesionNumber as "ACCESSION_NUMBER",
    concat(pa.primerApellido, ' ', pa.segundoApellido, ' ', pa.primerNombre, ' ', pa.segundoNombre) as "PACIENTE",
	pa.idPaciente as "ID_PACIENTE",
	cm.descripcion as "MODALIDAD",
	cp.imagenes as "IMÁGENES",
	cp.fechaHora as "FECHA_DE_ESTUDIO", 
    CASE 
    	WHEN `cp`.`idsucursal` LIKE "1" THEN "Unidad_1"
	    WHEN `cp`.`idsucursal` LIKE "2" THEN "Unidad_2"
		WHEN `cp`.`idsucursal` LIKE "3" THEN "Unidad_3"
		WHEN `cp`.`idsucursal` LIKE "4" THEN "Unidad_4"
		WHEN `cp`.`idsucursal` LIKE "5" THEN "Unidad_5"
		WHEN `cp`.`idsucursal` LIKE "6" THEN "Unidad_6"
		WHEN `cp`.`idsucursal` LIKE "7" THEN "Unidad_7"
		WHEN `cp`.`idsucursal` LIKE "8" THEN "Unidad_8"
		WHEN `cp`.`idsucursal` LIKE "9" THEN "Unidad_9"
		WHEN `cp`.`idsucursal` LIKE "10" THEN "Unidad_10"
		WHEN `cp`.`idsucursal` LIKE "11" THEN "Unidad_11"
		WHEN `cp`.`idsucursal` LIKE "12" THEN "Unidad_12"
		WHEN `cp`.`idsucursal` LIKE "13" THEN "Unidad_13"
		WHEN `cp`.`idsucursal` LIKE "14" THEN "Unidad_14"
		WHEN `cp`.`idsucursal` LIKE "15" THEN "Unidad_15"
	END as "UNIDAD"
    FROM
    pacientes pa
    INNER JOIN cuenta cu ON cu.idPaciente = pa.idPaciente
    INNER JOIN cuenta_partidas cp ON cp.idCuenta = cu.idCuenta
    INNER JOIN bitacora_cuentap bcp ON bcp.idCuentaPartida = cp.idCuentaPartida
    LEFT JOIN  interpretaciones inter ON inter.idCuentaPartida = cp.idCuentaPartida
    INNER JOIN productos p ON p.idProducto = cp.idProducto 
    INNER JOIN cat_modalidad cm ON cm.idModalidad = p.idModalidad

    WHERE
    (cp.fechaHora >= '{start_date}')
    AND (`cp`.`fechaHora` <= '{end_date}')
    AND (`cp`.`idsucursal` LIKE '{branch_office}')
    AND (`cp`.`imagenes` IS NOT NULL or '0');"""

PACS_STUDIES="""
  SELECT 
        study.study_iuid
  FROM study 
  INNER JOIN patient ON patient.pk = study.patient_fk 
  INNER JOIN series ON series.study_fk = study.pk
  WHERE study.accession_no = '{accessionNumber}' limit 1;"""

PACS_STUDIES_DXA="""
  SELECT 
        study.study_iuid
  FROM study 
  INNER JOIN patient ON patient.pk = study.patient_fk
  INNER JOIN patient_id ON patient_id.pk = patient.patient_id_fk 
  INNER JOIN series ON series.study_fk = study.pk
  WHERE patient_id.pat_id = '{accessionNumber}' limit 1;"""

IMAGE_INTERPRETATION="""SELECT 
        interpretation.id_interpretation as idInterpretation,
        study.accession_number AS "ACCESSION NUMBER",
        concat(person."name",' ',person.first_lastname,' ', person.second_lastname ) as "PACIENTE",
        patient.id_patient as "ID PACIENTE",
        modality.acronym as "MODALIDAD",
        study_modality.name as "PERFIL DE ESTUDIO",
        study.quantity_images as "IMAGENES",
        study.registration_date as "FECHA DE ESTUDIO"

        FROM person
        INNER JOIN patient on person.id_person = patient.fk_person_id
        INNER JOIN branch_office on branch_office.id_branch_office = person.fk_branch_office_id
        INNER JOIN clinical_event on patient.id_patient = clinical_event.fk_patient_id
        INNER JOIN appointment on clinical_event.id_clinical_event = appointment.fk_clinical_event_id
        INNER JOIN study on appointment.id_appointment = study.fk_appointment_id
        INNER JOIN study_modality on study.fk_study_modality_id = study_modality.id_study_modality
        INNER JOIN modality on study_modality.fk_modality_id = modality.id_modality
        INNER JOIN speciality on modality.fk_speciality_id = speciality.id_speciality
        INNER JOIN interpretation on study.id_study = interpretation.fk_study_id

         
        WHERE study.status IN (6) and interpretation.status = 1
        AND study.registration_date >= '{start_date}'
        AND study.registration_date <= '{end_date}'
        AND branch_office.budget_key = '{branch_office}'
        --AND study_modality.acronym = 'DXA'
        --AND study.accession_number = 'ANC5-73329'
        ORDER BY branch_office.id_branch_office,study.registration_date ASC"""


SUIM_RESULTS="""
select patient.id_patient,
       concat(person.name, ' ', person.first_lastname, ' ', person.second_lastname),
       concat(modality.acronym, '-', modality.name),
       case
           when modality.fk_speciality_id = 3 then 'LABORATORIO'
               end,
       to_char(study.close_date, 'yyyy'),
       to_char(study.close_date, 'mm'),
       to_char(study.close_date, 'dd'),
       study.id_study,
       study_modality.name
FROM study
         INNER JOIN appointment ON study.fk_appointment_id = appointment.id_appointment
    AND study.status IN (13)
         INNER JOIN clinical_event ON appointment.fk_clinical_event_id = clinical_event.id_clinical_event
         INNER JOIN consulting_room ON appointment.fk_consulting_room_destination = consulting_room.id_consulting_room
         INNER JOIN branch_office ON consulting_room.fk_branch_office_id = branch_office.id_branch_office
         INNER JOIN patient ON clinical_event.fk_patient_id = patient.id_patient
         INNER JOIN person ON patient.fk_person_id = person.id_person
         INNER JOIN study_modality ON study.fk_study_modality_id = study_modality.id_study_modality
         INNER JOIN modality ON study_modality.fk_modality_id = modality.id_modality
                AND modality.fk_speciality_id = 3
         LEFT JOIN laboratory_label ON study.fk_laboratory_label_id = laboratory_label.id_laboratory_label
where study.close_date between '2022-01-01 00:00:00' and '2022-12-31 23:59:59'
  and branch_office.budget_key = '{}' order by patient.id_patient asc
"""

SUIM_CONSULTATION="""
select
       p2.id_patient                                                 as "ID PACIENTE",
       concat(p.name, ' ', p.first_lastname, ' ', p.second_lastname) as "PACIENTE",
       'CONSULTA DENTAL' AS "MODALIDAD",
       sp.name,
       to_char(medical_practice.registration_date, 'yyyy'),
       to_char(medical_practice.registration_date, 'mm'),
       to_char(medical_practice.registration_date, 'dd'),
       medical_practice.id_medical_practice,
       diagnostic.id_diagnostic,
       medical_practice.registration_date
from person p
         join patient p2 on p.id_person = p2.fk_person_id
         join branch_office bo on bo.id_branch_office = p.fk_branch_office_id
         join clinical_event ce on p2.id_patient = ce.fk_patient_id
         join appointment a on ce.id_clinical_event = a.fk_clinical_event_id
         join medical_practice ON medical_practice.fk_appointment_id = a.id_appointment
         join speciality sp on medical_practice.speciality = sp.id_speciality
         join diagnostic on diagnostic.fk_medical_practice_id = medical_practice.id_medical_practice
where medical_practice.registration_date between '2022-01-01 00:00:00' and '2022-12-21 23:59:59'
  and medical_practice.status = 3 AND medical_practice.speciality = 4
  and bo.budget_key = '{}' order by medical_practice.registration_date asc;
"""

