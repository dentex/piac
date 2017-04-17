#!/usr/bin/python -u

from time import *
import sys, getopt
import lcdui


def usage():
    print 'Usage: lcdui.py --init --debug --backlightoff -x <1st row string> -y <2nd row string>'


def main(argv):
    string1 = ''
    string2 = ''
    initFlag = False
    debug = False
    backlight = True

    try:
        opts, args = getopt.getopt(argv, 'hidbx:y:', ['help', 'init', 'debug', 'backlightoff', 'string1=', 'string2='])
    except getopt.GetoptError:
        usage()
        sys.exit(2)


    for opt, arg in opts:
        if opt == '-h' or opt == '--help':
            usage()
            sys.exit()
        elif opt in ('-i', '--init'):
            initFlag = True
        elif opt in ('-d', '--debug'):
            debug = True
        elif opt in ('-b', '--backlightoff'):
            backlight = False
        elif opt in ('-x', '--string1'):
            string1 = arg
        elif opt in ('-y', '--string2'):
            string2 = arg

    if debug:
        print '*******************'
        if initFlag:
            print 'Doing initialization...'
        else:
            print 'Skipping initialization...'

        print '*******************'
        print "1=>" + string1
        print "2=>" + string2
        print '*******************'

    device = lcdui.lcd(0x27, 1, backlight, initFlag)

    device.lcd_puts(string1, 1)
    #sleep(0.1)
    device.lcd_puts(string2, 2)


if __name__ == '__main__':
    main(sys.argv[1:])

