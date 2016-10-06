#!/usr/bin/python

# ---------- old script -------------
#import time
#import pylcdlib
#lcd = pylcdlib.lcd(0x27,1)

#lcd.lcd_backlight(0)
#lcd.lcd_write(0x01)
# ---------- old script -------------

from time import *
import sys, getopt
import lcdui

device = lcdui.lcd(0x27, 1, False, False)
device.lcd_puts('', 1)
device.lcd_puts('', 1)
