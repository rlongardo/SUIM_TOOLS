import json , re
import os, sys, logging, datetime
import openpyxl
import requests
import urllib3
from PyPDF2 import PdfReader
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

from config import BRANCH_OFFICE, get_connection, DB_CONNECTIONS, PARAMETERS_JSON, PARAMETERS_TYPE, \
    SUIM_RESULTS, IMAGE_INTERPRETATION, SUIM_CONSULTATION, TOKEN

state=os.environ.get('STATE')

def updateToken(username, Params):
    try: 
        conexion = get_connection(Params)
        cursor_query = conexion.cursor()
        cursor_query.execute(TOKEN, (username,))
        token = cursor_query.fetchall()
        conexion.close()
        headers = {'authorization': token[0][0], 'Content-Type': 'application/json;'}
        return headers
    except:
        print('Error al actualizar token')

def create_dictionary(template_file):
    workbook = openpyxl.load_workbook(template_file, data_only=True)
    worksheet = workbook.active
    headers = [cell.value for cell in worksheet[1]]
    dataDict = []
    for row in worksheet.iter_rows(min_row=2, values_only=True):
        row_dict = dict(zip(headers, row))
        dataDict.append(row_dict)
    workbook.close()
    return dataDict

#def pdf_validation(sheet,i,directory_name):

def search_files(url, tipo):
    files = {}
    for dirpath, dirnames, filenames in os.walk(url):
        for archivo in filenames:
            if archivo.endswith(tipo):
                #archivoPath = os.path.join(dirpath, archivo)
                files[archivo] = dirpath
    return files

def validation(current_files, fileName):
    sizefile  = os.stat((current_files[fileName] + '/' + fileName)).st_size
    print('size '+ str(sizefile))
    reader = PdfReader((current_files[fileName] + '/' + fileName))
    number_of_pages = len(reader.pages)
    print ('number_of_pages: ' + str(number_of_pages))
    if (sizefile != 0 and number_of_pages >=2):
        return True
    else:
        return False

def download_interpretation(directory, username, fileName, data_to_send, endpoint, interpretation):
    if not (os.path.exists(directory)):
        os.makedirs(directory)
    headers = updateToken(username , DB_CONNECTIONS[state])
    print(data_to_send)
    with requests.post(endpoint, data=json.dumps(data_to_send) ,headers=headers, verify=False, stream=True) as r:
        if r.status_code == 200:
            with open(os.path.join(directory,fileName), 'wb') as f:
                f.write(r.content)
                logging.info("El estudio con ID de interpretación " + interpretation['idinterpretation'] + " se generó correctamente")
        else:
            print(r)
            logging.warning("Revisar el archivo del estudio con ID de interpretación " + interpretation['idinterpretation'])
    

def pdfInterpretation(state, template_directory, download_directory):
    username = 'rlongardo'
    
    current_files = search_files(download_directory+'/', '.pdf') 
    #print(current_files)
    
    if state:
        print("\t[INTERPRETACIONES - PDF] :: " + state + " ")
        ip_prov = DB_CONNECTIONS[state].split()                             #Se obtienen los valores de la conexión de DB y se divide en subcadenas
        HOST = ip_prov[3][6:-1]
        endpoint = f'https://{HOST}:8091/risws/app/sc/rpsvc/{PARAMETERS_TYPE["IMAGE"][1]}'      #Tipo de reporte como argumento Ej: IMAGE_INTERPRETATION
        templates = os.listdir(template_directory)
        templates.sort()

        for file in templates:
            template_file = os.path.join(template_directory,file)
            print("\nProcesando:  " + file)
            pattern = re.compile(r'\d+')
            unit = str(pattern.findall(file)[0])
            dataDict = create_dictionary(template_file) 

            for interpretation in dataDict:
                print(interpretation)
                data_to_send = PARAMETERS_JSON['VALUES']['IMAGE']

                for data in data_to_send:
                    if data.lower() in interpretation:
                        data_to_send[data] = interpretation[data.lower()]

                fileName = interpretation['ID PACIENTE'] + '-' + "".join(filter(str.isalnum, interpretation['PACIENTE'])) + '-' + interpretation['ACCESSION NUMBER'] + '.pdf'
                data_to_send['fileName'] = fileName
                directory = os.path.join(download_directory, state , 'UMM ' + unit , interpretation['FECHA DE ESTUDIO'].strftime('%Y'), interpretation['MODALIDAD'], interpretation['FECHA DE ESTUDIO'].strftime('%m'), interpretation['FECHA DE ESTUDIO'].strftime('%d'))
                if fileName in current_files.keys():
                    validation_file = validation(current_files, fileName)
                    if validation_file:                  
                        logging.info("El estudio con ID de interpretación " + interpretation['idinterpretation'] + " ya existe")  
                    else:
                        download_interpretation(directory, username, fileName, data_to_send, endpoint, interpretation)
                else:
                    download_interpretation(directory, username, fileName, data_to_send, endpoint, interpretation)

        end = datetime.datetime.now().strftime('%d-%B-%Y %H:%M')
        print("Finalización: " + end)    

def main():
    __LOG__ = "logger-" + datetime.datetime.now().strftime("%d%m-%H-%M-%S") + ".log"
    logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s : %(levelname)s : %(message)s',
                    filename = __LOG__,
                    filemode = 'w',)
    print("[INIT] :: PDF")
    pdfInterpretation(state, sys.argv[1], sys.argv[2])

if __name__ == '__main__':
    main()

#USAGE python3 .\main_interpretacion.py "python/TEMPLATES/INTERPRETATION" "/home/pacs/interpretations"          Asignar valor a STATE