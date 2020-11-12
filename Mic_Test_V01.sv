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

module Mic_Demo(
    output anout,
    output ampSD,
	output sclk,
	output ncs,
	input sdata,
    input clk,
    input bt1,
    input bt2,
    output ledwrite,
    output ledread
    );
    
    //PSRAM logic
    logic[22:0] MEM_ADDR_OUT;
    logic MEM_CEN;
    logic MEM_OEN;
    logic MEM_WEN;
    logic MEM_LBN;
    logic MEM_UBN;
    logic MEM_ADV;
    logic MEM_CRE;
    logic[15:0] MEM_DATA_I;
    logic[15:0] MEM_DATA_O;
    logic[15:0] MEM_DATA_T;
    
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
    
    //AXI4 Write Address Channel
    logic[C_S_AXI_ID_WIDTH-1:0] S_AXI_AWID = 1'b0; //ID doesn't matter in our application
    logic[C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR = 24'b000000000000000000000100; //Just initializing the address (Mem addr goes from 23:2)
    logic[7:0] S_AXI_AWLEN = 8'b00000000; //One burst at a time
    logic[2:0] S_AXI_AWSIZE = 3'b101; //32 Bit data bus
    logic[1:0] S_AXI_AWBURST = 2'b00; //Fixed burst, but we are only doing 1 burst at a time.
    logic S_AXI_AWLOCK = 1'b0; //Lock type, doesn't really matter
    logic[3:0] S_AXI_AWCACHE = 1'b0000; //Don't need any cache assitance
    logic[2:0] S_AXI_AWPROT = 3'b001; //Data, secure, priviledged access
    logic[3:0] S_AXI_AWQOS = 4'b0000; //Not using QOS scheme
    logic[3:0] S_AXI_AWREGION = 4'b0000; //Default is all 0
    logic[C_S_AXI_AWUSER_WIDTH-1:0] S_AXI_AWUSER; //Signal doesn't matter
    logic S_AXI_AWVALID = 1'b0; //Initially 0
    logic S_AXI_AWREADY;
    
    //AXI4 Write Data Channel
    logic[C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA = 32'b00000000000000000000000000000000; //Initializing data signal
    logic[(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB = 4'b0000; //Have strobe read high bytes of Data
    logic S_AXI_WLAST = 1'b1;
    logic[C_S_AXI_WUSER_WIDTH-1:0] S_AXI_WUSER; // Signal doesn't matter
    logic S_AXI_WVALID = 1'b0; //Write Valid
    logic S_AXI_WREADY; // Write ready
    
    //AXI4 Write Response Channel
    logic[C_S_AXI_ID_WIDTH-1:0] S_AXI_BID; //Response ID tag
    logic[1:0] S_AXI_BRESP; // Write Response
    logic[C_S_AXI_BUSER_WIDTH-1:0] S_AXI_BUSER; // Signal doesn't matter
    logic S_AXI_BVALID; //Write Response Valid
    logic S_AXI_BREADY = 1'b0; //Response ready
    
    //AXI4 Read Address Channel
    logic[C_S_AXI_ID_WIDTH-1:0] S_AXI_ARID = 1'b0;
    logic[C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR = 24'b000000000000000000000100;
    logic[7:0] S_AXI_ARLEN = 8'b00000000;
    logic[2:0] S_AXI_ARSIZE = 3'b101;
    logic[1:0] S_AXI_ARBURST = 2'b00;
    logic S_AXI_ARLOCK = 1'b0;
    logic[3:0] S_AXI_ARCACHE = 4'b0000;
    logic[2:0] S_AXI_ARPROT = 3'b001;
    logic[3:0] S_AXI_ARQOS = 4'b0000;
    logic[3:0] S_AXI_ARREGION = 4'b0000;
    logic[C_S_AXI_ARUSER_WIDTH-1:0] S_AXI_ARUSER;
    logic S_AXI_ARVALID = 1'b0;
    logic S_AXI_ARREADY;
    
    //AXI4 Read Data Channel
    logic[C_S_AXI_ID_WIDTH-1:0] S_AXI_RID;
    logic[C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA;
    logic[1:0] S_AXI_RRESP;
    logic S_AXI_RLAST;
    logic[C_S_AXI_RUSER_WIDTH-1:0] S_AXI_RUSER;
    logic S_AXI_RVALID;
    logic S_AXI_RREADY = 1'b0;
    
    //Buffers for read/write address and data
    logic[C_S_AXI_ADDR_WIDTH-1:0] Write_Add = 24'b000000000000000000000000;
    logic[C_S_AXI_DATA_WIDTH-1:0] Write_Data = 32'b00000000000000000000000000000000;
    logic[C_S_AXI_ADDR_WIDTH-1:0] Read_Add = 24'b000000000000000000000000;
    logic[C_S_AXI_DATA_WIDTH-1:0] Read_Data;
    
psram_ip_v1_1_S00_AXI u1(clk, S_AXI_ARESETN, S_AXI_AWID, S_AXI_AWADDR, S_AXI_AWLEN,
                         S_AXI_AWSIZE, S_AXI_AWBURST, S_AXI_AWLOCK, S_AXI_AWCACHE,
                         S_AXI_AWPROT, S_AXI_AWQOS, S_AXI_AWREGION, 
                         S_AXI_AWVALID, S_AXI_AWREADY, S_AXI_WDATA, S_AXI_WSTRB,
                         S_AXI_WLAST, S_AXI_WVALID, S_AXI_WREADY, 
                         S_AXI_BID, S_AXI_BRESP, S_AXI_BVALID, S_AXI_BREADY,
                         S_AXI_ARID, S_AXI_ARADDR, S_AXI_ARLEN, S_AXI_ARSIZE, S_AXI_ARBURST,
                         S_AXI_ARLOCK, S_AXI_ARCACHE, S_AXI_ARPROT, S_AXI_ARQOS, S_AXI_ARREGION,
                          S_AXI_ARVALID, S_AXI_ARREADY, S_AXI_RID, S_AXI_RDATA,
                         S_AXI_RRESP, S_AXI_RLAST, S_AXI_RVALID, S_AXI_RREADY,
                         MEM_ADDR_OUT, MEM_CEN, MEM_OEN, MEM_WEN, MEM_LBN, MEM_UBN,
                         MEM_ADV, MEM_CRE, MEM_DATA_I, MEM_DATA_O, MEM_DATA_T);

//State and Counter logic                
logic[26:0] counter = 27'b000000000000000000000000000;  //Counter to count to 100 Million (1 Second)  
logic [5:0] bitcounter = 6'b010000;  // Initialize to 16 
logic speakerswitch = 0;
logic bstate, rstate, wstate, ledr, ledw = 1'b0;

//Wrapper for Block Memory
//logic en;
logic wea = 1;
logic[17:0] addra = 0;
logic[15:0] dina = 0;
logic[15:0] douta = 0;
blk_mem_gen_0 bm(clk, wea, addra, dina, douta);

integer a_count = 3;
always @(posedge clk)
begin
    addra = MEM_ADDR_OUT[17:0] - (a_count - 1);
    if(wstate == 1)begin
        wea = 1;
        dina = MEM_DATA_O;
    end
    if(rstate == 1)begin
        wea = 0;
        MEM_DATA_I = douta;
    end   
end

//Button debounce for writing
wire pb_write;
debounce uut2 (
    .pb_1(bt2), 
    .clk(clk), 
    .pb_out(pb_write)
);
//Button debounce for reading
wire pb_read;
debounce uut (
    .pb_1(bt1), 
    .clk(clk), 
    .pb_out(pb_read)
);

assign ledwrite = ledw;
assign ledread = ledr;

//reg [4:0]clk_cntr_reg = 5'b00000;
integer clk_cntr_reg = 0;
reg pwm_val_reg;

always @(posedge clk)
begin
    clk_cntr_reg = clk_cntr_reg + 1;
    if(clk_cntr_reg > 32)begin
        clk_cntr_reg = 0;
    end
end
        
integer i = 16;
integer j = 0;
integer k = 16;
integer l = 0;


//Writing/Reading to memory
always @(posedge clk)
begin
if(wstate == 1)begin
        ledw = 1'b1;
        counter = counter + 1;
        if(counter >= 99999999)begin
            counter = 0;
            a_count = 3;
            wstate = 1'b0;
            Write_Add = 24'b000000000000000000000100;
            ledw <= 1'b0;
        end
    end
    if(rstate == 1)begin
        ledr = 1'b1;
        counter = counter + 1;
        if(counter >= 99999999)begin
            counter = 0;
            a_count = 3;
            rstate = 1'b0;
            speakerswitch = 0;
            Read_Add = 24'b000000000000000000000100;
            ledr <= 1'b0;
        end
    end
    if(bt1 == 1)begin
        rstate <= 1'b1;
        //S_AXI_ARVALID = 1; //Try to start the reading process
        speakerswitch = 1;
    end
    if(bt2 == 1)begin
        wstate <= 1'b1;
    end
    ////////////////WRITING
    j = j + 1;
    if(clk_cntr_reg == 32 & S_AXI_AWVALID == 0 & wstate == 1)begin
        Write_Data[i] = sdata;
        i = i+1;
        //S_AXI_AWVALID = 0; //Don't write to address yet
        //S_AXI_WVALID = 0; //Don't write data yet
    end
    if(i == 32 & wstate == 1) begin
        j = 0;
        i = 16;
        a_count = a_count + 1;
        Write_Add = Write_Add + 4; //Increment address
        S_AXI_AWADDR = Write_Add;
        S_AXI_AWVALID = 1; //Address is valid and ready to be sent
    end
    /////////////////////
    if(j >= 2 & S_AXI_AWVALID == 1 & S_AXI_AWREADY == 1 & wstate == 1) begin //Give AWVALID enough time to assert, then switch to write data
        S_AXI_AWVALID = 0;
        S_AXI_WVALID = 1; //Data is valid
        j = 0;
    end
    if(j >= 2 & S_AXI_WVALID == 1 & S_AXI_WREADY == 1 & wstate == 1) begin //Give WVALID enough time to assert, then stop writing
        S_AXI_WVALID = 0;
        j = 0;
    end
    if(S_AXI_WVALID == 1)begin
        S_AXI_WDATA = Write_Data;
    end
    if(S_AXI_WVALID == 0)begin
        S_AXI_WDATA = 0;
    end
    ///////////////////READING
    l = l + 1;
    if(bt1 == 1)begin
        S_AXI_ARVALID = 1; //Try to start the reading process
    end
    if(clk_cntr_reg == 32 & S_AXI_ARVALID == 0 & rstate == 1) begin
        pwm_val_reg = Read_Data[k];
        k = k + 1;
        //S_AXI_ARVALID = 0; //Read address
        //S_AXI_RREADY = 0; //Don't read yet
    end
    if(k == 32 & rstate == 1) begin
        l = 0;
        k = 16;
        a_count = a_count + 1;
        Read_Add = Read_Add + 4; //Increment address
        S_AXI_ARADDR = Read_Add;
        S_AXI_ARVALID = 1; //Address is valid and ready to be sent
    end
    //////////////////
     //l = l + 1;
    if(l >= 2 & S_AXI_ARVALID == 1 & S_AXI_ARREADY == 1 & rstate == 1) begin //Give ARVALID enough time to assert, then switch to reading data
        S_AXI_ARVALID = 0;
        S_AXI_RREADY = 1; //Ready to get read data
        l = 0;
    end
    if(l >= 2 & S_AXI_RREADY == 1 & S_AXI_RVALID == 1 & rstate == 1) begin //Give RREADY enough time to assert, then stop reading
        S_AXI_RREADY = 0;
        l = 0;
    end
    if(S_AXI_RREADY == 1)begin
        Read_Data = S_AXI_RDATA; //Lock in Read data to buffer
    end
end

assign sclk = clk_cntr_reg[4];
assign anout = pwm_val_reg;
assign ncs = 1'b0; 
assign ampSD = speakerswitch;

endmodule
