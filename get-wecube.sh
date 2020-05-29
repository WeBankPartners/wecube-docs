#!/bin/sh

#### Configuration Section ####
INSTALLER_URL="https://github.com/WeBankPartners/delivery-by-terraform/archive/master.zip"
PLUGIN_INSTALLER_URL="https://github.com/WeBankPartners/wecube-auto/archive/master.zip"

wecube_version_default="latest"
install_target_host_default="127.0.0.1"
dest_dir_default="/data/wecube"
mysql_password_default="WeCube1qazXSW@"
#### End of Configuration Section ####

set -e

echo -e "Checking Docker...\n"
docker version || (echo 'Docker Engine is not installed!' && exit 1)
docker-compose version || (echo 'Docker Compose is not installed!' && exit 1)
curl http://127.0.0.1:2375/version || (echo 'Docker Engine is not listening on TCP port 2375!' && exit 1)
echo -e "\nCongratulations, Docker is properly installed.\n" 


read -p "Please enter WeCube version (wecube_version=$wecube_version_default): " wecube_version
wecube_version=${wecube_version:-$wecube_version_default}

read -p "Please specify host IP address (install_target_host=$install_target_host_default): " install_target_host
install_target_host=${install_target_host:-$install_target_host_default}

read -p "Please specify destination dir (dest_dir=$dest_dir_default): " dest_dir
dest_dir=${dest_dir:-$dest_dir_default}

read -s -p "Please enter mysql root password (mysql_password=$mysql_password_default): " mysql_password_1 && echo ""
[ -n "$mysql_password_1" ] && read -s -p "Please re-enter the password to confirm: " mysql_password_2 && echo ""
[ -n "$mysql_password_1" ] && [ "$mysql_password_1" != "$mysql_password_2" ] && echo 'Inputs do not match!' && exit 1
mysql_password=${mysql_password_1:-$mysql_password_default}

echo ""
echo "- wecube_version=$wecube_version"
echo "- install_target_host=$install_target_host"
echo "- dest_dir=$dest_dir"
echo "- mysql_password=(*not shown*)"
echo ""
read -p "Continue? [y/Y] " -n 1 -r && echo ""
[[ ! $REPLY =~ ^[Yy]$ ]] && echo "Installation aborted." && exit 1


GITHUB_RELEASE_URL="https://api.github.com/repos/WeBankPartners/wecube-platform/releases/$wecube_version"
GITHUB_RELEASE_JSON=""
RETRIES=30
echo -e "\nFetching release info for $wecube_version from $GITHUB_RELEASE_URL..."
while [ $RETRIES -gt 0 ] && [ -z "$GITHUB_RELEASE_JSON" ]; do
    RETRIES=$((RETRIES - 1))
    GITHUB_RELEASE_JSON=$(curl -sSfl "$GITHUB_RELEASE_URL")
    if [ -z "$GITHUB_RELEASE_JSON" ]; then
        echo "Retry in 1 second..."
        sleep 1
    else
        break
    fi
done
[ -z "$GITHUB_RELEASE_JSON" ] && echo -e "\nFailed to fetch release info from $GITHUB_RELEASE_URL\nInstallation aborted." && exit 1

RELEASE_TAG_NAME=$(grep -o '"tag_name":[ ]*"[^"]*"' <<< "$GITHUB_RELEASE_JSON" | grep -o 'v[[:digit:]\.]*')
[ -z "$RELEASE_TAG_NAME" ] && echo -e "\nFailed to fetch release tag name!\Installation aborted." && exit 1
echo "wecube_release_tag_name=$RELEASE_TAG_NAME"

wecube_image_version="$wecube_version"
PLUGIN_PKGS=()
COMPONENT_TABLE_MD=$(grep -o '|[ ]*wecube image[ ]*|.*|\\r\\n' <<< "$GITHUB_RELEASE_JSON" | sed -e 's/[ ]*|[ ]*/|/g')
while [[ $COMPONENT_TABLE_MD ]]; do
    COMPONENT=${COMPONENT_TABLE_MD%%"\r\n"*}
    COMPONENT_TABLE_MD=${COMPONENT_TABLE_MD#*"\r\n"}

    COMPONENT=${COMPONENT#"|"}
    COMPONENT_NAME=${COMPONENT%%"|"*}

    COMPONENT=${COMPONENT#*"|"}
    COMPONENT_VERSION=${COMPONENT%%"|"*}

    COMPONENT=${COMPONENT#*"|"}
    COMPONENT_LINK=${COMPONENT%%"|"*}

    if [ "$COMPONENT_NAME" == 'wecube image' ]; then
        wecube_image_version="$COMPONENT_VERSION"
    elif [ "$COMPONENT_NAME" ]; then
        PLUGIN_PKGS+=("$COMPONENT_LINK")
    fi
done
echo "wecube_image_version: $wecube_image_version"
echo "wecube_plugins:"
printf '%s\n' "${PLUGIN_PKGS[@]}"
[ ${#PLUGIN_PKGS[@]} == 0 ] && echo -e "\nFailed to fetch component versions from $GITHUB_RELEASE_URL\nInstallation aborted." && exit 1

BASE_DIR="$dest_dir/installer"
mkdir -p "$BASE_DIR"
INSTALLER_PKG="$BASE_DIR/wecube-installer.zip"
echo -e "\nFetching wecube-installer from $INSTALLER_URL"
curl -#L $INSTALLER_URL -o $INSTALLER_PKG
unzip -o -q $INSTALLER_PKG -d $BASE_DIR
cp -R "$BASE_DIR/delivery-by-terraform-master/delivery-wecube-for-stand-alone/application-for-tencentcloud/wecube" $BASE_DIR
INSTALLER_DIR="$BASE_DIR/wecube"

pushd $INSTALLER_DIR >/dev/null

echo -e "\nRunning wecube-installer scripts...\n"
./setup-wecube-containers.sh $install_target_host $mysql_password $wecube_image_version $dest_dir
echo -e "\nWeCube installation completed. Please visit WeCube at http://${install_target_host}:19090\n"

#read -p "Continue with plugin configuration? [y/Y] " -n 1 -r && echo ""
#[[ ! $REPLY =~ ^[Yy]$ ]] && echo "Installation completed with no plugin configured." && exit 1

echo -e "\nNow starting to configure plugins...\n"
PLUGIN_INSTALLER_PKG="$INSTALLER_DIR/wecube-plugin-installer.zip"
PLUGIN_INSTALLER_DIR="$INSTALLER_DIR/wecube-plugin-installer"
mkdir -p "$PLUGIN_INSTALLER_DIR"
echo "Fetching wecube-plugin-installer from $PLUGIN_INSTALLER_URL"
curl -#L $PLUGIN_INSTALLER_URL -o $PLUGIN_INSTALLER_PKG
unzip -o -q $PLUGIN_INSTALLER_PKG -d $PLUGIN_INSTALLER_DIR

echo -e "\nFetching plugin packages...."
PLUGIN_PKG_DIR="$PLUGIN_INSTALLER_DIR/plugins"
mkdir -p "$PLUGIN_PKG_DIR"
PLUGIN_LIST_CSV="$PLUGIN_PKG_DIR/plugin-list.csv"
echo "plugin_package_path" > $PLUGIN_LIST_CSV
for PLUGIN_URL in "${PLUGIN_PKGS[@]}"; do
    PLUGIN_PKG_FILE="$PLUGIN_PKG_DIR/${PLUGIN_URL##*'/'}"
    echo -e "\nFetching from $PLUGIN_URL"
    curl -#L $PLUGIN_URL -o $PLUGIN_PKG_FILE
    echo $PLUGIN_PKG_FILE >> $PLUGIN_LIST_CSV
done

./configure-plugins.sh "$install_target_host" "$PLUGIN_INSTALLER_DIR/wecube-auto-master" "$PLUGIN_PKG_DIR" "$mysql_password"

popd
echo -e "\nWeCube installation completed. Please visit WeCube at http://${install_target_host}:19090\n"
