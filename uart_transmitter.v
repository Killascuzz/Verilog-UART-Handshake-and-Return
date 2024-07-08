`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2024 02:43:37 PM
// Design Name: 
// Module Name: uart_transmitter
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


module uart_transmitter
#(parameter CLKS_PER_BIT = 10416) //10416 clock cycles per bit of UART data stream
(
    input clk,
    input TX_DV,    //data valid to send
    input [7:0] TXByte,
    output TX_Active,
    output reg TxD,
    output TXOver
    
    );
    
    //state machine states
    parameter IDLE = 3'b000;
    parameter TX_START_BIT = 3'b001;
    parameter TX_DATA_BIT = 3'b010;
    parameter TX_STOP_BIT = 3'b011;
    parameter CLEANUP = 3'b100;
    
    //registers
      reg [13:0] rClkCount; //counts the ammount of clock cycles passed since last UART tick
    reg [2:0] rBitIndex;
    reg [7:0] rTXByte;
    reg rTXActive;
    reg rTXOver;
    reg [2:0] rState;   //current state of the state machine
    
    
    
    
    
     always @(posedge clk)
       begin
 
    case (rState)
        //the state machine has not detected a start bit yet
        IDLE:
        begin
        rClkCount <= 0;
        TxD <= 1'b1;    //the start bit has not been sent, keep TxD at 1
        
        if(TX_DV == 1'b1) //if data is ready to send
        begin
        rTXActive <= 1'b1;
        rTXByte <= TXByte;  //the input byte is updated in the register, so that data is not overlapped durring transmission
        rState <= TX_START_BIT; //move to start bit state
        end
        end
        
        //send start bit (0)
       TX_START_BIT:
       begin
       TxD <= 0;
       rClkCount = rClkCount + 1;
       //wait
       if(rClkCount == (CLKS_PER_BIT - 1))
       begin
       rClkCount <= 0;  //resetting clk counter
       rState <= TX_DATA_BIT;
       end
       end
       
       TX_DATA_BIT:
       begin
       TxD <= rTXByte[rBitIndex];   //drive the output to the current bit of data
       rClkCount = rClkCount + 1;
        
        //check if time for next bit
        if(rClkCount == (CLKS_PER_BIT - 1))
       begin
       rClkCount = 0;
       
       if(rBitIndex < 7)
       begin
       rBitIndex <= rBitIndex + 1;  //increasing the index
       end
       //all the data has been sent
       else
       begin
       rBitIndex = 0;
       rState <= TX_STOP_BIT;
       end
       end
       end
       
       
   TX_STOP_BIT:
   begin
   rClkCount = rClkCount + 1;
   TxD <= 1'b1;
   if(rClkCount == (CLKS_PER_BIT - 1))
   begin
   rClkCount <= 0;
   rState <= CLEANUP;
   rTXActive <= 1'b0;
   end
   end    
   
   //wait, set rTXOver to true
   CLEANUP:
   begin
   rTXOver <= 1'b1;
   rState <= IDLE;
   end    
       
   default: 
   rState <= IDLE;    

       endcase
        end
    
    assign TX_Active = rTXActive;
    assign TXOver = rTXOver;
    
    
    
    
    
    
    
    
    
    
endmodule
