/*
This file is part of arduiggler.

arduiggler is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

arduiggler is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with arduiggler.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
Arduino Wiggler cable simulator
ver 1.0 originally written by jtrimble for tjtag
http://www.dd-wrt.com/phpBB2/viewtopic.php?p=435578&sid=0c7c7b114dc7239be2620514cecbe2d8
*/
////////////////////////////////////////////////////////////////////////////////
// Pins 0-7 are part of PORTD
// pins 0 and 1 are RX and TX, respectively
const int pinGP0   = 2;
const int pinTMS0  = 3;
const int pinTCK0  = 4;
const int pinTDI0  = 5;
const int pinTRST0 = 6;
const int pinTDO0  = 7;
const int pinLED   = 13;

const long DEFAULT_RS232_RATE = 115200L;

const char *APP_VER = "2.00";
////////////////////////////////////////////////////////////////////////////////
const byte CMD_RESET  = 0x74; //ASCII for t
const byte CMD_STATUS = 0x3F; //ASCII for ?
const byte CMD_GETVER = 0x61; //ASCII for a
const byte CMD_SEND   = 0x73; //ASCII for s
const byte CMD_READ   = 0x72; //ASCII for r
const byte CMD_FORCE  = 0x66; //ASCII for f

const int STATUS_OK   = 0x6F6B; //ASCII for ok
const int STATUS_ERR1 = 0x6531; //ASCII for e1
const int STATUS_ERR2 = 0x6532; //ASCII for e2

const byte MASK_TDI  = 0x01;
const byte MASK_TCK  = 0x02;
const byte MASK_TMS  = 0x04;
const byte MASK_TRST = 0x08;
const byte MASK_GP0  = 0x10;
const byte MASK_GP1  = 0x20;
const byte MASK_GP2  = 0x40;
const byte MASK_GP3  = 0x80;

int status;
////////////////////////////////////////////////////////////////////////////////
/*
Wapper functions for clear/set individual pins.
Just in case it needs to be replaced with direct pins access
*/
inline void setGP0() {
  digitalWrite(pinGP0, HIGH);
}

inline void clrGP0() {
  digitalWrite(pinGP0, LOW);
}

inline void setTRST0() {
  digitalWrite(pinTRST0, HIGH);
}

inline void clrTRST0() {
  digitalWrite(pinTRST0, LOW);
}

inline void setTMS0() {
  digitalWrite(pinTMS0, HIGH);
}

inline void clrTMS0() {
  digitalWrite(pinTMS0, LOW);
}

inline void setTCK0() {
  digitalWrite(pinTCK0, HIGH);
}

inline void clrTCK0() {
  digitalWrite(pinTCK0, LOW);
}

inline void toggleTCK0() {
  //assume it is LOW by default
  digitalWrite(pinTCK0, HIGH);
  digitalWrite(pinTCK0, LOW);
}

inline void setTDI0() {
  digitalWrite(pinTDI0, HIGH);
}

inline void clrTDI0() {
  digitalWrite(pinTDI0, LOW);
}
////////////////////////////////////////////////////////////////////////////////
void setup() {
  pinMode(pinGP0, OUTPUT);
  pinMode(pinTRST0, OUTPUT);
  pinMode(pinTMS0, OUTPUT);
  pinMode(pinTCK0, OUTPUT);
  pinMode(pinTDI0, OUTPUT);
  pinMode(pinTDO0, INPUT);
  pinMode(pinLED, OUTPUT);

  digitalWrite(pinLED, LOW);
  clrGP0();
  clrTRST0();
  clrTMS0();
  clrTCK0();
  clrTDI0();

  Serial.begin(DEFAULT_RS232_RATE);
  status = STATUS_OK;
}
////////////////////////////////////////////////////////////////////////////////
void loop() {
  if(Serial.available() > 0) {
    byte cmd = (byte)Serial.read();
    //Serial.print("cmd received: ");
    //Serial.println(cmd, HEX);

    switch(cmd) {
      case CMD_RESET: {
        //Serial.println("CMD_RESET");
        clrGP0();
        clrTRST0();
        clrTMS0();
        clrTCK0();
        clrTDI0();
        digitalWrite(pinLED, HIGH);
        status = STATUS_OK;
        break;
      }
      case CMD_SEND: {
        //Serial.println("CMD_SEND");
        byte data;

        while(Serial.available() == 0);
        data = (byte)Serial.read();

        if(data & MASK_TDI)
          setTDI0();
        else
          clrTDI0();
        if(data & MASK_TMS)
          setTMS0();
        else
          clrTMS0();

        while(Serial.available() == 0);
        data = (byte)Serial.read();

        while(data > 0) {
          toggleTCK0();
          data --;
        }
        status = STATUS_OK;
        break;
      }
      case CMD_READ: {
        //Serial.println("CMD_READ");
        byte tmp;

        if(digitalRead(pinTDO0) == HIGH) {
          tmp = 0x31;
        }
        else {
          tmp = 0x30;
        }
        Serial.write(tmp);
        status = STATUS_OK;
        break;
      }
      case CMD_FORCE: {
        //Serial.println("CMD_FORCE");
        byte data;

        while(Serial.available() == 0);
        data = (byte)Serial.read();

        if(data & MASK_TDI)
          setTDI0();
        else
          clrTDI0();
        if(data & MASK_TMS)
          setTMS0();
        else
          clrTMS0();
        if(data & MASK_TCK)
          setTCK0();
        else
          clrTCK0();
        if(data & MASK_TRST)
          setTRST0();
        else
          clrTRST0();
        if(data & MASK_GP0)
          setGP0();
        else
          clrGP0();
        status = STATUS_OK;
        break;
      }
      case CMD_GETVER: {
        //Serial.println("CMD_GETVER");
        Serial.print(APP_VER);
        break;
      }
      case CMD_STATUS: {
        //Serial.println("CMD_STATUS");
        break;
      }
      default: {
        //Serial.println(cmd, HEX);
        digitalWrite(pinLED, LOW);
        status = STATUS_ERR1;
        break;
      }
    }
    Serial.write(highByte(status));
    Serial.write(lowByte(status));
    Serial.flush();
  }
}
////////////////////////////////////////////////////////////////////////////////