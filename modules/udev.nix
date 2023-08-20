{ pkgs, ... }:

{
  services.udev = {
    packages = with pkgs; [
      android-udev-rules
      chrysalis
      logitech-udev-rules
      qmk-udev-rules
      via
      vial
    ];
    extraRules = ''
      # make the trackpoint much more usable
      ACTION=="add", SUBSYSTEM=="input", ATTR{name}=="TPPS/2 IBM TrackPoint", ATTR{device/drift_time}="25"

      # HHKB Professional Hybrid
      KERNEL=="hidraw*", ATTRS{idVendor}=="04fe", TAG+="uaccess"

      # Serial Port Rules
      KERNEL=="ttyUSB[0-9]*", TAG+="udev-acl", TAG+="uaccess", OWNER="$1"
      KERNEL=="ttyACM[0-9]*", TAG+="udev-acl", TAG+="uaccess", OWNER="$1"

      # Arduino M0/M0 Pro, Primo UDEV Rules for CMSIS-DAP port
      ACTION!="add|change", GOTO="openocd_rules_end"
      SUBSYSTEM!="usb|tty|hidraw", GOTO="openocd_rules_end"
      ATTRS{product}=="*CMSIS-DAP*", MODE="664", GROUP="plugdev"
      LABEL="openocd_rules_end"

      # AVRisp UDEV rules
      SUBSYSTEM!="usb_device", ACTION!="add", GOTO="avrisp_end"
      # Atmel Corp. JTAG ICE mkII
      ATTR{idVendor}=="03eb", ATTRS{idProduct}=="2103", MODE="660", GROUP="dialout"
      # Atmel Corp. AVRISP mkII
      ATTR{idVendor}=="03eb", ATTRS{idProduct}=="2104", MODE="660", GROUP="dialout"
      # Atmel Corp. Dragon
      ATTR{idVendor}=="03eb", ATTRS{idProduct}=="2107", MODE="660", GROUP="dialout"
      LABEL="avrisp_end"

      # STM32 bootloader mode UDEV rules
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="664", GROUP="plugdev", TAG+="uaccess"

      # Arduino 101 in DFU Mode
      SUBSYSTEM=="tty", ENV{ID_REVISION}=="8087", ENV{ID_MODEL_ID}=="0ab6", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0"
      SUBSYSTEM=="usb", ATTR{idVendor}=="8087", ATTR{idProduct}=="0aba", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1"

      # allow "dialout" group read/write access to ADI PlutoSDR devices
      # DFU Device
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b674", MODE="0664", GROUP="dialout"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2fa2", ATTRS{idProduct}=="5a32", MODE="0664", GROUP="dialout"
      # SDR Device
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b673", MODE="0664", GROUP="dialout"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2fa2", ATTRS{idProduct}=="5a02", MODE="0664", GROUP="dialout"
      # tell the ModemManager (part of the NetworkManager suite) that the device is not a modem,
      # and don't send AT commands to it
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b673", ENV{ID_MM_DEVICE_IGNORE}="1"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2fa2", ATTRS{idProduct}=="5a02", ENV{ID_MM_DEVICE_IGNORE}="1"
      # allow "dialout" group read/write access to ADI M2K devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b672", MODE="0664", GROUP="dialout"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b675", MODE="0664", GROUP="dialout"
      # tell the ModemManager (part of the NetworkManager suite) that the device is not a modem,
      # and don't send AT commands to it
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b672", ENV{ID_MM_DEVICE_IGNORE}="1"

      # Intel Quartus
      # USB-Blaster
      SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6001", MODE="0666", GROUP="usbblaster"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6002", MODE="0666", GROUP="usbblaster"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6003", MODE="0666", GROUP="usbblaster"
      # USB-Blaster II
      SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6010", MODE="0666", GROUP="usbblaster"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6810", MODE="0666", GROUP="usbblaster"

      # TI Code Composer Studio
      # MSP430UIF
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0010", MODE="0666"
      # MSP430EZ
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0013", MODE="0666"
      # MSP430MSPFET
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0014", MODE="0666"
      # MSP430HID
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0203", MODE="0666"
      # MSP430HID2
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0204", MODE="0666"
      # MSP430EZ430
      ATTRS{idVendor}=="0451", ATTRS{idProduct}=="f432", MODE="0666"

      # Texas Instruments USB devices
      SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="a6d0",MODE:="0666"
      SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="a6d1",MODE:="0666"
      SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="6010",MODE:="0666"
      SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="6011",MODE:="0666"
      SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="bcd9",MODE:="0666"
      SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="bcda",MODE:="0666"
      SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1cbe",ATTRS{idProduct}=="00fd",MODE:="0666"
      SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1cbe",ATTRS{idProduct}=="00ff",MODE:="0666"
      SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef1",MODE:="0666"
      SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef2",MODE:="0666"
      SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef3",MODE:="0666"
      SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef4",MODE:="0666"
      SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1cbe",ATTRS{idProduct}=="02a5",MODE:="0666"
      SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="c32a",MODE:="0666"
      ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef0",ENV{ID_MM_DEVICE_IGNORE}="1"
      ATTRS{idVendor}=="0c55",ATTRS{idProduct}=="0220",ENV{ID_MM_DEVICE_IGNORE}="1"
      KERNEL=="ttyACM[0-9]*",MODE:="0666"
      ACTION=="add",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="a6d0",RUN+="/sbin/modprobe ftdi_sio",RUN+="${pkgs.bash}/bin/sh -c 'echo 0403 a6d0 > /sys/bus/usb-serial/drivers/ftdi_sio/new_id'"
      ACTION=="add",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="a6d1",RUN+="/sbin/modprobe ftdi_sio",RUN+="${pkgs.bash}/bin/sh -c 'echo 0403 a6d1 > /sys/bus/usb-serial/drivers/ftdi_sio/new_id'"
      KERNEL=="hidraw*",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef3",MODE:="0666"
      KERNEL=="hidraw*",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef4",MODE:="0666"
      # Spectrum Digital USB devices
      SUBSYSTEM=="usb", ATTR{idVendor}=="0c55" ,ATTR{idProduct}=="0540", ATTR{manufacturer}=="Spectrum Digital Inc.",MODE="0666"
      SUBSYSTEM=="usb", ATTR{idVendor}=="0c55" ,ATTR{idProduct}=="0510", ATTR{manufacturer}=="Spectrum Digital, Inc.",MODE="0666"
      SUBSYSTEM=="usb", ATTR{idVendor}=="0c55" ,ATTR{idProduct}=="2000", ATTR{manufacturer}=="Spectrum Digital, Inc.",MODE="0666"
      SUBSYSTEM=="usb", ATTR{idVendor}=="0c55" ,ATTR{idProduct}=="0562",MODE="0666"
      SUBSYSTEM=="usb", ATTR{idVendor}=="0c55" ,ATTR{idProduct}=="0566",MODE="0666"

      # TI USB Emulators
      ACTION!="add|change", GOTO="mm_usb_device_blacklist_end"
      SUBSYSTEM!="usb", GOTO="mm_usb_device_blacklist_end"
      ENV{DEVTYPE}!="usb_device",  GOTO="mm_usb_device_blacklist_end"

      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0010", ENV{ID_MM_DEVICE_IGNORE}="1"
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0010", ENV{MTP_NO_PROBE}="1"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0010", MODE:="0666"
      KERNEL=="ttyACM*", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0010", MODE:="0666"
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0013", ENV{ID_MM_DEVICE_IGNORE}="1"
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0013", ENV{MTP_NO_PROBE}="1"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0013", MODE:="0666"
      KERNEL=="ttyACM*", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0013", MODE:="0666"
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0014", ENV{ID_MM_DEVICE_IGNORE}="1"
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0014", ENV{MTP_NO_PROBE}="1"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0014", MODE:="0666"
      KERNEL=="ttyACM*", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0014", MODE:="0666"
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0203", ENV{ID_MM_DEVICE_IGNORE}="1"
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0203", ENV{MTP_NO_PROBE}="1"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0203", MODE:="0666"
      KERNEL=="ttyACM*", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0203", MODE:="0666"
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0204", ENV{ID_MM_DEVICE_IGNORE}="1"
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0204", ENV{MTP_NO_PROBE}="1"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0204", MODE:="0666"
      KERNEL=="ttyACM*", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="0204", MODE:="0666"
      ATTRS{idVendor}=="0451", ATTRS{idProduct}=="f432", ENV{ID_MM_DEVICE_IGNORE}="1"
      ATTRS{idVendor}=="2047", ATTRS{idProduct}=="f432", ENV{MTP_NO_PROBE}="1"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="f432", MODE:="0666"
      KERNEL=="ttyACM*", ATTRS{idVendor}=="2047", ATTRS{idProduct}=="f432", MODE:="0666"
      LABEL="mm_usb_device_blacklist_end"
    '';
  };
}
