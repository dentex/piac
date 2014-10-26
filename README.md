PiAC
====

###(Raspberry) Pi Aquarium Controller

##Info
This is a DIY project to control and monitor some aspects of my fresh-water aquarium.

It uses a Raspberry Pi and some hardware to control/monitor four mains sockets, a blue LED strip, two cooling fans and two temperature probes. Some schematics are available in the *hardware_info* folder, although I didn't include the *mains* wiring: it's just the four sockets closed by four relays and the wiring towards the two power supplies, 12V and 4.5V.

On the software side, this project uses/depends on:
- https://github.com/richardghirst/PiBits/tree/master/ServoBlaster
- https://projects.drogon.net/raspberry-pi/wiringpi/
- https://github.com/andreafabrizi/Dropbox-Uploader
- https://ngrok.com/

Basically, is then a little collection of simple **bash** scripts run with `cron` on a **Raspbian** distribution.

**Please note**: this repository is not really useful as an out-of-the-box working project, since it also depends on some Debian packages installed and their configurations. I will be glad to explain further to anyone interested and anyway I think I'll expand the repository with some configuration files from the `/etc` folder.

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
