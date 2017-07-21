#!/bin/bash

if [ $# -eq 0 ] 
then
echo 3 > /sys/class/fe_mux245/fe_mux245/output
else
echo $1 > /sys/class/fe_mux245/fe_mux245/output
fi

echo "Readback Value:"
cat /sys/class/fe_mux245/fe_mux245/output
