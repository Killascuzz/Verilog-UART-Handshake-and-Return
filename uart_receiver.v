`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2024 08:55:51 AM
// Design Name: 
// Module Name: uart_receiver
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

// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 100 MHz Clock, 115200 baud UART
// (100000000)/(115200) = 868.05


module uart_receiver
#(parameter CLKS_PER_BIT = 10416) //868 clock cycles per bit of UART data stream
(
    input clk,
    input RxD,
    output RX_DV,   //single pulse, data valid
    output [7:0] byte
    );
    
    //state machine parameters
    parameter IDLE = 3'b000;
    parameter RX_START_BIT = 3'b001;
    parameter RX_DATA_BIT = 3'b010;
    parameter RX_STOP_BIT = 3'b011;
    parameter CLEANUP = 3'b100;

    
    //registers
    reg [13:0] rClkCount; //counts the ammount of clock cycles passed since last tick
    reg [2:0] rBitIndex;
    reg [7:0] rRXByte;
    reg rRXDV;
    reg [2:0] rState;   //current state of the state machine
    
    
    
    
    
    always @(posedge clk)
    begin
    
    case (rState)
        //the state machine has not detected a start bit yet
        IDLE:
        begin
        rRXDV <= 0; //data is not valid
        rClkCount <= 0;
        
        if(RxD == 1'b0) //if start bit found
        begin
        rState <= RX_START_BIT;
        end
   
    
    end
    //check middle of detected start bit to ensure it is a start bit
    RX_START_BIT:   
    begin
    if(rClkCount == (CLKS_PER_BIT / 2))
    begin
    //check is middle of start bit is 0
    if(RxD == 1'b0)
    begin
    rState <= RX_DATA_BIT;  //change state to data collection
    end
    
    else    //if RxD == 1'b1, not a star bit
    begin
        rState <= IDLE;  //Not a start bit, reset state to IDLE
    end
            rClkCount <= 1'b0;  //reset clock count after if statements
    end
    else
    begin
    rClkCount <= rClkCount + 1;
    end
    end
    
    
    
   //a data bit is being captured
    RX_DATA_BIT:
    begin
    rClkCount = rClkCount + 1;
    if(rClkCount == CLKS_PER_BIT)   //take a sample
    begin 
    rRXByte[rBitIndex] <= RxD;  //update data 
    rClkCount <= 1'b0;
    if(rBitIndex < 7)  //increase index
    begin 
    rBitIndex = rBitIndex + 1;
    end
    
    else    //at the last bit, update the state machine to stop state
    begin
    rState <= RX_STOP_BIT;
    rBitIndex = 0;
    end
    end
    end
    
    
    
    
    RX_STOP_BIT:
    begin 
    rClkCount = rClkCount + 1;
        if(rClkCount == CLKS_PER_BIT)
        begin
        rState <= CLEANUP;
        rClkCount <= 0;
        rRXDV <= 1'b1;  //Data valid is turned on for 1 clock cycle
        end
    
    end
    
    CLEANUP:
    begin 
           rRXDV <= 1'b0;  //Data valid is turned on for 1 clock cycle, and then driven to 0
           rState <= IDLE;
    end
    
   
   default:
    rState <= IDLE;
   
    
    endcase //end of case statement
    end
    
    
    //assign statements
    assign RX_DV = rRXDV;
    assign byte = rRXByte;
    
    
endmodule
