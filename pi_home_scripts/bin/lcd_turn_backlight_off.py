#!/usr/bin/python

import time
import pylcdlib
lcd = pylcdlib.lcd(0x27,1)

lcd.lcd_backlight(0)
lcd.lcd_write(0x01)
