#!/usr/bin/env bash
set -e -u -o pipefail

# remove info.php (prevents server info leak)
rm /srv/http/info.php

# to mount SMB shares: 
pacman -S --noconfirm --noprogress --needed smbclient

# for video file previews
pacman -S --noconfirm --noprogress --needed ffmpeg

# for document previews
pacman -S --noconfirm --noprogress --needed libreoffice-fresh

# for ssh mounts
pacman -S --noconfirm --noprogress --needed openssh

# for image previews
pacman -S --noconfirm --noprogress --needed imagemagick ghostscript openexr openexr openexr libxml2 librsvg libpng libwebp

# not 100% sure what needs this:
pacman -S --noconfirm --noprogress --needed gamin

# nextcloud itself
su docker -c 'gpg --recv-key D75899B9A724937A'
su docker -c 'pacaur -m --noprogressbar --noedit --noconfirm nextcloud'
pacman -U --noconfirm --needed /home/docker/.cache/pacaur/nextcloud/nextcloud-${NC_VERSION}-any.pkg.tar

# setup Apache for nextcloud
cp /etc/webapps/nextcloud/apache.example.conf /etc/httpd/conf/extra/nextcloud.conf
sed -i 's,Alias / "/usr/share/webapps/nextcloud",Alias /${TARGET_SUBDIR} "/usr/share/webapps/nextcloud",g' /etc/httpd/conf/extra/nextcloud.conf
sed -i '$a Include conf/extra/nextcloud.conf' /etc/httpd/conf/httpd.conf

# reduce docker layer size
cleanup-image
