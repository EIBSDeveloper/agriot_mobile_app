# # myapp/management/commands/backup_db.py
# from django.core.management.base import BaseCommand
# import sqlite3
# import os

# class Command(BaseCommand):
#     help = 'Backs up the SQLite database to a .sql file'

#     def handle(self, *args, **kwargs):
#         db_path = os.path.join(os.getcwd(), 'db.sqlite3')  # Adjust to your DB file path
#         backup_file = 'backup.sql'

#         try:
#             # Connect to the SQLite database
#             conn = sqlite3.connect(db_path)
#             with open(backup_file, 'w') as f:
#                 for line in conn.iterdump():
#                     f.write(f'{line}\n')
#             conn.close()

#             self.stdout.write(self.style.SUCCESS(f'Successfully backed up database to {backup_file}'))

#         except Exception as e:
#             self.stdout.write(self.style.ERROR(f'Error backing up database: {str(e)}'))


from django.core.management.base import BaseCommand
import subprocess
import os
from django.conf import settings

class Command(BaseCommand):
    help = 'Backs up the PostgreSQL database to a .sql, .tar, .csv, or .txt file'

    def add_arguments(self, parser):
        parser.add_argument(
            '--format',
            choices=['sql', 'tar', 'csv', 'txt'],
            default='sql', 
            help='Specify the format of the backup file (sql, tar, csv, txt). Default is sql.'
        )

    def handle(self, *args, **kwargs):
        db_name = settings.DATABASES['default']['NAME']
        db_user = settings.DATABASES['default']['USER']
        db_password = settings.DATABASES['default']['PASSWORD']
        db_host = settings.DATABASES['default']['HOST']
        db_port = settings.DATABASES['default']['PORT']

        backup_format = kwargs['format']

        if backup_format == 'sql':
            backup_file = 'backup.sql'
            pg_dump_format = 'p'  
        elif backup_format == 'tar':
            backup_file = 'backup.tar'
            pg_dump_format = 't'  
        elif backup_format == 'csv':
            backup_file = 'backup.csv'
            pg_dump_format = 'c' 
        elif backup_format == 'txt':
            backup_file = 'backup.txt'
            pg_dump_format = 'p'  
        
        os.environ['PGPASSWORD'] = db_password

        try:
            pg_dump_path = r"C:\Program Files\PostgreSQL\17\bin\pg_dump.exe"
            command = [
                pg_dump_path,
                '-h', db_host,
                '-p', str(db_port),
                '-U', db_user,
                '-F', pg_dump_format, 
                '-b', 
                '-v',  
                '-f', backup_file,
                db_name
            ]
            
            subprocess.run(command, check=True)

            self.stdout.write(self.style.SUCCESS(f'Successfully backed up PostgreSQL database to {backup_file}'))

        except subprocess.CalledProcessError as e:
            self.stdout.write(self.style.ERROR(f'Error backing up database: {str(e)}'))
        except Exception as e:
            self.stdout.write(self.style.ERROR(f'Unexpected error: {str(e)}'))
