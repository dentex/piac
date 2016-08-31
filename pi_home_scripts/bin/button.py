#!/usr/bin/python

import RPi.GPIO as GPIO
import time
import os
import threading

GPIO.setmode(GPIO.BCM)

PIN_BTN_1 = 19
PIN_LED = 26

stop_blinking = False

GPIO.setup(PIN_BTN_1, GPIO.IN, pull_up_down=GPIO.PUD_UP)

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
            print "stop blinking"
            break
        print "."
        blink(1, 0.1, 1)
        i += 1

    if stop_blinking is False:
        print "time out"


def waiting_cmd(dur):
    blinking_thread = threading.Thread(target=standing_by_blinking)
    blinking_thread.start()
    global stop_blinking
    GPIO.wait_for_edge(PIN_BTN_1, GPIO.FALLING)
    if blinking_thread.is_alive():
        print "@@@ executing cmd for btn " + dur + "-press @@@"
        stop_blinking = True
        blink(1, 1, 0)
        # sleeping simulates a longer cmd
        time.sleep(5)
    else:
        print "### btn pressed after time out ###"
        blink(5, 0.1, 0.1)


try:
    while True:
        GPIO.wait_for_edge(PIN_BTN_1, GPIO.FALLING)
        stop_blinking = False
        blink(1, 0.1, 0)
        print ""
        print "--> btn Pressed <--"
        start = time.time()
        time.sleep(0.2)

        while GPIO.input(PIN_BTN_1) == GPIO.LOW:
            time.sleep(0.02)

        length = time.time() - start
        print length

        if length > 3:
            print "(Long Press)"
            blink(4, 0.4, 0.2)
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
