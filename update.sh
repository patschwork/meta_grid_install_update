#!/bin/sh

# sudo apt-get install jq
# brew install jq
# sudo apt-get install curl

whichjq=$(which jq)
whichcurl=$(which curl)
whichpython3=$(which python3)
whichpip=$(which pip)

if [ -z "$whichjq" ]
then
      if [ -z "$whichpip" ]
      then
            echo "jq AND pip is not installed. One of tools are needed. Sorry, cannot proceed."
            exit
      fi
      echo "jq not found, now installing 'lastversion' as fallback"
      
      pip install lastversion
      if [ $? -ne 0 ]
      then
            echo "Because jq isn't installed, it was tried to install 'pip install lastversion' which also did not work. Sorry, cannot proceed."
            echo "(You may try to install jq or pip manual (e.g. sudo apt install jq or brew install jq))"
            exit
      fi
fi

if [ -z "$whichcurl" ]
then
      echo "curl is not installed. Cannot proceed."
      exit
fi

destdir=$PWD
url_repo="patschwork/meta_grid_install_update"
if [ -z "$whichpip" ]
then
      latest=$(curl --silent "https://api.github.com/repos/$url_repo/releases/latest" | jq -r .tag_name)
else
      latest=$(lastversion $url_repo)
fi
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
    echo "Backup existing install_settings.ini to install_settings.ini_BACKUP..."
    cp $destdir/install_settings.ini $destdir/install_settings.ini_BACKUP
    cp $destdir/install_settings.ini ./install_settings.ini_BACKUP
fi

cp -rfp meta-grid_install_or_update/* $destdir/

rm -r meta-grid_install_or_update

cd $destdir
chmod +x update.sh

echo "Done"
