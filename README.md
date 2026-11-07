**This bash script installs a Surface kernel on top of a fresh openSUSE Tumbleweed installation on a Surface laptop.**

- For the Surface kernel, until autumn 2026, all credits to https://download.opensuse.org/download/repositories/home:/MadZero:
- For the Surface kernel, from autumn 2026, all credits to https://download.opensuse.org/download/repositories/home:/twaggs:

***All needed requirements, actions, cleanups and settings are included:***
- to be done: Check on root rights and Surface hardware
- to be done: After last boot no sleep-mode should be happened
- to be done: Disable repo(s) on a device (USB-stick)
- Adding Surface kernel repo
- Setting lock on future install/upgrade of the default openSUSE kernel
- Install Surface kernel ... ofcourse
- Install Intel Precise Touch & Stylus daemon
- Handles all the bootmenu stuff
- One-time install Surface kernel MOK

***Installation and execution***
- Download the file **InstallSurfaceKernel.sh**
- Open a Terminal
- Go to the download folder: **cd** *< path download folder >*
- Make file executable: **chmod a+x InstallSurfaceKernel.sh**
- Execute file with root permission: **./InstallSurfaceKernel.sh**

***Nice to haves***
- In case of btrfs: cleaning intermediate snapshots
- Prevent or cleanup duplicates in bootmenu
- ... *(let me know)* ...

