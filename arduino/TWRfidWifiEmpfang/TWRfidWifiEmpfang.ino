
/*
  TWRfidWifiEmpfang.ino
  
  Der RFID Tag-Empfaenger.
  
  Serielle Konsole auf 9600 Baud stellen.
  
  Compile mit Arduino 1.5.8 IDE. Einstellung: Board Arduino Nano, Prozessor Arduino ATMega328, Programmer USBtinyISP
  
  Der Sketch verwendet 4.904 Bytes (15%) des Programmspeicherplatzes. Das Maximum sind 30.720 Bytes.
  Globale Variablen verwenden 416 Bytes (20%) des dynamischen Speichers, 1.632 Bytes für lokale Variablen verbleiben. Das Maximum sind 2.048 Bytes.
  
  Copyright (C) 01.02.2015 Thomas Wenzlaff http://www.wenzlaff.de
 
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
 
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
 
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see {http://www.gnu.org/licenses/}.
 */

#include <VirtualWire.h>

const int led_pin = 13;
const int transmit_pin = 12;
const int receive_pin = 11;
const int transmit_en_pin = 3;

byte message[VW_MAX_MESSAGE_LEN]; // Buffer fuer die eintrffenden Nachrichten
byte messageLength = VW_MAX_MESSAGE_LEN; // die Groesse der Nachricht


void setup()
{
    delay(1000);
    Serial.begin(9600);	
    Serial.println("Starte RFID-Wifi Empfaenger V. 1.0 von wenzlaff.info");

    vw_set_tx_pin(transmit_pin);
    vw_set_rx_pin(receive_pin);
    vw_set_ptt_pin(transmit_en_pin);
    vw_set_ptt_inverted(true); // fuer DR3100
    vw_setup(2000);	 // Bits per sec
    
    Serial.println("OK");

    vw_rx_start();
}

void loop()
{
  if (vw_get_message(message, &messageLength)) // non-blocking
  {
    digitalWrite(led_pin, HIGH);
    Serial.print("OK: ");
    for (int i = 0; i < messageLength; i++)
    {
      Serial.write(message[i]);
    }
    digitalWrite(led_pin, LOW);
    Serial.println();
  }
  
}
