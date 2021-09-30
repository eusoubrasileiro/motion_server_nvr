import time, datetime 
import subprocess
import threading as th
from pathlib import Path
import sys, os 
import re 
import requests


__home__ = str(Path.home()) 
__storage_path__ = '/home/andre/nwrouter' # target_dir for motion
__motion_pictures_path__ = os.path.join(__storage_path__,'motion_data/pictures')
__motion_movies_path__ = os.path.join(__storage_path__,'motion_data/movies')
__log_file_path__ = os.path.join(__home__, 'motion_nvr.txt')

lock = th.Lock()
# only need to lock when printing on main or background threads
log_file = open(__log_file_path__, 'w') 

cams = {'ipcam_frontwall' : {'ip' : '192.168.0.146', 'mac' : 'A0:9F:10:00:93:C6'},
  'ipcam_garage' :  { 'ip' : '192.168.0.102', 'mac' : 'A0:9F:10:01:30:D2'},
  'ipcam_kitchen' : {'ip' : '192.168.0.100', 'mac' : 'A0:9F:10:01:30:D8'}}


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


def current_hosts():
    "get current /etc/hosts"
    with open('/etc/hosts', 'r') as f:
        text = f.read()
    ipcams = re.findall('(.+)\s{4,}(ipcam_.+)', text)
    for ip, name in ipcams:
        cams[name]['ip'] = ip


# repeater is modifying the last values of the mac address
def update_hosts():
    """not having dns-server or willing to install dd-wrt (dnsmasq) for while"""
    tries=0
    while True:
        try:
            tries +=1 
            # default /etc/hosts file
            # python string formated
            hostsfile_default= "127.0.0.1       localhost\\n::1             localhost ip6-localhost ip6-loopback\\nff02::1         ip6-allnodes\\nff02::2         ip6-allrouters\\n"
            hostsfile_write_cmd = "sh -c -e \"echo 'python_string_formated_lines' > /etc/hosts\""
            # hostsfile_write_cmd.replace('python_string_formated_lines', hostsfile_default)
            #"""192.168.0.51    ipcam_frontwall
            #192.168.0.52    ipcam_garage
            #192.168.0.53    ipcam_kitchen
            #"""
            # command that workss
            #sudo -- sh -c -e "echo '127.0.0.1       localhost\n::1             localhost ip6-localhost ip6-loopback\nff02::1         ip6-allnodes\nff02::2         ip6-allrouters\n' > /etc/hosts"
            current_hosts()
            log_print('motion nvr :: current hostname ips')
            for cam, cam_ip_mac in cams.items():
                log_print("{0:<30} {1:<30} {2:30}".format(cam, cam_ip_mac['ip'], cam_ip_mac['mac']))
        
            log_print('motion nvr :: updating /etc/hosts with nmap')
            #nmap --privileged -sS 192.168.0.1 from https://secwiki.org/w/Running_nmap_as_an_unprivileged_user 
            # to avoid typing passwd again/again - need to install and config libcap
            # or 
            # export NMAP_PRIVILEGED=""
            output = subprocess.check_output(['nmap', '-p', '554,80,5000', '-T4', '--min-hostgroup', '50',
            '--max-rtt-timeout', '1000ms', '--initial-rtt-timeout', '300ms', '--max-retries', '5', '--host-timeout', '20m',
            '--max-scan-delay', '1000ms',
            '192.168.0.0/24']).decode()
            #sudo nmap -p 554,80,5000 -T4 --min-hostgroup 50 --max-rtt-timeout 1000ms --initial-rtt-timeout 300ms --max-retries 3 \
            # --host-timeout 20m --max-scan-delay 1000ms 192.168.0.0/24
        
            ips = re.findall('\d{3}\.\d{3}\.\d{1}\.\d{1,3}', output)
            macs = re.findall('(?:[0-9A-F]{2}[:-]){5}(?:[0-9A-F]{2})', output)
            for cam, cam_ip_mac in cams.items():
                for ip, mac in zip(ips, macs):
                    # compare only the last 3 groups of hex values
                    # since the repeater may have changed the first 3 groups
                    if mac[-8:] == cam_ip_mac['mac'][-8:]:
                        cams.update({cam :  {'ip' : ip, 'mac' : mac} })
        
            log_print("motion nvr :: mac's found")
            log_print(macs)
            log_print('motion nvr :: updated hostname ips')
            for cam, cam_ip_mac in cams.items():
                log_print("{0:<30} {1:<30} {2:30}".format(cam, cam_ip_mac['ip'], cam_ip_mac['mac']))
        
            hosts_cams_lines = [cam_ip_mac['ip']+' '*4+cam+'\\n' for cam, cam_ip_mac in cams.items() if cam_ip_mac['ip'] != '' ] # ignore empty ip's
            os.system(hostsfile_write_cmd.replace('python_string_formated_lines',
                  hostsfile_default+''.join(hosts_cams_lines)))
        except Exception as e:
          log_print("motion nvr :: update_hosts python exception")
          log_print(e)
          time.sleep(1)
          if tries > 3: # try 3 times
              return False
          continue
        else:
          return True


def get_size_avgfile(path):
    file_sizes = [p.stat().st_size for p in Path(path).rglob('*')]
    total = sum(file_sizes)
    return total, total/len(file_sizes)


def clean_folder_old(path='.', percent=50):
    # younger first
    files  = subprocess.check_output(['ls', '-t', path]).decode().split('\n')
    # number of files to remove
    ndelete = int(len(files)*percent/100.)
    # get oldest first
    files = files[::-1][:ndelete]
    log_print('motion nvr :: cleaning ', percent, ' percent files. Deleting: ', ndelete, ' files')
    for cfile in progressbar(files, "deleting old files: ", 50):
        cfile_path = os.path.join(path, cfile)
        if os.path.exists(cfile_path) and os.path.isfile(cfile_path):
          os.remove(cfile_path)


def check_clean_sdcard():
    """wether clean motion folders on sdcard due 90% space used"""
    output = subprocess.check_output(['df', __storage_path__]).decode().replace('\n',' ').split(' ')
    sdcard_usage = int(output[-3][:-1]) # in percent
    log_print('motion nvr :: sdcard usage is: ', sdcard_usage, ' percent')
    if sdcard_usage > 90:
        # remove 90% of oldest pictures
        clean_folder_old(__motion_pictures_path__, 90)
        # remove 50% of oldest movies
        clean_folder_old(__motion_movies_path__, 50)

def running_pids(sudo=False):
    """return list of pid's of running processes or [] empty if not running"""
    cmd = ['ps', '-eo', 'pid']
    if sudo:
      cmd = ['sudo'] + cmd      
    pids = subprocess.check_output(cmd).decode().split('\n')[1:-2]
    return [ int(pid) for pid in pids ]

def is_running_byname(name_contains, sudo=False):
    """return list of pid's of running processes or [] empty if not running"""
    # ignore last command that's ps itself
    cmd = ['ps', '-eo', 'pid,cmd']
    if sudo:
        cmd = ['sudo'] + cmd
    pss = subprocess.check_output(cmd).decode().split('\n')[1:-2]
    # ps -eo pid,cmd # format specifiers to see all list ps L
    # above only pid and command
    pids = []
    for ps in pss:
        if ps.find(name_contains) != -1:
          pid = int(re.findall('\d{3,}', ps)[0]) #PID
          pids.append(pid)
    return pids

def kill_byname(name_contains,current_pid=os.getpid()):
    for pid in is_running_byname(name_contains, False):   
        if pid == current_pid: 
            continue # prevent suicide
        while pid in running_pids(False): # try to kill as many times as needed                        
            os.system('kill '+ str(pid))
        log_print("motion nvr :: killed by name contains: ", name_contains, " and pid: ", pid)            

def is_running_motion():
    if is_running_byname('motiond'):
      return True
    return False


def kill_motion():
    kill_byname('motiond')


def kill_python_nvr():
    kill_byname('motion_nvr.py')


def start_motion():
    log_print('motion nvr :: starting motion')
    # run inside the configuration folder to guarantee those configurations are used
    return subprocess.Popen('cd ~/android_ldeploy_nvr/motion_config && motiond -d 6', stdout=subprocess.PIPE,
          stderr=subprocess.PIPE, shell=True, universal_newlines=True)


def update_motion_config():
    # check if main config file already using the proper storage path
    with open('motion.conf', 'r') as file:
        content = file.read()
    target_dir = re.findall('target_dir /.+', content)[0].split('target_dir')[1].strip()   
    mask_file /home/android 
    if target_dir != __storage_path__: # not using create new file
        re.sub('target_dir /.+', 'target_dir '+__storage_path__+'/motion_data', content)


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
    check_clean_sdcard()    # should also clean log-file once in a while to not make it huge
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
        check_clean_sdcard()    # should also clean log-file once in a while to not make it huge
        update_hosts()

def main_wrapper():
    try:
        main()
    except Exception as e:
        log_print("motion nvr :: Python exception")
        log_print(e)
        log_print("motion nvr :: restarting")
        main_wrapper()

if __name__ == "__main__":
    main_wrapper()        

# rclone mount -vv nvr_remote:sda1 /home/android/nvr_dir --daemon 
