import socket
import time
import os
from datetime import datetime


SUCCESS = 0
ERROR = 1
INTERVAL = 0.1
MAX_RETRY = 1200

port = int(os.environ["DB_PORT"])
print("Waiting for postgres ...")
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
count = 0

while count < MAX_RETRY:
    try:
        s.connect(('{{ project_name }}-db', port))
        s.close()
        print("... postgres up and runing")
        exit(0)
    except socket.error as ex:
        print(datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3])
        print("... waiting for postgres ...")
        count += 1
        time.sleep(INTERVAL)

print("Not connected to postgres after %d with %f seconds interval!" % (MAX_RETRY, INTERVAL))
exit(ERROR)
