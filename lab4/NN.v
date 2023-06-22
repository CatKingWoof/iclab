/*//synopsys translate_off
`include “/usr/synthesis/dw/sim_ver/DW_fp_mult.v”
`include “/usr/synthesis/dw/sim_ver/DW_fp_add.v”
`include “/usr/synthesis/dw/sim_ver/DW_fp_exp.v”
`include “/usr/synthesis/dw/sim_ver/DW_fp_recip.v”
//synopsys translate_on*/
module NN(
           // Input signals
           clk,
           rst_n,
           in_valid,
           weight_u,
           weight_w,
           weight_v,
           data_x,
           data_h,
           // Output signals
           out_valid,
           out
       );

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 1;
parameter inst_faithful_round = 0;
parameter round =3'b0 ;
genvar  i,j;
integer k,y;
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input  clk, rst_n, in_valid;
input [inst_sig_width+inst_exp_width:0] weight_u, weight_w, weight_v;
input [inst_sig_width+inst_exp_width:0] data_x,data_h;
output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg [inst_sig_width+inst_exp_width:0] m1_in1,m1_in2,a1_in1,  m2_in1,m2_in2,a2_in1,  m3_in1,m3_in2,a3_in1,exp_in,a4_in1,r1_in1 ;
wire [inst_sig_width+inst_exp_width:0] m1_out,a1_out,  m2_out,a2_out,  m3_out,a3_out,exp_out,a4_out,r1_out;
reg [5:0] current_state;
reg  state[0:39];
reg [inst_sig_width+inst_exp_width:0] u[0:2][0:2],v[0:2][0:2],w[0:2][0:2],x[0:8],h[0:2];
//desgin
//FSM
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        current_state<=0;
    end
    else
    begin
        if(current_state==0)
        begin
            if(!in_valid)
                current_state<=current_state;
            else
                current_state<=current_state+1;
        end
        else if(current_state==40)
            current_state<=0;
        else
        begin
            current_state<=current_state+1;
        end
    end
end
always @(*) begin
    if(!current_state&&in_valid)
        state[0]=1;
    else
        state[0]=0;
end
generate
    for (i = 1; i<40; i=i+1) begin
        always @(*) begin
            if(i==current_state)
                state[i]=1;
            else
                state[i]=0;
        end
    end
endgenerate
//weight matrix
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        for(k=0;k<3;k=k+1)begin
            for(y=0;y<3;y=y+1)begin
                u[k][y]<=0;
                v[k][y]<=0;
                w[k][y]<=0;
            end
        end
    end
    else*/
    begin
        if(state[0])
        begin
            u[0][0]<=weight_u;
            w[0][0]<=weight_w;
            v[0][0]<=weight_v;
        end
        else
        begin
            u[0][0]<=u[0][0];
            w[0][0]<=w[0][0];
            v[0][0]<=v[0][0];
        end
        if(state[1])
        begin
            u[0][1]<=weight_u;
            w[0][1]<=weight_w;
            v[0][1]<=weight_v;
        end
        else
        begin
            u[0][1]<=u[0][1];
            w[0][1]<=w[0][1];
            v[0][1]<=v[0][1];
        end
        if(state[2])
        begin
            u[0][2]<=weight_u;
            w[0][2]<=weight_w;
            v[0][2]<=weight_v;
        end
        else
        begin
            u[0][2]<=u[0][2];
            w[0][2]<=w[0][2];
            v[0][2]<=v[0][2];
        end
        if(state[3])
        begin
            u[1][0]<=weight_u;
            w[1][0]<=weight_w;
            v[1][0]<=weight_v;
        end
        else
        begin
            u[1][0]<=u[1][0];
            w[1][0]<=w[1][0];
            v[1][0]<=v[1][0];
        end
        if(state[4])
        begin
            u[1][1]<=weight_u;
            w[1][1]<=weight_w;
            v[1][1]<=weight_v;
        end
        else
        begin
            u[1][1]<=u[1][1];
            w[1][1]<=w[1][1];
            v[1][1]<=v[1][1];
        end
        if(state[5])
        begin
            u[1][2]<=weight_u;
            w[1][2]<=weight_w;
            v[1][2]<=weight_v;
        end
        else
        begin
            u[1][2]<=u[1][2];
            w[1][2]<=w[1][2];
            v[1][2]<=v[1][2];
        end
        if(state[6])
        begin
            u[2][0]<=weight_u;
            w[2][0]<=weight_w;
            v[2][0]<=weight_v;
        end
        else
        begin
            u[2][0]<=u[2][0];
            w[2][0]<=w[2][0];
            v[2][0]<=v[2][0];
        end
        if(state[7])
        begin
            u[2][1]<=weight_u;
            w[2][1]<=weight_w;
            v[2][1]<=weight_v;
        end
        else
        begin
            u[2][1]<=u[2][1];
            w[2][1]<=w[2][1];
            v[2][1]<=v[2][1];
        end
        if(state[8])
        begin
            u[2][2]<=weight_u;
            w[2][2]<=weight_w;
            v[2][2]<=weight_v;
        end
        else
        begin
            u[2][2]<=u[2][2];
            w[2][2]<=w[2][2];
            v[2][2]<=v[2][2];
        end
    end
end
/*generate
    for (i = 0; i<9; i=i+1) begin
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)
                x[i]<=0;
            else
            begin
                if(state[i])
                    x[i]<=data_x;
                else
                    x[i]<=x[i];
            end
        end
    end
endgenerate*/
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        for (k = 0; k<9; k=k+1) begin
            x[k]<=0;
        end
    end
    else*/
    begin
        if(state[0])
            x[0]<=data_x;
        else if (state[17])
            x[0]<=r1_out;
        else
            x[0]<=x[0];

        if(state[1])
            x[1]<=data_x;
        else if (state[18])
            x[1]<=r1_out;
        else
            x[1]<=x[1];

        if(state[2])
            x[2]<=data_x;
        else if (state[19])
            x[2]<=r1_out;
        else
            x[2]<=x[2];

        if(state[3])
            x[3]<=data_x;
        else if (state[27])
            x[3]<=r1_out;
        else
            x[3]<=x[3];

        if(state[4])
            x[4]<=data_x;
        else if (state[28])
            x[4]<=r1_out;
        else
            x[4]<=x[4];

        if(state[5])
            x[5]<=data_x;
        else if (state[29])
            x[5]<=r1_out;
        else
            x[5]<=x[5];

        if(state[6])
            x[6]<=data_x;
        else
            x[6]<=x[6];

        if(state[7])
            x[7]<=data_x;
        else
            x[7]<=x[7];

        if(state[8])
            x[8]<=data_x;
        else
            x[8]<=x[8];

    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        h[0]<=0;
    end
    else*/
    begin
        if(state[0])
            h[0]<=data_h;
        else if (state[11]||state[21]||state[31]) begin
            if(a1_out[31])
                h[0]<=m1_out;
            else
                h[0]<=m1_in1;
            if(m1_in1[31])
                h[0]<=m1_out;
            else
                h[0]<=m1_in1;
        end
        else
            h[0]<=h[0];
    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        h[1]<=0;
    end
    else*/
    begin
        if(state[1])
            h[1]<=data_h;
        else if (state[12]||state[22]||state[32]) begin
            if(a2_out[31])
                h[1]<=m2_out;
            else
                h[1]<=m2_in1;
        end
        else
            h[1]<=h[1];
    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        h[2]<=0;
    end
    else*/
    begin
        if(state[2])
            h[2]<=data_h;
        else if (state[13]||state[23]||state[33]) begin
            if(a3_out[31])
                h[2]<=m3_out;
            else
                h[2]<=m3_in1;
        end
        else
            h[2]<=h[2];
    end
end

always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        m1_in1<=0;
    end
    else*/
    begin
        if (state[4]||state[14]||state[24])
            m1_in1<=u[0][0];
        else if (state[5]||state[15]||state[25])
            m1_in1<=u[0][1];
        else if (state[6]||state[16]||state[26])
            m1_in1<=u[0][2];
        else if (state[7]||state[17]||state[27])
            m1_in1<=w[0][0];
        else if (state[8]||state[18]||state[28])
            m1_in1<=w[0][1];
        else if (state[9]||state[19]||state[29])
            m1_in1<=w[0][2];
        else if (state[10]||state[20]||state[30])
            m1_in1<=a1_out;
        else if (state[11]||state[21]||state[31])
            m1_in1<=v[0][0];
        else if (state[12]||state[22]||state[32])
            m1_in1<=v[0][1];
        else if (state[13]||state[23]||state[33])
            m1_in1<=v[0][2];
        else
            m1_in1<=m1_in1;
    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        m1_in2<=0;
    end
    else*/
    begin
        if (state[4])
            m1_in2<=x[0];
        else if (state[5])
            m1_in2<=x[1];
        else if (state[6])
            m1_in2<=x[2];
        else if (state[7]||state[17]||state[27])
            m1_in2<=h[0];
        else if (state[8]||state[18]||state[28])
            m1_in2<=h[1];
        else if (state[9]||state[19]||state[29])
            m1_in2<=h[2];
        else if (state[10]||state[20]||state[30])
            m1_in2<=32'b00111101110011001100110011001101;
        else if (state[11]||state[21]||state[31])
            //m1_in2<=m1_out;
        begin
            if(m1_in1[31])
                m1_in2<=m1_out;
            else
                m1_in2<=m1_in1;
        end

        else if (state[12]||state[22]||state[32])

            //m1_in2<=m2_out;
        begin
            if(m2_in1[31])
                m1_in2<=m2_out;
            else
                m1_in2<=m2_in1;
        end
        else if (state[13]||state[23]||state[33])
            //m1_in2<=m3_out;
        begin
            if(m3_in1[31])
                m1_in2<=m3_out;
            else
                m1_in2<=m3_in1;
        end
        else if (state[14])
            m1_in2<=x[3];
        else if (state[15])
            m1_in2<=x[4];
        else if (state[16])
            m1_in2<=x[5];
        else if (state[24])
            m1_in2<=x[6];
        else if (state[25])
            m1_in2<=x[7];
        else if (state[26])
            m1_in2<=x[8];
        else
            m1_in2<=m1_in2;
    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        a1_in1<=0;
    end
    else*/
    begin
        if (state[5]||state[12]||state[15]||state[22]||state[25]||state[32])
            a1_in1<=m1_out;
        else
            a1_in1<=a1_out;
    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        m2_in1<=0;
    end
    else*/
    begin
        if (state[5]||state[15]||state[25])
            m2_in1<=u[1][0];
        else if (state[6]||state[16]||state[26])
            m2_in1<=u[1][1];
        else if (state[7]||state[17]||state[27])
            m2_in1<=u[1][2];
        else if (state[8]||state[18]||state[28])
            m2_in1<=w[1][0];
        else if (state[9]||state[19]||state[29])
            m2_in1<=w[1][1];
        else if (state[10]||state[20]||state[30])
            m2_in1<=w[1][2];
        else if (state[11]||state[21]||state[31])
            m2_in1<=a2_out;
        else if (state[12]||state[22]||state[32])
            m2_in1<=v[1][0];
        else if (state[13]||state[23]||state[33])
            m2_in1<=v[1][1];
        else if (state[14]||state[24]||state[34])
            m2_in1<=v[1][2];
        else
            m2_in1<=m2_in1;

    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        m2_in2<=0;
    end
    else*/
    begin
        if (state[5])
            m2_in2<=x[0];
        else if (state[6])
            m2_in2<=x[1];
        else if (state[7])
            m2_in2<=x[2];
        else if (state[8]||state[12]||state[18]||state[22]||state[28]||state[32])
            m2_in2<=h[0];
        else if (state[9]||state[13]||state[19]||state[23]||state[29]||state[33])
            m2_in2<=h[1];
        else if (state[10]||state[14]||state[20]||state[24]||state[30]||state[34])
            m2_in2<=h[2];
        else if (state[11]||state[21]||state[31])
            m2_in2<=32'b00111101110011001100110011001101;
        else if (state[15])
            m2_in2<=x[3];
        else if (state[16])
            m2_in2<=x[4];
        else if (state[17])
            m2_in2<=x[5];
        else if (state[25])
            m2_in2<=x[6];
        else if (state[26])
            m2_in2<=x[7];
        else if (state[27])
            m2_in2<=x[8];
    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        a2_in1<=0;
    end
    else*/
    begin
        if (state[6]||state[13]||state[16]||state[23]||state[26]||state[33])
            a2_in1<=m2_out;
        else
            a2_in1<=a2_out;
    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        m3_in1<=0;
    end
    else*/
    begin
        if(state[6]||state[7]||state[8])
            m3_in1<=weight_u;
        else if (state[16]||state[26])
            m3_in1<=u[2][0];
        else if (state[17]||state[27])
            m3_in1<=u[2][1];
        else if (state[18]||state[28])
            m3_in1<=u[2][2];
        else if (state[9]||state[19]||state[29])
            m3_in1<=w[2][0];
        else if (state[10]||state[20]||state[30])
            m3_in1<=w[2][1];
        else if (state[11]||state[21]||state[31])
            m3_in1<=w[2][2];
        else if (state[12]||state[22]||state[32])
            m3_in1<=a3_out;
        else if (state[13]||state[23]||state[33])
            m3_in1<=v[2][0];
        else if (state[14]||state[24]||state[34])
            m3_in1<=v[2][1];
        else if (state[15]||state[25]||state[35])
            m3_in1<=v[2][2];
        else
            m3_in1<=m3_in1;
    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        m3_in2<=0;
    end
    else*/
    begin
        if(state[6])
            m3_in2<=x[0];
        else if (state[7])
            m3_in2<=x[1];
        else if (state[8])
            m3_in2<=x[2];
        else if (state[9]|||state[13]||state[19]||state[23]||state[29]||state[33])
            m3_in2<=h[0];
        else if (state[10]||state[14]||state[20]||state[24]||state[30]||state[34])
            m3_in2<=h[1];
        else if (state[11]||state[15]||state[21]||state[25]||state[31]||state[35])
            m3_in2<=h[2];
        else if (state[12]||state[22]||state[32])
            m3_in2<=32'b00111101110011001100110011001101;
        else if (state[16])
            m3_in2<=x[3];
        else if (state[17])
            m3_in2<=x[4];
        else if (state[18])
            m3_in2<=x[5];
        else if (state[26])
            m3_in2<=x[6];
        else if (state[27])
            m3_in2<=x[7];
        else if (state[28])
            m3_in2<=x[8];

    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        a3_in1<=0;
    end
    else*/
    begin
        if (state[7]||state[14]||state[17]||state[24]||state[27]||state[34])
            a3_in1<=m3_out;
        else
            a3_in1<=a3_out;
    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        exp_in<=0;
    end
    else*/
    begin
        if(state[14]||state[24]||state[34])
            exp_in<={~a1_out[31],a1_out[30:0]};
        else if (state[15]||state[25]||state[35])
            exp_in<={~a2_out[31],a2_out[30:0]};
        else if (state[16]||state[26]||state[36])
            exp_in<={~a3_out[31],a3_out[30:0]};
        else
            exp_in<=exp_in;
    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        a4_in1<=0;
    end
    else*/
    begin
        a4_in1<=exp_out;
    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        r1_in1<=0;
    end
    else*/
    begin
        r1_in1<=a4_out;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        out<=0;
        out_valid<=0;
    end
    else
    begin
        if (state[31])
        begin
            out<=x[0];
            out_valid<=1;
        end
        else if (state[32])
        begin
            out<=x[1];
            out_valid<=1;
        end
        else if (state[33])
        begin
            out<=x[2];
            out_valid<=1;
        end
        else if (state[34])
        begin
            out<=x[3];
            out_valid<=1;
        end
        else if (state[35])
        begin
            out<=x[4];
            out_valid<=1;
        end
        else if (state[36])
        begin
            out<=x[5];
            out_valid<=1;
        end
        else if (state[37])
        begin
            out<=r1_out;
            out_valid<=1;
        end
        else if (state[38])
        begin
            out<=r1_out;
            out_valid<=1;
        end
        else if (state[39])
        begin
            out<=r1_out;
            out_valid<=1;
        end
        else
        begin
            out<=0;
            out_valid<=0;
        end
    end
end

//mal1
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) M1 (.a(m1_in1),.b(m1_in2),.rnd(round),.z(m1_out));
DW_fp_add #(inst_sig_width,inst_exp_width,inst_ieee_compliance) A1 (.a(a1_in1),.b(m1_out),.rnd(round),.z(a1_out));
//mal2
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) M2 (.a(m2_in1),.b(m2_in2),.rnd(round),.z(m2_out));
DW_fp_add #(inst_sig_width,inst_exp_width,inst_ieee_compliance) A2 (.a(a2_in1),.b(m2_out),.rnd(round),.z(a2_out));
//mal3
DW_fp_mult #(inst_sig_width,inst_exp_width,inst_ieee_compliance) M3 (.a(m3_in1),.b(m3_in2),.rnd(round),.z(m3_out));
DW_fp_add #(inst_sig_width,inst_exp_width,inst_ieee_compliance) A3 (.a(a3_in1),.b(m3_out),.rnd(round),.z(a3_out));
//exp
DW_fp_exp #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch) E1 (.a(exp_in),.z(exp_out));
//add
DW_fp_add #(inst_sig_width,inst_exp_width,inst_ieee_compliance) A4 (.a(a4_in1),.b(32'b00111111100000000000000000000000),.rnd(round),.z(a4_out));
//recip
DW_fp_recip #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_faithful_round) R1 (.a(r1_in1),.rnd(round),.z(r1_out));
endmodule
