#!/usr/bin/python -u

import RPi.GPIO as GPIO
import time
import os
import threading

GPIO.setmode(GPIO.BCM)

"""
short-press:  test (does nothing)
medium-press: system reboot
long-press:   system shutdown
"""

PIN_BTN = 19
PIN_LED = 26

stop_blinking = False

GPIO.setup(PIN_BTN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

GPIO.setup(PIN_LED, GPIO.OUT)
GPIO.output(PIN_LED, 0)


def blink(num_times, speed, pause):
    for i in range(0, num_times):
        GPIO.output(PIN_LED, True)
        time.sleep(speed)
        GPIO.output(PIN_LED, False)
        time.sleep(pause)


def standing_by_blinking():
    print "waiting for a cmd"
    i = 0
    time.sleep(1)
    while i < 5:
        if stop_blinking is True:
            print "break standing_by_blinking"
            break
        print "."
        blink(1, 0.1, 1)
        i += 1

    if stop_blinking is False:
        print "standing_by_blinking timed out"


def waiting_cmd(dur):
    blinking_thread = threading.Thread(target=standing_by_blinking)
    blinking_thread.start()
    global stop_blinking
    GPIO.wait_for_edge(PIN_BTN, GPIO.FALLING)
    if blinking_thread.is_alive():
        print "@@@ executing cmd for btn " + dur + "-press @@@"
        stop_blinking = True
        blink(1, 1, 0)

        if dur == "medium":
            print "system reboot..."
            os.system("/home/pi/bin/piac_halt.sh -r >> /home/pi/log/piac.log 2>&1")
        elif dur == "long":
            print "system shutdown..."
            os.system("/home/pi/bin/piac_halt.sh >> /home/pi/log/piac.log 2>&1")

    else:
        print "### btn pressed after time out ###"
        blink(5, 0.1, 0.1)


try:
    while True:
        GPIO.wait_for_edge(PIN_BTN, GPIO.FALLING)
        stop_blinking = False
        blink(1, 0.1, 0)
        print ""
        print "--> btn Pressed <--"
        start = time.time()
        time.sleep(0.2)

        while GPIO.input(PIN_BTN) == GPIO.LOW:
            time.sleep(0.02)

        length = time.time() - start
        print length

        if length > 3:
            print "(Long Press)"
            blink(3, 0.4, 0.2)
            waiting_cmd("long")

        elif length > 1:
            print "(Medium Press)"
            blink(2, 0.4, 0.2)
            waiting_cmd("medium")

        else:
            print "(Short Press)"
            blink(1, 0.1, 0)

except KeyboardInterrupt:
    pass
finally:
    GPIO.cleanup()
