#!/usr/bin/python3 
import sqlite3
import os

dbpath = "{{ motion_storage_dir }}/{{ motion_dbfile }}"
if os.path.exists(dbpath):
    os.remove(dbpath)

conn = sqlite3.connect(dbpath) 
c = conn.cursor()
c.execute("CREATE TABLE event ("
"event_id INTEGER PRIMARY KEY AUTOINCREMENT, " # id row unique
"cam INTEGER, " # camera id 
"name TEXT, " # camera name  - could not make work with REAL 
"start TEXT, " # timestamp date + time 
"stop TEXT, " # timestamp date + time        
"src_id INTEGER, " # id number source event
"npixels INTEGER, " # number of pixels that changed
"file TEXT, " # name of file     
"width INTEGER, " # width in pixels
"height INTEGER, " # height    
"motion_width INTEGER, " # width motion area in pixels
"motion_height INTEGER, " # height 
"center_x INTEGER, " # center of motion x coordinate
"center_y INTEGER, " # ... y coordinate
"threshold INTEGER " # threshold
");") 
conn.commit()

