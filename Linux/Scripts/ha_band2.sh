#!/bin/bash

echo $1 > /sys/class/fe_HA248/fe_HA248/band2_gain
echo $1 > /sys/class/fe_HA249/fe_HA249/band2_gain 


echo "Readback Value:"
cat /sys/class/fe_HA248/fe_HA248/band2_gain
