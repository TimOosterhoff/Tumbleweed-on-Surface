# Install the surface kernel on top of a CLEAN install of Tumbleweed 

if [ $(dmidecode -s system-family) == "Surface" ]; then

	# Install Surface kernel
	
	# Set lock on the standard kernel
	echo "Surface detected, setting lock on the standard kernel-default*"
	zypper al --type package --repo download.opensuse.org-oss --comment "Microsoft Surface laptop" kernel-default*

	# add Repo MadZero
	zypper --non-interactive --gpg-auto-import-keys addrepo --no-gpgcheck  --refresh -r https://download.opensuse.org/download/repositories/home:/MadZero:/Surface/openSUSE_Tumbleweed/home:MadZero:Surface.repo --priority 60
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
	
	# Isolate the Git-hash (for insiance 'g1533bda')
	Git_Hash=$(rpm -q --qf "%{RELEASE}\n" kernel-default | grep -oE 'g[0-9a-f]+')
	
	# Search in bootctl list for the ID which contains these hash ánd '-1.conf'
	Conf_File=$(bootctl --no-pager list | awk -v h="$Git_Hash" '/id:/ && $0 ~ h && /-1.conf/ {print $2; exit}')

	sdbootutil set-default "$Conf_File"

fi # if Surface
