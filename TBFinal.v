module TBFinal();
    parameter C_S_AXI_ID_WIDTH = 1;
    parameter C_S_AXI_DATA_WIDTH = 32;
    parameter C_S_AXI_ADDR_WIDTH = 24;
    parameter C_S_AXI_AWUSER_WIDTH = 0;
    parameter C_S_AXI_ARUSER_WIDTH = 0;
    parameter C_S_AXI_WUSER_WIDTH = 0;
    parameter C_S_AXI_RUSER_WIDTH = 0;
    parameter C_S_AXI_BUSER_WIDTH = 0;
    
    logic anout = 0;
    logic ampSD = 0;
	logic sclk = 0;
	logic ncs = 0;
	logic sdata = 0;
    logic clk = 0;
    logic bt1 = 0;
    logic bt2 = 0;
    logic ledwrite = 0;
    logic ledread = 0;
    
    /*
    logic[12:0] ddr2_addr;
    logic[2:0] ddr2_ba;
    logic ddr2_ras_n;
    logic ddr2_cas_n;
    logic ddr2_we_n;
    logic[0:0] ddr2_ck_p;
    logic[0:0] ddr2_ck_n;
    logic[0:0] ddr2_cke;
    logic[0:0] ddr2_cs_n;
    logic[1:0] ddr2_dm;
    logic[0:0] ddr2_odt;
    wire[15:0] ddr2_dq;
    wire[1:0] ddr2_dqs_p;
    wire[1:0] ddr2_dqs_n;
    */
    
    always 
        #1 clk <= !clk;
        
    Mic_Demo u2(anout, ampSD, sclk, ncs, sdata, clk, bt1, bt2, ledwrite, ledread);
    /*
                ddr2_addr, ddr2_ba, ddr2_ras_n, ddr2_cas_n, ddr2_we_n, ddr2_ck_p,
                ddr2_ck_n, ddr2_cke, ddr2_cs_n, ddr2_dm, ddr2_odt, ddr2_dq, ddr2_dqs_p, ddr2_dqs_n);
    */
    logic[C_S_AXI_ADDR_WIDTH-1:0] Write_Add;
    logic[C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR;
    logic[C_S_AXI_DATA_WIDTH-1:0] Write_Data;
    logic[C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA;
    logic[C_S_AXI_ADDR_WIDTH-1:0] Read_Add;
    logic[C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR;
    logic[C_S_AXI_DATA_WIDTH-1:0] Read_Data;
    
    logic S_AXI_AWVALID; //Initially 0
    logic S_AXI_AWREADY;
    logic S_AXI_WVALID; //Write Valid
    logic S_AXI_WREADY;
    logic S_AXI_ARVALID;
    logic S_AXI_ARREADY;
    logic S_AXI_RVALID;
    logic S_AXI_RREADY;
    
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
    
    //logic en;
    logic wea;
    logic[17:0] addra;
    logic[15:0] dina;
    logic[15:0] douta;
    
    
    assign Write_Add = u2.Write_Add;
    assign S_AXI_AWADDR = u2.S_AXI_AWADDR;
    assign Write_Data = u2.Write_Data;
    assign S_AXI_WDATA = u2.S_AXI_WDATA;
    assign Read_Add = u2.Read_Add;
    assign S_AXI_ARADDR = u2.S_AXI_ARADDR;
    assign Read_Data = u2.Read_Data;
    
    
    assign S_AXI_AWVALID = u2.S_AXI_AWVALID;
    assign S_AXI_AWREADY = u2.S_AXI_AWREADY;
    assign S_AXI_WVALID = u2.S_AXI_WVALID;
    assign S_AXI_WREADY = u2.S_AXI_WREADY;
    assign S_AXI_ARVALID = u2.S_AXI_ARVALID;
    assign S_AXI_ARREADY = u2.S_AXI_ARREADY;
    assign S_AXI_RVALID = u2.S_AXI_RVALID;
    assign S_AXI_RREADY = u2.S_AXI_RREADY;
    
    assign MEM_ADDR_OUT = u2.MEM_ADDR_OUT;
    assign MEM_CEN = u2.MEM_CEN;
    assign MEM_OEN = u2.MEM_OEN;
    assign MEM_WEN = u2.MEM_WEN;
    assign MEM_LBN = u2.MEM_LBN;
    assign MEM_UBN = u2.MEM_UBN;
    assign MEM_ADV = u2.MEM_ADV;
    assign MEM_CRE = u2.MEM_CRE;
    assign MEM_DATA_I = u2.MEM_DATA_I;
    assign MEM_DATA_O = u2.MEM_DATA_O;
    assign MEM_DATA_T = u2.MEM_DATA_T;
   
    //assign en = u2.en;
    assign wea = u2.wea;
    assign addra = u2.addra;
    assign dina = u2.dina;
    assign douta = u2.douta;
    
   initial begin
        clk = 0;
        #100
        //sdata = 1;
        bt1 = 1;
        #5
        bt1 = 0;
        #5000
        $finish;
   end
endmodule
