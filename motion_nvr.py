import time, datetime 
import subprocess
import threading as th
import traceback
import sys, os, re
import requests
import argparse
from pathlib import Path


__home__ = '' # must be full path since a service is run by root
__storage_path__ = '' # target_dir for motion
__motion_pictures_path__ = ''
__motion_movies_path__ = ''
__log_file_path__ = ''

lock = th.Lock()
# only need to lock when printing on main or background threads
log_file = None

# hostnames cannot have _ underscore in its name
# https://stackoverflow.com/questions/3523028/valid-characters-of-a-hostname
# givin errors systemd-resolved 
cams = {'ipcam.frontwall' : {'ip' : '192.168.0.146', 'mac' : 'A0:9F:10:00:93:C6'},
  'ipcam.garage' :  { 'ip' : '192.168.0.102', 'mac' : 'A0:9F:10:01:30:D2'},
  'ipcam.kitchen' : {'ip' : '192.168.0.100', 'mac' : 'A0:9F:10:01:30:D8'}}


def progressbar(it, prefix="", size=60, file=sys.stdout):
    count = len(it)
    def show(j):
        x = int(size*j/count)
        file.write("%s[%s%s] %i/%i\r" % (prefix, "#"*x, "."*(size-x), j, count))
        file.flush()
    show(0)
    for i, item in enumerate(it):
        yield item
        show(i+1)
    file.write("\n")
    file.flush()


def log_print(*args, **kwargs):
    with lock:    
        print(time.strftime("%Y-%m-%d %H:%M:%S")," ".join(map(str,args)), file=log_file,**kwargs)
        if kwargs.get('print_stdout', True):    # by default don't print on stdout - since inside tmux and log-file already exists     
            print(time.strftime("%Y-%m-%d %H:%M:%S")," ".join(map(str,args)),**kwargs)

def background_print_motion_logs(popen_file):
    def print_output(popen_file):
        for line in iter(popen_file.readline, ''):
            log_print(line, end='') # printing to stdout
        popen_file.close()
    thout = th.Thread(target=print_output, args=(popen_file.stdout,)) # sons of daemon are daemons
    therr = th.Thread(target=print_output, args=(popen_file.stderr,))
    thout.start()
    therr.start()


# repeater is modifying the first values of the mac address
def update_hosts():
    """not having dns-server or willing to install dd-wrt (dnsmasq) for while"""
    tries=0
    while True:
        try:
            tries +=1 
            log_print('motion nvr :: updating /etc/hosts with nmap') 
            log_print('motion nvr :: current hostname ips')
            for cam, attr in cams.items():
                log_print("{0:<30} {1:<30} {2:30}".format(cam, attr['ip'], attr['mac']))

            # get ips from cameras macs
            # same as arp-scan -localnet but don't need root
            neighbours = subprocess.check_output(['ip', 'neighbour', 'show']).decode() 
            ips = re.findall('\d{3}\.\d{3}\.\d{1}\.\d{1,3}', neighbours)
            macs = re.findall('(?:[0-9A-Fa-f]{2}[:-]){5}(?:[0-9A-Fa-f]{2})', neighbours)
            macs = [ mac.upper() for mac in macs] # make sure all upper-case 
            log_print("motion nvr :: mac's found")
            log_print(macs)

            for cam, attr in cams.items():
                for ip, mac in zip(ips, macs):
                    # compare only the last 3 groups of hex values
                    # since the repeater may have changed the first 3 groups
                    if mac[-8:] == attr['mac'][-8:]:
                        cams[cam]['ip'] = ip

            log_print('motion nvr :: updated hostname ips')
            for cam, attr in cams.items():
                log_print("{0:<30} {1:<30} {2:30}".format(cam, attr['ip'], attr['mac']))

            # update file /etc/hosts ip -> name
            with open('/etc/hosts', 'r') as f:
                fhosts = f.readlines()
            
            # in case hosts doesnt have cameras hostnames 
            # this wont add the cameras ips
            with open('/etc/hosts', 'w') as f: 
                for line in fhosts:
                    _, hostname = re.findall('(\S+)\s+(\S+)', line)[0] # ip, hostname
                    hostname = hostname.strip()
                    if hostname in cams:
                        #print(hostname+' '*4+cams[hostname]['ip'])
                        f.write(cams[hostname]['ip']+' '*4+hostname+'\n')
                    else:
                        f.write(line)
                        #print(line[:-1])
        except Exception:
          log_print("motion nvr :: update_hosts python exception")
          log_print(traceback.format_exc())
          time.sleep(1)
          if tries > 3: # try 3 times
              return False
          continue
        else:
          return True



def recover_space(space_max=300, perc_pics=20, perc_vids=60):
    """run cleanning motion folders files reclaiming space used (older files first)
    * space_max : float (default 300 GB)
        maximum folder size in GB
    * perc_pics : float 
        percentage of space_max to reclaim from the pictures folder
    * perc_vids : float
        percentage of space_max to reclaim from the video folder
    """
    def clean_old_files(path='.', percent=50):        
        files  = subprocess.check_output(['ls', '-t', path]).decode().split('\n') # -t younger first        
        ndelete = int(len(files)*percent/100.) # number of files to remove        
        files = files[::-1][:ndelete] # get oldest first
        log_print('motion nvr :: cleaning ', percent, ' percent files. Deleting: ', ndelete, ' files')
        for cfile in progressbar(files, "deleting old files: ", 50):
            cfile_path = os.path.join(path, cfile)
            if os.path.exists(cfile_path) and os.path.isfile(cfile_path):
                os.remove(cfile_path)

    def folder_size(folder: str) -> float:
        """folder size in GB"""
        return sum(p.stat().st_size for p in Path(folder).rglob('*'))/(1024**3)

    space_usage = folder_size(__storage_path__)    
    log_print('motion nvr :: space usage is: ', space_usage, ' percent')
    if space_usage >= 0.9*space_max:
        clean_old_files(__motion_pictures_path__, perc_pics) # remove % of oldest pictures
        clean_old_files(__motion_movies_path__, perc_vids) # remove % of oldest movies

def psrunning_byname(name_contains):
    """return list of pid's of running processes or [] empty if not running
    if str.name contains"""
    # ignore last command that's ps itself
    cmd = ['ps', '-eo', 'pid,cmd']
    pss = subprocess.check_output(cmd).decode().split('\n')[1:-2]
    # 'ps -eo pid,cmd' format specifiers to see ps with
    # only pid and command
    pids = []
    for ps in pss:
        if ps.find(name_contains) != -1:
          pid = int(re.findall('\d{3,}', ps)[0]) #PID
          pids.append(pid)
    return pids

def kill_byname(name_contains, current_pid=os.getpid()):
    pids = psrunning_byname(name_contains)   
    while pids:
        for pid in pids:
            if pid == current_pid:  # self motion pid
                if len(pids) == 1: # only self running - everybody else dead
                    return 
                continue # prevent suicide            
            # try to kill as many times as needed                        
            os.system('kill '+ str(pid))
            log_print("motion nvr :: killed by name contains: ", name_contains, " and pid: ", pid)     
        pids = psrunning_byname(name_contains)   

def is_running_motion():
    if psrunning_byname('motiond'):
      return True
    return False

def kill_motion():
    kill_byname('motiond')

def kill_python_nvr():
    kill_byname('motion_nvr.py')

def start_motion():
    log_print('motion nvr :: starting motion')
    # run inside the configuration folder to guarantee those configurations are used
    return subprocess.Popen('cd /home/andre/motion_server_nvr/motion_config && motiond -d 6', stdout=subprocess.PIPE,
          stderr=subprocess.PIPE, shell=True, universal_newlines=True)

def set_motion_folders(dir_motion_data, dir_home):
    """Set the motion folders:
    * motion_data: str
        sets `__storage_path__`  -> target_dir (motion.conf)
    * home: str
        sets `__home__` since this can be run as .service
    """
    #if not os.path.isdir(motion_data):
    #    raise Exception("motion_data not a directory")
    __storage_path__ = dir_motion_data
    __home__ = dir_home
    __log_file_path__ = os.path.join(__home__, 'motion_nvr.txt')
    __motion_pictures_path__ = os.path.join(__storage_path__, 'pictures')
    __motion_movies_path__ = os.path.join(__storage_path__, 'movies')    
    global log_file 
    log_file = open(__log_file_path__, 'w') 

    repository_name = 'motion_server_nvr'
    # no matter what replaces the config file with passed target_dir
    with open(os.path.join(__home__, repository_name, 'motion.conf'), 'r') as file:
        content = file.read()    
    with open(os.path.join(__home__, repository_name, 'motion.conf'), 'w') as file:
        re.sub('target_dir /.+', 'target_dir '+__storage_path__, content)
        file.write(content)


regstat = re.compile('status (\w+)')
def motion_detection():
    """return detection status for all cameras
    True if all active False otherwise"""
    while True:
        try:
            log_print("motion nvr :: getting detection status")
            res = requests.get("http://localhost:8088/0/detection/status").content.decode()
            for cam_status in regstat.findall(res):
                if cam_status != 'ACTIVE':
                    return False
            return True
        except:
            time.sleep(1)
            continue

def pause_detection(bool=True):
    "True to pause all detection False to start detection'"
    cmd = 'pause' if bool else 'start'
    while True:
        try: # start/pause motion detection
            for i in range(1,4):
                requests.get('http://localhost:8088/'+str(i)+'/detection/'+cmd)
            if not motion_detection() == bool:
                break
        except Exception as e:
            log_print("motion nvr :: could not set detection parameter yet - exception: ", e)
            log_print("motion nvr :: could not set detection parameter yet - waiting")
            time.sleep(1)
            continue # try again
        else:
            log_print("motion nvr :: motion detection ", "paused" if cmd=="pause" else "restarted")
            return False if cmd=="pause" else True # detection status


def main():
    log_print('motion nvr :: starting system :: pid :', os.getpid())
    kill_python_nvr()
    kill_motion()
    recover_space()    # should also clean log-file once in a while to not make it huge
    update_hosts()
    proc_motion = start_motion()
    background_print_motion_logs(proc_motion)  # 2 threads running on background printing motion log messages
    while True:
        if not is_running_motion(): # check if motion is running
            # time to re-start motion
            kill_motion() # just to make sure
            proc_motion = start_motion()
            background_print_motion_logs(proc_motion)  # 2 threads running on background printing motion log messages
        else: # running
            if not motion_detection():
                if datetime.datetime.now().time() > datetime.time(hour=20) or datetime.datetime.now().time() < datetime.time(hour=6):
                    pause_detection(False)
            else: # detection running
                if datetime.datetime.now().time() < datetime.time(hour=20) and datetime.datetime.now().time() > datetime.time(hour=6):
                    pause_detection()
        time.sleep(15*60) # every 15 minutes only
        recover_space()    # should also clean log-file once in a while to not make it huge
        update_hosts()

def main_wrapper():
    try:
        main()
    except Exception as e:
        log_print("motion nvr :: Python exception")
        log_print(e)
        log_print("motion nvr :: restarting")
        kill_motion() # kill what's left 
        main_wrapper()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Start Motion NVR Server')
    parser.add_argument('-s','--storage-path', help='Path to store videos and pictures  -> target_dir (motion.conf)', required=True)
    parser.add_argument('-h','--home-folder', help='Path to home folder from where server will run', required=True)
    args = parser.parse_args()
    set_motion_folders(args.storage_path, args.home_folder)    
    main_wrapper()
    
# rclone mount -vv nvr_remote:sda1 /home/android/nvr_dir --daemon 
