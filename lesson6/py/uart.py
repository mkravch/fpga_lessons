import serial
import time
import random

port = "COM3"
baudrate = 115200
parity=serial.PARITY_NONE
no=serial.EIGHTBITS
stopbits= serial.STOPBITS_ONE

ser=serial.Serial()
ser.port=port
ser.baudrate=baudrate
ser.timeout=1
ser.parity=parity
ser.bytesize=no
ser.stopbits=stopbits

ser.open()

packet = [0x10,0x20,0x45,0x34,0x92,0x44,0x99]

ser.write(packet)
    
ser.close()
