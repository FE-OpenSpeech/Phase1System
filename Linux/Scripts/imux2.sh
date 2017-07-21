#!/bin/bash

if [ $# -eq 0 ] 
then
echo 1 > /sys/class/fe_mux246/fe_mux246/input
else
echo $1 > /sys/class/fe_mux246/fe_mux246/input
fi

echo "Readback Value:"
cat /sys/class/fe_mux246/fe_mux246/input
