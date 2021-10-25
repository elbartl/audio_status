# audiostatus
## Simple script to automatically detect raspberry pi playback status to power on/off audio gear

Script created couple years ago, to avoid switching on and off amplifier each time audio playback is started or stopped on my network raspberri pi player. To do so script  checks `/proc/asound/card*/*p/*/status` for `state: RUNNING`. When detected (something is sending audio through sound card) audio gear needs to be powered on accordingly. Script activates relay connected through rasperry pi gpio port to allow audio to pass through external gear. 

Tested on the following boards: raspberry pi 1b, rasberry pi 4b raspberry pi zero, bananapi m1, banana pi pro. It should work on others too. I have used it on raspberry pi os (both 32bit and 64bit), bananian and armbian.

### Use case

* control external amplifier, used as raspberry pi audio output. It needs to have some opton to be stwitch on/off simply by power to it or control power button by relay.

### prerequisites 

* WiringPi library - it is possible to use it without this library, you need to coment out `WiringPi version`  section and uncomment `Direct GPIO`

### Usage

1. copy audio_status.sh to  /etc/AudioStatus/ and make it executable
2. create service audio_status

    ```
    sudo vim /lib/systemd/system/audio_status.service
    ```
    
   with the folowing content:
   
    ```
    [Unit]
    Description=Audio Control Daemon

    [Service]
    ExecStart=/etc/AudioStatus/audio_status.sh &

    # Give a reasonable amount of time for the server to start up/shut down
    #TimeoutSec=30

    [Install]
    WantedBy=multi-user.target
    ```
    
  3. enable and start service

      ```
      sudo systemctl enable audio_status
      sudo systemctl start audio_status
      ```

    
