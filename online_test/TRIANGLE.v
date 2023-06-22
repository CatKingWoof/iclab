//synopsys translate_off
`include "DW_div.v"
`include "DW_div_seq.v"
`include "DW_div_pipe.v"
//synopsys translate_on

module TRIANGLE(
    clk,
    rst_n,
    in_valid,
    in_length,
    out_cos,
    out_valid,
    out_tri
);
input wire clk, rst_n, in_valid;
input wire [7:0] in_length;

output reg out_valid;
output reg [15:0] out_cos;
output reg [1:0] out_tri;

reg [6:0] count;
reg [7:0] a,b,c;
reg [17:0] ya1,xa1,yb1,xb1,yc1,xc1;
reg[30:0] ya2,yb2,yc2; 
wire [30:0] a_out,b_out,c_out;
reg [30:0] za,zb,zc;
reg h,s;
//FSM
always@(posedge clk or negedge rst_n)begin
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
		else if(count==27)
			count<=0;
		else
		begin
			count<=count+1;
		end
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
	begin
		a<=0;
	end
	else
	begin
		if(count==0&&in_valid)
			a<=in_length;
		else
			a<=a;
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
	begin
		b<=0;
	end
	else
	begin
		if(count==1)
			b<=in_length;
		else
			b<=b;
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
	begin
		c<=0;
	end
	else
	begin
		if(count==2)
			c<=in_length;
		else
			c<=c;
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
	begin
		ya1<=0;
	end
	else
	begin
		if(count==3)
			ya1<=b*b+c*c-a*a;
		else
			ya1<=ya1;
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
	begin
		xa1<=0;
	end
	else
	begin
		if(count==3)
			xa1<=2*b*c;
		else
			xa1<=xa1;
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
	begin
		yb1<=0;
	end
	else
	begin
		if(count==3)
			yb1<=a*a+c*c-b*b;
		else
			yb1<=yb1;
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
	begin
		xb1<=0;
	end
	else
	begin
		if(count==3)
			xb1<=2*a*c;
		else
			xb1<=xb1;
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
	begin
		yc1<=0;
	end
	else
	begin
		if(count==3)
			yc1<=a*a+b*b-c*c;
		else
			yc1<=yc1;
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
	begin
		xc1<=0;
	end
	else
	begin
		if(count==3)
			xc1<=2*a*b;
		else
			xc1<=xc1;
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
	begin
		ya2<=0;
	end
	else
	begin
		if(count==4)
			ya2<=ya1<<13;
		else
			ya2<=ya2;
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
	begin
		yb2<=0;
	end
	else
	begin
		if(count==4)
			yb2<=yb1<<13;
		else
			yb2<=yb2;
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
	begin
		yc2<=0;
	end
	else
	begin
		if(count==4)
			yc2<=yc1<<13;
		else
			yc2<=yc2;
	end
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		h<=0;
	else
		h<=0;
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		s<=0;
	else if(count==4)
		s<=1;
	else
		s<=0;
end
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
	begin
		za<=0;
		zb<=0;
		zc<=0;
	end
	else if(count==21)
	begin
		za<=a_out;
		zb<=b_out;
		zc<=c_out;
	end
	else
	begin
		za<=za;
		zb<=zb;
		zc<=zc;
	end
end
reg[15:0] za2,zb2,zc2;
reg [1:0] ot;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
	begin
		za2<=0;
		zb2<=0;
		zc2<=0;
	end
	else if(count==22)
	begin
		za2<={za[30],za[14:0]};
		zb2<={zb[30],zb[14:0]};
		zc2<={zc[30],zc[14:0]};
	end
	else
	begin
		za2<=za2;
		zb2<=zb2;
		zc2<=zc2;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
	begin
		ot<=0;
	end
	else
	begin
		if(count==23)
		begin
			if(za2==0||zb2==0||zc2==0)
				ot<=2'b11;
			else if(za2[15]||zb2[15]||zc2[15])
				ot<=2'b01;
			else
				ot<=2'b00;
		end
		else
			ot<=ot;
	end
end


always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
	begin
		out_valid<=0;
		out_tri<=0;
		out_cos<=0;
	end
	else
	begin
		if(count==24)
		begin
			out_valid<=1;
			out_tri<=ot;
			out_cos<=za2;
		end
		else if(count==25)
		begin
			out_valid<=1;
			out_tri<=0;
			out_cos<=zb2;
		end
		else if(count==26)
		begin
			out_valid<=1;
			out_tri<=0;
			out_cos<=zc2;
		end
		else if(count==27)
		begin
			out_valid<=0;
			out_tri<=0;
			out_cos<=0;
		end
		else
		begin
			out_valid<=out_valid;
			out_tri<=out_tri;
			out_cos<=out_cos;
		end
	end
end
   
DW_div_seq #(.a_width(31),.b_width(18),.tc_mode(1),.num_cyc(15)) div_a (.clk(clk),.rst_n(rst_n),.hold(h),.start(s),.a(ya2),.b(xa1),.quotient(a_out));

DW_div_seq #(.a_width(31),.b_width(18),.tc_mode(1),.num_cyc(15)) div_b (.clk(clk),.rst_n(rst_n),.hold(h),.start(s),.a(yb2),.b(xb1),.quotient(b_out));

DW_div_seq #(.a_width(31),.b_width(18),.tc_mode(1),.num_cyc(15)) div_c (.clk(clk),.rst_n(rst_n),.hold(h),.start(s),.a(yc2),.b(xc1),.quotient(c_out));
endmodule
