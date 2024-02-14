import psycopg2
import pymysql
from sshtunnel import SSHTunnelForwarder

#SITDRIS_JALISCO_SSH = { "port": "4569", "hostname": "201.144.248.134", "username": "root", "password": "n3wR00tP4ssw0rd_2019" }

def get_connection(params : str):
    try:
        return psycopg2.connect(params)
    except:
        print("Fallo la conexión: " + params)
        exit()

def get_mysql_connection():
    try:
        return pymysql.connect(
            host='127.0.0.1',
            user='root',
            password='secret',
            database='sitdris',
            port=33060
            )
    except:
        print("Can't connect to database")
        exit()

def ssh_connection(**connection_data):
    global tunnel

    tunnel = SSHTunnelForwarder(
        (connection_data.get("hostname"), connection_data.get("port")),
        ssh_username = connection_data.get("username"),
        ssh_password = connection_data.get("password"),
        remote_bind_address = ('127.0.0.1', 3306)
    )
    tunnel.start()