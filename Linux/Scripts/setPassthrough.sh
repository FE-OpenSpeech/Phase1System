#!/bin/bash

echo 1 > /sys/class/fe_mux247/fe_mux247/input
echo 1 > /sys/class/fe_mux248/fe_mux248/input
echo 3 > /sys/class/fe_mux246/fe_mux246/output

/root/hp_vc 0

echo 1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0 > /sys/class/fe_fir245/fe_fir245/coefs
echo 1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0 > /sys/class/fe_fir244/fe_fir244/coefs

