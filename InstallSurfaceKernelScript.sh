# Tumbleweed-on-Surface

# Install script for Tumbleweed on a Surface laptop
# Kernel used from repo MadZero. Thanks!

# 1-st: install recent Tumbleweed including default online repos and reboot
# 2-sec: (before first hybernation(!) execute this script

if [ $(dmidecode -s system-family) == "Surface" ]; then

	# Install Surface kernel on top of openSUSE Tumbleweed
	
	# Set install lock on standard kernel
	echo "Surface detected, set lock on standard kernel-default*"
	zypper al --type package --repo download.opensuse.org-oss --comment "Microsoft Surface laptop" kernel-default*

	# Edit /etc/kernel/entry-token 
	sed -i 's/^\(opensuse-tumbleweed\)$/\surface-kernel/' /etc/kernel/entry-token
	
	# Add repo MadZero
	zypper --non-interactive --gpg-auto-import-keys addrepo --no-gpgcheck  --refresh -r https://download.opensuse.org/download/repositories/home:/MadZero:/Surface/openSUSE_Tumbleweed/home:MadZero:Surface.repo
	zypper refresh
	
	kernelMadZero=$(zypper lr | grep MadZero | cut -d'|' -f1 | xargs)

	# Install Surface kernel
	echo "Install Surface kernel ..."
	zypper install --repo $kernelMadZero --force --no-confirm kernel-default
	echo "Surface kernel installed"
	echo

	# Install Intel Precise Touch & Stylus daemon
	echo "Install Intel Precise Touch & Stylus daemon ..."
	zypper --quiet --non-interactive --no-gpg-checks install iptsd
	echo "Intel Precise Touch & Stylus daemon installed"
	echo

	# Set default boot entry

	# Look for unique signature of the Surface kernel
	entrySubstring=$(zypper se --details --type package --repo $kernelMadZero --match-exact kernel-default | grep kernel-default | cut -d'|' -f4  | grep -o '[^.]*$')
	# Look for the regarding entry file in /boot/efi/loader/entries
	entryDefaultFile=$(ls /boot/efi/loader/entries  | grep system | grep $entrySubstring | tail -1)
	bootctl set-default $entryDefaultFile

	# Delete default kernel.conf(s)
	rm /boot/efi/loader/entries/system-opensuse-tumbleweed*

fi # if Surface

