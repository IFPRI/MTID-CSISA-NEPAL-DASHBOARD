!pip install mysql-connector-python
!pip install pandas mysql-connector-python
!pip install hdx-python-api

import pandas as pd
from sqlalchemy import create_engine, text 
from sqlalchemy.engine import reflection
from sqlalchemy.exc import ProgrammingError
from sqlalchemy import inspect
from sqlalchemy.orm import sessionmaker
import numpy as np

import pandas as pd
from sqlalchemy import create_engine, text 
from sqlalchemy.engine import reflection
from sqlalchemy.exc import ProgrammingError
from sqlalchemy import inspect
from sqlalchemy.orm import sessionmaker
import numpy as np
# Replace these values with your actual database information
config = {
    'user': 'admin',
    'password': 'Q3aikjweEVYoox6yyZhi',
    'host': 'nepal-dashboard-db.c5nzpjrxfrcj.us-east-1.rds.amazonaws.com',
    'database': 'fsp_data',
    'raise_on_warnings': True
    }

 # Create an SQLAlchemy engine for pandas to use
engine = create_engine(f'mysql+mysqlconnector://{config["user"]}:{config["password"]}@{config["host"]}/{config["database"]}')
Session = sessionmaker(bind=engine)
session = Session()


def truncate_existing_tables(tables):
    try:
        for table in tables:
            # Construct the TRUNCATE TABLE SQL query
            truncate_query = text(f"TRUNCATE TABLE {table}")
            
            try:
                # Execute the TRUNCATE TABLE query
                session.execute(truncate_query)
                session.commit()
                print(f"Table {table} truncated successfully.")
            except Exception as error:
                session.rollback()
                print(f"Error truncating table {table}: {error}")
    except Exception as error:
        print(f"Error connecting to the database: {error}")

def insert_Dataframe_To_DB(df, table_name):
    if not isinstance(df, pd.DataFrame):
        return False
    
    if not isinstance(table_name,str ):
        raise ValueError("table_name must be a string")   
        return False    


     # Create an SQLAlchemy engine for pandas to use
    #engine = create_engine(f'mysql+mysqlconnector://{config["user"]}:{config["password"]}@{config["host"]}/{config["database"]}')
    
    # Insert the DataFrame into MySQL, replacing the table if it exists
    df.to_sql(name=table_name, con=engine, if_exists='replace', index=False)
    

    print(f'Data successfully inserted into {table_name}.')

