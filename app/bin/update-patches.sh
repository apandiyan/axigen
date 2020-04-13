#!/bin/bash
set -eo pipefail

# dep_curl=$(type curl 2>&1)
# retcode_curl=$?
# dep_wget=$(type wget 2>&1)
# retcode_wget=$?

# defaults
axigen_binary="/opt/axigen/bin/axigen"
AXIGEN_DATA_DIR="/var/opt/axigen"
update_folder="/axigen/app/patching"
mkdir patching; cd patching

# check if curl or wget are installed
# if [ $retcode_curl -gt 0 ] && [ $retcode_wget -gt 0 ]; then
# 	echo "Curl and Wget utilities are not installed, please use your OS repository to install any of them (preffered: curl)"
# 	exit 1
# fi

current_version=$($axigen_binary --version | awk '{print $4}' | sed 's/[^0-9.]*//g')
webmail_version=$(sed  's/[^"]*"\([^"]*\)".*/\1/' ${AXIGEN_DATA_DIR}/webmail/default/config.hsp | head -n1)
webadmin_version=$(sed  's/[^"]*"\([^"]*\)".*/\1/' ${AXIGEN_DATA_DIR}/webadmin/config.hsp | head -n1)

# check patch is available for your version
url="https://www.axigen.com/api/product/updates/latest/?v=$current_version"
# if [ $retcode_curl -eq 0 ]
# then
new_version=$(curl -sS "$url" 2>&1)
# else
#   new_version=$(wget -q -O - "$url" 2>&1)
# fi

new_version=$(echo -e "$new_version" | sed 's/[^0-9.]*//g')

if [ -z "$new_version" ]
then
  echo "no available patches for your current version"
  exit
fi

# cleanup new_version
new_version=$(echo -e "$new_version" | head -n 1)

major_current=$(echo "$current_version" | awk -F "." '{print $1"."$2"."$3}')
minor_current=$(echo "$current_version" | awk -F "." '{print $4}')
major_new=$(echo "$new_version" | awk -F "." '{print $1"."$2"."$3}')
minor_new=$(echo "$new_version" | awk -F "." '{print $4}')

if [ -z "$minor_current" ]; then
	minor_current=0
fi

if [ -z "$minor_new" ]; then
	echo "The version $version is not valid"
	echo "Please run $0 <SERVICE_NAME> to obtain the latest patch available for AXIGEN $binary_version" >&2
	exit 4
fi

if [ "$major_current" != "$major_new" ]; then
	echo "The patched version $version is not compatible with currrent version of AXIGEN $binary_version" >&2
	echo "Please run $0 <SERVICE_NAME> to obtain the latest patch available for AXIGEN $binary_version" >&2
	exit 4
fi

if [ $minor_current -eq $minor_new ]; then
	echo "The Axigen $version is already installed" >&2
elif [ $minor_current -gt $minor_new ]; then
	echo "The patched version $version is older that current version of AXIGEN $binary_version" >&2
elif [ $minor_current -lt $minor_new ]; then
	patch_archive="axigen-$new_version-linux.tar.gz"

	# download patch from online
	url="https://update.axigen.com/download/$patch_archive"
	# if [ "$retcode_curl" -eq 0 ]
	# then
	curl -O -# "$url"
	# else
	# 	wget --progress=bar "$url"
	# fi

	echo -n "Unpack the patch archive"
	tar xzf "$patch_archive"
	echo -n "."
	chmod +x axigen
	tar xzf webmail-$new_version.*.tar.gz --checkpoint-action=dot --checkpoint=50
	chown -R axigen:axigen webmail
	echo -n "."
	tar xzf webadmin-$new_version.*.tar.gz --checkpoint-action=dot --checkpoint=50
	chown -R axigen:axigen webadmin
	echo " done"

	new_webmail_version=$(sed  's/[^"]*"\([^"]*\)".*/\1/' webmail/default/config.hsp | head -n1)
	new_webadmin_version=$(sed  's/[^"]*"\([^"]*\)".*/\1/' webadmin/config.hsp | head -n1)

	# install axigen binary
	if [ -h "$axigen_binary" ]
	then
		unlink $axigen_binary
	else
		mv $axigen_binary $axigen_binary-$current_version
	fi

	mv axigen $axigen_binary-$new_version
	ln -s $axigen_binary-$new_version $axigen_binary

	# install webmail directory
	echo -n "Installing Webmail Interface $new_version ..."
	cd "${AXIGEN_DATA_DIR}"
	rm -rf webmail
	mv "$update_folder/webmail" .
	cd - > /dev/null
	echo " done"

	echo -n "Installing Webadmin Interface $new_version ..."
	cd "${AXIGEN_DATA_DIR}"
	rm -rf webadmin
	mv "$update_folder/webadmin" .
	cd - > /dev/null
	echo " done"
	echo ""
fi

cd /axigen/app; rm -rf patching
