import pandas as pd
import logging
from sqlalchemy import create_engine
import pyodbc
import os

# Configuración de logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

try:
    # Autenticación a la base de datos de origen (Alzheimer)
    server = 'CARLOS_LAPTOP\\MSSQLSERVER01'
    database_source = 'Alzheimer'
    driver = 'ODBC Driver 17 for SQL Server'
    connection_string = f'mssql+pyodbc://@{server}/{database_source}?driver={driver}&trusted_connection=yes'
    
    engine = create_engine(connection_string)
    conn_source = pyodbc.connect(f'DRIVER={driver};SERVER={server};DATABASE={database_source};Trusted_Connection=yes;')
    cursor_source = conn_source.cursor()

    # Verificar la existencia de la tabla y crearla si no existe
    cursor_source.execute("""
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Alzheimer')
    BEGIN
        CREATE TABLE Alzheimer (
            RowId VARCHAR(255),
            YearStart VARCHAR(255),
            YearEnd VARCHAR(255),
            LocationAbbr VARCHAR(255),
            LocationDesc VARCHAR(255),
            Datasource VARCHAR(255),
            Class VARCHAR(255),
            Topic VARCHAR(255),
            Question VARCHAR(255),
            Data_Value_Unit VARCHAR(50),
            DataValueTypeID VARCHAR(50),
            Data_Value_Type VARCHAR(50),
            Data_Value DECIMAL(10, 2),
            Data_Value_Alt DECIMAL(10, 2),
            Data_Value_Footnote_Symbol VARCHAR(10),
            Data_Value_Footnote VARCHAR(255),
            Low_Confidence_Limit DECIMAL(10, 2),
            High_Confidence_Limit DECIMAL(10, 2),
            StratificationCategory1 VARCHAR(255),
            Stratification1 VARCHAR(255),
            StratificationCategory2 VARCHAR(255),
            Stratification2 VARCHAR(255),
            Geolocation VARCHAR(255),
            ClassID VARCHAR(255),
            TopicID VARCHAR(255),
            QuestionID VARCHAR(255),
            LocationID VARCHAR(255),
            StratificationCategoryID1 VARCHAR(255),
            StratificationID1 VARCHAR(255),
            StratificationCategoryID2 VARCHAR(255),
            StratificationID2 VARCHAR(255)
        );
    END
    """)
    conn_source.commit()
    
    # Truncar la tabla transformada antes de insertar nuevos datos
    cursor_source.execute("TRUNCATE TABLE Alzheimer")
    conn_source.commit()
    logging.info('Tabla Alzheimer truncada con éxito')
    
    # Lectura de la consulta SQL desde un archivo
    with open('Query.sql', 'r') as file:
        query = file.read()
        
    # Extracción de la tabla
    data = pd.read_sql_query(query, engine)
    logging.info('Data extraída con éxito')
    
    # Limpieza de datos
    data = data.fillna({
        'Data_Value': 0,
        'Data_Value_Alt': 0,
        'Data_Value_Footnote_Symbol': '',
        'Data_Value_Footnote': 'No hay informacion disponible',
        'Low_Confidence_Limit': 0,
        'High_Confidence_Limit': 0,
        'StratificationCategory1': 'No hay informacion disponible',
        'Stratification1': 'No hay informacion disponible',
        'StratificationCategory2': 'No hay informacion disponible',
        'Stratification2': 'No hay informacion disponible',
        'Geolocation': 'No hay informacion disponible'
    })
    
    # Cargar los datos limpios y transformados a la tabla final
    data.to_sql('Alzheimer', engine, if_exists='append', index=False)
    logging.info('Datos cargados con éxito en la tabla Alzheimer')

except Exception as e:
    logging.error(f'Error en el proceso ETL: {e}')
    raise

finally:
    # Cerrar la conexión a la base de datos de origen
    cursor_source.close()
    conn_source.close()

# Ejecutar el script SQL para transformar e insertar los datos
try:
    # Conectar a la base de datos SQL Server (base de datos target)
    database_target = 'DimensionalDB'
    conn_target = pyodbc.connect(f'DRIVER={driver};SERVER={server};DATABASE={database_target};Trusted_Connection=yes;')
    cursor_target = conn_target.cursor()

    # Ruta al archivo SQL
    sql_file_path = 'transform_and_insert.sql'

    # Verificar si el archivo SQL existe y ejecutarlo
    if os.path.exists(sql_file_path):
        with open(sql_file_path, 'r') as sql_file:
            sql_commands = sql_file.read()
        
        try:
            # Ejecutar los comandos SQL de truncamiento y creación de tablas
            cursor_target.execute(sql_commands)
            conn_target.commit()
            logging.info("Script SQL cargar datos a Fact y Dimensionales.")
        except Exception as e:
            logging.error(f"Error al ejecutar el  SQL: {e}")
            conn_target.rollback()
    else:
        logging.error(f"El archivo SQL '{sql_file_path}' no existe")

finally:
    # Cerrar la conexión a la base de datos de destino
    cursor_target.close()
    conn_target.close()
