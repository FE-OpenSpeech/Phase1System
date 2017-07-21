/**
 * Library program to control the input mux selection (Memory mapped interface)
 *
 * Copyright 2017 by FlatEarth, Inc
 *
 * @par Compiler
 * GNU GCC
 *
 * @author Raymond Weber
 */

#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <error.h>
#include <stdint.h>
#include <sys/mman.h>

#include "hps_0.h"

// The start address and length of the Lightweight bridge
#define HPS_TO_FPGA_LW_BASE 0xFF200000
#define HPS_TO_FPGA_LW_SPAN 0x80000
#define INPUT_MUX_BASE 0x70000

int main(int argc, char ** argv)
{
  void * lw_bridge_map = 0;
  int devmem_fd = 0;
  int result = 0;

  int32_t * custom_mux_map = 0;

  printf("Opening memory\n");

  // Open up the /dev/mem device (aka, RAM)
  devmem_fd = open("/dev/mem", O_RDWR | O_SYNC);
  if (devmem_fd <= 0) {
    printf("Failed to open /dev/mem\n");
    perror("devmem open");
    exit(EXIT_FAILURE);
  }

  // mmap() the entire address space of the Lightweight bridge so we can access our custom module 
  lw_bridge_map = (uint32_t*)mmap(NULL, HPS_TO_FPGA_LW_SPAN, PROT_READ|PROT_WRITE, MAP_SHARED, devmem_fd, HPS_TO_FPGA_LW_BASE); 
  if (lw_bridge_map == MAP_FAILED) {
    perror("devmem mmap");
    close(devmem_fd);
    exit(EXIT_FAILURE);
  }


  printf("set pointer to memory and write it\n");

  // Set the custom_led_map to the correct offset within the RAM (CUSTOM_LEDS_0_BASE is from "hps_0.h")
  custom_mux_map = (int32_t*)(lw_bridge_map+INPUT_MUX_BASE);

  //Set the input to the first argument
  custom_mux_map[0] = atoi(argv[1]);

  printf("Closing mmap\n");

  // Unmap everything and close the /dev/mem file descriptor
  result = munmap(lw_bridge_map, HPS_TO_FPGA_LW_SPAN); 
  if (result < 0) {
    perror("devmem munmap");
    close(devmem_fd);
    return 1;
  }

  printf("Closing memory\n");
  close(devmem_fd);
  return 0;
  //exit(EXIT_SUCCESS);
}

