/** @file

Program to enable and set a volume level on the headphone amplifier chip

@author Raymond Weber
@copyright 2017 Flat Earth Inc

*/


#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <error.h>
#include <stdint.h>
#include <sys/mman.h>

#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


/** Typedef for a single volume level to hold the db volume level and the matching register value */
typedef struct {
  double value;
  uint8_t code;
} volumeLevel;


/** Structure with all possible volume level codes to use in TPA6130_register0.volume */
static volumeLevel volumeLevels[] = {
{.value = -100,  .code = 0x0C},
{.value = -59.5, .code = 0x00},
{.value = -53.5, .code = 0x01},
{.value = -50.0, .code = 0x02},
{.value = -47.5, .code = 0x03},
{.value = -45.5, .code = 0x04},
{.value = -43.9, .code = 0x05},
{.value = -41.4, .code = 0x06},
{.value = -39.5, .code = 0x07},
{.value = -36.5, .code = 0x08},
{.value = -35.3, .code = 0x09},
{.value = -33.3, .code = 0x0A},
{.value = -31.7, .code = 0x0B},
{.value = -30.4, .code = 0x0C},
{.value = -28.6, .code = 0x0D},
{.value = -27.1, .code = 0x0E},
{.value = -26.3, .code = 0x0F},
{.value = -24.7, .code = 0x10},
{.value = -23.7, .code = 0x11},
{.value = -22.5, .code = 0x12},
{.value = -21.7, .code = 0x13},
{.value = -20.5, .code = 0x14},
{.value = -19.6, .code = 0x15},
{.value = -18.8, .code = 0x16},
{.value = -17.8, .code = 0x17},
{.value = -17.0, .code = 0x18},
{.value = -16.2, .code = 0x19},
{.value = -15.2, .code = 0x1A},
{.value = -14.5, .code = 0x1B},
{.value = -13.7, .code = 0x1C},
{.value = -13.0, .code = 0x1D},
{.value = -12.3, .code = 0x1E},
{.value = -11.6, .code = 0x1F},
{.value = -10.9, .code = 0x20},
{.value = -10.3, .code = 0x21},
{.value = -9.7,  .code = 0x22},
{.value = -9.0,  .code = 0x23},
{.value = -8.5,  .code = 0x24},
{.value = -7.8,  .code = 0x25},
{.value = -7.2,  .code = 0x26},
{.value = -6.7,  .code = 0x27},
{.value = -6.1,  .code = 0x28},
{.value = -5.6,  .code = 0x29},
{.value = -5.1,  .code = 0x2A},
{.value = -4.5,  .code = 0x2B},
{.value = -4.1,  .code = 0x2C},
{.value = -3.5,  .code = 0x2D},
{.value = -3.1,  .code = 0x1E},
{.value = -2.6,  .code = 0x1F},
{.value = -2.1,  .code = 0x30},
{.value = -1.7,  .code = 0x31},
{.value = -1.2,  .code = 0x32},
{.value = -0.8,  .code = 0x33},
{.value = -0.3,  .code = 0x34},
{.value = 0.1,  .code = 0x35},
{.value = 0.5,  .code = 0x36},
{.value = 0.9,  .code = 0x37},
{.value = 1.4,  .code = 0x38},
{.value = 1.7,  .code = 0x39},
{.value = 2.1,  .code = 0x3A},
{.value = 2.5,  .code = 0x3B},
{.value = 2.9,  .code = 0x3C},
{.value = 3.3,  .code = 0x3D},
{.value = 3.6,  .code = 0x3E},
{.value = 4.0,  .code = 0x3F}};

//mode 00 = stereo headphone
//mode 01 = dual mono headphone
//mode 10 = bridge-tied load mode


/** Structure type to hold register 1 information */
typedef union {
  struct {
    uint32_t softwareShutdown   : 1;
    uint32_t thermalShutdown    : 1;
    uint32_t reservedBits       : 2;
    uint32_t mode               : 2;
    uint32_t rightChannelEnable : 1;
    uint32_t leftChannelEnable  : 1;
  };
  uint8_t reg;
} TPA6130_register1_t;

/** Structure type to hold register 2 information */
typedef union {
  struct {
    uint32_t volume            : 6;
    uint32_t muteRight         : 1;
    uint32_t muteLeft          : 1;
  };
  uint8_t reg;
} TPA6130_register2_t;

/** Structure type to hold register 3 information */
typedef union {
  struct {
    uint32_t HighZ_R            : 1;
    uint32_t HighZ_L            : 1;
    uint32_t reservedBits       : 6;
  };
  uint8_t reg;
} TPA6130_register3_t;

/** Structure type to hold register 4 information */
struct {
    uint32_t version            : 4;
    uint32_t reservedBits       : 4;
} TPA6130_register4_t;

int file;                                   /// I2C file discriptor


TPA6130_register1_t TPA6130_register1;      /// Instance of the struct to store register 1 data
TPA6130_register2_t TPA6130_register2;      /// Instance of the struct to store register 2 data


/** Function to set the volume close to a desired dB level

This function will effectivly ceil() to the closes dB level

For Example if:

If level is -18.8 -> the volume will be set to -18.8dB

If level is -18.9 -> the volume will be set to -18.8dB (rounds up to the next step)

If level is -18.7 -> the volume will be set to -17.8dB (rounds up to the next step)

@param level Desired volume level to set the headphone amp to
@return SUCCESS/FAILURE of the function
*/
int tpa6130_setVolume(double level)
{
    int i=0;
    char buf[10];

    printf("%f\n", level);

    //Find the closes volume level to the desired set point
    for (i=0; i<62; i++)
    {
        if (volumeLevels[i].value >= level)
            break;
    }

    printf("%d\n", i);

    TPA6130_register2.volume = volumeLevels[i].code;


    buf[0] = 0x02;
    buf[1] = TPA6130_register2.reg;

    if (write(file, buf, 2) != 2) {
        return 1;
    }

    printf("Set volume to %fdB\n", volumeLevels[i].value);

    return 0;
}



/**
Main loop for the function

This enables the headphone amplifier and reads the input arguments to determine what volume level to set things to.

@param argc Number of input arguments
@param argv 2d char array of the input arguments themselves
@return SUCCESS/FAILURE code
*/
int main(int argc, char ** argv)
{
    int i=0;

    for (i = 0; i < argc; i++) {
        printf("Argument %s\n", argv[i]);
    }

    //Set some defaults for the headphone amp
    TPA6130_register1.leftChannelEnable = 1;
    TPA6130_register1.rightChannelEnable = 1;
    TPA6130_register1.mode = 0;
    TPA6130_register1.softwareShutdown = 0;

    TPA6130_register2.muteLeft = 0;
    TPA6130_register2.muteRight = 0;
    TPA6130_register2.volume = volumeLevels[60].code;

    //Send out the headphone configuration
    char filename[40];
    int addr = 0x60;        // The I2C address of the ADC

    char buf[10];

    sprintf(filename, "/dev/i2c-0");
    if ((file = open(filename, O_RDWR)) < 0) {
        printf("Failed to open the bus.");
        exit(1);
    }

    if (ioctl(file, I2C_SLAVE, addr) < 0) {
        printf("Failed to acquire bus access and/or talk to slave.\n");
        exit(1);
    }

    //Enable both channels
    //0x01 0xc0
    buf[0] = 0x01;
    buf[1] = TPA6130_register1.reg;

    if (write(file, buf, 2) != 2) {
        printf("Failed to write to the i2c bus.\n");
        printf("\n\n");
    }

    //Set a default volume level
    buf[0] = 0x02;
    buf[1] = TPA6130_register2.reg;

    if (write(file, buf, 2) != 2) {
        printf("Failed to write to the i2c bus.\n");
        printf("\n\n");
    }

    //Set the volume level specified by the input argument
    ///@todo make this optional
    tpa6130_setVolume( atof(argv[1]) );

    return 0;
}


