#!/bin/sh

plex_remote="$(curl -sX GET https://api.github.com/repos/tidusjar/PlexRequests.Net/releases/latest | awk '/browser_download_url/{print $4;exit}' FS='[""]')"

# check for original config file in app dir
if [ -f /app/PlexRequests.Net/PlexRequests.sqlite && ! -f /config/PlexRequests.Net/PlexRequests.sqlite ]; then
  mv /app/PlexRequests.Net/PlexRequests.sqlite /config/PlexRequests.sqlite
fi

rm -rf /app/PlexRequests.Net

if [ "$DEV" = "1" ]; then
  python /get-dev.py
else
  curl -o /tmp/plexrequestsnet.zip -L "$plex_remote"
fi
unzip -o /tmp/plexrequestsnet.zip -d /tmp

mv /tmp/Release /app/PlexRequests.Net
rm /tmp/plexrequestsnet.zip

cd /config

if [ ! -f /config/PlexRequests.sqlite ]; then
  sqlite3 PlexRequests.sqlite "create table aTable(field1 int); drop table aTable;" # create empty db
fi

# check for Backups folder in config
if [ ! -d /config/Backup ]; then
  echo "Creating Backup dir..."
  mkdir /config/Backup
fi


ln -s /config/PlexRequests.sqlite /app/PlexRequests.Net/PlexRequests.sqlite
ln -s /config/Backup /app/PlexRequests.Net/Backup

cd /app/PlexRequests.Net
mono PlexRequests.exe
