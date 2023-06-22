module QUEEN(
           //Input Port
           clk,
           rst_n,

           in_valid,
           col,
           row,

           in_valid_num,
           in_num,

           out_valid,
           out,

       );

input               clk, rst_n, in_valid,in_valid_num;
input       [3:0]   col,row;
input       [2:0]   in_num;

output reg          out_valid;
output reg  [3:0]   out;

//==============================================//
//             Parameter and Integer            //
//==============================================//
genvar  i,j;
parameter INPUT= 3'd0,
          FIND_1 = 3'd1,
          FIND_2= 3'd2,
          CLEAR_1= 3'd3,
          CLEAR_2 = 3'd4,
          OUTPUT =3'd5;
//==============================================//
//                 reg declaration              //
//==============================================//
reg[2:0] current_state,next_state;
reg [2:0] map [0:11][0:11];//descent_reg[0:11][0:11];
//wire diagonal_descent[0:11][0:11];
wire diagonal[0:11][0:11];
reg visited [0:11][0:11];
wire alert[1:11];
wire forward[0:11];
//wire backward[0:11];
wire backward;
reg in_col[0:11];
reg [3:0] sel_col,sel_row;
reg signed[4:0] d_i_row[0:11],d_j_col[0:11],d_col_j[0:11];
reg [3:0] in_flag;
reg flag;
reg [3:0] stack_row[0:11],ptr;
reg [3:0] w_row[0:11];
reg [3:0] finish;

//==============================================//
//            FSM State Declaration             //
//==============================================//

//current_state
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) current_state <= INPUT;
    else  current_state <=next_state;
end
//next_state
always @(*) begin
    if (!rst_n) next_state=INPUT;
    else begin
        case (current_state)
            INPUT:begin
                if(in_flag==1)
                    next_state= FIND_1;
                else
                    next_state=INPUT;

            end
            FIND_1:begin
                if(ptr==finish&backward==0)
                    next_state=OUTPUT;
                else
                    next_state=FIND_2;

            end
            FIND_2:begin
                if(backward)
                    next_state= CLEAR_1;
                else
                    next_state=FIND_1;
            end
            CLEAR_1:
            begin
                next_state=CLEAR_2;
            end
            CLEAR_2:begin
                if(forward[ptr])
                    next_state=FIND_1;
                else
                    next_state=CLEAR_1;
            end



            OUTPUT:begin
                if(in_flag<13)
                    next_state=OUTPUT;
                else
                    next_state=INPUT;
            end

            default: next_state=INPUT;
        endcase
    end
end
//==============================================//
//                  Input Block                 //
//==============================================//


//map reg
generate
    for (i=0; i<12; i=i+1) begin: map_row
        for(j=0; j<12; j=j+1)begin: map_col
            always @(posedge clk or negedge rst_n) begin
                if(!rst_n)
                begin
                    map[i][j]<=3'd0;
                end
                else
                begin
                    case (current_state)
                        INPUT:begin

                            if(in_valid)
                            begin
                                if(i==row|j==col|diagonal[i][j])
                                    map[i][j]<=map[i][j]+1;
                            end


                        end
                        FIND_2:begin

                            if(!backward)begin
                                if((i==sel_row)|(j==sel_col)|(diagonal[i][j]))
                                    map[i][j]<=map[i][j]+1;
                            end

                        end
                        CLEAR_2:begin
                            if(((i==stack_row[ptr])|(j==ptr)|(diagonal[i][j])))
                                map[i][j]<=map[i][j]-1;
                        end
                        OUTPUT:begin
                            map[i][j]<=3'd0;
                        end
                    endcase
                end

            end
        end
    end
endgenerate


//visited reg
generate
    for(i=0;i<12;i=i+1) begin
        for(j=0; j<12; j=j+1)begin
            always @(posedge clk or negedge rst_n) begin
                if(!rst_n)
                begin
                    visited[i][j]<=0;
                end

                else
                begin
                    case (current_state)
                        FIND_2: begin
                            if(!backward&i==sel_row&j==sel_col)
                                visited[i][j]<=1;
                        end
                        CLEAR_2:begin

                            if(!forward[ptr]&j==ptr)
                                visited[i][j]<=0;

                        end
                        OUTPUT:begin
                            visited[i][j]<=0;
                        end

                    endcase
                end
            end
        end
    end
endgenerate



//stack
generate
    for(i=0;i<12;i=i+1) begin
        always @(*) begin
            begin
                case (current_state)

                    FIND_1:
                    begin
                        //if(i==ptr) begin
                        if(!map[0][i]&&!visited[0][i])
                            w_row[i]=0;
                        else if(!map[1][i]&&!visited[1][i])
                            w_row[i]=1;
                        else if(!map[2][i]&&!visited[2][i])
                            w_row[i]=2;
                        else if(!map[3][i]&&!visited[3][i])
                            w_row[i]=3;
                        else if(!map[4][i]&&!visited[4][i])
                            w_row[i]=4;
                        else if(!map[5][i]&&!visited[5][i])
                            w_row[i]=5;
                        else if(!map[6][i]&&!visited[6][i])
                            w_row[i]=6;
                        else if(!map[7][i]&&!visited[7][i])
                            w_row[i]=7;
                        else if(!map[8][i]&&!visited[8][i])
                            w_row[i]=8;
                        else if(!map[9][i]&&!visited[9][i])
                            w_row[i]=9;
                        else if(!map[10][i]&&!visited[10][i])
                            w_row[i]=10;
                        else if(!map[11][i]&&!visited[11][i])
                            w_row[i]=11;
                        else
                            w_row[i]=4'd0;
                    end

                    CLEAR_1:begin

                        if(map[0][i]==1&!visited[0][i])
                            w_row[i]=0;
                        else if(map[1][i]==1&!visited[1][i])
                            w_row[i]=1;
                        else if(map[2][i]==1&!visited[2][i])
                            w_row[i]=2;
                        else if(map[3][i]==1&!visited[3][i])
                            w_row[i]=3;
                        else if(map[4][i]==1&!visited[4][i])
                            w_row[i]=4;
                        else if(map[5][i]==1&!visited[5][i])
                            w_row[i]=5;
                        else if(map[6][i]==1&!visited[6][i])
                            w_row[i]=6;
                        else if(map[7][i]==1&!visited[7][i])
                            w_row[i]=7;
                        else if(map[8][i]==1&!visited[8][i])
                            w_row[i]=8;
                        else if(map[9][i]==1&!visited[9][i])
                            w_row[i]=9;
                        else if(map[10][i]==1&!visited[10][i])
                            w_row[i]=10;
                        else if(map[11][i]==1&!visited[11][i])
                            w_row[i]=11;
                        else
                            w_row[i]=4'd0;
                    end
					default:w_row[i]=4'd0;
                endcase
            end
        end
    end
endgenerate
generate

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        begin
            stack_row[0]<=0;
            stack_row[1]<=0;
            stack_row[2]<=0;
            stack_row[3]<=0;
            stack_row[4]<=0;
            stack_row[5]<=0;
            stack_row[6]<=0;
            stack_row[7]<=0;
            stack_row[8]<=0;
            stack_row[9]<=0;
            stack_row[10]<=0;
            stack_row[11]<=0;
        end
        else begin
            case (current_state)
                INPUT:begin
                    if(in_valid)
                        stack_row[col]<=row;
                end
                FIND_1:begin
                    if(ptr==finish&backward==0)
                    begin
                        stack_row[ptr]<=w_row[ptr];
                    end
                end
                FIND_2:begin
                    if(!backward)
                    begin
                        stack_row[ptr]<=w_row[ptr];
                    end
                end

                OUTPUT:begin
                    if(in_flag<4'd14)
                    begin
                        stack_row[0]<=stack_row[1];
                        stack_row[1]<=stack_row[2];
                        stack_row[2]<=stack_row[3];
                        stack_row[3]<=stack_row[4];
                        stack_row[4]<=stack_row[5];
                        stack_row[5]<=stack_row[6];
                        stack_row[6]<=stack_row[7];
                        stack_row[7]<=stack_row[8];
                        stack_row[8]<=stack_row[9];
                        stack_row[9]<=stack_row[10];
                        stack_row[10]<=stack_row[11];
                        stack_row[11]<=0;
                    end

                end
            endcase
        end
    end

endgenerate

//stack pointer
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ptr<=0;
    else
    begin
        case (current_state)
            INPUT:begin
                if(flag)
                begin
                    if(!in_col[0])
                        ptr<=0;
                    else if(!in_col[1])
                        ptr<=1;
                    else if(!in_col[2])
                        ptr<=2;
                    else if(!in_col[3])
                        ptr<=3;
                    else if(!in_col[4])
                        ptr<=4;
                    else if(!in_col[5])
                        ptr<=5;
                    else
                        ptr<=6;
                end
            end
            FIND_2:begin
                if(backward)begin
                    if(!in_col[ptr-1])
                        ptr<=ptr-1;
                    else if(!in_col[ptr-2])
                        ptr<=ptr-2;
                    else if(!in_col[ptr-3])
                        ptr<=ptr-3;
                    else if(!in_col[ptr-4])
                        ptr<=ptr-4;
                    else if(!in_col[ptr-5])
                        ptr<=ptr-5;
                    else if(!in_col[ptr-6])
                        ptr<=ptr-6;
                    else
                        ptr<=ptr-7;
                end
                else begin
                    if(!in_col[ptr+1])
                        ptr<=ptr+1;
                    else if(!in_col[ptr+2])
                        ptr<=ptr+2;
                    else if(!in_col[ptr+3])
                        ptr<=ptr+3;
                    else if(!in_col[ptr+4])
                        ptr<=ptr+4;
                    else if(!in_col[ptr+5])
                        ptr<=ptr+5;
                    else if(!in_col[ptr+6])
                        ptr<=ptr+6;
                    else
                        ptr<=ptr+7;
                end

            end
            CLEAR_2:begin
                if(!forward[ptr]) begin
                    if(!in_col[ptr-1])
                        ptr<=ptr-1;
                    else if(!in_col[ptr-2])
                        ptr<=ptr-2;
                    else if(!in_col[ptr-3])
                        ptr<=ptr-3;
                    else if(!in_col[ptr-4])
                        ptr<=ptr-4;
                    else if(!in_col[ptr-5])
                        ptr<=ptr-5;
                    else if(!in_col[ptr-6])
                        ptr<=ptr-6;
                    else
                        ptr<=ptr-7;
                end
                else begin
                    ptr<=ptr;
                end
            end
            OUTPUT:begin
                ptr<=0;
            end
        endcase
    end
end

//other reg
generate

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        begin

            in_flag<=0;
            flag<=0;
        end
        else begin
            case (current_state)
                INPUT: begin

                    if(in_valid)
                        flag<=1;
                    if(in_valid&(!flag))
                        in_flag<=in_num;
                    else if(in_valid)
                        in_flag<=in_flag-1;
                end
                OUTPUT:begin
                    in_flag<=in_flag+1;

                    flag<=0;
                end
            endcase
        end
    end

endgenerate

generate
    for(i=0;i<12;i=i+1) begin
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)
            begin
                in_col[i]<=0;
            end
            else begin
                case (current_state)
                    INPUT: begin
                        if(in_valid)begin
                            if(i==col)
                                in_col[i]<=1;
                        end
                        else
                            in_col[i]<=in_col[i];
                        if(in_valid)begin
                            if(i==col)
                                in_col[i]<=1;
                        end

                    end
                    OUTPUT:begin

                        in_col[i]<=0;

                    end
                endcase
            end
        end

    end
endgenerate



//finish reg
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        finish<=11;
    else begin
        case (current_state)
            FIND_1:begin
                if(!in_col[11])
                    finish<=11;
                else if(!in_col[10])
                    finish<=10;
                else if(!in_col[9])
                    finish<=9;
                else if(!in_col[8])
                    finish<=8;
                else if(!in_col[7])
                    finish<=7;
                else if(!in_col[6])
                    finish<=6;
                else
                    finish<=5;


            end
        endcase
    end



end


//control wire

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        sel_col<=0;
        sel_row<=0;
    end

    else begin
        case (current_state)
            FIND_1:begin
                if(!backward)
                begin
                    sel_col<=ptr;
                    sel_row<=w_row[ptr];
                end
            end
        endcase
    end
end



generate
    for(i=0;i<12;i=i+1) begin
        always @(*) begin
            if(current_state==INPUT)
            begin
                d_i_row[i]=i-row;
                d_j_col[i]=i-col;
                d_col_j[i]=col-i;
            end
            else if(current_state==FIND_1|current_state==FIND_2)
            begin
                d_i_row[i]=i-sel_row;
                d_j_col[i]=i-sel_col;
                d_col_j[i]=sel_col-i;
            end
            else
            begin
                d_i_row[i]=i-stack_row[ptr];
                d_j_col[i]=i-ptr;
                d_col_j[i]=ptr-i;
            end
        end
    end
endgenerate



generate
    for (i=0; i<12; i=i+1) begin: diagonal_row
        for(j=0; j<12; j=j+1)begin: diagonal_col
            assign diagonal[i][j]=(d_i_row[i]==d_j_col[j])|(d_i_row[i]==d_col_j[j]);
        end
    end
endgenerate


generate
    for (i=1; i<12; i=i+1) begin
        assign alert[i]= (map[0][i]||visited[0][i])&&(map[1][i]||visited[1][i])&&(map[2][i]||visited[2][i])&&(map[3][i]||visited[3][i])&&(map[4][i]||visited[4][i])&&(map[5][i]||visited[5][i])&&(map[6][i]||visited[6][i])&&(map[7][i]||visited[7][i])&&(map[8][i]||visited[8][i])&&(map[9][i]||visited[9][i])&&(map[10][i]||visited[10][i])&&(map[11][i]||visited[11][i])&&!in_col[i]&&(ptr<=i);
    end
endgenerate
assign backward=alert[1]||alert[2]||alert[3]||alert[4]||alert[5]||alert[6]||alert[7]||alert[8]||alert[9]||alert[10]||alert[11];

generate
    for (i=0; i<12; i=i+1) begin
        assign forward[i]=(map[0][i]==1&!visited[0][i])|(map[1][i]==1&!visited[1][i])|(map[2][i]==1&!visited[2][i])|(map[3][i]==1&!visited[3][i])|((map[4][i]==1&!visited[4][i])|(map[5][i]==1&!visited[5][i])|(map[6][i]==1&!visited[6][i])|(map[7][i]==1&!visited[7][i]))|((map[8][i]==1&!visited[8][i])|(map[9][i]==1&!visited[9][i])|(map[10][i]==1&!visited[10][i])|(map[11][i]==1&!visited[11][i]));
    end
endgenerate


//OUTPUT
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        out<=0;
        out_valid<= 0;
    end
    else
    begin
        case (current_state)
            OUTPUT:begin
                if(in_flag<4'd13)
                begin
                    out_valid<=1;
                    out<=stack_row[0];

                end
                else
                begin
                    out_valid<=0;
                    out<=0;
                end
            end
        endcase
    end
end

endmodule
