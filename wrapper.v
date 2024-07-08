`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2024 09:51:15 AM
// Design Name: 
// Module Name: wrapper
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


module wrapper(
    input CLK100MHZ,
    input UART_TXD_IN,
    output [7:0] LED,
    output UART_RXD     //output of UART

    );
    wire RX_DV; //data valid wire
    reg rTX_DV;
    wire TXOver;
    wire TX_Active;
    wire [7:0] byteTx;
    wire [7:0] byteRX;
    reg [7:0] lastValidByte;
    uart_receiver uart_receiver
    (
        .clk(CLK100MHZ),
        .RxD(UART_TXD_IN),
        .RX_DV(RX_DV),
        .byte(byteRX)
    );
    
    uart_transmitter uart_transmitter
    (
        .clk(CLK100MHZ),
        .TX_DV(rTX_DV),
        .TxD(UART_RXD),
        .TXOver(TXOver),
        .TX_Active(TX_Active),
        .TXByte(byteTx)
    
    
    );
    
    
    always @ (posedge CLK100MHZ)
    begin
        if(RX_DV == 1'b1)//if recived data is valid (has been received)
        begin
            lastValidByte <= byteRX;
            rTX_DV <= 1'b1;
        end
    if(TX_Active == 1'b1)   //if transmission has started, dont call to send the same packet anymore
    begin
             rTX_DV <= 1'b0; //resetting data valid so data isnt coninuously sent
    end
    end

   
    
    assign LED = lastValidByte;
    
        //testing
            assign byteTx = lastValidByte;

endmodule
