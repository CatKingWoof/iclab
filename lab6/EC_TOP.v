//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright Optimum Application-Specific Integrated System Laboratory
//    All Right Reserved
//		Date		: 2023/03
//		Version		: v1.0
//   	File Name   : EC_TOP.v
//   	Module Name : EC_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "INV_IP.v"
//synopsys translate_on

module EC_TOP(
           // Input signals
           clk, rst_n, in_valid,
           in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a,
           // Output signals
           out_valid, out_Rx, out_Ry
       );

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [6-1:0] in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a;
output reg out_valid;
output reg [6-1:0] out_Rx, out_Ry;
wire [6-1:0] inv_out;
reg [5:0] IP_out;
reg [1:0] count;
reg [6-1:0] IN_1,IN_Px,IN_Py,IN_Qx,IN_Qy,IN_a,IN_prime,m_out,IN_2;

reg [5:0] ox,oy;
reg [12:0] mod3_in;
reg [11:0] mod1_in;
reg [11:0] mod2_in;

reg [5:0] mod1_out,mod2_out,mod3_out;
//FSM
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        count<=0;
    end
    else
    begin
        if(count==0)
        begin
            if(in_valid)
                count<=count+1;
            else
                count<=count;
        end
        else
        begin
            if(out_valid)
                count<=0;
            else
                count<=count+1;
        end
    end
end
//procedure design
always @(posedge clk /*or negedge rst_n*/)
begin
    /*if(!rst_n)
    begin
        IN_Px<=0;
        IN_Py<=0;
        IN_Qx<=0;
        IN_Qy<=0;
        IN_a<=0;
        IN_prime<=0;
    end
    else*/
    begin
        if(in_valid)begin
            IN_Px<=in_Px;
            IN_Py<=in_Py;
            IN_Qx<=in_Qx;
            IN_Qy<=in_Qy;
            IN_a<=in_a;
            IN_prime<=in_prime;
        end
        else begin
            IN_Px<=IN_Px;
            IN_Py<=IN_Py;
            IN_Qx<=IN_Qx;
            IN_Qy<=IN_Qy;
            IN_a<=IN_a;
            IN_prime<=IN_prime;
        end
    end
end
always @(posedge clk /*or negedge rst_n*/)
begin
    /*if(!rst_n)
    begin
        IP_out<=0;
    end
    else*/
    begin
        if(count==1)
            IP_out<=inv_out;
        else
            IP_out<=IP_out;
    end
end
/*always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        IN_1<=0;
    end
    else
    begin
        if(in_valid)
            IN_1<=in_prime;
        else
            IN_1<=IN_1;
    end
end*/
always @(posedge clk /*or negedge rst_n*/)
begin
    /*if(!rst_n)
    begin
        IN_2<=0;
    end
    else*/
    begin
        if(in_valid)begin
            IN_2<=mod1_out;
        end
        else
            IN_2<=IN_2;
    end
end

always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        m_out<=0;
    end
    else*/
    begin
        if(count==1)
            // m_out<=t_cccc1;
            m_out<=mod3_out;
        else
            m_out<=m_out;
    end
end

//mod

always @(*) begin
    if(count==0)
    begin
        if(in_Px!=in_Qx||in_Py!=in_Qy)
            mod1_in=in_prime+in_Qx-in_Px;
        else
            mod1_in=2*in_Py;
    end
    /*else if(count==1)
        mod1_in=3*IN_Px;*/
    else if (count==1) begin
        mod1_in=mod2_out*IN_Px;
    end
    else if (count==2)
        mod1_in=IP_out*m_out;
    else if (count==3)
        mod1_in=IP_out*m_out;
    else
        mod1_in=0;
end

always @(*) begin
    /*if (count==1) begin
        mod2_in=mod1_out*IN_Px;
    end*/
    if(count==1)
        mod2_in=3*IN_Px;
    else if (count==2)
        mod2_in=IN_prime+IN_prime-IN_Px-IN_Qx;
    else if (count==3)
        mod2_in=IN_prime+IN_Px-ox;
    else
        mod2_in=0;
end
always @(*) begin
    if(count==1)begin
        if(IN_Px!=IN_Qx||IN_Py!=IN_Qy)
            mod3_in=IN_prime+IN_Qy-IN_Py;
        else
            mod3_in=mod1_out+IN_a;
    end
    else if (count==2)
        mod3_in=mod1_out*mod1_out+mod2_out;
    else if (count==3)
        mod3_in=mod1_out*mod2_out+IN_prime-IN_Py;
    else
        mod3_in=0;
end

always @(*) begin
    if(count==0)
        mod1_out=mod1_in%in_prime;
    else
        mod1_out=mod1_in%IN_prime;
end
always @(*) begin
    mod2_out=mod2_in%IN_prime;
end
always @(*) begin
    mod3_out=mod3_in%IN_prime;
end

/*assign mod1_out=(count==0) ?mod1_in%in_prime :mod1_in%IN_prime;
assign mod2_out=mod2_in%IN_prime;
assign mod3_out=mod3_in%IN_prime;*/
//output

always @(posedge clk /*or negedge rst_n*/)
begin
    /*if(!rst_n)
    begin
        ox<=0;
    end
    else*/
    begin
        if(count==2)
            ox<=mod3_out;
        else
            ox<=ox;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        out_Rx<=0;
        out_Ry<=0;
        out_valid<=0;
    end
    else
    begin
        if(count==3)
        begin
            out_valid<=1;
            out_Rx<=ox;
            out_Ry<=mod3_out;
        end
        else
        begin
            out_valid<=0;
            out_Rx<=0;
            out_Ry<=0;
        end
    end
end

INV_IP #(.IP_WIDTH(6)) I_INV_IP (.IN_1(IN_prime),.IN_2(IN_2),.OUT_INV(inv_out));


endmodule

