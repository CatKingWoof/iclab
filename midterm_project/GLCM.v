//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NCTU ED415
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 spring
//   Midterm Proejct            : GLCM
//   Author                     : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : GLCM.v
//   Module Name : GLCM
//   Release version : V1.0 (Release Date: 2023-04)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module GLCM(
           clk,
           rst_n,

           in_addr_M,
           in_addr_G,
           in_dir,
           in_dis,
           in_valid,
           out_valid,


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
parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 32;
input			  clk,rst_n;
parameter IN_MEM_BITS = 20, IN_MEM_WORDS=16;


// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
       your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
	   therefore I declared output of AXI as wire in Poly_Ring
*/

// -----------------------------
// IO port
input [ADDR_WIDTH-1:0]      in_addr_M;
input [ADDR_WIDTH-1:0]      in_addr_G;
input [1:0]  	  		in_dir;
input [3:0]	    		in_dis;
input 			    	in_valid;
output reg 	              out_valid;
// -----------------------------


// axi write address channel
output  wire [ID_WIDTH-1:0]        awid_m_inf;
output  wire [ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [2:0]            awsize_m_inf;
output  wire [1:0]           awburst_m_inf;
output  wire [3:0]             awlen_m_inf;
output  wire                 awvalid_m_inf;
input   wire                 awready_m_inf;
// axi write data channel
output  wire [ DATA_WIDTH-1:0]     wdata_m_inf;
output  wire                   wlast_m_inf;
output  wire                  wvalid_m_inf;
input   wire                  wready_m_inf;
// axi write response channel
input   wire [ID_WIDTH-1:0]         bid_m_inf;
input   wire [1:0]             bresp_m_inf;
input   wire              	   bvalid_m_inf;
output  wire                  bready_m_inf;
// -----------------------------
// axi read address channel
output  wire [ID_WIDTH-1:0]       arid_m_inf;
output  wire [ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [3:0]            arlen_m_inf;
output  wire [2:0]           arsize_m_inf;
output  wire [1:0]          arburst_m_inf;
output  wire                arvalid_m_inf;
input   wire               arready_m_inf;
// -----------------------------
// axi read data channel
input   wire [ID_WIDTH-1:0]         rid_m_inf;
input   wire [DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [1:0]             rresp_m_inf;
input   wire                   rlast_m_inf;
input   wire                  rvalid_m_inf;
output  wire                  rready_m_inf;
// -----------------------------
reg [3:0] current_state,next_state;
reg [31:0] addr_M,addr_G;
reg [1:0] dir;
reg [3:0] dis;
reg [3:0] c;
reg [5:0] mem1_ref_a,mem1_c_a,mem1_input_a;
//reg in_flag;
//reg [1:0] in_flag;
//in_mem declare
wire [IN_MEM_BITS-1:0] mem1_out,mem1_d;
reg [5:0] mem1_a;
wire mem1_wen;
//out mem
wire [31:0]mem2_out;
reg [31:0] mem2_d;
reg [7:0] mem2_a,mem2_write_a,mem2_reset_a;
reg reset_finish;
reg mem2_wen;
reg mem2_access[0:31][0:7];
//out ram a
reg [79:0] GLCM_r_d;
reg [4:0] out_col,out_row;
//reg [3:0] ref;
reg wen_ctr;
reg [1:0] round,round_count;
reg not_first_cycle;
wire [3:0] d_col,d_row;
//DRAM read
reg [31:0] DRAM_adress,DRAM_adress_W;
reg [59:0] SRAM_input;
reg ar_ready,aw_ready;
reg [3:0] write_count;
reg [ DATA_WIDTH-1:0] write_data;
reg [3:0] out_round;
reg round_over,round_start;
wire input_mode;
reg [1:0] mem1_flag;
//FSM
reg [10:0] counter;
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        counter<=0;
    end
    else
    begin
	if(bvalid_m_inf||rready_m_inf)
        counter<=0;
	else
		counter<=counter+1;
    end
end
genvar  i,j;
parameter INPUT = 0,
          WAIT_AWREADY=1,
          READ_DRAM=2,
          GLCM_c=3,
          GLCM_ref=4,
          GLCM_out=5,
          WRITE_address=6,
          WRITE_DRAM=7,
          WRITE_response=8,
          OUTPUT=9;
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        current_state<=INPUT;
    end
    else
    begin
        current_state<=next_state;
    end
end
always @(*) begin
    case (current_state)
        INPUT:begin
            if(in_valid)
                next_state=WAIT_AWREADY;
            else
                next_state=INPUT;
        end
        WAIT_AWREADY:begin
            if((ar_ready||arready_m_inf)&&reset_finish)
                next_state=READ_DRAM;
            else
                next_state=WAIT_AWREADY;
        end
        READ_DRAM:begin
            if(rlast_m_inf)
            begin
                if(round_start)
                    next_state=GLCM_c;
                else
                    next_state=WAIT_AWREADY;
            end
            else
                next_state=READ_DRAM;
        end
        GLCM_c:begin
            if(mem1_flag==1&&round_over)
            begin
                if(mem1_c_a==0)
                    next_state=WRITE_address;
                else
                    next_state=READ_DRAM;
            end
            else if(mem1_flag==3)
                next_state=GLCM_ref;
            else
                next_state=GLCM_c;
        end
        GLCM_ref:begin
            if(mem1_flag==3)
                next_state=GLCM_out;
            else
                next_state=GLCM_ref;
        end
        GLCM_out:begin
            if(c==15&&not_first_cycle)
                next_state=GLCM_c;
            else
                next_state=GLCM_out;
        end
        WRITE_address:begin
            if(awready_m_inf)
                next_state=WRITE_DRAM;
            else
                next_state=WRITE_address;
        end
        WRITE_DRAM:begin
            if(wlast_m_inf)
                next_state=WRITE_response;
            else
                next_state=WRITE_DRAM;
        end
        WRITE_response:begin
            if(bvalid_m_inf)
            begin
                if(out_round==15)
                    next_state=OUTPUT;
                else
                    next_state=WRITE_address;
            end

            else
                next_state=WRITE_response;
        end
        OUTPUT:begin
            next_state=INPUT;
        end
        default:next_state=INPUT;
    endcase
end
always @(*) begin
    if(round_count==0)
    begin
        if(d_row<4)
            round_start=1;
        else
            round_start=0;
    end
    else if (round_count==1)
    begin
        if(d_row<8)
            round_start=1;
        else
            round_start=0;
    end
    else if (round_count==2)
    begin
        if(d_row<12)
            round_start=1;
        else
            round_start=0;
    end
    else
    begin
        round_start=1;
    end
end
always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        round_over<=0;
    end
    else*/
    begin
        if(current_state==READ_DRAM)
            round_over<=0;
        else if (current_state==GLCM_out&&round_count==0&&mem1_c_a==16)
            round_over<=1;
        else if (current_state==GLCM_out&&round_count==1&&mem1_c_a==32)
            round_over<=1;
        else if (current_state==GLCM_out&&round_count==2&&mem1_c_a==48)
            round_over<=1;
        else if (current_state==GLCM_out&&round_count==3&&mem1_c_a==0)
            round_over<=1;
    end
end

assign input_mode= (d_row>=12) ? 0 : 1;

always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        not_first_cycle<=0;
    end
    else*/
    begin
        if(current_state==READ_DRAM||current_state==GLCM_ref)
            not_first_cycle<=0;
        else if (current_state==GLCM_out)
            not_first_cycle<=1;
    end
end
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        round<=0;
    end
    else
    begin
        if(current_state==READ_DRAM||current_state==INPUT)
            round<=0;
        else if(current_state==GLCM_ref&&not_first_cycle)
            round<=round+1;
    end
end
always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        round_count<=0;
    end
    else*/
    begin
        if(current_state==INPUT)
            round_count<=0;
        else if(current_state==GLCM_c&&mem1_flag==1&&round_over )
            round_count<=round_count+1;
        else if (current_state==READ_DRAM&&!round_start&&rlast_m_inf)
        begin
            if(input_mode==0)
                round_count<=3;
            else
                round_count<=round_count+1;
        end
    end
end

//input
always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        addr_G<=0;
        addr_M<=0;
        dir<=0;
        dis<=0;
    end
    else*/
    begin
        if(current_state==INPUT)
        begin
            if(in_valid)
            begin
                addr_G<=in_addr_G;
                addr_M<=in_addr_M;
                dir<=in_dir;
                dis<=in_dis;
            end
        end
    end
end
assign d_col = (dir[1]) ? dis :0;
assign d_row = (dir[0]) ? dis :0;
//DRAM read
assign arid_m_inf=4'b0;
assign arlen_m_inf=15;
assign arsize_m_inf=3'b010;
assign arburst_m_inf=2'b01;

assign araddr_m_inf=  ((current_state==WAIT_AWREADY&&!ar_ready )|| ( (current_state==GLCM_c||current_state==GLCM_ref||current_state==GLCM_out)&&!ar_ready&&round_count!=3) ) ? DRAM_adress : 0;
assign arvalid_m_inf =((current_state==WAIT_AWREADY&&!ar_ready)|| ( (current_state==GLCM_c||current_state==GLCM_ref||current_state==GLCM_out)&&!ar_ready&&round_count!=3) ) ? 1 : 0;
assign rready_m_inf =(current_state==READ_DRAM) ? 1 : 0;

//DRAM write
assign awid_m_inf=4'b0;
assign awlen_m_inf =15;
assign awsize_m_inf= 3'b010;
assign awburst_m_inf=2'b01;
assign awaddr_m_inf=(current_state==WRITE_address) ? DRAM_adress_W : 0;
assign awvalid_m_inf=(current_state==WRITE_address) ? 1 : 0;
assign wdata_m_inf =(current_state==WRITE_DRAM) ? {mem2_out[7:0],mem2_out[15:8],mem2_out[23:16],mem2_out[31:24]} : 0 ;
assign wlast_m_inf =(write_count==15) ? 1 :0;
assign wvalid_m_inf =(current_state==WRITE_DRAM) ? 1 : 0;
assign bready_m_inf =(current_state==WRITE_response) ? 1 : 0;
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        mem2_write_a<=0;
    end
    else
    begin
        if(current_state==INPUT)
            mem2_write_a<=0;
        else if (current_state==WRITE_DRAM&&wready_m_inf)
            mem2_write_a<=mem2_write_a+1;

    end
end
always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        write_count<=0;
    end
    else*/
    begin
        if(wvalid_m_inf&&wready_m_inf)
            write_count<=write_count+1;
        else
            write_count<=0;
    end
end
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        ar_ready<=0;
    end
    else
    begin
        if(current_state==READ_DRAM)
            ar_ready<=0;
        else if(arready_m_inf)
            ar_ready<=1;
    end
end
always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        DRAM_adress<=0;
    end
    else*/
    begin
        if(current_state==INPUT)
        begin
            if(in_valid)
                DRAM_adress<=in_addr_M;
        end
        else  if(arready_m_inf)
        begin
            if(input_mode==0)
                DRAM_adress<=DRAM_adress+192;
            else
                DRAM_adress<=DRAM_adress+64;
        end

    end
end
always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        DRAM_adress_W<=0;
    end
    else*/
    begin
        if(current_state==INPUT)
        begin
            if(in_valid)
                DRAM_adress_W<=in_addr_G;
        end
        else  if(bvalid_m_inf)
            DRAM_adress_W<=DRAM_adress_W+64;
    end
end
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        out_round<=0;
    end
    else
    begin
        if(current_state==INPUT)
            out_round<=0;
        else if (bvalid_m_inf)
            out_round<=out_round+1;
    end
end

//sram1_addr
always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        mem1_input_a<=0;
    end
    else*/
    begin
        if(current_state==INPUT)
            mem1_input_a<=0;
        else if(current_state==READ_DRAM)
        begin
            if(input_mode==0&&rlast_m_inf)
                mem1_input_a<=48;
            else if(rvalid_m_inf)
                mem1_input_a<=mem1_input_a+1;
        end
    end
end
always @(*)begin
    if(current_state==READ_DRAM)
        mem1_a=mem1_input_a;
    else if (current_state==GLCM_c)
        mem1_a=mem1_c_a;
    else if(current_state==GLCM_ref)
        mem1_a=mem1_ref_a;
    else
        mem1_a=mem1_ref_a;
end
always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        mem1_flag<=0;
    end
    else*/
    begin
        if(current_state==GLCM_c||current_state==GLCM_ref)
            mem1_flag<=mem1_flag+1;
        else if(current_state==READ_DRAM)
            mem1_flag<=0;
    end
end
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        mem1_ref_a<=0;
    end
    else
    begin
        if(current_state==INPUT)
            mem1_ref_a<=0;
        else if(current_state==GLCM_ref)
            mem1_ref_a<=mem1_ref_a+1;
    end
end
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        mem1_c_a<=0;
    end
    else
    begin
        if(current_state==INPUT)
        begin
            if(in_dir[0])
                mem1_c_a<=in_dis*4;
            else
                mem1_c_a<=0;
        end
        else if(current_state==GLCM_c&&!round_over)
            mem1_c_a<=mem1_c_a+1;
    end
end
assign mem1_wen =(current_state==READ_DRAM) ?  0 : 1 ;
assign mem1_d={rdata_m_inf[4:0],rdata_m_inf[12:8],rdata_m_inf[20:16],rdata_m_inf[28:24]} ;

//sram1_out
reg [79:0] GLCM_c_d;


//W16B40 mem1 (.Q(mem1_out), .CLK(clk), .CEN(1'b0), .WEN(mem1_wen), .A(mem1_a), .D(mem1_d), .OEN(1'b0) );
W64B20 mem1 (.Q(mem1_out), .CLK(clk), .CEN(1'b0), .WEN(mem1_wen), .A(mem1_a), .D(mem1_d), .OEN(1'b0) );
W256B32 mem2 (.Q(mem2_out), .CLK(clk), .CEN(1'b0), .WEN(mem2_wen), .A(mem2_a), .D(mem2_d), .OEN(1'b0) );

//sram2_a
reg [7:0] mem2_glcm_write_a,mem2_glcm_read_a;
reg [31:0] mem2_glcm_d;
reg [1:0] glcm_read_flag;

always @(*)begin
    if(current_state==WAIT_AWREADY&&round_count==0)
        mem2_wen=0;
    else if(current_state==GLCM_out)
    begin
        if(not_first_cycle&&glcm_read_flag==2)
            mem2_wen=0;
        else
            mem2_wen=1;
    end
    else if(current_state==GLCM_c&&mem1_flag==1&&not_first_cycle)
        mem2_wen=0;
    else
        mem2_wen=1;
end
always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        glcm_read_flag<=0;
    end
    else*/
    begin
        if(current_state==GLCM_ref)
            glcm_read_flag<=0;
        else if (current_state==GLCM_out&&not_first_cycle)
        begin
            if(mem2_wen)
                glcm_read_flag<=glcm_read_flag+1;
            else
                glcm_read_flag<=0;
        end
    end
end

always @(*) begin
    if(current_state==WAIT_AWREADY&&round==0&&round_count==0)
        mem2_a=mem2_reset_a;
    else if(current_state==GLCM_out||current_state==GLCM_ref||current_state==GLCM_c)
    begin
        mem2_a=mem2_glcm_read_a;
    end
    else if (current_state==WRITE_DRAM && wready_m_inf)
        mem2_a=mem2_write_a+1;
    else
        mem2_a=mem2_write_a;

end
always @(*) begin
    mem2_glcm_read_a=out_row*8+out_col/4;
end


//sram2 write
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        mem2_reset_a<=0;
    end
    else
    begin
        if(current_state==INPUT)
            mem2_reset_a<=0;
        else if(current_state==WAIT_AWREADY)
            mem2_reset_a<=mem2_reset_a+1;
    end
end
always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        reset_finish<=0;
    end
    else*/
    begin
        if(current_state==INPUT)
            reset_finish<=0;
        else if (mem2_reset_a==255)
            reset_finish<=1;
    end
end



reg [7:0] temp;
always @(*) begin
    case (out_col%4)
        0: temp= mem2_glcm_d[31:24]+1;
        1: temp= mem2_glcm_d[23:16]+1;
        2: temp= mem2_glcm_d[15:8]+1;
        3: temp= mem2_glcm_d[7:0]+1;
        default: temp= mem2_glcm_d[31:24]+1;
    endcase
end
always @(*) begin
    if(current_state==GLCM_out&&glcm_read_flag!=0 || current_state==GLCM_c&&mem1_flag==1)
    begin
        begin
            case (out_col%4)
                0: mem2_d={temp,mem2_glcm_d[23:16],mem2_glcm_d[15:8],mem2_glcm_d[7:0]};
                1: mem2_d={mem2_glcm_d[31:24],temp,mem2_glcm_d[15:8],mem2_glcm_d[7:0]};
                2: mem2_d={mem2_glcm_d[31:24],mem2_glcm_d[23:16],temp,mem2_glcm_d[7:0]};
                3: mem2_d={mem2_glcm_d[31:24],mem2_glcm_d[23:16],mem2_glcm_d[15:8],temp};
                default:mem2_d=0;
            endcase
        end
    end
    else
        mem2_d=0;
end

always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        mem2_glcm_d<=0;
    end
    else*/
    begin
        if(current_state==GLCM_out&&glcm_read_flag==1)
            mem2_glcm_d<=mem2_out;
        else if(current_state==GLCM_c&&mem1_flag==0)
            mem2_glcm_d<=mem2_out;
    end
end



//sram2_in
always @(posedge clk /*or negedge rst_n*/) begin
    /*if (!rst_n)
    begin
        c<=0;
    end
    else*/
    begin
        if(current_state==GLCM_c)
            c<=d_col;
        else if (current_state==GLCM_out&&!mem2_wen&&not_first_cycle)
        begin
            c<=c+1;
        end
    end
end
always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        GLCM_c_d<=0;
    end
    else*/
    begin
        if(current_state==GLCM_c&&!round_over)
        begin
            case (mem1_flag)
                1:GLCM_c_d[79:60]<=mem1_out;
                2:GLCM_c_d[59:40]<=mem1_out;
                3:GLCM_c_d[39:20]<=mem1_out;
            endcase
        end
        else if(current_state==GLCM_ref)
        begin
            if(mem1_flag==0)
                GLCM_c_d[19:0]<=mem1_out;
            else if(mem1_flag==1)
                GLCM_c_d<=GLCM_c_d<<(d_col)*5;
        end
        else if(current_state==GLCM_out&&!mem2_wen&&not_first_cycle)
            GLCM_c_d<=GLCM_c_d<<5;
    end
end

always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        GLCM_r_d<=0;
    end
    else*/
    begin
        if(current_state==GLCM_ref)
        begin
            case (mem1_flag)
                1:GLCM_r_d[79:60]<=mem1_out;
                2:GLCM_r_d[59:40]<=mem1_out;
                3:GLCM_r_d[39:20]<=mem1_out;
            endcase
        end
        else if(current_state==GLCM_out&&!not_first_cycle)
            GLCM_r_d[19:0]<=mem1_out;
        else if (current_state==GLCM_out&&!mem2_wen&&not_first_cycle)
            GLCM_r_d<=GLCM_r_d<<5;
    end
end

always @(*)begin
    if(current_state==GLCM_out||current_state==GLCM_c||current_state==GLCM_ref)
        out_col=GLCM_c_d[79:75];
    else
        out_col=0;
end
always @(*)begin

    begin
        if(current_state==GLCM_out||current_state==GLCM_c||current_state==GLCM_ref)
        begin
            if(!not_first_cycle)
                out_row=mem1_out[19:15];
            else
                out_row=GLCM_r_d[79:75];
        end
        else
            out_row=0;

    end
end
//sram2 out

//out
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        out_valid<=0;
    end
    else
    begin
        if(current_state==OUTPUT)
            out_valid<=1;
        else
            out_valid<=0;
    end
end
endmodule








