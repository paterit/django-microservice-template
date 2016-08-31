import socket
import time
import os

port = int(os.environ["DB_PORT"])

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
while True:
    try:
        s.connect(('{{ project_name }}-db', port))
        s.close()
        break
    except socket.error as ex:
        time.sleep(0.1)
