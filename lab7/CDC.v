`include "AFIFO.v"

module CDC #(parameter DSIZE = 8,
             parameter ASIZE = 4)(
           //Input Port
           rst_n,
           clk1,
           clk2,
           in_valid,
           doraemon_id,
           size,
           iq_score,
           eq_score,
           size_weight,
           iq_weight,
           eq_weight,
           //Output Port
           ready,
           out_valid,
           out,

       );
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
output reg  [7:0] out;
output reg	out_valid,ready;

input rst_n, clk1, clk2, in_valid;
input  [4:0]doraemon_id;
input  [7:0]size;
input  [7:0]iq_score;
input  [7:0]eq_score;
input [2:0]size_weight,iq_weight,eq_weight;
reg [2:0] in_flag;
reg [2:0] count1;
reg [DSIZE - 1: 0] wdata1;
wire [DSIZE - 1: 0] rdata1;
wire winc,rinc;
wire wfull_1,rempty_1;
wire finish;
reg [4:0] id0,id1,id2,id3,id4;
reg [7:0]  iq0,iq1,iq2,iq3,iq4, eq0,eq1,eq2,eq3,eq4, size0,size1,size2,size3,size4;
reg [2:0] size_w,iq_w,eq_w;
wire[12:0] big_34,big_12,big_1234;
wire [2:0] big_id_34,big_id_12,big_id_1234,bigest_id;
reg [7:0] out_buffer;
reg [12:0] pat_count,out_count;
reg out_enable;
//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
always @(posedge clk1 or negedge rst_n)begin
    if (!rst_n)
    begin
        count1<=0;
    end
    else
    begin
        if(count1==0)
        begin
            if(in_flag==4)
                count1<= count1+1;
        end
        else
            count1<=1;

    end
end
always @(posedge clk1 or negedge rst_n)begin
    if (!rst_n)
    begin
        pat_count<=0;
    end
    else
    begin
        if(in_valid||pat_count==6000)
            pat_count<=pat_count+1;
    end
end

always @(posedge clk1 or negedge rst_n)begin
    if (!rst_n)
    begin
        in_flag<=0;
    end
    else
    begin
        if(in_valid&&in_flag<4)
            in_flag<=in_flag+1;
    end
end
always @(posedge clk1 /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        size_w<=0;
        iq_w<=0;
        eq_w<=0;
    end
    else*/
    begin
        if(count1==0&&in_flag==4 || count1==1&&in_valid)
        begin
            size_w<=size_weight;
            iq_w<=iq_weight;
            eq_w<=eq_weight;
        end
    end
end
always @(posedge clk1 /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        id0<=0;
        size0<=0;
        iq0<=0;
        eq0<=0;
    end
    else*/
    begin
        if(count1==0&&in_valid)
        begin
            id0<=id1;
            size0<=size1;
            iq0<=iq1;
            eq0<=eq1;
        end
        else if (count1==1&&bigest_id==0&&in_valid)
        begin
            id0<=doraemon_id;
            size0<=size;
            iq0<=iq_score;
            eq0<=eq_score;
        end

    end
end
always @(posedge clk1 /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        id1<=0;
        size1<=0;
        iq1<=0;
        eq1<=0;
    end
    else*/
    begin
        if(count1==0&&in_valid)
        begin
            id1<=id2;
            size1<=size2;
            iq1<=iq2;
            eq1<=eq2;
        end
        else if (count1==1&&bigest_id==1&&in_valid)
        begin
            id1<=doraemon_id;
            size1<=size;
            iq1<=iq_score;
            eq1<=eq_score;
        end
    end
end
always @(posedge clk1 /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        id2<=0;
        size2<=0;
        id2<=0;
        eq2<=0;
    end
    else*/
    begin
        if(count1==0&&in_valid)
        begin
            id2<=id3;
            size2<=size3;
            iq2<=iq3;
            eq2<=eq3;
        end
        else if (count1==1&&bigest_id==2&&in_valid)
        begin
            id2<=doraemon_id;
            size2<=size;
            iq2<=iq_score;
            eq2<=eq_score;
        end
    end
end
always @(posedge clk1 /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        id3<=0;
        size3<=0;
        id3<=0;
        eq3<=0;
    end
    else*/
    begin
        if(count1==0&&in_valid)
        begin
            id3<=id4;
            size3<=size4;
            iq3<=iq4;
            eq3<=eq4;
        end
        else if (count1==1&&bigest_id==3&&in_valid)
        begin
            id3<=doraemon_id;
            size3<=size;
            iq3<=iq_score;
            eq3<=eq_score;
        end
    end
end
always @(posedge clk1 /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        id4<=0;
        size4<=0;
        id4<=0;
        eq4<=0;
    end
    else*/
    begin
        if(count1==0&&in_valid)
        begin
            id4<=doraemon_id;
            size4<=size;
            iq4<=iq_score;
            eq4<=eq_score;
        end
        else if (count1==1&&bigest_id==4&&in_valid)
        begin
            id4<=doraemon_id;
            size4<=size;
            iq4<=iq_score;
            eq4<=eq_score;
        end
    end
end
wire [12:0] p0,p1,p2,p3,p4;
assign p0=size0*size_w+iq0*iq_w+eq0*eq_w;
assign p1=size1*size_w+iq1*iq_w+eq1*eq_w;
assign p2=size2*size_w+iq2*iq_w+eq2*eq_w;
assign p3=size3*size_w+iq3*iq_w+eq3*eq_w;
assign p4=size4*size_w+iq4*iq_w+eq4*eq_w;

assign big_12 = (p1<p2) ? p2 : p1;
assign big_34=  (p3<p4) ? p4 : p3;
assign big_1234=  (big_12<big_34) ? big_34 : big_12;

assign big_id_12=  (p1<p2) ? 2 : 1;
assign big_id_34 = (p3<p4) ? 4 : 3;
assign big_id_1234 =(big_12<big_34) ? big_id_34 : big_id_12;

assign bigest_id = (p0<big_1234) ? big_id_1234 : 0;

assign rinc=~rempty_1;
assign winc=(count1&&in_valid||pat_count==6000);

always @(*) begin
    begin
        case (bigest_id)
            0: wdata1={bigest_id,id0};
            1: wdata1={bigest_id,id1};
            2: wdata1={bigest_id,id2};
            3: wdata1={bigest_id,id3};
            4: wdata1={bigest_id,id4};
            default: wdata1={bigest_id,id0};
        endcase
    end

end

AFIFO AFIFO_bigest(
          .rclk(clk2),
          .rinc(rinc),
          .rempty(rempty_1),
          .wclk(clk1),
          .winc(winc),
          .wfull(wfull_1),
          .rst_n(rst_n),
          .rdata(rdata1),
          .wdata(wdata1)
      );

always @(*)begin
    if(!rst_n)
        ready=0;
    else if(wfull_1||pat_count>6000)
        ready=0;
    else
        ready=1;
end
always @(posedge clk2 or negedge rst_n)begin
    if (!rst_n)
    begin
        out_valid<=0;
        out<=0;
    end
    else
    begin
        if(rinc)
        begin
            out_valid<=1;
            out<=rdata1;
        end
        else
        begin
            out_valid<=0;
            out<=0;
        end
    end
end
endmodule
