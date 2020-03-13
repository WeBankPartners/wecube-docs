#!/bin/sh
set -e

echo "Checking Docker..."
docker version || (echo "Docker Engine is not installed!" && exit 1)
docker-compose version || (echo "Docker Compose is not installed!" && exit 1)
curl http://127.0.0.1:2375/version || (echo "Docker Engine is not listening on TCP port 2375!" && exit 1)
echo -e "\nCongratulations, Docker is properly installed.\n" 


install_target_host_default="127.0.0.1"
read -p "Please specify host IP address (install_target_host=$install_target_host_default): " install_target_host
install_target_host=${install_target_host:-$install_target_host_default}

dest_dir_default="/data/wecube"
read -p "Please specify destination dir (dest_dir=$dest_dir_default): " dest_dir
dest_dir=${dest_dir:-$dest_dir_default}

wecube_version_default="v2.1.1"
read -p "Please enter WeCube version (wecube_version=$wecube_version_default): " wecube_version
wecube_version=${wecube_version:-$wecube_version_default}

mysql_password_default="WeCube1qazXSW@"
read -s -p "Please enter mysql root password (mysql_password=$mysql_password_default): " mysql_password_1 && echo ""
[ -n "$mysql_password_1" ] && read -s -p "Please re-enter the password to confirm: " mysql_password_2 && echo ""
[ -n "$mysql_password_1" ] && [ "$mysql_password_1" != "$mysql_password_2" ] && echo 'Inputs do not match!' && exit 1
mysql_password=${mysql_password_1:-$mysql_password_default}

echo ""
echo "- install_target_host=$install_target_host"
echo "- dest_dir=$dest_dir"
echo "- wecube_version=$wecube_version"
echo "- mysql_password=(*not shown*)"
echo ""
read -p "Continue? [y/Y] " -n 1 -r && echo ""
[[ ! $REPLY =~ ^[Yy]$ ]] && echo "Installation aborted." && exit 1


INSTALLER_DIR=$dest_dir/installer
mkdir -p $INSTALLER_DIR
INSTALLER_URL=https://github.com/kanetz/delivery-by-terraform-1/releases/download/wecube-installer-20200312/wecube-installer.tar.gz
echo "Retrieving wecube-installer from $INSTALLER_URL"
curl -fsSL $INSTALLER_URL -o $INSTALLER_DIR/wecube-installer.tar.gz
tar xzvf $INSTALLER_DIR/wecube-installer.tar.gz -C $INSTALLER_DIR

echo -e "\nRunning wecube-installer scripts...\n"
pushd $INSTALLER_DIR/wecube >/dev/null
./setup-wecube-containers.sh $install_target_host $mysql_password $wecube_version_default $dest_dir
popd
echo -e "\nWeCube installation completed. Please visit WeCube at http://${install_target_host}:19090\n"
