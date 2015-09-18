PiAC v1.4
====

###(Raspberry) Pi Aquarium Controller

##Info
This is a DIY project to control and monitor some aspects of my fresh-water aquarium.

It uses a Raspberry Pi and some hardware to control/monitor some mains sockets, a blue LED strip, a custom-built LED fixture (actually four spotlights) two cooling fans and two temperature probes. Some schematics are available in the *hardware_info* folder, although I didn't include some *mains* wiring; anyway it's simple: it's just the four sockets closed by four relays and the wiring towards two buck-converters to have 12V and 5V from the 24V power supply now in use for the main LEDs).

On the software side, this project uses/depends on:
- https://github.com/richardghirst/PiBits/tree/master/ServoBlaster *(hybrid hardware/software PWM)*
- https://projects.drogon.net/raspberry-pi/wiringpi/ *(userspace GPIO pins control)*
- https://github.com/andreafabrizi/Dropbox-Uploader *(auto-upload backups to DropBox)*
- https://ngrok.com/ *(remote `ssh` and web access)*
- https://dweet.io and https://freeboard.io *(IoT: messages from this project to a web dasboard)*
- https://stedolan.github.io/jq/ *(a lightweight and flexible command-line JSON processor)*

Basically, then I wrote a collection of simple **bash** scripts running with `cron` on a **Raspbian** distribution.

**Please note**: this repository may not work out-of-the-box to start a similar project. Some other bits are necessary, since **PiAC** also depends on some Debian packages manually installed and their configurations. I will be glad to explain further to anyone interested and anyway I'm expanding the repository with some configuration files (i.e. from the `/etc` folder).

##Features
####v1.0
- three GPIO pins (17, 27, 22) connected to an ULN2003A and a 12V rail to have three "PWM to voltage" channels, to use with:
 1. a blue night LED strip
 2. *unused*
 3. *unused*
- four GPIO pins (18, 23, 24, 25) to switch 4 single relay boards via four opto-isolators "modules", to use with:
 1. lid cooling fan (+ LED spotlights cooling fans, from v1.3)
 2. CO2 electrovalve
 3. secondary (micro-)acquarium LED light
 4. *unused*
- GPIO pin n.4 (1-wire) to two DS18B20 temp probe connectors (water and RPi case);

####v1.1
- Switched from a Raspberry Pi model B rev1 to a model B+;
- Finished mounting the lid cooler fan;
- Real Time Clock added;
- rootfs mounted on USB stick.

####v1.2
- Manage a DIY LED fixture with sunrise/sunset simulation.

####v1.3
- Use two DC-DC converters to have 12V (for blue LEDs and fans) and 5V (for the RPi itself) from the 24V main power supply in use for the LED fixtures;
- LED spotlights cooling fans.

####v1.4
- Fetch sunrise/sunset data from http://sunrise-sunset.org and build a new timetable every day (based on actual location).

####TO-DO
- Power button on the main enclosure, to reboot/shutdown the RPi.
