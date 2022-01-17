#!/usr/bin/python3 -u
# -u is needed to unbuffer print making everything go to syslog instantly 
import time 
import traceback
import subprocess
import os, re, io 
import argparse
import threading as th
import numpy as np 


# recommended approach dict as global
config = { 'home' : None,  # must be full path since a service is run by root
    'storage_path' : None, # target_dir for motion
    'motion_pictures_path' : None,
    'motion_movies_path' : None,
    'data_size' : 550.
}

lock = th.Lock()
# only need to lock when printing on main or background threads

# hostnames cannot have _ underscore in its name
# https://stackoverflow.com/questions/3523028/valid-characters-of-a-hostname
# givin errors systemd-resolved 
cams = {'ipcam.frontwall' : {'ip' : '', 'mac' : 'A0:9F:10:00:93:C6', 'name' : 'frontwall'},
  'ipcam.garage' :  { 'ip' : '', 'mac' : 'A0:9F:10:01:30:D2', 'name' : 'garage'},
  'ipcam.kitchen' : {'ip' : '', 'mac' : 'A0:9F:10:01:30:D8', 'name' : 'kitchen'},
  'ipcam.street' : {'ip' : '', 'mac' : '9C:A3:A9:6A:87:5B', 'name' : 'street'}
}


def log_print(*args, **kwargs):
    with lock:    
        # by default print on stdout -> go to syslog     
        print(time.strftime("%Y-%m-%d %H:%M:%S")," ".join(map(str,args)),**kwargs)


# repeater is modifying the first values of the mac address
def update_hosts():
    """not having dns-server or willing to install dd-wrt (dnsmasq) for while"""
    tries=0
    while True:
        try:
            tries +=1 
            log_print('motion helper :: updating /etc/hosts with `ip neighbour show`') 
            log_print('motion helper :: current hostname ips')
            for cam, attr in cams.items():
                log_print("{0:<30} {1:<30} {2:30}".format(cam, attr['ip'], attr['mac']))

            # get ips from cameras macs
            # same as arp-scan -localnet but don't need root
            neighbours = subprocess.check_output(['ip', 'neighbour', 'show']).decode() 
            ip_mac = re.findall('(\d{3}\.\d{3}\.\d{1,3}\.\d{1,3}).+((?:[0-9a-fA-F]{2}:?){6})', neighbours)
            ips, macs = zip(*ip_mac)
            macs = [ mac.upper() for mac in macs] # make sure all upper-case 
            log_print("motion helper :: ip-mac's found")
            log_print(ip_mac)
            for cam, attr in cams.items():
                cams[cam]['ip'] = '' # clean ips to only update what changed
                for ip, mac in zip(ips, macs):
                    # compare only the last 3 groups of hex values
                    # since the repeater may have changed the first 3 groups
                    if mac[-8:] == attr['mac'][-8:]:
                        cams[cam]['ip'] = ip

            log_print('motion helper :: updated hostname ips')
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
                    if hostname in cams and cams[hostname]['ip'] != '': # only update ip's that changed
                        #print(hostname+' '*4+cams[hostname]['ip'])
                        f.write(cams[hostname]['ip']+' '*4+hostname+'\n')
                    else:
                        f.write(line)
                        #print(line[:-1])
        except Exception:
          log_print("motion helper :: update_hosts python exception")
          log_print(traceback.format_exc())
          time.sleep(1)
          if tries > 3: # try 3 times
              return False
          continue
        else:
          return True


def recover_space():
    """run cleanning motion folders files reclaiming space used (older files first)
    """
    storage_path = config['storage_path'] #'/mnt/motion_data'    
    result = subprocess.run(r"find " + storage_path + r" -type f -printf '%T@;;%p;;%s\n'", 
        stdout=subprocess.PIPE, shell=True, universal_newlines=True)        
    data = np.loadtxt(io.StringIO(result.stdout), dtype=[('age', '<f8'),('path', 'U200'), ('size', 'i8')], delimiter=';;')
    data.sort(order='age') # big numbers last means younger files last
    data = data[::-1] #  (reverse it)
    space_max = config['data_size']*1024**3 # maximum size to bytes    
    sizes = np.cumsum(data['size']) # cumulative folder size starting with younger ones
    space_usage = sizes[-1]
    log_print('motion helper :: data folder size is {:.2f}  GiB'.format(space_usage/(1024**3)))
    if space_usage >= space_max : # only if folder bigger than maxsize 
        del_start = np.argmax(sizes >= space_max) # index where deleting should start             
        log_print('motion helper :: recovering space. Deleting: ', len(sizes)-del_start, ' files')        
        for path in data['path'][del_start:]:            
            os.remove(path)
    subprocess.run("find " + storage_path + " -type d -empty -delete", shell=True) # delete empty folders
    # python pathlib or os is 1000x slower than find 
    # find saving timestamp, paths of files and size (recursive)
    # find /mnt/motion_data/pictures -type f -printf '%T@;;%p;;%s\n' 


def set_motion_config(dir_motion_data, dir_home, data_size):
    """Sets the motion configuration files, paths and log-file:
    * motion_data: str
        sets `config['storage_path']`  -> target_dir (motion.conf)
    * home: str
        sets `config['home']` since this can be run as .service
    * data_size: float 
         sets `config['data_size']` maximum size folder to reclaim space
    """
    #if not os.path.isdir(motion_data):
    #    raise Exception("motion_data not a directory")
    config['storage_path'] = dir_motion_data
    config['home'] = dir_home    
    config['motion_pictures_path'] = os.path.join(config['storage_path'], 'pictures')
    config['motion_movies_path'] = os.path.join(config['storage_path'], 'movies')     
    config['data_size'] = data_size

    log_print("motion helper :: config options")

    for key, value in config.items():
        log_print(key, value)

    repository_name = 'motion_server_nvr'
    log_print("motion helper :: updating config files")
    # no matter what replaces the config file with passed target_dir
    with open(os.path.join(config['home'], repository_name, 'motion_config', 'motion.conf'), 'r') as file:
        content = file.read()    
    with open(os.path.join(config['home'], repository_name, 'motion_config', 'motion.conf'), 'w') as file:
        content = re.sub('target_dir /.+', 'target_dir '+os.path.abspath(config['storage_path']), content)        
        file.write(content)


def main():
    try:
        log_print('motion helper :: starting')
        # you can read syslog or log messages use events from motion.conf to get when thereis a disconnection or else    
        while True:            
            # takes almost forever to compute disk usage size so put on another thread  
            th.Thread(target=recover_space).start()             
            # I use syslog so I dont need to clean up self-made logs
            update_hosts()
            time.sleep(15*60) # every 15 minutes only
            # could change to events motion.conf
    except Exception as e:
        log_print("motion helper :: Python exception")
        log_print(traceback.format_exc())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Motion NVR Helper')
    parser.add_argument('-d','--data-path', help='Path to store videos and pictures (all data) -> target_dir (motion.conf)', required=True)
    parser.add_argument('-s','--server-home', help='Path to home folder from where server will run', required=True)
    parser.add_argument('-m','--data-size', help='Maximum folder data size in GB to reclaim space (delete old)', required=False, default="550")
    args = parser.parse_args()
    set_motion_config(args.data_path, args.server_home, float(args.data_size))    
    main()
    
# rclone mount -vv nvr_remote:sda1 /home/android/nvr_dir --daemon 
