#!/usr/bin/python3 
import sqlite3
import os

dbpath = "/home/andre/motion.db"
if os.path.exists(dbpath):
    os.remove(dbpath)

conn = sqlite3.connect(dbpath) 
c = conn.cursor()
c.execute("CREATE TABLE events ("
"row_id INTEGER PRIMARY KEY AUTOINCREMENT, " # id row unique
"cam INTEGER, " # camera id 
"start INTEGER, " # unix epoch timestamp date + time 
"stop INTEGER, " # unix epoch timestamp date + time        
"name TEXT, " # camera name 
"mfile TEXT, " # movie file
"pfile TEXT, " # picture file
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

# # modifying existing table, getting data and creating table again
# # cnx = sqlite3.connect('/media/andre/Data/Downloads/motion.db')
# # df = pd.read_sql_query("SELECT * FROM events", cnx)
# cnx1 = sqlite3.connect('/media/andre/Data/Downloads/motion1.db')
# c = cnx1.cursor()
# c.execute("CREATE TABLE events ("
# "row_id INTEGER PRIMARY KEY AUTOINCREMENT, " # id row unique
# "cam INTEGER, " # camera id 
# "start INTEGER, " # unix epoch timestamp date + time 
# "stop INTEGER, " # unix epoch timestamp date + time        
# "name TEXT, " # camera name 
# "mfile TEXT, " # movie file
# "pfile TEXT, " # picture file
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
# df['start'] = pd.to_datetime(df['start'])
# df['stop'] = pd.to_datetime(df['stop'])
# df['start']  = df['start'].map(pd.Timestamp.timestamp).astype('uint32')+10800 # convert to GMT UTC since timestamp is utc
# df['stop'] = df['stop'].map(pd.Timestamp.timestamp).astype('uint32')+10800 # convert to GMT UTC since timestamp is utc
# df = df[['cam', 'start', 'stop', 'name']+df.columns.to_list()[6:]] 
# df.iloc[:, 0] = df.iloc[:, 0].astype(np.int32)
# df.iloc[:, 1:3] = df.iloc[:, 1:3].astype(np.int64)
# df.iloc[:, 3:6] = df.iloc[:, 3:6].astype('string')
# df.iloc[:, 6:] = df.iloc[:, 6:].astype(np.int32)
# # # #df.tail()
# # must be append otherwise autoincrement doesn't work
# df.to_sql('events', cnx1, if_exists='append', index=False) # writes to file
# cnx1.close() # good practice: close connection