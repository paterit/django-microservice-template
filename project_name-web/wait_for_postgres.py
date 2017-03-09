import socket
import time
import os
from datetime import datetime


port = int(os.environ["DB_PORT"])
print("Waiting for postgres ...")
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
while True:
    try:
        s.connect(('{{ project_name }}-db', port))
        s.close()
        print("... postgres up and runing")
        break
    except socket.error as ex:
        print(datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3])
        print("... waiting ...")
        time.sleep(0.1)
