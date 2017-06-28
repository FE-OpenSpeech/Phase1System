# Phase1System

This GitHub repository contains source code for Flat Earth, Inc.'s  Open Speech FPGA Signal Processing Platform

## Introduction
Flat Earth, Inc. was recently awarded an NIH SBIR to help develop Open Design Tools
for Speech Signal Processing (NIH RFA-DC-16-002). Flat Earth is developing a FPGA
based computational platform that will bring FPGA capabilities of real-time computation
and deterministic low latency to the speech and hearing aid research community. Flat
Earth has developed a Phase I system that demonstrates three subsystems. The first
subsystem is the developed audio board that implements an audio codec and transmits
the digital data to/from the FPGA. The second subsystem is the data plane in the
FPGA fabric where all DSP processing is done in real-time. The third subsystem is the
control of the data plane where Linux, running on ARM CPUs inside the FPGA, can
communicate parameters to the data plane processing blocks in order to control them.
Flat Earth’s goal is to develop a platform where users can design their DSP algorithms
in Mathwork’s Simulink and then have these algorithms automatically placed in the
FPGA where they will process data in real-time.

More information can be found at:  
- https://flatearthinc.com/
- https://flatearthinc.com/open-speech-platform-0
- https://store.flatearthinc.com/

## The Phase1System repository is organized as follows:

#### [AD1939 Audio Codec](http://www.analog.com/en/products/audio-video/audio-codecs/ad1939.html) (Analog Device's 4 ADC/8 DAC with PLL, 192 kHz, 24-Bit Codec)


- **/AD1939**    - contains source and material related to Analog Device's AD1939 audio codec that we used for the audio daughter card
    - **/AD1939/Source_Files**         - contains the source code
        - **/AD1939/Source_Files/Matlab**  - contains Matlab source code
        - **/AD1939/Source_Files/VHDL**    - contains VHDL source code
        - **/AD1939/Source_Files/IP**      - contains IP generated by Quartus Prime that is used by the VHDL files
    - **/AD1939/Documentation**        - Data sheets, etc.

