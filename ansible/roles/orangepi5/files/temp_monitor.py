"""
Uses TEMPer2 sensor from https://pcsensor.com/manuals-detail?article_id=474 
to monitor temperature at our house. Writes on a database sqlite internal 
(sensor temperature) and external temperature (probe on the end of black wire)

# this fork supports my version of TEMPer 4.1
Uses `git clone https://github.com/greg-kodama/temper.git -b TEMPer2_V4.1 -depth 1`
pip install pyserial pandas
for arm use https://conda-forge.org/miniforge/
"""

import pandas as pd 
import subprocess 
import time
from datetime import datetime
import sqlite3

# in case no permissions
# sudo chmod o+rw /dev/hidraw*

dbfile = '/home/andre/home_temperature.db'
temperpy_exec = '/home/andre/temper/temper.py'

while True:    
    cmd = f"/usr/bin/python3 {temperpy_exec}".split()
    res = subprocess.run(cmd, stdout=subprocess.PIPE, text=True) 
    temp_in, temp_out = res.stdout.split()[-6][:-1], res.stdout.split()[-3][:-1]
    now = datetime.now()
    with sqlite3.connect(dbfile) as conn:
        cursor = conn.cursor()
        cursor.execute(f"INSERT INTO home (time, temp_out, temp_in) VALUES (?, ?, ?)", (datetime.now(), float(temp_out), float(temp_in)))
        conn.commit()    
    time.sleep(60*5) # every 5 minutes