/*
  RFIDReader 
  
  Beschreibung: Dieses Programm liesst RFID-Tags von Transponer ein und ueberprueft die Checksumme (XOR)
  und gibt die Nummer auf der Seriellen-Konsole aus wenn die Nummer erkannt wurde gefolgt von einem OK. 
  
  Folgende Verbindungen sind noetig:
  
  Arduino Nano: D6 auf PIN 1 des RDM630
               +5v auf PIN 5 des RDM630 (+5 Volt)
               GND auf PIN 4 des RDM630 (GND)
               
               Antenne auf P2 PIN 1 und 2 des RDM630
               
  Serielle Konsole auf 57000 Baud stellen.
  
  Compile mit Arduino 1.5.8 IDE. Einstellung: Board Arduino Nano, Prozessor Arduino ATMega328, Programmer USBtinyISP
  
  Der Sketch verwendet 8.216 Bytes (26%) des Programmspeicherplatzes. Das Maximum sind 30.720 Bytes.
  Globale Variablen verwenden 378 Bytes (18%) des dynamischen Speichers, 1.670 Bytes für lokale Variablen verbleiben. Das Maximum sind 2.048 Bytes.
 
  Dieses Programm basiert auf dem Beispielprogramm von maniacbug https://maniacbug.wordpress.com/2011/10/09/125khz-rfid-module-rdm630/
  
  Copyright (C) 2015 Thomas Wenzlaff http://www.wenzlaff.de
 
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
#include <SoftwareSerial.h>
 
// Pin definitions
// Specifies a function to call when an external interrupt occurs. Replaces any previous function that was attached to the interrupt. 
// Most Arduino boards have two external interrupts: numbers 0 (on digital pin 2) and 1 (on digital pin 3). 
// The Arduino Mega has an additional four: numbers 2 (pin 21), 3 (pin 20), 4 (pin 19), and 5 (pin 18). 
const int rfid_irq = 0;
// PIN 6 ist auf dem Nano der D6 oder der Pin 9 von rechts, wenn die Stecker rechts liegen
const int rfid_tx_pin = 6;
// RX wird nicht benoetigt
const int rfid_rx_pin = 7;
// Untertrueckung von Rauschen bzw. leer Ausgaben, evl. aendern
const long LEER = 16843009L;
// Baud Rate zum Host PC, evl. aendern
const long baudRate = 57600L;
 
// For communication with RFID module
SoftwareSerial rfid(rfid_tx_pin, rfid_rx_pin);
 
// Indicates that a reading is now ready for processing
volatile bool ready = false;
 
// Buffer to contain the reading from the module
uint8_t buffer[14];
uint8_t* buffer_at;
uint8_t* buffer_end = buffer + sizeof(buffer);
 
void rfid_read(void);
 
void setup(void)
{
  // Oeffnet die Serielle Verbindung zum Host PC um die Ausgabe der RFID-Tags zu sehen
  // Geschwindigkeit kann angepasst werden
  Serial.begin(baudRate);
  Serial.println("Starte RFID-Reader V. 1.0 von wenzlaff.info");
 
  // Open software serial connection to RFID module
  pinMode(rfid_tx_pin,INPUT);
  // muss fest fuer das Modul auf 9600 stehen
  rfid.begin(9600);
  
  Serial.println("OK");
  
  // Listen for interrupt from RFID module. Fallingfor when the pin goes from high to low. 
  attachInterrupt(rfid_irq,rfid_read,FALLING);
}

void loop(void)
{
  if ( ready )
  {
    // Convert the buffer into a 32-bit value
    uint32_t result = 0;
    
    // Skip the preamble
    ++buffer_at;
    
    // Accumulate the checksum, starting with the first value
    uint8_t checksum = rfid_get_next();
    
    // We are looking for 4 more values
    int i = 4;
    while(i--)
    {
      // Grab the next value
      uint8_t value = rfid_get_next();
      
      // Add it into the result
      result <<= 8;
      result |= value;
      
      // Xor it into the checksum
      checksum ^= value;
    }
    
    // Pull out the checksum from the data
    uint8_t data_checksum = rfid_get_next();
    
    // evl. die Nummer anpassen, oder die if abfrage loeschen
     if (result != LEER){    
      if ( checksum == data_checksum ){
        Serial.print(result);
        Serial.println(" OK");
      }
    }
    // We're done processing, so there is no current value
    ready = false;
  }
}
 
// Convert the next two chars in the stream into a byte and
// return that
uint8_t rfid_get_next(void)
{
  // sscanf needs a 2-byte space to put the result but we
  // only need one byte.
  uint16_t result;
 
  // Working space to assemble each byte
  static char byte_chars[3];
  
  // Pull out one byte from this position in the stream
  snprintf(byte_chars,3,"%c%c",buffer_at[0],buffer_at[1]);
  sscanf(byte_chars,"%x",&result);
  buffer_at += 2;
  
  return static_cast<uint8_t>(result);
}
 
void rfid_read(void)
{
  // Only read in values if there is not already a value waiting to be
  // processed
  if ( ! ready )
  {
    // Read characters into the buffer until it is full
    buffer_at = buffer;
    while ( buffer_at < buffer_end )
      *buffer_at++ = rfid.read();
      
    // Reset buffer pointer so it's easy to read out
    buffer_at = buffer;
  
    // Signal that the buffer has data ready
    ready = true;
  }
  
}

