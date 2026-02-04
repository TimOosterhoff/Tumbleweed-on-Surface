**This bash script installs a Surface kernel on top of a fresh openSUSE Tumbleweed installation on a Surface laptop.**

For de Surface kernel all credits to https://download.opensuse.org/download/repositories/home:/MadZero:

***All needed requirements, actions, cleanups and settings are included:***
- Check on root rights and Surface hardware
- After last boot no sleep-mode should be happened
- Disable repo(s) on a device (USB-stick)
- Adding Surface kernel repo
- Setting lock on future install/upgrade of the default openSUSE kernel
- Install Surface kernel ... ofcourse
- Install Intel Precise Touch & Stylus daemon
- Handles all the GRUB2-BLS stuff



***Installation and execution***
- Download the file InstallSurfaceKernel.sh
- Go to the download folder
- Make file executable: chmod a+x InstallSurfaceKernel.sh
- Execute file: ./InstallSurfaceKernel.sh
