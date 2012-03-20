/* serial.h */
#ifndef _SERIAL_H_
#define _SERIAL_H_

/*
libarduinocore.a(HardwareSerial.o): In function `HardwareSerial::available()':
/usr/share/arduino/hardware/arduino/cores/arduino/HardwareSerial.cpp:234: undefined reference to `__cxa_pure_virtual'
/usr/share/arduino/hardware/arduino/cores/arduino/HardwareSerial.cpp:234: undefined reference to `__cxa_pure_virtual'
/usr/share/arduino/hardware/arduino/cores/arduino/HardwareSerial.cpp:234: undefined reference to `__cxa_pure_virtual'
/usr/share/arduino/hardware/arduino/cores/arduino/HardwareSerial.cpp:234: undefined reference to `__cxa_pure_virtual'
/usr/share/arduino/hardware/arduino/cores/arduino/HardwareSerial.cpp:235: undefined reference to `__cxa_pure_virtual'
libarduinocore.a(Print.o):/usr/share/arduino/hardware/arduino/cores/arduino/Print.cpp:34: more undefined references to `__cxa_pure_virtual' follow
*/

extern "C" void __cxa_pure_virtual(void);

#endif /* _SERIAL_H_ */
