# PiZeroRTOS
Because why not? This repo starts out as a Pi Zero bare metal project and it could very well end up as a viable RTOS implementation with a brand as yet to be determined.

Various baremetal developers and hackers out there have made great resources on Rasperry Pi 2/3/4 arm7 and byond to aarch64 but have appeared to abandon the Pi Zero and its arm1176jzf-s processor.

Well, perhaps I'm too stupid to know better but I submit that this is a worthy target now that qemu sufficently supports the Pi Zero as an emulated device.

This is a work in progress project but what I put up is a working example of starting the Pi Zero on qemu emulator.

I hope it proves to be a worthy foundation to greater things for you.

# What to anticipate from this work

* A really bare bonze OS that is not much more than a task scheduler
* Ability for a task to take ownership of a hardware device directly - there is no expectation of a device driver that is brokered by the OS
* A method for tasks to inter-communicate, preferably by hardware supported means
* A functioning frame buffer with hardware supported OpenGL
* UART, I2C, and SPI device examples
* Interrupt handling
* DMA (even if only used between SPI and Frame buffer)

# What it is now
* UART working
* bare metal booting
* Attempt to save the Pi 3/4 examples that are copied but then transposed to Pi Zero where only Pi Zero is actively tested
* Working build examples (built on a MacOS environment augmented by many gcc et. al. tools)

# Some key requirements
- https://www.qemu.org (download and build from github for the latest Pi Zero support, many distros don't include that)
- Xcode 
- xcode-select --install (command line tools)
- https://github.com/ARMmbed/homebrew-formulae

# Most usefull links
- https://azeria-labs.com/writing-arm-assembly-part-1/
- https://github.com/umanovskis/baremetal-arm
- https://pnx9.github.io/thehive/Debugging-Linux-Kernel.html
- https://github.com/dwelch67/raspberrypi
- https://www.raspberrypi.org/documentation/hardware/raspberrypi/README.md
- https://github.com/s-matyukevich/raspberry-pi-os
