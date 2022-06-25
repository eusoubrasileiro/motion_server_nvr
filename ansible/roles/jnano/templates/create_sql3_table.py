#!/usr/bin/python3 
import sqlite3
import os

dbpath = "{{ motion_storage_dir }}/{{ motion_dbfile }}"
if os.path.exists(dbpath):
    os.remove(dbpath)

conn = sqlite3.connect(dbpath) 
c = conn.cursor()
c.execute("CREATE TABLE events ("
"row_id INTEGER PRIMARY KEY AUTOINCREMENT, " # id row unique
"id INTEGER, " # motion event id
"cam INTEGER, " # camera id 
"name TEXT, " # camera name  - could not make work with REAL 
"start TEXT, " # timestamp date + time 
"stop TEXT, " # timestamp date + time        
"mfile TEXT, " # movie file
"pfile TEXT, " # movie file
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

# modifying existing table, getting data and creating table again
# # cnx = sqlite3.connect('/media/andre/Data/Downloads/motion.db')
# # df = pd.read_sql_query("SELECT * FROM events", cnx)
# cnx1 = sqlite3.connect('/media/andre/Data/Downloads/motion1.db')
# c = cnx1.cursor()
# c.execute("CREATE TABLE events ("
# "row_id INTEGER PRIMARY KEY AUTOINCREMENT, " # id row unique
# "id INTEGER, " # motion event id
# "cam INTEGER, " # camera id 
# "name TEXT, " # camera name  - could not make work with REAL 
# "start TEXT, " # timestamp date + time 
# "stop TEXT, " # timestamp date + time        
# "mfile TEXT, " # movie file
# "pfile TEXT, " # movie file
# "nchange_pixels INTEGER, " # number of pixels that changed
# "width INTEGER, " # width in pixels
# "height INTEGER, " # height    
# "motion_width INTEGER, " # width motion area in pixels
# "motion_height INTEGER, " # height 
# "motion_cx INTEGER, " # center of motion x coordinate
# "motion_cy INTEGER, " # ... y coordinate
# "threshold INTEGER, " # threshold
# "fps INTEGER, "
# "frame INTEGER "
# ");") 
# cnx1.commit()
# #reformatting table
# df.dropna(inplace=True)
# # df.rename(columns={'event_id': 'row_id'}, inplace=True) #not needed
# df['id'] = np.int64(0)
# df = df[['id']+df.columns.to_list()[1:-1]] 
# df.iloc[:, 0:1] = df.iloc[:, 0:1].astype(np.int64)
# df.iloc[:, 1] = df.iloc[:, 1].astype(np.int32)
# df.iloc[:, 2:8] = df.iloc[:, 2:8].astype('string')
# df.iloc[:, 8:] = df.iloc[:, 8:].astype(np.int32)
# # # #df.tail()
# # must be append otherwise autoincrement doesn't work
# df.to_sql('events', cnx1, if_exists='append', index=False) # writes to file
# cnx1.close() # good practice: close connection