PiAC
====

###(Raspberry) Pi Aquarium Controller

##Info
This is a DIY project to control and monitor some aspects of my fresh-water aquarium.

It uses a Raspberry Pi and some hardware to control/monitor some mains sockets, a blue LED strip, a custom-built LED fixture (actually four spotlights) two cooling fans and two temperature probes. Some schematics are available in the *hardware_info* folder, although I didn't include some *mains* wiring: it's just the four sockets closed by four relays and the wiring towards the two power supplies, 12V and 4.5V (this will change soon for a new revision, that will include a couple of buck-converters to have 12V and 5V from the 24V power supply now in use for the main LEDs).

On the software side, this project uses/depends on:
- https://github.com/richardghirst/PiBits/tree/master/ServoBlaster *(hybrid hardware/software PWM)*
- https://projects.drogon.net/raspberry-pi/wiringpi/ *(userspace GPIO pins control)*
- https://github.com/andreafabrizi/Dropbox-Uploader *(auto-upload backups to DropBox)*
- https://ngrok.com/ *(remote `ssh` and web access)*
- https://dweet.io and https://freeboard.io *(IoT: messages from this project to a web dasboard)*

Basically, is then a collection of simple **bash** scripts running with `cron` on a **Raspbian** distribution.

**Please note**: this repository may not work out-of-the-box to start a similar project. Some other bits are necessary, since **PiAC** also depends on some Debian packages manually installed and their configurations. I will be glad to explain further to anyone interested and anyway I'm expanding the repository with some configuration files (i.e. from the `/etc` folder).

##Features
####v1.0
- three GPIO pins (17, 27, 22) connected to an ULN2003A and a 12V rail to have three "PWM to voltage" channels, to use with:
 1. a blue night LED strip
 2. a lid cooling fan
 3. *unused*
- four GPIO pins (18, 23, 24, 25) to switch 4 single relay boards via four opto-isolators "modules", to use with:
 1. T8 fluorescent lamp
 2. CO2 electrovalve
 3. *unused*
 4. *unused*
- GPIO pin n.4 (1-wire) to two DS18B20 probe connectors;

####v1.1
- Switched from a Raspberry Pi model B rev1 to a model B+;
- Finished mounting the lid cooler fan;
- Real Time Clock added;
- rootfs mounted on USB stick.

####v1.2
- Manage a DIY LED fixture with sunrise/sunset simulation.

####TO-DO
- Use two DC-DC converters to have 12V (for blue LEDs and fans) and 5V (for the RPi itself) out of the 24V main power supply used for the LED fixtures;
- LED spotlights cooling fans;
- Power button, to reboot/shutdown the RPi, on the main enclosure.
