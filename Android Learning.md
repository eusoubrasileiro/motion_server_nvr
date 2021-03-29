Learned about Android

### Turning your Android in a server 

**Danger**: don't do this if your ssh-server/mosh-server is not running properly in Termux/LinuxDeploy. 

With root run `stop`. It will kill all services on Android/Zygote. No screen, nothing will be running.   
Type again `run` to start all services again. Learned from [ChrootOnAndroid][3].  
Mostly will release a lot of memory and threads.   
**Downside:** if your wifi restarts android will not reconnect.   
I think it's better to tweak the oom (out-of-memory) killer bellow.   

### Sometimes Android will kill your process ([reclaim memory with `oomkiller`][4]). What to do:

1. Disable battery optimization for your app

2. Set a wake_lock for forever:   
  ```su
  echo whatever_wake_lock > /sys/power/wake_lock
  ```   
  Unless you remove the wake_lock it will (supposedly) never deep-sleep.

3. Reduce killability based on [this][1] and [this][2]  
  Find the pid of your frocess/app   
  ```ps -A grep termux # for example pid is 6067```   
  Then set oom_score_adj to -1000 from scale -1000/1000 "killability"   
  ```echo -1000 > /proc/6067/oom_score_adj```   

[1]: https://android.stackexchange.com/questions/183401/is-there-a-way-with-root-to-prevent-android-task-killer-from-killing-certain
[2]: https://askubuntu.com/questions/60672/how-do-i-use-oom-score-adj
[3]: https://wiki.debian.org/ChrootOnAndroid
[4]: https://en.wikipedia.org/wiki/Out_of_memory#Out_of_memory_management


### Remounting file system for writing with su/root

```mount -o rw,remount /system```
