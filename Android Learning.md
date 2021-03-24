Learned about Android

### Turning your Android in a server

With root run `stop`. It will kill all services



### Sometimes Android will kill your process (reclaim memory). What to do:

1. Disable battery optimization for your app

2. Set a wake_lock for forever
  su
  echo whatever_wake_lock > /sys/power/wake_lock
  unless you remove the wake_lock it will suppossely never sleep

3. Reduce killability based on [this](1) and [this][2]
  Find the pid of your frocess/app
  `ps -A grep termux` # for example pid is 6067
  Then set oom_score_adj to -1000 from scale -1000/1000 "killability"
  echo -1000 > /proc/6067/oom_score_adj

1. https://android.stackexchange.com/questions/183401/is-there-a-way-with-root-to-prevent-android-task-killer-from-killing-certain
and this
2. https://askubuntu.com/questions/60672/how-do-i-use-oom-score-adj


### Remounting file system for writing with su/root

mount -o rw,remount /system
