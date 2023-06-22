//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright Optimum Application-Specific Integrated System Laboratory
//    All Right Reserved
//		Date		: 2023/03
//		Version		: v1.0
//   	File Name   : INV_IP.v
//   	Module Name : INV_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module INV_IP #(parameter IP_WIDTH = 6) (
    // Input signals
    IN_1, IN_2,
    // Output signals
    OUT_INV
);

// ===============================================================
// Declaration
// ===============================================================
input  [IP_WIDTH-1:0] IN_1, IN_2;
output [IP_WIDTH-1:0] OUT_INV;
genvar idx;
wire signed [IP_WIDTH:0] lv_out,w7_lv_out;
wire [IP_WIDTH-1:0] big_in,small_in;
assign big_in=(IN_1>IN_2)? IN_1 : IN_2;
assign small_in=(IN_1>IN_2)? IN_2 : IN_1;
generate

	if(IP_WIDTH==6)begin :w6
		for(idx=1;idx<=IP_WIDTH+1;idx=idx+1)begin:level

				if(idx==1)begin:lv_1
					wire [5:0] a;
					wire [5:0] b;
					wire [4:0] q;
					wire [4:0] r;
					wire signed [5:0]t1;
					wire signed [5:0]t2;
					wire signed [5:0] t3;
					assign a=big_in;
					assign b=small_in;
					assign q=a/b;
					assign r=a%b;
					assign t1=0;
					assign t2=1;
					assign t3=t1-t2*q;
				end
				else if(idx==2)begin:lv_2
					wire [5:0] a;
					wire [4:0] b;
					wire [4:0] q;
					wire [4:0] r;
					wire signed [5:0]t1;
					wire signed [5:0]t2;
					wire signed [5:0] t3;
					assign a=w6.level[idx-1].lv_1.b;
					assign b=(w6.level[idx-1].lv_1.r==0) ? 1 : w6.level[idx-1].lv_1.r;
					assign q=a/b;
					assign r=a%b;
					assign t1=w6.level[idx-1].lv_1.t2;
					assign t2=(w6.level[idx-1].lv_1.r==0) ? w6.level[idx-1].lv_1.t2 : w6.level[idx-1].lv_1.t3;
					assign t3=t1-t2*q;
					
				end
				else if(idx==3)begin:lv_3
					wire [4:0] a;
					wire [4:0] b;
					wire [3:0] q;
					wire [3:0] r;
					wire signed [5:0]t1;
					wire signed [5:0]t2;
					wire signed [5:0] t3;
					assign a=w6.level[idx-1].lv_2.b;
					assign b=(w6.level[idx-1].lv_2.r==0) ? 1 : w6.level[idx-1].lv_2.r;
					assign q=a/b;
					assign r=a%b;
					assign t1=w6.level[idx-1].lv_2.t2;
					assign t2=(w6.level[idx-1].lv_2.r==0) ? w6.level[idx-1].lv_2.t2 : w6.level[idx-1].lv_2.t3;
					assign t3=t1-t2*q;
				end
				else if(idx==4)begin:lv_4
					wire [4:0] a;
					wire [3:0] b;
					wire [3:0] q;
					wire [2:0] r;
					wire signed [5:0]t1;
					wire signed [5:0]t2;
					wire signed [5:0] t3;
					assign a=w6.level[idx-1].lv_3.b;
					assign b=(w6.level[idx-1].lv_3.r==0) ? 1 : w6.level[idx-1].lv_3.r;
					assign q=a/b;
					assign r=a%b;
					assign t1=w6.level[idx-1].lv_3.t2;
					assign t2=(w6.level[idx-1].lv_3.r==0) ? w6.level[idx-1].lv_3.t2 : w6.level[idx-1].lv_3.t3;
					assign t3=t1-t2*q;
				end
				else if(idx==5)begin:lv_5
					wire [3:0] a;
					wire [2:0] b;
					wire [2:0] q;
					wire [1:0] r;
					wire signed [5:0]t1;
					wire signed [5:0]t2;
					wire signed [5:0] t3;
					assign a=w6.level[idx-1].lv_4.b;
					assign b=(w6.level[idx-1].lv_4.r==0) ? 1 : w6.level[idx-1].lv_4.r;
					assign q=a/b;
					assign r=a%b;
					assign t1=w6.level[idx-1].lv_4.t2;
					assign t2=(w6.level[idx-1].lv_4.r==0) ? w6.level[idx-1].lv_4.t2 : w6.level[idx-1].lv_4.t3;
					assign t3=t1-t2*q;
				end
				else if(idx==6)begin:lv_6
					wire [2:0] a;
					wire [1:0] b;
					wire [1:0] q;
					wire  r;
					wire signed [5:0]t1;
					wire signed [5:0]t2;
					wire signed [5:0] t3;
					assign a=w6.level[idx-1].lv_5.b;
					assign b=(w6.level[idx-1].lv_5.r==0) ? 1 : w6.level[idx-1].lv_5.r;
					assign q=a/b;
					assign r=a%b;
					assign t1=w6.level[idx-1].lv_5.t2;
					assign t2=(w6.level[idx-1].lv_5.r==0) ? w6.level[idx-1].lv_5.t2 : w6.level[idx-1].lv_5.t3;
					assign t3=t1-t2*q;
				end
				else if(idx==7)begin:lv_7
					wire [1:0] a;
					wire  b;
					wire  q;
					wire r;
					wire signed [5:0]t1;
					wire signed [5:0]t2;
					wire signed [5:0] t3;
					assign a=w6.level[idx-1].lv_6.b;
					assign b=(w6.level[idx-1].lv_6.r==0) ? 1 : w6.level[idx-1].lv_6.r;
					assign q=a/b;
					assign r=a%b;
					assign t1=w6.level[idx-1].lv_6.t2;
					assign t2=(w6.level[idx-1].lv_6.r==0) ? w6.level[idx-1].lv_6.t2 : w6.level[idx-1].lv_6.t3;
					assign t3=t1-t2*q;
					assign lv_out=t2;
				end
		end
	end
	else  if(IP_WIDTH==5||IP_WIDTH==7)begin :w7
			for(idx=1;idx<=IP_WIDTH+2;idx=idx+1)begin:level
				wire [IP_WIDTH-1:0] a,b,r,q;
				wire signed [IP_WIDTH*IP_WIDTH-1:0] t1,t2,t3;
				if(idx==1)begin:lv_1
					assign w7.level[idx].a=big_in;
					assign w7.level[idx].b=small_in;
					assign w7.level[idx].q=w7.level[idx].a/w7.level[idx].b;
					assign w7.level[idx].r=w7.level[idx].a%w7.level[idx].b;
					assign w7.level[idx].t1=0;
					assign w7.level[idx].t2=1;
					assign w7.level[idx].t3=w7.level[idx].t1-w7.level[idx].t2*w7.level[idx].q;
				end
				else begin:lv
					assign w7.level[idx].a=w7.level[idx-1].b;
					assign w7.level[idx].b=(w7.level[idx-1].r==0) ? 1 : w7.level[idx-1].r;
					assign w7.level[idx].q=w7.level[idx].a/w7.level[idx].b;
					assign w7.level[idx].r=w7.level[idx].a%w7.level[idx].b;
					assign w7.level[idx].t1=w7.level[idx-1].t2;
					assign w7.level[idx].t2=(w7.level[idx-1].r==0) ? w7.level[idx-1].t2 : w7.level[idx-1].t3;
					assign w7.level[idx].t3=w7.level[idx].t1-w7.level[idx].t2*w7.level[idx].q;
				end
				if(idx==IP_WIDTH+2)
					assign w7_lv_out=w7.level[idx].t2;
			end
	end
endgenerate


assign OUT_INV =(IP_WIDTH==6) ?((lv_out[IP_WIDTH]) ? lv_out+big_in: lv_out)
			      :((w7_lv_out[IP_WIDTH]) ? w7_lv_out+big_in : w7_lv_out);
					
endmodule
