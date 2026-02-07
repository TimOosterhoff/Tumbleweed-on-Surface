#!/bin/bash

# Working on v0.1.1

# Install Surface aware kernel on Tumbleweed on a Surface laptop
# Kernel used from repo MadZero. Thanks !!

clear -x
echo "$(date '+%Y-%m-%d %H:%M:%S') Starting script: $0"; echo
SECONDS=0

# Running on supported os $NAME and $VERSION_ID?
source /etc/os-release
case $NAME in
	"openSUSE Tumbleweed" )
		[[ ! "$VERSION_ID" > "20251201" ]] && { echo "Script not designed/tested on $NAME version before 2025-12-01"; exit 99; }
		;;
	* )
		echo "Script not designed/tested on $NAME"
		exit 99
		;;
esac

# root privileges?
[[ $EUID -ne 0 ]] && { echo "This script requires root privileges"; exit 99; }

# Site available?
site="download.opensuse.org"
ping -c1 "$site" > /dev/null 2>&1
[ $? -gt 0 ] && { echo "Site $site not available"; exit 99; }

# No sleep mode after last boot	
[[ $(journalctl -b -gsleep -q) ]] && { echo "Laptop has slept after last reboot, reboot first"; exit 99; }

if [ $(dmidecode -s system-family) == "Surface" ]; then

	# Disable repo(s) on USB
	echo "Disable repo(s) on USB"
	zypper mr --disable $(zypper repos --uri | grep -e device | awk '{print $1}')

	# Install Surface kernel on top of openSUSE Tumbleweed
	
	# Set install lock on standard kernel
	echo "Surface detected, set lock on standard kernel-default*"
	zypper al --type package --repo download.opensuse.org-oss --comment "Microsoft Surface laptop" kernel-default*

	# Edit /etc/kernel/entry-token 
	sed -i 's/^\(opensuse-tumbleweed\)$/\surface-kernel/' /etc/kernel/entry-token
	
	# Add repo MadZero
	zypper --non-interactive --gpg-auto-import-keys addrepo --no-gpgcheck --refresh -r https://download.opensuse.org/download/repositories/home:/MadZero:/Surface/openSUSE_Tumbleweed/home:MadZero:Surface.repo
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
	entrySubstring=$(zypper se --details --type package --repo $kernelMadZero --match-exact kernel-default | grep kernel-default | cut -d'|' -f4 | grep -o '[^.]*$')
	# Look for the regarding entry file in /boot/efi/loader/entries
	entryDefaultFile=$(ls /boot/efi/loader/entries | grep system | grep $entrySubstring | tail -1)
	bootctl set-default $entryDefaultFile

	# Delete, if exists, default kernel.conf(s)
	Path="/boot/efi/loader/entries/"
	FileNameRegex="system-opensuse-tumbleweed.*"
	TempLog="/tmp/CleanUp $(date '+%Y-%m-%d %H:%M:%S').log"
	
	echo "Cleanup old files in $Path ..."
	find "$Path" -type f -regex "$FileNameRegex" | tee "$TempLog"
	
	if [[ $(find "$TempLog" -size +0) ]]; then
		awk -v q='"' '$0="rm -r " q $0 q' "$TempLog" | sh
		[ $? -gt 0 ] && echo "Cleanup old files did not work"
	fi
	echo "Cleanup $( wc -l < "$TempLog") files finished"

	
	echo
	echo "$(date '+%Y-%m-%d %H:%M:%S') Script finished (duration: $(TZ=UTC0 printf '%(%H:%M:%S)T\n' $SECONDS)), reboot needed"

fi # if Surface

