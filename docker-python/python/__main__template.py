import os, time
import openpyxl
from config import get_connection, BRANCH_OFFICE, DB_CONNECTIONS, SUIM_TEMPLATE, IMAGE_INTERPRETATION

#----------------------------------------------------------------------------------------------------------VARIABLES-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
state=os.environ.get('STATE')
start_date=os.environ.get('START_DATE')
end_date=os.environ.get('END_DATE')
type=os.environ.get('TYPE')

def main():
    for project, units in BRANCH_OFFICE.items():
        if state == project:
            print(type)
            print("\nProyecto SUIM " + state)
            conn = get_connection(DB_CONNECTIONS[state])                                        #Conexión a BD SUIM postgres
            for unit in units:
                print("\nSucursal " + unit)         
                cursor_query = conn.cursor()
                if type == "DICOM":
                    cursor_query.execute(SUIM_TEMPLATE.format(start_date=start_date,end_date=end_date,branch_office=unit))
                elif type == "INTERPRETATION":
                    cursor_query.execute(IMAGE_INTERPRETATION.format(start_date=start_date,end_date=end_date,branch_office=unit))
                    headers = [column[0] for column in cursor_query.description]
                    print(headers)
                else:
                    print("Es necesario especificar el tipo de tarea que se necesita")
                    exit()
                template = cursor_query.fetchall()
                if not template:                                                                # Validación de consulta vacía
                    print(f"La consulta de la sucursal {unit} está vacía. Continuando con la siguiente sucursal\n")
                    continue
                wb = openpyxl.Workbook()                                                        # Crea un nuevo libro
                ws = wb.active                                                                  # Hoja activa
                if type == "DICOM":
                    ws.append(('ACCESSION_NUMBER','PACIENTE','ID_PACIENTE','MODALIDAD','IMÁGENES','FECHA_DE_ESTUDIO','UNIDAD'))
                elif type == "INTERPRETATION":
                    ws.append(headers)
                for item in template:
                    print(item)
                    ws.append(item)
                template_path = "/home/data/templates/"
                if not os.path.exists(template_path):
                    os.makedirs(template_path)
                wb.save(template_path + '/TEMPLATE-' + str(unit) + '.xlsx')
                print("Template de la sucursal " + str(unit) + " generado\n")
            conn.close()
    time.sleep(1)

if __name__ == "__main__":                                                                      # Llamar a la función main si este script se ejecuta como el programa principal
    main()