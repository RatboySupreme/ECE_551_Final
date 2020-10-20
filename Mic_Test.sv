`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2020 09:49:09 AM
// Design Name: 
// Module Name: Mic_Test
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


`timescale 1ns / 1ps

module Mic_Demo(
    output anout,
    output ampSD,
	output sclk,
	output ncs,
	input sdata,
    input clk
    );

reg [4:0]clk_cntr_reg;
reg pwm_val_reg;

always @(posedge clk)
begin
    clk_cntr_reg <= clk_cntr_reg + 1;
end

always @(posedge clk)
begin
    if(clk_cntr_reg == 5'b01111) begin
        pwm_val_reg <= sdata;
    end
end

//sclk = 100MHz / 32 = 3.125 MHz
assign sclk = clk_cntr_reg[4];

assign anout = pwm_val_reg;
assign ncs = 1'b0;      //mic LRSel
assign ampSD = 1'b1;


endmodule
