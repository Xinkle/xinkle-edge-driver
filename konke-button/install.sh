#!/bin/bash
#packageKey: 'zigbee-konke-button'
driverId=88195bef-3cba-4aad-bb65-f9d2b059e207
channel=83e4375f-fa44-4c9c-9c1e-d77c33ed3181 
hub=a7c6041b-37b4-4bad-b05b-58c3e0b77414

smartthings edge:drivers:package ./
smartthings edge:channels:assign $driverId --channel $channel
smartthings edge:drivers:install $driverId --channel $channel
smartthings edge:drivers:logcat