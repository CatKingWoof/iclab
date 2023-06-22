module SUBWAY(
           //Input Port
           clk,
           rst_n,
           in_valid,
           init,
           in0,
           in1,
           in2,
           in3,
           //Output Port
           out_valid,
           out
       );


input clk, rst_n;
input in_valid;
input [1:0] init;
input [1:0] in0, in1, in2, in3;
output reg       out_valid;
output reg [1:0] out;


//==============================================//
//       parameter & integer declaration        //
//==============================================//
parameter IDLE ='d0 ,
          STEP0 ='d1,
          STEP1 ='d2,
          STEP2 ='d3,
          STEP3 ='d4,
          STEP4 ='d5,
          STEP5 ='d6,
          STEP6 ='d7,
          STEP7 ='d8,
          OUTPUT='d9;


//==============================================//
//           reg & wire declaration             //
//==============================================//
reg [3:0] current_state,next_state;
reg out_reg[0:62];
reg [1:0]set_row,next_row;
reg[2:0] inflag;
reg flag;
reg [2:0]round;
reg map2,map4,map6;
reg control4[0:7];
reg control7[0:6];
wire in_row[0:3];
assign in_row[0]=in0[0];
assign in_row[1]=in1[0];
assign in_row[2]=in2[0];
assign in_row[3]=in3[0];
//==============================================//
//                  design                      //
//==============================================//
//current_state
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) current_state <= IDLE;
    else  current_state <=next_state;
end
//next state
always @(*) begin
    if (!rst_n) next_state=IDLE;
    else begin
        case (current_state)
            IDLE:begin
                if(inflag==4)
                    next_state=STEP0;
                else
                    next_state=IDLE;
            end
            STEP0:next_state=STEP1;
            STEP1:next_state=STEP2;
            STEP2:next_state=STEP3;
            STEP3:next_state=STEP4;
            STEP4:next_state=STEP5;
            STEP5:next_state=STEP6;
            STEP6:next_state=STEP7;
            STEP7:begin
                if (round==3'd7) begin
                    next_state=OUTPUT;
                end
                else
                    next_state=STEP0;
            end
            OUTPUT:begin
                if (round==3'd7&&inflag==3'd6) begin
                    next_state=IDLE;
                end
                else
                    next_state=OUTPUT;
            end
            default:next_state=IDLE;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        inflag<=0;
        flag<=0;
    end
    else begin
        case (current_state)
            IDLE:begin
                if(in_valid)
                begin
                    inflag<=inflag+1;
                    flag<=1;
                end

            end
            STEP7:begin
                if(round==3'd7)
                    inflag<=inflag+1;
            end
            OUTPUT:begin
                if(round==3'd7&&inflag==3'd6)
                    inflag<=0;
                else
                    inflag<=inflag+1;

            end
            default:
            begin
                inflag<=0;
                flag<=0;
            end
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        round<=0;
    end
    else
    begin
        case (current_state)

            STEP7: begin
                round<=round+1;
            end
            OUTPUT:begin
                if(inflag==3'd7)
                    round<=round+1;
                else if(round==3'd7&&inflag==3'd6)
                    round<=0;
                else
                    round<=round;
            end

            default: round<=round;
        endcase
    end
end

always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)begin
        map2<=0;
        map4<=0;
        map6<=0;
    end
    else */begin
        case (current_state)
            IDLE:begin
                if(inflag==3'd2)
                    map2<=in_row[set_row];
                else
                    map2<=map2;
                if(inflag==3'd4)
                    map4<=in_row[set_row];
                else
                    map4<=map4;
            end
            STEP5:begin
                if(in_valid)
                begin
                    map2<=in_row[next_row];
                end
                else
                    map2<=map2;
            end
            STEP7:begin
                if(in_valid)
                begin
                    map4<=in_row[next_row];
                end
                else
                    map4<=map4;
            end
            STEP1:begin
                if(in_valid)
                begin
                    if(round==0)
                    begin
                        if(set_row==0||set_row==1)
                            map6<=in_row[1];
                        else
                            map6<=in_row[2];
                    end
                    else
                    begin
                        if(next_row==0||next_row==1)
                            map6<=in_row[1];
                        else
                            map6<=in_row[2];
                    end

                end
                else
                    map6<=map6;
            end

            default: begin
                map2<=map2;
                map4<=map4;
                map6<=map6;
            end
        endcase
    end
end

always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)begin
        next_row<=0;
    end
    else*/
    begin
        case (current_state)
            STEP3:begin
                if (in_valid) begin
                    if(in1==0)
                        next_row<=1;
                    else if(in2==0)
                        next_row<=2;
                    else if(in0==0)
                        next_row<=0;
                    else
                        next_row<=3;
                end
                else
                    next_row<=next_row;
            end
            default: next_row<=next_row;
        endcase
    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if (!rst_n) begin
        set_row<=0;
    end
    else */begin
        case (current_state)
            IDLE:begin
                if (in_valid&&!flag) begin
                    set_row<=init;
                end
                else
                    set_row<=set_row;
            end
            STEP7:begin
                set_row<=next_row;
            end
            default: begin
                set_row<=set_row;
            end
        endcase
    end
end
integer i;
always @(posedge clk /*or negedge rst_n*/) begin
    /*if (!rst_n) begin
        for(i=0;i<63;i=i+1)
        begin
            out_reg[i]<=0;
        end
    end
    else*/
    begin
        case (current_state)
            STEP0:begin
                out_reg[56]<=0;
                out_reg[48]<=out_reg[56];
                out_reg[40]<=out_reg[48];
                out_reg[32]<=out_reg[40];
                out_reg[24]<=out_reg[32];
                out_reg[16]<=out_reg[24];
                out_reg[8]<=out_reg[16];
                out_reg[0]<=out_reg[8];
            end
            STEP1:begin
                if(map2==2'b01)
                    out_reg[57]<=1;
                else
                    out_reg[57]<=0;
                out_reg[1]<=out_reg[9];
                out_reg[9]<=out_reg[17];
                out_reg[17]<=out_reg[25];
                out_reg[25]<=out_reg[33];
                out_reg[33]<=out_reg[41];
                out_reg[41]<=out_reg[49];
                out_reg[49]<=out_reg[57];

            end
            STEP2:begin
                out_reg[58]<=0;
                out_reg[2]<=out_reg[10];
                out_reg[10]<=out_reg[18];
                out_reg[18]<=out_reg[26];
                out_reg[26]<=out_reg[34];
                out_reg[34]<=out_reg[42];
                out_reg[42]<=out_reg[50];
                out_reg[50]<=out_reg[58];


            end
            STEP3:begin
                if(map4==2'b01)
                    out_reg[59]<=1;
                else
                    out_reg[59]<=0;
                out_reg[3]<=out_reg[11];
                out_reg[11]<=out_reg[19];
                out_reg[19]<=out_reg[27];
                out_reg[27]<=out_reg[35];
                out_reg[35]<=out_reg[43];
                out_reg[43]<=out_reg[51];
                out_reg[51]<=out_reg[59];
            end
            STEP4:begin
                if (set_row==0||set_row==3)
                    out_reg[60]<=1;
                else
                    out_reg[60]<=0;
                out_reg[4]<=out_reg[12];
                out_reg[12]<=out_reg[20];
                out_reg[20]<=out_reg[28];
                out_reg[28]<=out_reg[36];
                out_reg[36]<=out_reg[44];
                out_reg[44]<=out_reg[52];
                out_reg[52]<=out_reg[60];

            end
            STEP5:begin
                if(map6==2'b01)
                    out_reg[61]<=1;
                else
                    out_reg[61]<=0;
                out_reg[5]<=out_reg[13];
                out_reg[13]<=out_reg[21];
                out_reg[21]<=out_reg[29];
                out_reg[29]<=out_reg[37];
                out_reg[37]<=out_reg[45];
                out_reg[45]<=out_reg[53];
                out_reg[53]<=out_reg[61];

            end
            STEP6:begin
                begin
                    if(next_row==0||next_row==1)
                        out_reg[62]<=0;
                    else
                        out_reg[62]<=1;
                    out_reg[6]<=out_reg[14];
                    out_reg[14]<=out_reg[22];
                    out_reg[22]<=out_reg[30];
                    out_reg[30]<=out_reg[38];
                    out_reg[38]<=out_reg[46];
                    out_reg[46]<=out_reg[54];
                    out_reg[54]<=out_reg[62];
                end


            end
            STEP7:begin
                if(round==7)
                begin
                    for (i = 0; i<61; i=i+1) begin
                        out_reg[i]<=out_reg[i+1];
                    end
                    out_reg[62]<=0;
                end
                else
                begin
                    if(set_row==0||set_row==1)
                        out_reg[55]<=0;
                    else
                        out_reg[55]<=1;
                    out_reg[7]<=out_reg[15];
                    out_reg[15]<=out_reg[23];
                    out_reg[23]<=out_reg[31];
                    out_reg[31]<=out_reg[39];
                    out_reg[39]<=out_reg[47];
                    out_reg[47]<=out_reg[55];
                end


            end
            OUTPUT:begin
                for (i = 0; i<61; i=i+1) begin
                    out_reg[i]<=out_reg[i+1];
                end
                out_reg[62]<=0;
            end

            default:begin
                for(i=0;i<63;i=i+1)
                begin
                    out_reg[i]<=out_reg[i];
                end
            end
        endcase
    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        for (i = 0; i<8;i=i+1 ) begin
            control4[i]<=0;
        end
        for (i = 0; i<7;i=i+1 ) begin
            control7[i]<=0;
        end
    end
    else */begin
        case (current_state)
            STEP4:begin
                if(set_row==0||set_row==1)
                    control4[7]<=1;
                else
                    control4[7]<=0;
                control4[0]<=control4[1];
                control4[1]<=control4[2];
                control4[2]<=control4[3];
                control4[3]<=control4[4];
                control4[4]<=control4[5];
                control4[5]<=control4[6];
                control4[6]<=control4[7];
            end
            STEP7:begin
                if(round!=3'd7)
                begin
                    if(next_row==1||next_row==3)
                        control7[6]<=1;
                    else
                        control7[6]<=0;
                    control7[0]<=control7[1];
                    control7[1]<=control7[2];
                    control7[2]<=control7[3];
                    control7[3]<=control7[4];
                    control7[4]<=control7[5];
                    control7[5]<=control7[6];
                end
                else
                begin
                    for (i = 0; i<7;i=i+1 ) begin
                        control7[i]<=control7[i];
                    end
                end
            end
            OUTPUT:begin
                if(inflag==3'd7||(round==3'd7&&inflag==3'd6)) begin
                    for (i = 0; i<7;i=i+1 ) begin
                        control4[i]<=control4[i+1];
                    end
                    for (i = 0; i<6;i=i+1 ) begin
                        control7[i]<=control7[i+1];
                    end
                    control4[7]<=0;
                    control7[6]<=0;
                end
                else
                begin
                    for (i = 0; i<8;i=i+1 ) begin
                        control4[i]<=control4[i];
                    end
                    for (i = 0; i<7;i=i+1 ) begin
                        control7[i]<=control7[i];
                    end
                end
            end
            default:begin
                for (i = 0; i<8;i=i+1 ) begin
                    control4[i]<=control4[i];
                end
                for (i = 0; i<7;i=i+1 ) begin
                    control7[i]<=control7[i];
                end
            end
        endcase
    end
end
//output
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out<=0;
        out_valid<=0;
    end
    else
    begin
        case (current_state)
            //STEP3:out_valid<=1;
            IDLE:begin
                out<=0;
                out_valid<=0;
            end
            STEP7:begin
                if(round==3'd7)
                begin
                    if(out_reg[0]==0)
                        out<=0;
                    else
                        out<=2;
                    out_valid<=1;
                end
            end
            OUTPUT:begin

                out_valid<=1;
                case (inflag)
                    'd6:begin
                        if(out_reg[0]==0)
                            out<=2;
                        else
                            out<=1;

                    end
                    'd4:begin
                        if(control4[0]==0)
                        begin
                            if(out_reg[0]==0)
                                out<=0;
                            else
                                out<=2;
                        end
                        else
                        begin
                            if(out_reg[0]==0)
                                out<=0;
                            else
                                out<=1;
                        end
                    end
                    'd7:begin
                        if (control7[0]==0) begin
                            if(out_reg[0]==0)
                                out<=0;
                            else
                                out<=2;
                        end
                        else
                        begin
                            if(out_reg[0]==0)
                                out<=1;
                            else
                                out<=0;
                        end
                    end
                    default:begin
                        if(out_reg[0]==0)
                            out<=0;
                        else
                            out<=3;
                    end
                endcase
            end
            default:begin
                out<=0;
                out_valid<=0;
            end
        endcase
    end
end


endmodule

