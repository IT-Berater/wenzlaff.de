#
#   99_myTWUtils.pm Version 1.0 vom 11.09.2013
#   
#   Dieses Perl Script (99_myTWUtils.pm) enthaelt alle Tools die fuer Fhem noch benoetigt werden.
#
#   1. fb_mail Methode zum versenden von E-Mails
#  
#   2. Event Zeitfunktion, liefert die Lokalzeit in der Form: 19:00:57 25.02.2014
# 
#   3. Liefert die Differenz zweier Zeiten
#
#   4. Setzen der Temperaturliste für das Wohnzimmmer
#
#   5. Setzen der Temperaturliste für das Arbeitszimmer
#
#   6. Set_Karotz_Nachricht sendet eine Textnachricht an Karotz
#         
#   (C) 2013-2014 Thomas Wenzlaff http://www.wenzlaff.de
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
 
package main;
use strict;
use warnings;
use POSIX;

sub
myTWUtils_Initialize($$)
{
my ($hash) = @_;
}

sub 
fb_mail 
{
 my $empfaenger = $_[0];
 my $subject = $_[1];
 my $text = $_[2];
 Log 5, ">>> fb_mail Eintrag: Empfaenger: $empfaenger  Betreff: $subject  Text: $text";
 Log 5, ">>> ---------------------------------------------------------------------------------";
 
 system("/bin/echo -e \"To: $empfaenger\nFrom: $empfaenger\nReply-to: $empfaenger\nSubject: $subject\n\n$text\" | ssmtp  \"$empfaenger\"");

 return "OK, E-Mail an $empfaenger versendet! Betr.: $subject Inhalt: $text";
}

#
# Event Zeitfunktion, liefter die lokalzeit in der Form: 19:00:57 25.02.2014
# Aufruf: {EventZeit()}
#
sub 
EventZeit()
{
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time());
return sprintf ("%2d:%02d:%02d %2d.%02d.%4d", $hour,$min,$sec,$mday,($mon+1),($year+1900));
}

#
# Berechnet die Differenz.
# und liefert das Ergebnis zurück in Minuten
#
sub
differenzZeit($;$)
{
  my $letzte = shift;
  my $aktuelle = shift;

  my $intLetzte=time_str2num($letzte);
  my $intAktuelle=time_str2num($aktuelle);

  my $erg=$intAktuelle-$intLetzte;
  my $minuten=$erg/60;

  return $minuten;
}

#########################################################
# Temperatur-Liste fuer das Wohnzimmer
# setzen per Aufruf von "{SetTempList_wz}"
#
# Die Zeiten sind jeweils bis-Zeiten! 
#########################################################
sub
SetTempList_wz()
{
 { fhem ("set wz_Wandthermostat_Klima tempListMon prep 05:30 17.0 07:00 17.0 16:00 19.0 20:30 20.5 24:00 17.0")};
 { fhem ("set wz_Wandthermostat_Klima tempListTue prep 05:30 17.0 07:00 17.0 16:00 19.0 20:30 20.5 24:00 17.0")};
 { fhem ("set wz_Wandthermostat_Klima tempListWed prep 05:30 17.0 07:00 17.0 16:00 19.0 20:30 20.5 24:00 17.0")};
 { fhem ("set wz_Wandthermostat_Klima tempListThu prep 05:30 17.0 07:00 17.0 16:00 19.0 20:30 20.5 24:00 17.0")};
 { fhem ("set wz_Wandthermostat_Klima tempListFri prep 05:30 17.0 07:00 17.0 15:00 19.0 20:30 20.5 24:00 17.0")};
 { fhem ("set wz_Wandthermostat_Klima tempListSat prep 07:00 17.0 09:00 17.0 15:00 19.0 21:00 21.0 24:00 17.0")};
 { fhem ("set wz_Wandthermostat_Klima tempListSun exec 07:00 17.0 09:00 17.0 15:00 19.0 21:00 21.0 24:00 17.0")};
}

##################################################################################
# Temperatur-Liste für das Arbeitszimmer
# setzen per Aufruf von "{SetTempList_az}"
#
# Vorsicht, da kein HM-CC-TC, sondern HM-CC-RT-DN, ist hier ein anderer Channel 
# Clim_RT Kanl 4 - az_Heizungsthermostat_Klima
# zu nehmen. Zudem wird mit prep|exec gearbeitet, um nicht alle Zeilen als
# einzelnen Befehl zu senden, sondern per "prep" erst alles 
# zusammenzufassen und dann per "exec" an das Thermostat zu senden.
# Also als ein einziger Befehl statt sieben. Vermeidet "NACKs"
# Die Zeiten sind jeweils bis-Zeiten! 
# 
##################################################################################
sub
SetTempList_az()
 {
   { fhem ("set az_Heizungsthermostat_Klima tempListMon prep 05:30 16.0 07:00 18.0 16:00 18.5 20:30 19.0 24:00 16.0")};
   { fhem ("set az_Heizungsthermostat_Klima tempListTue prep 05:30 16.0 07:00 18.0 16:00 18.5 20:30 19.0 24:00 16.0")};
   { fhem ("set az_Heizungsthermostat_Klima tempListWed prep 05:30 16.0 07:00 18.0 16:00 18.5 20:30 19.0 24:00 16.0")};
   { fhem ("set az_Heizungsthermostat_Klima tempListThu prep 05:30 16.0 07:00 18.0 16:00 18.5 20:30 19.0 24:00 16.0")};
   { fhem ("set az_Heizungsthermostat_Klima tempListFri prep 05:30 16.0 07:00 18.0 15:00 18.5 20:30 19.0 24:00 16.0")};
   { fhem ("set az_Heizungsthermostat_Klima tempListSat prep 07:00 16.0 09:00 18.0 15:00 18.5 21:00 19.0 24:00 16.0")};
   { fhem ("set az_Heizungsthermostat_Klima tempListSun exec 07:00 16.0 09:00 19.0 15:00 19.5 21:00 20.0 24:00 16.0")};
}

#
# Sendet eine Nachricht an Karotz über den PushingBox Service.
#
# Es muss auf dem Karotz die PushingBox installiert sein und ein Account auf PuchingBox eingerichtet werden.
# 
# Aufruf:  Set_Karotz_Nachricht('Device ID','Nachricht die Karotz ansagt')
#   z.B.: {Set_Karotz_Nachricht('Device ID','Hallo herzlich Willkommen zu Hause')}
#
sub 
Set_Karotz_Nachricht 
{
 my ($devid, $text) = @_;

 Log 5, ">>> Set_Karotz_Nachricht: $text";
 Log 5, ">>> ---------------------------------------------------------------------------------";
 
 system("curl -d \"devid=$devid&nachricht=$text\" http://api.pushingbox.com/pushingbox");

 return "OK, sende die Nachricht:\"$text\" an Karotz.";
}

1;

