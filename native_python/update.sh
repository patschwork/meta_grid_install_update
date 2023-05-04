#!/bin/sh

# sudo apt-get install jq
# sudo apt-get install curl

whichjq=$(which jq)
whichcurl=$(which curl)

if [ -z "$whichjq" ]
then
      echo "jq is not installed. Cannot proceed."
      exit
fi

if [ -z "$whichcurl" ]
then
      echo "curl is not installed. Cannot proceed."
      exit
fi

destdir=$PWD
url_repo="patschwork/meta_grid_install_update"
latest=$(curl --silent "https://api.github.com/repos/$url_repo/releases/latest" | jq -r .tag_name)
file="meta_grid_updater.zip"


if [ -z "$latest" ]
then
      echo "Could not examine the latest version. Cannot proceed."
      exit
fi

echo "$latest is the latest version" 

cd /tmp
rm -Rf mg_updatetool
mkdir mg_updatetool
cd mg_updatetool

#wget https://github.com/$url_repo/releases/download/$latest/$file -O $file
curl -L -o $file https://github.com/$url_repo/releases/download/$latest/$file

unzip $file -d meta-grid_install_or_update

ls $destdir/install_settings.ini >/dev/null 2>&1
if [ $? = 0 ]; then
    echo "Backup existint install_settings.ini..."
    cp $destdir/install_settings.ini $destdir/install_settings.ini_BACKUP
    cp $destdir/install_settings.ini ./install_settings.ini_BACKUP
fi

cp -rfp meta-grid_install_or_update/* $destdir/

rm -r meta-grid_install_or_update

cd $destdir
chmod +x update.sh

echo "Done"
