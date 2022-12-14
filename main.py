#!/usr/bin/python3
import os
from flask import Flask

app = Flask(__name__)
import psycopg2


def connect():
    """ Connect to the PostgreSQL database server """
    global db_ver
    conn = None
    try:
        # connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(dbname=os.environ["DB_NAME"], user=os.environ["DB_USER"],
                                password=os.environ["DB_PASS"], host=os.environ["DB_HOST"], port="5432")

        # create a cursor
        cur = conn.cursor()

        # execute a statement
        print('PostgreSQL database version:')
        db_ver = cur.execute('SELECT version()')

        # display the PostgreSQL database server version
        db_version = cur.fetchone()
        print(db_version)

        # close the communication with the PostgreSQL
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        print("ERROR !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')

    return db_ver


if __name__ == '__main__':
    connect()


@app.route('/')
def hello_world():
    name = os.environ.get('NAME', 'World !!!')
    return 'Hello {}!'.format(name)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT',
                                                                8080)))
