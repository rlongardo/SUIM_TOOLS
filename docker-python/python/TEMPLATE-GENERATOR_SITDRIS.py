import os, time
import openpyxl
import subprocess #import call
from config import get_connection, get_mysql_connection, BRANCH_OFFICE, DB_CONNECTIONS, SUIM_TEMPLATE, SITDRIS_TEMPLATE

#----------------------------------------------------------------------------------------------------------VARIABLES-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ris=os.environ.get('RIS')
state=os.environ.get('STATE')
start_date=os.environ.get('START_DATE')
end_date=os.environ.get('END_DATE')
branch_office=os.environ.get('BRANCH_OFFICE')

def main():
    # ---------------------------------------------------------------------------------------------------------Conexión BD:------------------------------------------------------------------------------------------------------------------------------
    if ris == 'SITDRIS':
        try:
            conn = get_mysql_connection(database="sitdris1")                                #Se mantiene el try en SITDRIS debido al posible montaje del servidor con el ghost 
            query= conn.cursor()
            query.execute(SITDRIS_TEMPLATE.format(start_date=start_date,end_date=end_date,branch_office=branch_office))
        except:
            print("Error, no se hizo la consulta")
            exit()
    else:
        for state, units in BRANCH_OFFICE.items():
            if state:
                conn = get_connection(DB_CONNECTIONS[state])                                        #Conexión a BD SUIM postgres          
                query = conn.cursor()
                query.execute(SUIM_TEMPLATE.format(start_date=start_date,end_date=end_date,branch_office=branch_office))
            template = query.fetchall()
            print(template)
            conn.close()
            pruebaarreglo=template[0][1]
            name_prueba=str(pruebaarreglo)
            print("EL NOMBRE ES: "+name_prueba)
            wb = openpyxl.Workbook()                                                                # Crea un nuevo libro
            ws = wb.active                                                                          # Hoja activa
            print(f'Hoja activa: {ws.title}')
            ws.append(('ACCESSION_NUMBER','PACIENTE','ID_PACIENTE','MODALIDAD','IMÁGENES','FECHA_DE_ESTUDIO','UNIDAD'))
            for item in template:
                print(item)
                ws.append(item)
            wb.save('TEMPLATE.xlsx')
            print("Template generado")
    time.sleep(3)
    subprocess.run(["python3", "DICOM_DOWNLOADER.py", "TEMPLATE.xlsx", "/home/data"])

if __name__ == "__main__":                                                                  # Llamar a la función main si este script se ejecuta como el programa principal
    main()