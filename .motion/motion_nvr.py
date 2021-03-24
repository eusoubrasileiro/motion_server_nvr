import time, datetime, os, subprocess, re
from pathlib import Path


__motion_pictures_path__ = '/mnt/expand/518bdff5-5ae6-4193-b48b-640186b01ea0/media/motion_data/pictures/'
__motion_movies_path__ = '/mnt/expand/518bdff5-5ae6-4193-b48b-640186b01ea0/media/motion_data/movies/'

def get_size_avgfile(path):
    file_sizes = [p.stat().st_size for p in Path(path).rglob('*')]  
    total = sum(file_sizes)  
    return total, total/len(file_sizes)
    
def clean_folder_old(path='.', percent=50):
    # path = '/mnt/expand/518bdff5-5ae6-4193-b48b-640186b01ea0/media/motion_data/pictures/'
    # younger first
    files  = subprocess.check_output(['ls', '-t', path]).decode().split('\n')
    # number of files to remove
    ndelete = int(len(files)*percent/100.)
    # get oldest first
    files = files[::-1][:ndelete]
    print('motion nvr :: cleaning ', percent, ' percent files. Deleting: ', ndelete, ' files')
    for file in files:
        os.remove(file)

def check_clean_sdcard():
    """wether clean motion folders on sdcard due 90% space used"""  
    output = subprocess.check_output(['df', '/mnt/expand/518bdff5-5ae6-4193-b48b-640186b01ea0']).decode().replace('\n',' ').split(' ')
    sdcard_usage = int(output[-3][:-1]) # in percent
    print('motion nvr :: sdcard usage is: ', sdcard_usage, ' percent')
    if sdcard_usage > 90:
        # remove 90% of oldest pictures
        clean_folder_old(__motion_pictures_path__, 90) 
        # remove 50% of oldest movies
        clean_folder_old(__motion_movies_path__, 50) 

def kill_motion():
    ps = subprocess.check_output(['ps','-A']).decode()
    if ps.find('motion') != -1:
        print('motion nvr :: killing motion')
        os.system('pkill motion')
        motion_running = False
        
def start_motion():
    print('motion nvr :: starting motion')
    check_clean_sdcard()  
    os.system('cd ~/.motion && motion &')
    motion_running = True      

def kill_python_nvr():
    """kill any existing motion_nvr.py running"""
    output = subprocess.check_output(['ps', '-t']).decode()
    pss = output.split('\n')[1:-2]
    for ps in pss:
        if ps.find('motion_nvr.py') != -1:
            pid = int(re.findall('\d{3,}', ps)[0])
            if pid == current_pid:
                continue
            print("motion nvr :: killing existing running instance : pid ", pid)
            output = subprocess.check_output(['kill', str(pid)]).decode()

### main


current_pid = os.getpid()
print('motion nvr :: starting system :: pid :', current_pid)

motion_running = False
kill_python_nvr()
kill_motion()
check_clean_sdcard()

while True:    
    if not motion_running:
        if datetime.datetime.now().time() > datetime.time(hour=20):
            # time to start motion
            # run inside the configuration folder to guarantee those configurations are used
            kill_motion()
            check_clean_sdcard()
            start_motion()
            motion_running = True
    else: # running
        if datetime.datetime.now().time() > datetime.time(hour=7):
            # time to shutdown motion? or just motion detection? 
            kill_motion()
    time.sleep(15*60) # every 15 minutes only