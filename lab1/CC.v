module CC(
           in_s0,
           in_s1,
           in_s2,
           in_s3,
           in_s4,
           in_s5,
           in_s6,
           opt,
           a,
           b,
           s_id0,
           s_id1,
           s_id2,
           s_id3,
           s_id4,
           s_id5,
           s_id6,
           out

       );
input [3:0]in_s0;
input [3:0]in_s1;
input [3:0]in_s2;
input [3:0]in_s3;
input [3:0]in_s4;
input [3:0]in_s5;
input [3:0]in_s6;
input [2:0]opt;
input [1:0]a;
input [2:0]b;
output [2:0] s_id0;
output [2:0] s_id1;
output [2:0] s_id2;
output [2:0] s_id3;
output [2:0] s_id4;
output [2:0] s_id5;
output [2:0] s_id6;
output [2:0] out;
//==================================================================
// reg & wire
//==================================================================
wire [7:0]in_0,in_1,in_2,in_3,in_4,in_5,in_6;
wire [7:0]sa[0:5],sb[0:1],sc[0:1],sd[0:1],se[0:3],sf[0:3],sg[0:5],sh[0:3],si[0:1];

//wire [4:0]pro_0,pro_1,pro_2,pro_3,pro_4,pro_5,pro_6;
wire signed [7:0] sum_score;
wire signed [4:0] sum[0:6];
wire signed [5:0] sum_cal;
reg [5:0] temp1[0:6];
reg signed [6:0] temp11[0:6];
reg signed [6:0] temp2[0:6];
//wire signed [6:0] new_score[0:6];
//wire [2:0] piyan,wenan,NL;
reg signed [3:0] temp[0:6];
//wire signed[3:0] t;
wire signed [2:0] aa ;
reg signed [3:0] bb;

wire count[0:6];
//==================================================================
// design
//==================================================================
//preprocess

assign in_0=(opt[1]) ? {(opt[0]&in_s0[3]),~in_s0,3'b000} : {~(opt[0]&in_s0[3]),in_s0,3'b000};
assign in_1=(opt[1]) ? {(opt[0]&in_s1[3]),~in_s1,3'b001} : {~(opt[0]&in_s1[3]),in_s1,3'b001};
assign in_2=(opt[1]) ? {(opt[0]&in_s2[3]),~in_s2,3'b010} : {~(opt[0]&in_s2[3]),in_s2,3'b010};
assign in_3=(opt[1]) ? {(opt[0]&in_s3[3]),~in_s3,3'b011} : {~(opt[0]&in_s3[3]),in_s3,3'b011};
assign in_4=(opt[1]) ? {(opt[0]&in_s4[3]),~in_s4,3'b100} : {~(opt[0]&in_s4[3]),in_s4,3'b100};
assign in_5=(opt[1]) ? {(opt[0]&in_s5[3]),~in_s5,3'b101} : {~(opt[0]&in_s5[3]),in_s5,3'b101};
assign in_6=(opt[1]) ? {(opt[0]&in_s6[3]),~in_s6,3'b110} : {~(opt[0]&in_s6[3]),in_s6,3'b110};

//sorting
assign sa[0]=(in_0>in_4) ? in_4 : in_0;
assign sa[3]=(in_0>in_4) ? in_0 : in_4;
assign sa[1]=(in_1>in_5) ? in_5 : in_1;
assign sa[4]=(in_1>in_5) ? in_1 : in_5;
assign sa[2]=(in_2>in_6) ? in_6 : in_2;
assign sa[5]=(in_2>in_6) ? in_2 : in_6;

assign sb[0]=(in_3>sa[3]) ? sa[3] : in_3;
assign sb[1]=(in_3>sa[3]) ? in_3 : sa[3];
assign sc[0]=(sb[1]>sa[4]) ? sa[4] : sb[1];
assign sc[1]=(sb[1]>sa[4]) ? sb[1] : sa[4];
assign sd[0]=(sc[1]>sa[5]) ? sa[5] : sc[1];
assign sd[1]=(sc[1]>sa[5]) ? sc[1] : sa[5];

assign se[0]=(sa[0]>sa[2]) ? sa[2] : sa[0];
assign se[2]=(sa[0]>sa[2]) ? sa[0] : sa[2];
assign se[1]=(sa[1]>sb[0]) ? sb[0] : sa[1];
assign se[3]=(sa[1]>sb[0]) ? sa[1] : sb[0];
assign sf[0]=(se[2]>sc[0]) ? sc[0] : se[2];
assign sf[2]=(se[2]>sc[0]) ? se[2] : sc[0];
assign sf[1]=(se[3]>sd[0]) ? sd[0] : se[3];
assign sf[3]=(se[3]>sd[0]) ? se[3] : sd[0];

assign sg[0]=(se[0]>se[1]) ? se[1] : se[0];
assign sg[1]=(se[0]>se[1]) ? se[0] : se[1];
assign sg[2]=(sf[0]>sf[1]) ? sf[1] : sf[0];
assign sg[3]=(sf[0]>sf[1]) ? sf[0] : sf[1];
assign sg[4]=(sf[2]>sf[3]) ? sf[3] : sf[2];
assign sg[5]=(sf[2]>sf[3]) ? sf[2] : sf[3];

assign sh[0]=(sg[1]>sg[2]) ? sg[2] : sg[1];
assign sh[1]=(sg[1]>sg[2]) ? sg[1] : sg[2];
assign sh[2]=(sg[3]>sg[4]) ? sg[4] : sg[3];
assign sh[3]=(sg[3]>sg[4]) ? sg[3] : sg[4];

assign si[0]=(sh[1]>sh[2]) ? sh[2] : sh[1];
assign si[1]=(sh[1]>sh[2]) ? sh[1] : sh[2];

//output order

assign s_id0=sg[0][2:0];
assign s_id1=sh[0][2:0];
assign s_id2=si[0][2:0];
assign s_id3=si[1][2:0];
assign s_id4=sh[3][2:0];
assign s_id5=sg[5][2:0];
assign s_id6=sd[1][2:0];



//pass score
assign sum[0]= {in_s0[3]&opt[0],in_s0};
assign sum[1]= {in_s1[3]&opt[0],in_s1};
assign sum[2]= {in_s2[3]&opt[0],in_s2};
assign sum[3]= {in_s3[3]&opt[0],in_s3};
assign sum[4]= {in_s4[3]&opt[0],in_s4};
assign sum[5]= {in_s5[3]&opt[0],in_s5};
assign sum[6]= {in_s6[3]&opt[0],in_s6};
assign sum_score=sum[0]+sum[1]+sum[2]+sum[3]+sum[4]+sum[5]+sum[6];
assign aa=a;
assign sum_cal=sum_score/7-aa-bb;
//transform score
integer idx;
always @(*) begin
    if(a==0)
    begin
        for(idx=0;idx<7;idx=idx+1)
        begin
            temp[idx]=sum[idx][3:0];
        end

    end
    else if(a==1)
    begin
        for (idx = 0; idx<7; idx=idx+1)
        begin
            if(sum[idx][0]==0)
            begin
                temp[idx]={1'b1,sum[idx][3:1]};
            end
            else
            begin
                temp[idx]=({1'b1,sum[idx][3:1]})+1;
            end

        end

    end
    else if (a==2)
    begin
        for (idx = 0; idx<7; idx=idx+1)
        begin
            case (sum[idx][3:0])
                4'b1111:temp[idx]=4'b0000;
                4'b1110:temp[idx]=4'b0000;
                4'b1101:temp[idx]=4'b1111;
                4'b1100:temp[idx]=4'b1111;
                4'b1011:temp[idx]=4'b1111;
                default:temp[idx]=4'b1110;
            endcase
        end
    end
    else
    begin
        for (idx = 0; idx<7; idx=idx+1) begin
            case (sum[idx][3:0])
                4'b1111:temp[idx]=4'b0000;
                4'b1110:temp[idx]=4'b0000;
                4'b1101:temp[idx]=4'b0000;
                4'b1000:temp[idx]=4'b1110;
                default: temp[idx]=4'b1111;
            endcase
        end
    end

    if(a==0)
    begin
        for (idx = 0; idx<7; idx=idx+1) begin
            temp1[idx]=sum[idx][3:0];
        end
    end
    else if(a==1)
    begin
        for (idx = 0; idx<7; idx=idx+1) begin
            temp1[idx]=sum[idx][3:0]<<1;
        end
    end
    else if(a==2)
    begin
        for (idx = 0; idx<7; idx=idx+1) begin
            temp1[idx]=sum[idx][3:0]+(sum[idx][3:0]<<1);
        end
    end
    else
    begin
        for (idx = 0; idx<7; idx=idx+1) begin
            temp1[idx]=sum[idx][3:0]<<2;
        end
    end

    bb=b;
    for (idx = 0; idx<7; idx=idx+1) begin
        temp11[idx]=temp1[idx];
    end
    for (idx = 0; idx<7; idx=idx+1) begin
        temp2[idx]=(sum[idx][4]) ? temp[idx] :temp11[idx];
    end

end

//cout the number of pass
assign  count[0]=(~(temp2[0]<sum_cal)^opt[2]) ? 1 : 0;
assign  count[1]=(~(temp2[1]<sum_cal)^opt[2]) ? 1 : 0;
assign  count[2]=(~(temp2[2]<sum_cal)^opt[2]) ? 1 : 0;
assign  count[3]=(~(temp2[3]<sum_cal)^opt[2]) ? 1 : 0;
assign  count[4]=(~(temp2[4]<sum_cal)^opt[2]) ? 1 : 0;
assign  count[5]=(~(temp2[5]<sum_cal)^opt[2]) ? 1 : 0;
assign  count[6]=(~(temp2[6]<sum_cal)^opt[2]) ? 1 : 0;
assign out = count[0]+count[1]+count[2]+count[3]+count[4]+count[5]+count[6];
endmodule
