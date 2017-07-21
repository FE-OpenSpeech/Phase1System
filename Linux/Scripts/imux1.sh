#!/bin/bash

if [ $# -eq 0 ] 
then
echo 1 > /sys/class/fe_mux247/fe_mux247/input
else
echo $1 > /sys/class/fe_mux247/fe_mux247/input
fi

echo "Readback Value:"
cat /sys/class/fe_mux247/fe_mux247/input
