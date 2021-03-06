import MySQLdb
import glob
import os
import re

os.chdir("./fixtures/init")

def execute_scripts_from_file(filename):
    fd = open(filename, 'r')
    sqlFile = fd.read()
    fd.close()
    sqlCommands = re.split(';\n', sqlFile)

    for command in sqlCommands:
        try:
            if command.strip() != '':
                cursor.execute(command)
        except IOError:
            print('Command skipped: ' + command)

def get_sql_files():
    sql_files = glob.glob('./*.sql')
    sql_files.sort()
    return sql_files

def main():
    for sql_file in get_sql_files():
        execute_scripts_from_file(sql_file)
        cnx.commit()

if __name__ == "__main__":
    if bool(os.environ['DEBUGFLAG']) == True:
        config = {
        'user': os.environ['MYSQL_USER'],
        'password': os.environ['MYSQL_PASSWORD'],
        'host': os.environ['MYSQL_HOST'],
        'database' : os.environ['MYSQL_DATABASE'],
        }
        cnx = MySQLdb.connect(**config)
        cursor = cnx.cursor()

        main()
        cursor.close()
        cnx.close()
