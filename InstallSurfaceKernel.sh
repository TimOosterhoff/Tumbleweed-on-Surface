# Install the surface kernel on top of a CLEAN install of Tumbleweed 

if [ $(dmidecode -s system-family) == "Surface" ]; then

	# Install Surface kernel
	
	# Set lock on the standard kernel
	echo "Surface detected, setting lock on the standard kernel-default*"
	zypper al --type package --repo download.opensuse.org-oss --comment "Microsoft Surface laptop" kernel-default*

	# add Repo twaggs
	zypper --non-interactive --gpg-auto-import-keys addrepo --no-gpgcheck  --refresh -r https://download.opensuse.org/repositories/home:/twaggs:/linux-surface/openSUSE_Tumbleweed/home:twaggs:linux-surface.repo --priority 60
	zypper refresh
	
	kerneltwaggs=$(zypper lr | grep twaggs | cut -d'|' -f1 | xargs)

	# Install Surface kernel
	echo "Install Surface kernel ..."
	zypper install --repo $kerneltwaggs --force --no-confirm kernel-default
	echo "Surface kernel installed"
	echo

	# Install Intel Precise Touch & Stylus daemon
	echo "Install Intel Precise Touch & Stylus daemon ..."
	zypper --quiet --non-interactive --no-gpg-checks install iptsd
	echo "Intel Precise Touch & Stylus daemon installed"
	echo

	# Set default boot entry
	
	# Isolate the Git-hash (for instance 'g7e74cac')
	Git_Hash=$(rpm -q --qf "%{RELEASE}\n" kernel-default | grep -oE 'g[0-9a-f]+')
	
	# Search in bootctl list for the ID which contains these hash ánd '-1.conf'
	Conf_File=$(bootctl --no-pager list | awk -v h="$Git_Hash" '/id:/ && $0 ~ h && /-1.conf/ {print $2; exit}')

	sdbootutil set-default "$Conf_File"

	# Certificate Surface kernel has to be installed

	# Location certificate file
	mokFile="/etc/uefi/certs/CAE170D1.crt"

	# Certificate file found?
	if [ ! -f "$mokFile" ]; then
		echo -e "\033[0;31mCertificate $mokFile not found.\033[0m"
		echo -e "\033[0;31mBoot the Surface with Security set to None, and fix this issue.\033[0m"
		echo -e "\033[0;31mCurrent state: $(mokutil --sb-state)\033[0m"
	else
		echo -e "\033[0;Find certificate: $mokFile\033[0m"

		# Has the certificate already installed?
		if mokutil --list-enrolled | grep -qi "twaggs1"; then
			# Certificate founded
			echo -e "\033[0;32mThe Surface-key is already active in the UEFI firmware. No actie needed!\033[0m"
		else
			# Install certificate 
			mokutil --import "$mokFile" --root-pw
			mokInstalled=true 
			echo -e "\033[0;32mThe key has been prepared for the next reboot!\033[0m"
			echo ""
			echo -e "\033[0;33mSteps at the next reboot:\033[0m"
			echo "1. Reboot the Surface."
			echo "2. In the blue window (MokManager), choose: 'Enroll MOK'."
			echo "3. Choose 'Continue' and then 'Yes'."
			echo "4. Fill in the current Linux ROOT-password."
			echo "5. Choose 'Reboot'."
		fi
	fi

fi # if Surface
