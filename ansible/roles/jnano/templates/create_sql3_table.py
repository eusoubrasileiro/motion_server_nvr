#!/usr/bin/python3 
import sqlite3
import os

dbpath = "{{ motion_storage_dir }}/{{ motion_dbfile }}"
if os.path.exists(dbpath):
    os.remove(dbpath)

conn = sqlite3.connect(dbpath) 
c = conn.cursor()
c.execute("CREATE TABLE events ("
"event_id INTEGER PRIMARY KEY AUTOINCREMENT, " # id row unique
"cam INTEGER, " # camera id 
"name TEXT, " # camera name  - could not make work with REAL 
"start TEXT, " # timestamp date + time 
"stop TEXT, " # timestamp date + time        
"source INTEGER, "
"type INTEGER, " # movie file     
"file TEXT, " # movie file
"nchange_pixels INTEGER, " # number of pixels that changed
"width INTEGER, " # width in pixels
"height INTEGER, " # height    
"motion_width INTEGER, " # width motion area in pixels
"motion_height INTEGER, " # height 
"motion_cx INTEGER, " # center of motion x coordinate
"motion_cy INTEGER, " # ... y coordinate
"threshold INTEGER, " # threshold
"fps INTEGER, "
"frame INTEGER "
");") 
conn.commit()

