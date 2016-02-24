#!/usr/bin/python

import time
import pylcdlib
import sys, getopt

def lcdprint(strA, strB):
   lcd = pylcdlib.lcd(0x27,1)

   lcd.lcd_puts(strA,1)
   lcd.lcd_puts(strB,2)

   time.sleep(6)
   lcd.lcd_clear()

   lcd = pylcdlib.lcd(0x27,1)

def main(argv):
   string1 = ''
   string2 = ''
   try:
      opts, args = getopt.getopt(argv,"ha:b:",["help","string1=","string2="])
   except getopt.GetoptError:
      print 'test.py -a <1st row string> -b <2ndrow string>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h' or opt == '--help':
         print 'test.py -a <1st row string> -b <2nd row string>'
         sys.exit()
      elif opt in ("-a", "--string1"):
         string1 = arg
      elif opt in ("-b", "--string2"):
         string2 = arg
   #print '1st row:', string1
   #print '2nd row:', string2
   lcdprint(string1, string2)

if __name__ == "__main__":
   main(sys.argv[1:])
