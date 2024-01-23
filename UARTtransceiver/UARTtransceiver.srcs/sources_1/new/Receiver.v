`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2024 12:30:25 PM
// Design Name: 
// Module Name: Receiver
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


module Receiver(
    input CLK100MHZ,
    input On,
    input UART_TXD_IN,
    output reg [7:0] Packet,
    output reg StopBit
    );
    
    parameter S_idle = 2'b00,
              S_waiting = 2'b01,
              S_listening = 2'b10;
              
    parameter ClkPerBit = 100000000/57600;
    reg [31:0] ClkCounter = 0;
    reg [3:0] BitCounter = 0;
    
    reg [1:0] currentState = S_idle;
    reg [7:0] PacketReg = 0;
    
    always @ (posedge CLK100MHZ) begin
        if (!On) begin
            currentState = S_idle;
            Packet = 0;
            BitCounter = 0;
            ClkCounter = 0;
        end
        case (currentState)
            S_idle: begin 
                if (On) begin
                    currentState = S_waiting;
                    ClkCounter = 0;
                    BitCounter = 0;
                    StopBit = 0;
                end
            end
            S_waiting: begin 
                if (!UART_TXD_IN) begin
                    if (ClkCounter == ClkPerBit/2) begin
                        currentState = S_listening;
                        ClkCounter = 0;
                    end else begin
                        ClkCounter = ClkCounter + 1;
                    end
                end
            end
            S_listening: begin 
                if (ClkCounter == ClkPerBit) begin
                    case (BitCounter)
                        0: Packet[0] = UART_TXD_IN;
                        1: Packet[1] = UART_TXD_IN;
                        2: Packet[2] = UART_TXD_IN;
                        3: Packet[3] = UART_TXD_IN;
                        4: Packet[4] = UART_TXD_IN;
                        5: Packet[5] = UART_TXD_IN;
                        6: Packet[6] = UART_TXD_IN;
                        7: Packet[7] = UART_TXD_IN;
                        8: begin
                            currentState = S_idle;
                            StopBit = UART_TXD_IN;
                        end
                    endcase
                    BitCounter = BitCounter + 1;
                    ClkCounter = 0;
                end else begin
                    ClkCounter = ClkCounter + 1;
                end
            end
        endcase
    end
endmodule
