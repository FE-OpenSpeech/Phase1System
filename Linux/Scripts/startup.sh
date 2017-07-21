#!/bin/bash

insmod /root/Drivers/FE_Qsys_HA_DRC.ko
insmod /root/Drivers/FE_Qsys_InputMux.ko
insmod /root/Drivers/FE_Qsys_OutputMux.ko
insmod /root/Drivers/FE_Qsys_FIR.ko

/root/ha_band1.sh 1.0
/root/ha_band2.sh 1.0
/root/ha_band3.sh 1.0
/root/ha_band4.sh 1.0
/root/ha_band5.sh 0.0

echo 2 > /sys/class/fe_mux246/fe_mux246/input
echo 1 > /sys/class/fe_mux247/fe_mux247/input

echo 3 > /sys/class/fe_mux245/fe_mux245/output

/root/hp_vc 0
