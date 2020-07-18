#!/bin/bash

#### Configuration Section ####
install_target_host_default="127.0.0.1"
wecube_version_default="latest"
dest_dir_default="/data/wecube"
mysql_password_default="Wecube@123456"
#### End of Configuration Section ####

set -e

read -p "Please specify host IP address (install_target_host=$install_target_host_default): " install_target_host
install_target_host=${install_target_host:-$install_target_host_default}

read -p "Please enter WeCube version (wecube_version=$wecube_version_default): " wecube_version
wecube_version=${wecube_version:-$wecube_version_default}

read -p "Please specify destination dir (dest_dir=$dest_dir_default): " dest_dir
dest_dir=${dest_dir:-$dest_dir_default}

read -s -p "Please enter mysql root password (mysql_password=$mysql_password_default): " mysql_password_1 && echo ""
[ -n "$mysql_password_1" ] && read -s -p "Please re-enter the password to confirm: " mysql_password_2 && echo ""
[ -n "$mysql_password_1" ] && [ "$mysql_password_1" != "$mysql_password_2" ] && echo 'Inputs do not match!' && exit 1
mysql_password=${mysql_password_1:-$mysql_password_default}

echo ""
echo "- install_target_host=$install_target_host"
echo "- wecube_version=$wecube_version"
echo "- dest_dir=$dest_dir"
echo "- mysql_password=(*not shown*)"
echo ""
read -p "Continue? [y/Y] " -n 1 -r && echo ""
[[ ! $REPLY =~ ^[Yy]$ ]] && echo "Installation aborted." && exit 1


BASE_DIR="$dest_dir/installer"
INSTALLER_DIR="$BASE_DIR/wecube"
mkdir -p "$INSTALLER_DIR"

INSTALLER_URL="https://github.com/kanetz/delivery-by-terraform/archive/master.zip"
INSTALLER_PKG="$BASE_DIR/wecube-installer.zip"
echo -e "\nFetching WeCube installer from $INSTALLER_URL"
RETRIES=30
while [ $RETRIES -gt 0 ]; do
  if $(curl --connect-timeout 30 --speed-time 30 --speed-limit 1000 -fL $INSTALLER_URL -o $INSTALLER_PKG); then
    break
  else
    RETRIES=$((RETRIES - 1))
    PAUSE=$(( ( RANDOM % 5 ) + 1 ))
    echo "Retry in $PAUSE seconds, $RETRIES times remaining..."
    sleep "$PAUSE"
  fi
done
[ $RETRIES -eq 0 ] && echo 'Failed to fetch installer package! Installation aborted.' && exit 1

unzip -o -q $INSTALLER_PKG -d $BASE_DIR
cp -R "$BASE_DIR/delivery-by-terraform-master/delivery-wecube-for-stand-alone/application-for-tencentcloud/wecube" $BASE_DIR
[ -f $wecube_version ] && cp $wecube_version $INSTALLER_DIR

echo -e "\nRunning WeCube installer scripts...\n"
pushd $INSTALLER_DIR >/dev/null
./install-wecube.sh $install_target_host $mysql_password $wecube_version $dest_dir 'Y'
popd >/dev/null

echo -e "\n\nWeCube installation completed. Please visit WeCube at http://${install_target_host}:19090\n"
