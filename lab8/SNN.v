// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
	`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on

module SNN(
           // Input signals
           clk,
           rst_n,
           cg_en,
           in_valid,
           img,
           ker,
           weight,

           // Output signals
           out_valid,
           out_data
       );

input clk;
input rst_n;
input in_valid;
input cg_en;
input [7:0] img;
input [7:0] ker;
input [7:0] weight;

output reg out_valid;
output reg [9:0] out_data;

//==============================================//
//       parameter & integer declaration        //
//==============================================//


//==============================================//
//           reg & wire declaration             //
//==============================================//
reg [7:0] in_m [0:13];
reg [7:0] ker_m [0:8];
reg [7:0] weight_m [0:3];
reg [19:0] conv_m [0:5];
reg [7:0] quan1_m [0:4];
reg [7:0] max_m[0:1];

reg  [7:0] fc_quan_m[0:3];
reg [8:0] L1_m;
reg [9:0] act;
reg [6:0] counter;
genvar idx;
wire in_ctrl[0:13];
wire k_ctrl[0:8];
wire conv_ctrl[0:15];
wire quan1_ctrl [0:4];
wire max_ctrl[0:1];

wire fc_quan_ctrl[0:3];
wire L1_ctrl;

reg [7:0] m[0:8];
reg [7:0] maxup,maxdown;
//==============================================//
//                 GATED_OR                     //
//==============================================//
assign in_ctrl[0]= counter==0 || counter==14 || counter==28 || counter==36 || counter==50 || counter==64;
assign in_ctrl[1]= counter==1 || counter==15 || counter==29 || counter==37 || counter==51 || counter==65;
assign in_ctrl[2]= counter==2 || counter==16 || counter==30 || counter==38 || counter==52 || counter==66;
assign in_ctrl[3]= counter==3 || counter==17 || counter==31 || counter==39 || counter==53 || counter==67;
assign in_ctrl[4]= counter==4 || counter==18 || counter==32 || counter==40 || counter==54 || counter==68;
assign in_ctrl[5]= counter==5 || counter==19 || counter==33 || counter==41 || counter==55 || counter==69;
assign in_ctrl[6]= counter==6 || counter==20 || counter==34 || counter==42 || counter==56 || counter==70;
assign in_ctrl[7]= counter==7 || counter==21                || counter==43 || counter==57 ;
assign in_ctrl[8]= counter==8 || counter==22                || counter==44 || counter==58 ;
assign in_ctrl[9]= counter==9 || counter==23                || counter==45 || counter==59 ;
assign in_ctrl[10]= counter==10 || counter==24                || counter==46 || counter==60 ;
assign in_ctrl[11]= counter==11 || counter==25                || counter==47 || counter==61 ;
assign in_ctrl[12]= counter==12 || counter==26                || counter==48 || counter==62 ;
assign in_ctrl[13]= counter==13 || counter==27                || counter==49 || counter==63 ;
//assign in_ctrl[14]= counter==14 || counter==29                || counter==50 || counter==65 ;

assign k_ctrl[0] = counter==0;
assign k_ctrl[1] = counter==1;
assign k_ctrl[2] = counter==2;
assign k_ctrl[3] = counter==3;
assign k_ctrl[4] = counter==4;
assign k_ctrl[5] = counter==5;
assign k_ctrl[6] = counter==6;
assign k_ctrl[7] = counter==7;
assign k_ctrl[8] = counter==8;

assign conv_ctrl[0]=counter==14 || counter==50 || counter==26 ||counter==62;
assign conv_ctrl[1]=counter==15 || counter==51 || counter==27 ||counter==63;
assign conv_ctrl[2]=counter==16 || counter==52 || counter==28 ||counter==64;
assign conv_ctrl[3]=counter==17 || counter==53 || counter==29 ||counter==65;
assign conv_ctrl[4]=counter==20 || counter==56 || counter==22 ||counter==32 ||counter==34 ||counter==58||counter==68 ||counter==70 ;
assign conv_ctrl[5]=counter==21 || counter==57 || counter==23 ||counter==33 ||counter==35 ||counter==59||counter==69 ||counter==71 ;


assign quan1_ctrl[0]= counter==15 || counter==51 || counter==27||counter==63;
assign quan1_ctrl[1]= counter==16 || counter==52 || counter==28||counter==64;
assign quan1_ctrl[2]= counter==17 || counter==53 || counter==29||counter==65;
assign quan1_ctrl[3]= counter==18 || counter==54 || counter==30||counter==66;
assign quan1_ctrl[4]= counter==21 || counter==57 || counter==23 || counter==33 || counter==35 ||counter==59||counter==69 || counter==71;


assign max_ctrl[0]= counter==22 || counter==34 || counter==58 || counter==70;
assign max_ctrl[1]= counter==24 || counter==36 || counter==60 || counter==72;

assign fc_quan_ctrl[0]= counter== 25;
assign fc_quan_ctrl[1]= counter== 26;
assign fc_quan_ctrl[2]= counter== 37;
assign fc_quan_ctrl[3]= counter== 38;

assign L1_ctrl=  counter==61;
//==============================================//
//                  design                      //
//==============================================//
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        counter<=0;
    end
    else
    begin
        if(counter==0)
        begin
            if(in_valid)
                counter<=counter+1;
            else
                counter<=counter;
        end
        else if (counter==73)
            counter<=0;
        else
            counter<=counter+1;
    end
end
generate
    for(idx=0;idx<14;idx=idx+1)
    begin:in_level
        GATED_OR GATED_in(.CLOCK(clk), .SLEEP_CTRL(!in_ctrl[idx] & cg_en), .RST_N(rst_n), .CLOCK_GATED(in_glck));
        always @(posedge in_glck)begin
            if(in_ctrl[idx])
            begin
                in_m[idx]<=img;
            end
        end
    end
endgenerate
generate
    for(idx=0;idx<4;idx=idx+1)
    begin:k1_level
        GATED_OR GATED_k_in(.CLOCK(clk), .SLEEP_CTRL(!k_ctrl[idx] & cg_en), .RST_N(rst_n), .CLOCK_GATED(k_glck));
        always @(posedge k_glck)begin
            if(k_ctrl[idx])
            begin
                ker_m[idx]<=ker;
                weight_m[idx]<=weight;
            end
        end
    end
endgenerate
generate
    for(idx=4;idx<9;idx=idx+1)
    begin:k2_level
        GATED_OR GATED_k_in(.CLOCK(clk), .SLEEP_CTRL(!k_ctrl[idx] & cg_en), .RST_N(rst_n), .CLOCK_GATED(k_glck));
        always @(posedge k_glck)begin
            if(k_ctrl[idx])
            begin
                ker_m[idx]<=ker;
            end
        end
    end
endgenerate

generate
    for(idx=0;idx<6;idx=idx+1)
    begin:conv_level
        GATED_OR GATED_conv(.CLOCK(clk), .SLEEP_CTRL(!conv_ctrl[idx] & cg_en), .RST_N(rst_n), .CLOCK_GATED(conv_glck));
        always @(posedge conv_glck)begin
            if(conv_ctrl[idx])
            begin
                conv_m[idx]<=m[0]*ker_m[0]+m[1]*ker_m[1]+m[2]*ker_m[2]+m[3]*ker_m[3]+m[4]*ker_m[4]+m[5]*ker_m[5]+m[6]*ker_m[6]+m[7]*ker_m[7]+m[8]*ker_m[8];
            end
        end
    end
endgenerate
always @(*) begin
    case (counter)
        14,50: m[0]=in_m[0];
        15,51: m[0]=in_m[1];
        16,52: m[0]=in_m[2];
        17,53: m[0]=in_m[3];
        20,56: m[0]=in_m[6];
        21,57: m[0]=in_m[7];
        22,58: m[0]=in_m[8];
        23,59: m[0]=in_m[9];
        26,62: m[0]=in_m[12];
        27,63: m[0]=in_m[13];
        28,64: m[0]=in_m[0];
        29,65: m[0]=in_m[1];
        32,68: m[0]=in_m[4];
        33,69: m[0]=in_m[5];
        34,70: m[0]=in_m[6];
        35,71: m[0]=in_m[7];
        /*31,32,67,68: m[0]=max_m[0];
        39,40,75,76: m[0]=max_m[2];*/
        default:m[0]=0;
    endcase
end
always @(*) begin
    case (counter)
        14,50: m[1]=in_m[1];
        15,51: m[1]=in_m[2];
        16,52: m[1]=in_m[3];
        17,53: m[1]=in_m[4];
        20,56: m[1]=in_m[7];
        21,57: m[1]=in_m[8];
        22,58: m[1]=in_m[9];
        23,59: m[1]=in_m[10];
        26,62: m[1]=in_m[13];
        27,63: m[1]=in_m[0];
        28,64: m[1]=in_m[1];
        29,65: m[1]=in_m[2];
        32,68: m[1]=in_m[5];
        33,69: m[1]=in_m[6];
        34,70: m[1]=in_m[7];
        35,71: m[1]=in_m[8];
        /*31,32,67,68: m[1]=max_m[1];
        39,40,75,76: m[1]=max_m[3];*/
        default:m[1]=0;
    endcase
end
always @(*) begin
    case (counter)
        14,50: m[2]=in_m[2];
        15,51: m[2]=in_m[3];
        16,52: m[2]=in_m[4];
        17,53: m[2]=in_m[5];
        20,56: m[2]=in_m[8];
        21,57: m[2]=in_m[9];
        22,58: m[2]=in_m[10];
        23,59: m[2]=in_m[11];
        26,62: m[2]=in_m[0];
        27,63: m[2]=in_m[1];
        28,64: m[2]=in_m[2];
        29,65: m[2]=in_m[3];
        32,68: m[2]=in_m[6];
        33,69: m[2]=in_m[7];
        34,70: m[2]=in_m[8];
        35,71: m[2]=in_m[9];
        default:m[2]=0;
    endcase
end
always @(*) begin
    case (counter)
        14,50: m[3]=in_m[6];
        15,51: m[3]=in_m[7];
        16,52: m[3]=in_m[8];
        17,53: m[3]=in_m[9];
        20,56: m[3]=in_m[12];
        21,57: m[3]=in_m[13];
        22,58: m[3]=in_m[0];
        23,59: m[3]=in_m[1];
        26,62: m[3]=in_m[4];
        27,63: m[3]=in_m[5];
        28,64: m[3]=in_m[6];
        29,65: m[3]=in_m[7];
        32,68: m[3]=in_m[10];
        33,69: m[3]=in_m[11];
        34,70: m[3]=in_m[12];
        35,71: m[3]=in_m[13];
        default:m[3]=0;
    endcase
end
always @(*) begin
    case (counter)
        14,50: m[4]=in_m[7];
        15,51: m[4]=in_m[8];
        16,52: m[4]=in_m[9];
        17,53: m[4]=in_m[10];
        20,56: m[4]=in_m[13];
        21,57: m[4]=in_m[0];
        22,58: m[4]=in_m[1];
        23,59: m[4]=in_m[2];
        26,62: m[4]=in_m[5];
        27,63: m[4]=in_m[6];
        28,64: m[4]=in_m[7];
        29,65: m[4]=in_m[8];
        32,68: m[4]=in_m[11];
        33,69: m[4]=in_m[12];
        34,70: m[4]=in_m[13];
        35,71: m[4]=in_m[0];
        default:m[4]=0;
    endcase
end
always @(*) begin
    case (counter)
        14,50: m[5]=in_m[8];
        15,51: m[5]=in_m[9];
        16,52: m[5]=in_m[10];
        17,53: m[5]=in_m[11];
        20,56: m[5]=in_m[0];
        21,57: m[5]=in_m[1];
        22,58: m[5]=in_m[2];
        23,59: m[5]=in_m[3];
        26,62: m[5]=in_m[6];
        27,63: m[5]=in_m[7];
        28,64: m[5]=in_m[8];
        29,65: m[5]=in_m[9];
        32,68: m[5]=in_m[12];
        33,69: m[5]=in_m[13];
        34,70: m[5]=in_m[0];
        35,71: m[5]=in_m[1];
        default:m[5]=0;
    endcase
end
always @(*) begin
    case (counter)
        14,50: m[6]=in_m[12];
        15,51: m[6]=in_m[13];
        16,52: m[6]=in_m[0];
        17,53: m[6]=in_m[1];
        20,56: m[6]=in_m[4];
        21,57: m[6]=in_m[5];
        22,58: m[6]=in_m[6];
        23,59: m[6]=in_m[7];
        26,62: m[6]=in_m[10];
        27,63: m[6]=in_m[11];
        28,64: m[6]=in_m[12];
        29,65: m[6]=in_m[13];
        32,68: m[6]=in_m[2];
        33,69: m[6]=in_m[3];
        34,70: m[6]=in_m[4];
        35,71: m[6]=in_m[5];
        default:m[6]=0;
    endcase
end
always @(*) begin
    case (counter)
        14,50: m[7]=in_m[13];
        15,51: m[7]=in_m[0];
        16,52: m[7]=in_m[1];
        17,53: m[7]=in_m[2];
        20,56: m[7]=in_m[5];
        21,57: m[7]=in_m[6];
        22,58: m[7]=in_m[7];
        23,59: m[7]=in_m[8];
        26,62: m[7]=in_m[11];
        27,63: m[7]=in_m[12];
        28,64: m[7]=in_m[13];
        29,65: m[7]=in_m[0];
        32,68: m[7]=in_m[3];
        33,69: m[7]=in_m[4];
        34,70: m[7]=in_m[5];
        35,71: m[7]=in_m[6];
        default:m[7]=0;
    endcase
end
always @(*) begin
    m[8]=img;
end

generate
    for(idx=0;idx<5;idx=idx+1)
    begin:quan1_level
        GATED_OR GATED_quan1(.CLOCK(clk), .SLEEP_CTRL(!quan1_ctrl[idx] & cg_en), .RST_N(rst_n), .CLOCK_GATED(quan1_glck));
        always @(posedge quan1_glck)begin
            if(quan1_ctrl[idx])
            begin
                quan1_m[idx]<=conv_m[idx]/2295;
            end
        end
    end
endgenerate

generate
    for(idx=0;idx<2;idx=idx+1)
    begin:max_level
        GATED_OR GATED_k_in(.CLOCK(clk), .SLEEP_CTRL(!max_ctrl[idx] & cg_en), .RST_N(rst_n), .CLOCK_GATED(max_glck));
        always @(posedge max_glck)begin
            if(max_ctrl[idx])
            begin
                max_m[idx]<=(maxup>maxdown) ? maxup : maxdown ;
            end
        end
    end
endgenerate
always @(*) begin
    case (counter)
        22,34,58,70: maxup=(quan1_m[0]>quan1_m[1]) ? quan1_m[0] : quan1_m[1] ;
        24,36,60,72: maxup=(quan1_m[2]>quan1_m[3]) ? quan1_m[2] : quan1_m[3] ;
        default: maxup=0;
    endcase
end
always @(*) begin
    if(max_ctrl[0]||max_ctrl[1])
        maxdown= ( quan1_m[4] > conv_m[5]/2295 ) ? quan1_m[4] : conv_m[5]/2295 ;
    else
        maxdown=0;
end
generate
    for(idx=0;idx<4;idx=idx+1)
    begin:fc_quan_level
        GATED_OR GATED_fc(.CLOCK(clk), .SLEEP_CTRL(!fc_quan_ctrl[idx] & cg_en), .RST_N(rst_n), .CLOCK_GATED(fc_quan_glck));
        reg [16:0]fc;
        always @(*) begin
            if(fc_quan_ctrl[idx])
            begin
                if (idx==0)
                begin
                    fc= max_m[0]*weight_m[0]+max_m[1]*weight_m[2] ;
                end
                else if(idx==1)
                begin
                    fc= max_m[0]*weight_m[1]+max_m[1]*weight_m[3];
                end
                else if(idx==2)
                begin
                    fc= max_m[0]*weight_m[0]+max_m[1]*weight_m[2];
                end
                else
                    fc= max_m[0]*weight_m[1]+max_m[1]*weight_m[3];
            end
            else
                fc=0;
        end
        always @(posedge fc_quan_glck)begin
            if(fc_quan_ctrl[idx])
            begin
                fc_quan_m[idx]<= fc /510;
            end
        end
    end
endgenerate
reg [16:0] fc_idx0,fc_idx1;
reg [7:0] L1_idx0,L1_idx1,L2_idx0,L2_idx1;
always @(*) begin
    if(L1_ctrl)
    begin
        L1_idx0=fc_quan_m[0];
        L1_idx1=fc_quan_m[1];
    end
    else if (counter==73)
    begin
        L1_idx0=fc_quan_m[2];
        L1_idx1=fc_quan_m[3];
    end
    else
    begin
        L1_idx0=0;
        L1_idx1=0;
    end
end
always @(*) begin
    if(counter==61||counter==73)
    begin
        fc_idx0=max_m[0]*weight_m[0]+max_m[1]*weight_m[2];
        fc_idx1=max_m[0]*weight_m[1]+max_m[1]*weight_m[3];
    end
    else
    begin
        fc_idx0=0;
        fc_idx1=0;
    end

end
always @(*) begin
    L2_idx0= fc_idx0/510;
    L2_idx1=fc_idx1/510;
end


GATED_OR GATED_L1(.CLOCK(clk), .SLEEP_CTRL(!L1_ctrl & cg_en), .RST_N(rst_n), .CLOCK_GATED(L1_glck));
always @(posedge L1_glck)begin
    if(L1_ctrl)
    begin
        if(L1_idx0 > L2_idx0)
        begin
            if(L1_idx1>L2_idx1)
                L1_m<= L1_idx0-L2_idx0 + L1_idx1-L2_idx1;
            else
                L1_m<=  L1_idx0-L2_idx0 + L2_idx1-L1_idx1;
        end
        else
        begin
            if(L2_idx1>L1_idx1)
                L1_m<= L2_idx0-L1_idx0 + L2_idx1-L1_idx1;
            else
                L1_m<= L2_idx0-L1_idx0 + L1_idx1-L2_idx1;
        end
    end
end
reg [9:0] ans;
always @(*) begin
    if(counter==73)
    begin
        if(L1_idx0 > L2_idx0)
        begin
            if(L1_idx1>L2_idx1)
                ans=L1_m+ L1_idx0-L2_idx0 + L1_idx1-L2_idx1;
            else
                ans=L1_m+  L1_idx0-L2_idx0 + L2_idx1-L1_idx1;
        end
        else
        begin
            if(L2_idx1>L1_idx1)
                ans=L1_m+ L2_idx0-L1_idx0 + L2_idx1-L1_idx1;
            else
                ans=L1_m+ L2_idx0-L1_idx0 + L1_idx1-L2_idx1;
        end
    end
    else
        ans=0;
end

always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        out_data<=0;
        out_valid<=0;
    end
    else
    begin
        if(counter==73)
        begin
            if(ans<16)
            begin
                out_data<=0;
                out_valid<=1;
            end
            else
            begin
                out_data<=ans;
                out_valid<=1;
            end
        end
        else
        begin
            out_data<=0;
            out_valid<=0;
        end
    end
end
endmodule
