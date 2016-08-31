#!/usr/bin/python

"""
MIT License

Copyright (c) 2016 Samuele Rini

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

import RPi.GPIO as GPIO
import time
import sys
import getopt

gpio_pin = 21  # change this and choose your preferred GPIO pin

GPIO.setmode(GPIO.BCM)
GPIO.setup(gpio_pin, GPIO.OUT)

presets = ['warning', 'single', 'burst']


def usage():
    print 'Usage: buzzer.py [OPTIONS]'
    print ''
    print 'Options:'
    print '-i, --iterations        number of iterations of buzzs/pauses (as integer)'
    print '-d, --duration          lenght of the buzzs in seconds (as float)'
    print '-p, --pause             lenght of the pause between buzzs in seconds (as float)'
    print ''
    print '-r, --recipe            rings the buzzer following a preset;'
    print '                        ignores other options if specified and expects one of the recipes available:'
    print '                        warning          it\'s like using params -i 4 -d 0.15 -p 0.05 repeated 2 times'
    print '                        single           it\'s like using params -i 1 -d 1.5 -p 0.1'
    print '                        burst            it\'s like using params -i 9 -d 0.05 -p 0.05'
    print ''
    print '-h, --help              swows this help'
    print ''
    print 'Example: buzzer.py -i 2 -d 1.5 -p 0.5'
    print '         rings 2 times for 1.5 seconds with half a second pause in between'


def buzz(num_times, duration, pause):
    for i in range(0, num_times):
        GPIO.output(gpio_pin, True)
        time.sleep(duration)
        GPIO.output(gpio_pin, False)
        time.sleep(pause)


def print_warning(msg):
    print '\n###'
    print '### ' + msg + ' ###'
    print '###\n'
    usage()
    sys.exit(2)


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hr:i:d:p:", ["help", "preset=", "iterations=", "duration=", "pause="])

        if not opts:
            usage()
            sys.exit(2)

    except getopt.GetoptError:
        usage()
        sys.exit(2)

    try:
        for opt, arg in opts:
            if opt in ("-h", "--help"):
                print 'Help:\n'
                usage()
                sys.exit()
            elif opt in ("-r", "--preset"):
                recipe = str(arg)

                if recipe not in presets:
                    print_warning("No valid recipe specified!")
                else:
                    if recipe == presets[0]:  # warning
                        buzz(4, 0.15, 0.05)
                        time.sleep(0.25)
                        buzz(4, 0.15, 0.05)
                    elif recipe == presets[1]:  # single
                        buzz(1, 1.5, 0.1)
                    elif recipe == presets[2]:  # burst
                        buzz(9, 0.05, 0.05)

                sys.exit()

            elif opt in ("-i", "--iterations"):
                iterations = int(arg)
            elif opt in ("-d", "--duration"):
                duration = float(arg)
            elif opt in ("-p", "--pause"):
                pause = float(arg)

    except ValueError:
        print_warning("Check the values entered as options (integers or float) and try again!")

    buzz(iterations, duration, pause)


try:
    if __name__ == "__main__":
        main()
except KeyboardInterrupt:
    pass
finally:
    GPIO.cleanup()
