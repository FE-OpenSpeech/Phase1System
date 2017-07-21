#!/bin/bash

/root/ha_band1.sh 0.0
/root/ha_band2.sh 0.0
/root/ha_band3.sh 0.0
/root/ha_band4.sh 0.0

if [ $# -eq 0 ] 
then
/root/ha_band5.sh 1.0
else
/root/ha_band5.sh $1
fi
