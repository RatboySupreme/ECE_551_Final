`timescale 1ns / 1ps

module debounce(input pb_1,clk,output pb_out);
wire slow_clk_en;
wire Q1,Q2,Q2_bar,Q0;
clock_enable u1(clk,slow_clk_en);
my_dff_en d0(clk,slow_clk_en,pb_1,Q0);

my_dff_en d1(clk,slow_clk_en,Q0,Q1);
my_dff_en d2(clk,slow_clk_en,Q1,Q2);
assign Q2_bar = ~Q2;
assign pb_out = Q1 & Q2_bar;
endmodule
// Slow clock enable for debouncing button 
module clock_enable(input Clk_100M,output slow_clk_en);
    reg [26:0]counter=0;
    always @(posedge Clk_100M)
    begin
       counter <= (counter>=249999)?0:counter+1;
    end
    assign slow_clk_en = (counter == 249999)?1'b1:1'b0;
endmodule
// D-flip-flop with clock enable signal for debouncing module 
module my_dff_en(input DFF_CLOCK, clock_enable,D, output reg Q=0);
    always @ (posedge DFF_CLOCK) begin
  if(clock_enable==1) 
           Q <= D;
    end
endmodule

module Mic_Demo_V01(
    output anout,
    output ampSD,
	output sclk,
	output ncs,
	input sdata,
    input clk,
    input bt1,
    input bt2,
    output ledwrite,
    output ledread,
    
    //Pass physical PSRAM signals up and out
    output[22:0] MEM_ADDR_OUT,
    output MEM_CEN,
    output MEM_OEN,
    output MEM_WEN,
    output MEM_LBN,
    output MEM_UBN,
    output MEM_ADV,
    output MEM_CRE,
    input[15:0] MEM_DATA_I,
    output[15:0] MEM_DATA_O,
    output[15:0] MEM_DATA_T
    );
    
    //AXI4 Full Bus Parameters
    parameter C_S_AXI_ID_WIDTH = 1;
    parameter C_S_AXI_DATA_WIDTH = 32;
    parameter C_S_AXI_ADDR_WIDTH = 24;
    parameter C_S_AXI_AWUSER_WIDTH = 0;
    parameter C_S_AXI_ARUSER_WIDTH = 0;
    parameter C_S_AXI_WUSER_WIDTH = 0;
    parameter C_S_AXI_RUSER_WIDTH = 0;
    parameter C_S_AXI_BUSER_WIDTH = 0;
    
    //AXI4 Full Bus Signals
    //logic S_AXI_ACLK;
    logic S_AXI_ARESETN = 1'b1; //Initializing reset to high
    logic[C_S_AXI_ID_WIDTH-1:0] S_AXI_AWID = 1'b0; //ID doesn't matter in our application
    logic[C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR = 16'b0000000000000000; //Just initializing the address
    logic[7:0] S_AXI_AWLEN = 8'b00000000; //One burst at a time
    logic[2:0] S_AXI_AWSIZE = 3'b101; //32 Bit data bus
    logic[1:0] S_AXI_AWBURST = 2'b01; //Incremental burst, but we are only doing 1 burst at a time.
    logic S_AXI_AWLOCK = 1'b0; //Lock type, doesn't really matter
    logic[3:0] S_AXI_AWCACHE = 1'b0000; //Don't need any cache assitance
    logic[2:0] S_AXI_AWPROT = 3'b001; //Data, secure, priviledged access
    logic[3:0] S_AXI_AWQOS = 4'b0000; //Not using QOS scheme
    logic[3:0] S_AXI_AWREGION = 4'b0000; //Default is all 0
    logic[C_S_AXI_AWUSER_WIDTH-1:0] S_AXI_AWUSER; //Signal doesn't matter
    logic S_AXI_AWVALID = 1'b0; //Initially 0
    logic S_AXI_AWREADY;
    logic[C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA = 32'b00000000000000000000000000000000;
    logic[(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB = 4'b1111;
    logic S_AXI_WLAST = 1'b0;
    logic[C_S_AXI_WUSER_WIDTH-1:0] S_AXI_WUSER; // Signal doesn't matter
    logic S_AXI_WVALID = 1'b0; //Write Valid
    logic S_AXI_WREADY; // Write ready
    logic[C_S_AXI_ID_WIDTH-1:0] S_AXI_BID; //Response ID tag
    logic[1:0] S_AXI_BRESP; // Write Response
    logic[C_S_AXI_BUSER_WIDTH-1:0] S_AXI_BUSER; // Signal doesn't matter
    logic S_AXI_BVALID; //Write Response Valid
    logic S_AXI_BREADY = 1'b0; //Response ready
    logic[C_S_AXI_ID_WIDTH-1:0] S_AXI_ARID = 1'b0;
    logic[C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR = 16'b0000000000000000;
    logic[7:0] S_AXI_ARLEN = 8'b00000000;
    logic[2:0] S_AXI_ARSIZE = 3'b101;
    logic[1:0] S_AXI_ARBURST = 2'b01;
    logic S_AXI_ARLOCK = 1'b0;
    logic[3:0] S_AXI_ARCACHE = 4'b0000;
    logic[2:0] S_AXI_ARPROT = 3'b001;
    logic[3:0] S_AXI_ARQOS = 4'b0000;
    logic[3:0] S_AXI_ARREGION = 4'b0000;
    logic[C_S_AXI_ARUSER_WIDTH-1:0] S_AXI_ARUSER;
    logic S_AXI_ARVALID = 1'b0;
    logic S_AXI_ARREADY;
    logic[C_S_AXI_ID_WIDTH-1:0] S_AXI_RID;
    logic[C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA;
    logic[1:0] S_AXI_RRESP;
    logic S_AXI_RLAST;
    logic[C_S_AXI_RUSER_WIDTH-1:0] S_AXI_RUSER;
    logic S_AXI_RVALID;
    logic S_AXI_RREADY = 1'b0;
    
psram_ip_v1_1_S00_AXI u1(clk, S_AXI_ARESETN, S_AXI_AWID, S_AXI_AWADDR, S_AXI_AWLEN,
                         S_AXI_AWSIZE, S_AXI_AWBURST, S_AXI_AWLOCK, S_AXI_AWCACHE,
                         S_AXI_AWPROT, S_AXI_AWQOS, S_AXI_AWREGION, S_AXI_AWUSER,
                         S_AXI_AWVALID, S_AXI_AWREADY, S_AXI_WDATA, S_AXI_WSTRB,
                         S_AXI_WLAST, S_AXI_WUSER, S_AXI_WVALID, S_AXI_WREADY, 
                         S_AXI_BID, S_AXI_BRESP, S_AXI_BUSER, S_AXI_BVALID, S_AXI_BREADY,
                         S_AXI_ARID, S_AXI_ARADDR, S_AXI_ARLEN, S_AXI_ARSIZE, S_AXI_ARBURST,
                         S_AXI_ARLOCK, S_AXI_ARCACHE, S_AXI_ARPROT, S_AXI_ARQOS, S_AXI_ARREGION,
                         S_AXI_ARUSER, S_AXI_ARVALID, S_AXI_ARREADY, S_AXI_RID, S_AXI_RDATA,
                         S_AXI_RRESP, S_AXI_RLAST, S_AXI_RUSER, S_AXI_RVALID, S_AXI_RREADY,
                         MEM_ADDR_OUT, MEM_CEN, MEM_OEN, MEM_WEN, MEM_LBN, MEM_UBN,
                         MEM_ADV, MEM_CRE, MEM_DATA_I, MEM_DATA_O, MEM_DATA_T);
                         
logic[26:0] counter = 27'b000000000000000000000000000;  //Counter to count to 100 Million (1 Second)     
logic rstate, wstate, ledr, ledw = 1'b0;

//Button debounce for reading
wire pb_read;
debounce uut (
    .pb_1(bt1), 
    .clk(clk), 
    .pb_out(pb_read)
);
always @(posedge pb_read)begin
    rstate <= 1'b1;
end

always @(posedge clk)begin
    if(rstate == 1)begin
        ledr = 1'b1;
        counter = counter + 1;
        if(counter >= 99999999)begin
            counter = 0;
            rstate = 1'b0;
            ledr <= 1'b0;
        end
    end
end  
assign ledread = ledr;

//Button debounce for writing
wire pb_write;
debounce uut2 (
    .pb_1(bt2), 
    .clk(clk), 
    .pb_out(pb_write)
);
always @(posedge pb_write)begin

end
assign ledwrite = ledw;

reg [4:0]clk_cntr_reg;
reg pwm_val_reg;

always @(posedge clk)
begin
    clk_cntr_reg <= clk_cntr_reg + 1;
end

//always @(posedge clk)
//begin
//    if(S_AXI_AWREADY == 1'b1 & S_AXI_AWVALID == 1'b1)begin
//       S_AXI_AWADDR = S_AXI_AWADDR + 1;
        
    
always @(posedge clk)
begin
    if(clk_cntr_reg == 5'b01111 & rstate == 1) begin
        pwm_val_reg <= sdata;
    end
end

//sclk = 100MHz / 32 = 3.125 MHz
assign sclk = clk_cntr_reg[4];

assign anout = pwm_val_reg;
assign ncs = 1'b0; 
assign ampSD = 1'b1;


endmodule
