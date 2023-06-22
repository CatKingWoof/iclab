//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Final Project: Customized ISA Processor
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2023-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################


module CPU(

           clk,
           rst_n,

           IO_stall,

           awid_m_inf,
           awaddr_m_inf,
           awsize_m_inf,
           awburst_m_inf,
           awlen_m_inf,
           awvalid_m_inf,
           awready_m_inf,

           wdata_m_inf,
           wlast_m_inf,
           wvalid_m_inf,
           wready_m_inf,

           bid_m_inf,
           bresp_m_inf,
           bvalid_m_inf,
           bready_m_inf,

           arid_m_inf,
           araddr_m_inf,
           arlen_m_inf,
           arsize_m_inf,
           arburst_m_inf,
           arvalid_m_inf,

           arready_m_inf,
           rid_m_inf,
           rdata_m_inf,
           rresp_m_inf,
           rlast_m_inf,
           rvalid_m_inf,
           rready_m_inf

       );
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  wire [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  wire [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  wire [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// -----------------------------
// axi read data channel
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------

//
//
//
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;


//###########################################
//
// Wrtie down your design below
//
//###########################################

reg [5:0] current_state,next_state;
reg [11:0] DRAM_inst_addr,DRAM_data_addr,DRAM_write_addr;
//wire[15:0] IM_out,IM_in;
wire[15:0] DM_out;
reg [15:0] DM_in;
wire[15:0] M_out;
reg [15:0] M_in;
//wire [6:0]IM_addr;
//wire [6:0]DM_addr;
reg [7:0]M_addr;
//wire IM_wen,DM_wen;
reg M_wen;
reg [6:0]IM_addr_readDRAM;
reg [6:0]DM_addr_readDRAM;
reg [15:0] I_stage2,I_stage3,I_stage4;
wire [15:0] I_stage1;
reg signed [15:0] data1,data2,ALU_result,WB_data,store_result;
wire [2:0] opcode;
wire [3:0] rs;
wire [3:0] rt;
wire [3:0] rd;
wire func;
wire signed [4:0] imm;
wire [12:0] addr;
wire signed[12:0]require_inst;
wire signed[12:0] IM_max,DM_max;
reg signed [12:0] IM_min,DM_min;
reg data_miss,inst_miss,data_dep,store_task,branch_task;
reg signed[12:0] pc;
wire signed [12:0] DM_process,IM_process;
wire [11:0] first_load;
reg first_execute;
reg signed [15:0]rs_data,rt_data;
reg stage1_stall;
reg [15:0]inst;
//reg rsp_flag;
parameter signed OFFSET=16'h1000;
parameter  width= 16,
           tc=1'b1;
wire signed [31:0]mult_out;
parameter IDLE=0,
          IF=1,
          RF=2,
          ALU=3,
          DF=4,
          WB=5,
          R_DRAM_D_addr=6,
          R_DRAM_D_data=7,
          R_DRAM_I_addr=8,
          R_DRAM_I_data=9,
          W_DRAM_addr=10,
          W_DRAM_data=11,
          W_DRAM_resp=12,
          MULT=13,
          BRANCH=14;


always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        current_state<=IDLE;
    end
    else
    begin
        current_state<=next_state;
    end
end
always @(*) begin
    case (current_state)
        IDLE:
            next_state=R_DRAM_I_addr;
        IF:begin
            if(inst_miss)
                next_state=R_DRAM_I_addr;
            else
                next_state=RF;
        end
        RF:begin
            next_state=ALU;
        end
        ALU:begin
            if(opcode==3'b100 || opcode==3'b101)
                next_state=BRANCH;
            else if(opcode==3'b000|| (opcode==3'b001&&func==1))
                next_state=WB;
            else if(opcode==3'b001&&func==0)
                next_state=MULT;
            else
                next_state=DF;
        end
        MULT:begin
            next_state=WB;
        end
        BRANCH:begin
            next_state=IF;
        end
        DF:begin
            if(data_miss|| !first_execute)
                next_state=R_DRAM_D_addr;
            else if(opcode==3'b010)
                next_state=W_DRAM_addr;
            else
                next_state=WB;
        end
        WB:begin
            next_state=IF;
        end
        R_DRAM_I_addr:begin
            if(arready_m_inf[1])
                next_state=R_DRAM_I_data;
            else
                next_state=R_DRAM_I_addr;
        end
        R_DRAM_I_data:begin
            if(rlast_m_inf[1])
                next_state=BRANCH;
            else
                next_state=R_DRAM_I_data;
        end
        R_DRAM_D_addr:begin
            if(arready_m_inf[0])
                next_state=R_DRAM_D_data;
            else
                next_state=R_DRAM_D_addr;
        end
        R_DRAM_D_data:begin
            if(rlast_m_inf[0])
                next_state=DF;
            else
                next_state=R_DRAM_D_data;
        end
        W_DRAM_addr:begin
            if(awready_m_inf[0])
                next_state=W_DRAM_data;
            else
                next_state=W_DRAM_addr;
        end
        W_DRAM_data:begin
            if(wready_m_inf[0])
                next_state=W_DRAM_resp;
            else
                next_state=W_DRAM_data;
        end
        W_DRAM_resp:begin
            if(bvalid_m_inf[0])
                next_state=IF;
            else
                next_state=W_DRAM_resp;
        end

        default: next_state=IDLE;
    endcase
end
//DRAM_inst read
assign arid_m_inf[7:4]=4'b0;
assign arlen_m_inf[13:7]=127;
assign arsize_m_inf[5:3]=3'b001;
assign arburst_m_inf[3:2]=2'b01;
//assign DRAM_inst_addr=require_inst<<2;
assign araddr_m_inf[63:32] =  (current_state==R_DRAM_I_addr)?{1'b1,DRAM_inst_addr} :0 ;
assign arvalid_m_inf[1]= (current_state==R_DRAM_I_addr) ? 1 :0;
assign rready_m_inf[1] = (current_state==R_DRAM_I_data) ? 1 : 0;
//DRAM_data read
assign arid_m_inf[3:0]=4'b0;
assign arlen_m_inf[6:0]=127;
assign arsize_m_inf[2:0]=3'b001;
assign arburst_m_inf[1:0]=2'b01;
assign araddr_m_inf[31:0] = (current_state==R_DRAM_D_addr ) ?{1'b1,DRAM_data_addr} :0;
assign arvalid_m_inf[0]= (current_state==R_DRAM_D_addr ) ? 1 : 0;
assign rready_m_inf[0] = (current_state==R_DRAM_D_data) ? 1 : 0;
//DRAM_data write
assign awid_m_inf=4'b0;
assign awlen_m_inf =0;
assign awsize_m_inf= 3'b001;
assign awburst_m_inf=2'b01;

assign awaddr_m_inf=(current_state==W_DRAM_addr) ? {1'b1,DRAM_data_addr} : 0;
assign awvalid_m_inf=(current_state==W_DRAM_addr) ? 1 : 0;
assign wdata_m_inf = store_result;
assign wlast_m_inf = (current_state==W_DRAM_data) ? 1 :0;
assign wvalid_m_inf = (current_state==W_DRAM_data) ? 1 : 0;
assign bready_m_inf = (current_state==W_DRAM_resp) ? 1 : 0;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        DRAM_inst_addr<=0;
    else if(current_state==IF)
    begin
        if(pc*2<64)
            DRAM_inst_addr<=0;
        else if(pc*2>'hf00)
            DRAM_inst_addr<='hf00;
        else
            DRAM_inst_addr<=pc*2-64;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        DRAM_data_addr<=0;
    else if(current_state==DF)
    begin
        if(opcode==3'b010)
            DRAM_data_addr<=ALU_result*2;
        else if(opcode==3'b011)begin
            if(ALU_result*2<64)
                DRAM_data_addr<=0;
            else if(ALU_result*2>'hf00)
                DRAM_data_addr<='hf00;
            else
                DRAM_data_addr<=ALU_result*2-64;
        end
    end
end
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        IM_min<='h0;
    end
    else
    begin
        if(current_state==R_DRAM_I_addr)
            IM_min<=DRAM_inst_addr/2;

    end
end
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        DM_min<='h0;
    end
    else
    begin
        if(current_state==R_DRAM_D_addr )
            DM_min<=DRAM_data_addr/2;
    end
end

/*
//inst sram
assign IM_addr= (current_state==R_DRAM_I_data) ? IM_addr_readDRAM : IM_process;
assign IM_wen =  (current_state==R_DRAM_I_data) ? 0 : 1;
assign IM_in = {rdata_m_inf[31:24],rdata_m_inf[23:16]};
//data sram
assign DM_addr= (current_state==R_DRAM_D_data) ? DM_addr_readDRAM : DM_process;
assign DM_wen = (current_state==R_DRAM_D_data || (current_state==DF&&opcode==3'b010&&!(ALU_result<DM_min || ALU_result>=DM_max)) ) ? 0 : 1;
assign DM_in = (current_state==R_DRAM_D_data) ? {rdata_m_inf[15:8],rdata_m_inf[7:0]} : store_result ;*/

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        IM_addr_readDRAM<=0;
    else if ( (current_state==R_DRAM_I_data&&rvalid_m_inf[1]) ) begin
        IM_addr_readDRAM<=IM_addr_readDRAM+1;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        DM_addr_readDRAM<=0;
    else if ((current_state==R_DRAM_D_data&&rvalid_m_inf[0]) ) begin
        DM_addr_readDRAM<=DM_addr_readDRAM+1;
    end
end

always @(*) begin
    if(current_state==R_DRAM_I_data)
        M_addr=IM_addr_readDRAM+128;
    else if(current_state==R_DRAM_D_data)
        M_addr=DM_addr_readDRAM;
    else if(current_state==DF)
        M_addr=DM_process;
    else
        M_addr=IM_process+128;

end
always @(*) begin
    if(current_state==R_DRAM_I_data || current_state==R_DRAM_D_data || (current_state==DF&&opcode==3'b010&&!(ALU_result<DM_min || ALU_result>=DM_max)))
        M_wen=0;
    else
        M_wen=1;
end
always @(*) begin
    if(current_state==R_DRAM_I_data)
        M_in={rdata_m_inf[31:24],rdata_m_inf[23:16]};
    else if(current_state==R_DRAM_D_data)
        M_in={rdata_m_inf[15:8],rdata_m_inf[7:0]};
    else if(current_state==DF)
        M_in=store_result;
    else
        M_in=0;

end
/*W128B16 mem1 (.Q(IM_out), .CLK(clk), .CEN(1'b0), .WEN(IM_wen), .A(IM_addr), .D(IM_in), .OEN(1'b0) );
W128B16 mem2 (.Q(DM_out), .CLK(clk), .CEN(1'b0), .WEN(DM_wen), .A(DM_addr), .D(DM_in), .OEN(1'b0) );*/
W256B16 big_mem (.Q(M_out), .CLK(clk), .CEN(1'b0), .WEN(M_wen), .A(M_addr), .D(M_in), .OEN(1'b0) );
//IM miss
//assign IM_min=DRAM_inst_addr;
assign IM_process=pc-IM_min;
assign IM_max=IM_min+128;
always @(*) begin
    if((pc<IM_min || pc>=IM_max) )
        inst_miss=1;
    else
        inst_miss=0;
end
//DM miss
assign DM_process= ALU_result-DM_min;
assign DM_max=DM_min+128;
always @(*) begin
    if((opcode==3'b011) && (ALU_result<DM_min || ALU_result>=DM_max))
        data_miss=1;
    else
        data_miss=0;
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        first_execute<=0;
    else if(rlast_m_inf[0])
        first_execute<=1;
end

//processor
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        inst<=0;
    else if(current_state==IF)
        inst<=M_out;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rs_data<=0;
    else if(current_state==RF)
    begin
        case (rs)
            0: rs_data<=core_r0;
            1: rs_data<=core_r1;
            2: rs_data<=core_r2;
            3: rs_data<=core_r3;
            4: rs_data<=core_r4;
            5: rs_data<=core_r5;
            6: rs_data<=core_r6;
            7: rs_data<=core_r7;
            8: rs_data<=core_r8;
            9: rs_data<=core_r9;
            10: rs_data<=core_r10;
            11: rs_data<=core_r11;
            12: rs_data<=core_r12;
            13: rs_data<=core_r13;
            14: rs_data<=core_r14;
            15: rs_data<=core_r15;
        endcase
    end

end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rt_data<=0;
    else if(current_state==RF)
    begin
        case (rt)
            0: rt_data<=core_r0;
            1: rt_data<=core_r1;
            2: rt_data<=core_r2;
            3: rt_data<=core_r3;
            4: rt_data<=core_r4;
            5: rt_data<=core_r5;
            6: rt_data<=core_r6;
            7: rt_data<=core_r7;
            8: rt_data<=core_r8;
            9: rt_data<=core_r9;
            10: rt_data<=core_r10;
            11: rt_data<=core_r11;
            12: rt_data<=core_r12;
            13: rt_data<=core_r13;
            14: rt_data<=core_r14;
            15: rt_data<=core_r15;
        endcase
    end
end
/*always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rs_data<=0;
    else if(current_state==RF)
        rs_data<=data1;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rt_data<=0;
    else if(current_state==RF)
        rt_data<=data2;
end*/
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ALU_result<=0;
    else if(current_state==ALU)
    begin
        if(opcode==3'b000)
        begin
            if(func==1)
                ALU_result<=rs_data+rt_data;
            else
                ALU_result<=rs_data-rt_data;
        end
        else if(opcode==3'b001)
        begin
            if(func==1)
            begin
                if(rs_data<rt_data)
                    ALU_result<=1;
                else
                    ALU_result<=0;
            end
        end
        else if(opcode==3'b011 || opcode==3'b010)
            ALU_result<=rs_data+imm;
    end
end
//mult

DW02_mult_2_stage #(width,width) M1 (.A(rs_data),.B(rt_data),.TC(tc),.CLK(clk),.PRODUCT(mult_out));


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        store_result<=0;
    else
        store_result<=rt_data;
end
/*always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        WB_data<=0;
    else
        WB_data<=ALU_result;
end*/
reg [11:0] old_pc;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        pc<='h0;
    else begin
        if(current_state==ALU )
        begin
            if (opcode==3'b100) begin
                pc<=(addr-OFFSET)/2;
            end
            else if(opcode==3'b101)begin
                if(rs_data==rt_data)
                    pc<=pc+1+imm;
                else
                    pc<=pc+1;
            end
            else
                pc<=pc+1;
        end
        /*else if(current_state==WB ||bvalid_m_inf)
            pc<=pc+1;*/
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        IO_stall<=1;
    else if(current_state==ALU && (opcode==3'b100 || opcode==3'b101))
        IO_stall<=0;
    else if(bvalid_m_inf)
        IO_stall<=0;
    else if(current_state==WB)
        IO_stall<=0;
    else
        IO_stall<=1;
end
/*always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rsp_flag<=0;
    else if(current_state==W_DRAM_resp)
        rsp_flag<=1;
    else
        rsp_flag<=0;
end*/
//register file
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r0<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==0 )
            core_r0<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==0)
            core_r0<=mult_out[15:0];
        else if(opcode==3'b011 && rt==0 )
            core_r0<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r1<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==1 )
            core_r1<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==1)
            core_r1<=mult_out[15:0];
        else if(opcode==3'b011 && rt==1 )
            core_r1<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r2<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==2 )
            core_r2<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==2)
            core_r2<=mult_out[15:0];
        else if(opcode==3'b011 && rt==2 )
            core_r2<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r3<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==3 )
            core_r3<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==3)
            core_r3<=mult_out[15:0];
        else if(opcode==3'b011 && rt==3 )
            core_r3<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r4<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==4 )
            core_r4<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==4)
            core_r4<=mult_out[15:0];
        else if(opcode==3'b011 && rt==4 )
            core_r4<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r5<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==5 )
            core_r5<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==5)
            core_r5<=mult_out[15:0];
        else if(opcode==3'b011 && rt==5 )
            core_r5<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r6<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==6 )
            core_r6<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==6)
            core_r6<=mult_out[15:0];
        else if(opcode==3'b011 && rt==6 )
            core_r6<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r7<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==7 )
            core_r7<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==7)
            core_r7<=mult_out[15:0];
        else if(opcode==3'b011 && rt==7 )
            core_r7<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r8<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==8 )
            core_r8<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==8)
            core_r8<=mult_out[15:0];
        else if(opcode==3'b011 && rt==8 )
            core_r8<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r9<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==9 )
            core_r9<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==9)
            core_r9<=mult_out[15:0];
        else if(opcode==3'b011 && rt==9 )
            core_r9<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r10<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==10 )
            core_r10<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==10)
            core_r10<=mult_out[15:0];
        else if(opcode==3'b011 && rt==10 )
            core_r10<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r11<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==11 )
            core_r11<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==11)
            core_r11<=mult_out[15:0];
        else if(opcode==3'b011 && rt==11 )
            core_r11<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r12<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==12 )
            core_r12<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==12)
            core_r12<=mult_out[15:0];
        else if(opcode==3'b011 && rt==12 )
            core_r12<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r13<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==13 )
            core_r13<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==13)
            core_r13<=mult_out[15:0];
        else if(opcode==3'b011 && rt==13 )
            core_r13<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r14<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==14 )
            core_r14<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==14)
            core_r14<=mult_out[15:0];
        else if(opcode==3'b011 && rt==14 )
            core_r14<=M_out;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_r15<=0;
    else if(current_state==WB)
    begin
        if((opcode==3'b000 || (opcode==3'b001&&func==1)) && rd==15 )
            core_r15<=ALU_result;
        else if(opcode==3'b001 && func==0 && rd==15)
            core_r15<=mult_out;
        else if(opcode==3'b011 && rt==15 )
            core_r15<=M_out;
    end
end

assign opcode=inst[15:13];
assign rs=inst[12:9];
assign rt=inst[8:5];
assign rd=inst[4:1];
assign func=inst[0];
assign imm=inst[4:0];
assign addr=inst[12:0];


endmodule



















