`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2024 01:53:32 PM
// Design Name: 
// Module Name: Transmitter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Transmitter(
    input CLK100MHZ,
    input Send,
    input [7:0] Packet,
    output reg UART_RXD_OUT = 1,
    output reg Done = 1
    );
    
    parameter S_idle = 2'b01,
              S_load = 2'b10,
              S_sending = 2'b11;
    
    //ClkPerBit = clk/baud, ClkPerBit above the baud rate may cause repetition.
    parameter ClkPerBit = 100000000/57600;
    reg [31:0] ClkCounter = 0;
    
    
    reg [1:0] currentState = S_idle;
    
    reg [9:0] SendingReg = 0;
    
    always @ (posedge CLK100MHZ) begin
        case(currentState)
            //Idle state until send command triggered.
            S_idle: begin 
                Done = 1;
                if (Send) begin
                    currentState = S_load;
                    Done = 0;
                end
            end
            //Reverse the input and concatonate into a UART format packet with start and stop bit.
            S_load: begin 
                SendingReg[1] = Packet[7];
                SendingReg[2] = Packet[6];
                SendingReg[3] = Packet[5];
                SendingReg[4] = Packet[4];
                SendingReg[5] = Packet[3];
                SendingReg[6] = Packet[2];
                SendingReg[7] = Packet[1];
                SendingReg[8] = Packet[0];
                SendingReg = {1'b0,SendingReg[8:1],1'b1};
                currentState = S_sending;
            end
            //Send a bit through UART_RXD every baud interval and shift message register until all bits are sent then set line high and go to idle.
            S_sending: begin 
                if (ClkCounter == ClkPerBit) begin
                    if (SendingReg != 10'b0000000000) begin
                        UART_RXD_OUT = SendingReg[9];
                        SendingReg = {SendingReg[8:0],1'b0};
                        ClkCounter = 0;
                    end else begin
                        //if (!Send) begin
                            currentState = S_idle;
                            ClkCounter = 0;
                        //end
                    end
                end else begin
                    ClkCounter = ClkCounter + 1;
                end
            end
        endcase
    end

endmodule
