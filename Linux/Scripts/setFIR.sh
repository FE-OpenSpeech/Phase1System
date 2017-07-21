#!/bin/bash

echo 1 > /sys/class/fe_mux247/fe_mux247/input
echo 1 > /sys/class/fe_mux246/fe_mux246/input
echo 3 > /sys/class/fe_mux245/fe_mux245/output

/root/hp_vc 0

cat Coefs_high.txt > /sys/class/fe_fir243/fe_fir243/coefs
cat Coefs_low.txt > /sys/class/fe_fir244/fe_fir244/coefs

