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

	# On a clean install of Tumbleweed there is no mokutil
	zypper --quiet --non-interactive install mokutil

	# twaggs should have created this KeyFile
	KeyFile="/etc/uefi/certs/CAE170D1.crt"
		
	# Verify that the key file actually exists
	if [ ! -f "$KeyFile" ]; then
		echo "Error: Key file '$KeyFile' not found."
		Error=1
		
	else

		echo "Checking the status of the Secure Boot key..."

		# Force English locale output to guarantee predictable pattern matching
		OUTPUT=$(LC_ALL=C mokutil --test-key "$KeyFile" 2>&1)
		Status=$?

		case $Status in
			0)
				# Situation A: Key is already stored manually in the UEFI MOK NVRAM list
				echo "[OK] Key is already enrolled in the UEFI MOK list."
				;;
				
			1)
				# Situation B: Key is still unknown, enrollment is required
				echo "[ACTION] Key is not enrolled yet. Initiating import using the root password..."
				
				# Staging automated import using the current root password
				if mokutil --import "$KeyFile" --root-passwd; then
					echo -e "\033[0;32mThe key has been prepared for the next reboot.\033[0m"
					echo ""
					echo -e "\033[0;33mSteps at the next reboot:\033[0m"
					echo "1. Reboot the Surface."
					echo "2. In the blue window (MokManager), choose: 'Enroll MOK'."
					echo "3. Choose 'Continue' and then 'Yes'."
					echo "4. Fill in the current Linux ROOT-password."
					echo "5. Choose 'Reboot'."
					echo
				else
					echo "The mokutil import command failed."
					Error=1
				fi
				;;
				
			255)
				# Situation C: Key is inherently trusted by the running kernel compilation
				if echo "$OUTPUT" | grep -q "already in the built-in trusted keyring"; then
					echo "Key is already in the built-in trusted keyring of the active kernel."
					echo "No additional UEFI MOK enrollment is required for this Surface kernel."
				else
					echo "ERROR Critical mokutil error (code 255): $OUTPUT"
					Error=255
				fi
				;;
				
			*)
				# Unexpected exit code (e.g., system booted via Legacy/CSM instead of UEFI)
				echo "ERROR Unexpected mokutil status (code $Status): $OUTPUT"
				Error=1
				;;
		esac
	
	fi
	
	if [[ -n "$Error" ]]; then
		echo -e "\033[0;31mInstalling of the KeyFile to MOK failed\033[0m"
		echo
	fi

fi # if Surface
