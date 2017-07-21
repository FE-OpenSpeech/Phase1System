#!/bin/bash

echo 1 > /sys/class/fe_mux248/fe_mux248/input
echo 2 > /sys/class/fe_mux247/fe_mux247/input
echo 3 > /sys/class/fe_mux246/fe_mux246/output

/root/hp_vc 0


echo 0.2      > /sys/class/fe_HA249/fe_HA249/band1_gain
echo 2880     > /sys/class/fe_HA249/fe_HA249/band1_delay
echo 0        > /sys/class/fe_HA249/fe_HA249/band1_drc_bypass
echo 10       > /sys/class/fe_HA249/fe_HA249/band1_drc_threshold
echo 5.62     > /sys/class/fe_HA249/fe_HA249/band1_drc_gain1
echo 31.62    > /sys/class/fe_HA249/fe_HA249/band1_drc_gain2
echo 0.25     > /sys/class/fe_HA249/fe_HA249/band1_drc_exponent





