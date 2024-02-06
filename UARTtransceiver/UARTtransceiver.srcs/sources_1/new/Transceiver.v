`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: N/A
// Engineer: Hamish Wood
// 
// Create Date: 01/21/2024 04:07:17 PM
// Design Name: 
// Module Name: Transceiver
// Project Name: 
// Target Devices: Nexys A7-100T
// Tool Versions: 
// Description: Full Duplex 32-Byte UART Transceiver.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Transceiver(
    input CLK100MHZ,
    //input [255:0] TransmitMessage, //modify width to required bit width.
    //output reg [255:0] ReceiverMessage = 0, //modify width to required bit width.
    input TransmitSend,
    output reg TransmitDone = 1,
    output UART_RXD_OUT,
    input UART_TXD_IN,
    output reg [7:0] ReceiverTest = 0, //Demonstration mode output, can be commented out along with line 197.
    input ReceiverOn,  //Drive high to run the UART receiver, switch off to reset.
    output reg ReceiverFull = 0 //flag which is driven high once the receivermessage register is full.
    );
    
    //Demonstration mode registers.
    //comment out and Reassign registers to input/output depending on how many bytes are needed.
    reg [255:0] TransmitMessage = 256'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
    reg [255:0] ReceiverMessage = 0;
    ////////////////////////////////////////////////
    
    parameter ST_idle = 2'b01,
              ST_load = 2'b10,
              ST_busy = 2'b11,
              SR_idle = 2'b01,
              SR_waiting = 2'b10,
              SR_bundle = 2'b11;
    
    //number of bytes per request, do not modify unless more than 32 bytes are needed.
    parameter Format = 32;
    reg [31:0] TclkDelay = 0;
    
    // Modify with equation counter = 32 - (Bytes needed) along with lines 127,148 then comment out 
    // out of range cases for lines 82-115 and 162-195.
    reg [7:0] TPacketCounter = 0;
    reg [7:0] RPacketCounter = 0;
    
    wire TransDone;
    reg [7:0] TransPacket = 0;
    reg TransSend = 0;
    Transmitter T0(.Packet(TransPacket), .Send(TransSend), .Done(TransDone), .CLK100MHZ(CLK100MHZ), .UART_RXD_OUT(UART_RXD_OUT));
    
    wire RecGood;
    reg RecToggle;
    wire [7:0] ReceiverPacket;
    Receiver R0(.Packet(ReceiverPacket),.CLK100MHZ(CLK100MHZ),.UART_TXD_IN(UART_TXD_IN),.On(RecToggle),.StopBit(RecGood));
    
    
    reg [1:0] TransState = ST_idle;
    reg [1:0] ReceiverState = SR_idle;
    
    
    always @ (posedge CLK100MHZ) begin
        case (TransState)
            ST_idle: begin
                if (TransmitSend) begin
                    TransState = ST_load;
                    TransmitDone = 0;
                end
            end
            ST_load: begin
                case (TPacketCounter)
                    31: TransPacket = TransmitMessage[7:0];
                    30: TransPacket = TransmitMessage[15:8];
                    29: TransPacket = TransmitMessage[23:16];
                    28: TransPacket = TransmitMessage[31:24];
                    27: TransPacket = TransmitMessage[39:32];
                    26: TransPacket = TransmitMessage[47:40];
                    25: TransPacket = TransmitMessage[55:48];
                    24: TransPacket = TransmitMessage[63:56];
                    23: TransPacket = TransmitMessage[71:64];
                    22: TransPacket = TransmitMessage[79:72];
                    21: TransPacket = TransmitMessage[87:80];
                    20: TransPacket = TransmitMessage[95:88];
                    19: TransPacket = TransmitMessage[103:96];
                    18: TransPacket = TransmitMessage[111:104];
                    17: TransPacket = TransmitMessage[119:112];
                    16: TransPacket = TransmitMessage[127:120];
                    15: TransPacket = TransmitMessage[135:128];
                    14: TransPacket = TransmitMessage[143:136];
                    13: TransPacket = TransmitMessage[151:144];
                    12: TransPacket = TransmitMessage[159:152];
                    11: TransPacket = TransmitMessage[167:160];
                    10: TransPacket = TransmitMessage[175:168];
                    9: TransPacket = TransmitMessage[183:176];
                    8: TransPacket = TransmitMessage[191:184];
                    7: TransPacket = TransmitMessage[199:192];
                    6: TransPacket = TransmitMessage[207:200];
                    5: TransPacket = TransmitMessage[215:208];
                    4: TransPacket = TransmitMessage[223:216];
                    3: TransPacket = TransmitMessage[231:224];
                    2: TransPacket = TransmitMessage[239:232];
                    1: TransPacket = TransmitMessage[247:240];
                    0: TransPacket = TransmitMessage[255:248];
                endcase
                TPacketCounter = TPacketCounter + 1;
                TransSend = 1;
                TransState = ST_busy;
            end
            ST_busy: begin
                TransSend = 0;
                if (TransDone) begin
                    if (TPacketCounter == Format) begin
                        if (!TransmitSend) begin
                            TransState = ST_idle;
                            TransmitDone = 1;
                            TPacketCounter = 0; //configurable.
                        end
                    end else if (TclkDelay == 1000000) begin  //Prevent packets from being transmitted too quickly.
                        TransState = ST_load;
                        TclkDelay = 0;
                    end else begin
                        TclkDelay = TclkDelay + 1;
                    end
                end
            end
        endcase
        
        case (ReceiverState)
            SR_idle: begin
                if (ReceiverOn & RPacketCounter != Format) begin
                    ReceiverState = SR_waiting;
                    RecToggle = 1;
                end else if (RPacketCounter == Format) begin
                    ReceiverFull = 1;
                end
                if (!ReceiverOn) begin
                    RPacketCounter = 0; //configurable.
                    RecToggle = 0;
                    ReceiverFull = 0;
                end
            end
            SR_waiting: begin
                if (RecGood) begin
                    ReceiverState = SR_bundle;
                end
                if (!ReceiverOn) begin
                    ReceiverState = SR_idle;
                end
            end
            SR_bundle: begin
                case (RPacketCounter)
                    0: ReceiverMessage[255:248] = ReceiverPacket;
                    1: ReceiverMessage[247:240] = ReceiverPacket;
                    2: ReceiverMessage[239:232] = ReceiverPacket;
                    3: ReceiverMessage[231:224] = ReceiverPacket;
                    4: ReceiverMessage[223:216] = ReceiverPacket;
                    5: ReceiverMessage[215:208] = ReceiverPacket;
                    6: ReceiverMessage[207:200] = ReceiverPacket;
                    7: ReceiverMessage[199:192] = ReceiverPacket;
                    8: ReceiverMessage[191:184] = ReceiverPacket;
                    9: ReceiverMessage[183:176] = ReceiverPacket;
                    10: ReceiverMessage[175:168] = ReceiverPacket;
                    11: ReceiverMessage[167:160] = ReceiverPacket;
                    12: ReceiverMessage[159:152] = ReceiverPacket;
                    13: ReceiverMessage[151:144] = ReceiverPacket;
                    14: ReceiverMessage[143:136] = ReceiverPacket;
                    15: ReceiverMessage[135:128] = ReceiverPacket;
                    16: ReceiverMessage[127:120] = ReceiverPacket;
                    17: ReceiverMessage[119:112] = ReceiverPacket;
                    18: ReceiverMessage[111:104] = ReceiverPacket;
                    19: ReceiverMessage[103:96] = ReceiverPacket;
                    20: ReceiverMessage[95:88] = ReceiverPacket;
                    21: ReceiverMessage[87:80] = ReceiverPacket;
                    22: ReceiverMessage[79:72] = ReceiverPacket;
                    23: ReceiverMessage[71:64] = ReceiverPacket;
                    24: ReceiverMessage[63:56] = ReceiverPacket;
                    25: ReceiverMessage[55:48] = ReceiverPacket;
                    26: ReceiverMessage[47:40] = ReceiverPacket;
                    27: ReceiverMessage[39:32] = ReceiverPacket;
                    28: ReceiverMessage[31:24] = ReceiverPacket;
                    29: ReceiverMessage[23:16] = ReceiverPacket;
                    30: ReceiverMessage[15:8] = ReceiverPacket;
                    31: ReceiverMessage[7:0] = ReceiverPacket;
                endcase
                RecToggle = 0;
                ReceiverTest = ReceiverPacket; //Demonstration mode assignment.
                if (!RecGood) begin
                    ReceiverState = SR_idle;
                    RPacketCounter = RPacketCounter + 1;
                end
            end
        endcase
    end
    
endmodule
