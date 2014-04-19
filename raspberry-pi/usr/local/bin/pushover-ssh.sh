#!/bin/sh
#
# pushover-ssh.sh
#
# Dieses Script versendet eine Pushover Nachricht wenn eine Anmeldung per SSH durchgefuehrt wird.
#
# Thomas Wenzlaff  15.04.2014 Installationsanleitung unter http://www.wenzlaff.info
#
#
# (C) 2014 Thomas Wenzlaff http://www.wenzlaff.de
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see {http://www.gnu.org/licenses/}.

# Hier den User Key von der https://pushover.net Seite eingeben:
PUSHOVER_USER="hier den Key";
# Hier den  API Token/Key eingeben. Zu finden unter dem Menü: Apps & Plugins dann die Applicaton 
PUSHOVER_API_TOKEN="hier den Token eingeben";


tail -F /var/log/auth.log | gawk '{if(NR>10 && $0 ~ /sshd/ && $0 ~ /Accepted/)\
{ cmd=sprintf("curl -s \
-F \"token='$PUSHOVER_API_TOKEN'\" \
-F \"user='$PUSHOVER_USER'\" \
-F \"message=SSH Zugriff erfolgt durch %s von %s\" \
-F \"title=Raspberry Pi\" https://api.pushover.net/1/messages.json",$9,$11); \
system(cmd)}}'

