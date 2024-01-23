# UART_Transceiver
Configurable Full Duplex UART Transceiver for FPGAs

This Repository contains the verilog code for a UART transmitter and receiver module which can be modified to fit the need of projects for students or hobbyists.  
  
The module starts in demonstration mode for initial testing and must be modified and integrated into an existing project.  
  
This module's default settings are to send and receive 32 byte messages over a 57600 baud connection with 1 stop bit and no handshake but can be configured according to the comments in its source files. 
  
Source Files - .srcs/sources_1/new/  
This Repo contains a compiled bitstream for the Nexys A7-100T FPGA to test serial connections: Transceiver.bit
