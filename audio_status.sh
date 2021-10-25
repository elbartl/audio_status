#!/bin/bash
#detecting audio playback

#AUDIO_GPIO - GPIO pin number connected to relay
AUDIO_GPIO=7
#TIMEOUT - inactivity time to switch the relay to OFF in seconds
TIMEOUT=600
#STEP - check frequency in seconds
STEP=0.5
#internal variables initialisation

### WiringPi version
SWITCH_ON="gpio write ${AUDIO_GPIO} 1;"
SWITCH_OFF="gpio write ${AUDIO_GPIO} 0;"

###  versio GPIO
#SWITCH_ON="echo 1 > /sys/class/gpio/gpio${AUDIO_GPIO}/value"
#SWITCH_OFF="echo 0 > /sys/class/gpio/gpio${AUDIO_GPIO}/value"

STATUS=0
PREVIOUS_STATUS=0
STATUS_CHANGE=0
OFF_TIMEOUT=0
OFF=1

#Initiating correct GPIO  for audio on/off

### WiringPi version
gpio mode ${AUDIO_GPIO} output

### Direct GPIO
#echo ${AUDIO_GPIO} > /sys/class/gpio/export


#Main checking function
function check {
        if [ "`grep -i running  /proc/asound/card*/*p/*/status`" ]
        then
                STATUS=1
                sleep $STEP
        else
                STATUS=0
                sleep $STEP
        fi
}

#checks weather status has changed from play/stop to stop/play
function status_change {
        if [ "$PREVIOUS_STATUS" != "$STATUS" ]
        then
                PREVIOUS_STATUS=$STATUS
                STATUS_CHANGE=1
        else
                STATUS_CHANGE=0
        fi
}

function playing {
        if [ $STATUS_CHANGE = 1 ]
        then
                echo "do that when start playing"
                eval $SWITCH_ON
                OFF_TIMEOUT=0
                OFF=0
        fi
}

function not_playing {
        if [ $STATUS_CHANGE = 1 ]
        then
                echo "do that when stop playing"
                OFF_TIMEOUT=1
        fi
}

#check if we are waiting timeout till OFF=1 - shuts down equipement
function timeout {
        if [ $OFF_TIMEOUT > 0 ] && [ "$OFF" = 0 ]
        then
                if [ $OFF_TIMEOUT != $TIMEOUT ]
                then
                        echo -n "."
                        OFF_TIMEOUT=$[OFF_TIMEOUT+1]
                else
                        echo "timeout reached"
                        OFF=1
                        eval $SWITCH_OFF
                fi
        fi
}

#Main loop
while true;
do
        check
        status_change
        if [ $STATUS = 1 ]
        then
                playing
        else
                not_playing
                timeout
        fi
        sleep $STEP
done
