module MMT(
           // input signals
           clk,
           rst_n,
           in_valid,
           in_valid2,
           matrix,
           matrix_size,
           matrix_idx,
           mode,

           // output signals
           out_valid,
           out_value
       );
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input        clk, rst_n, in_valid, in_valid2;
input [7:0] matrix;
input [1:0]  matrix_size,mode;
input [4:0]  matrix_idx;
output reg       	     out_valid;
output reg signed [49:0] out_value;
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
parameter IDLE = 0,
          INPUT =1,
          ORDER_INPUT=2,
          READ_a=3,
          READ_b=4,
          READ_c=5,
          BUFF=6,
          OUTPUT=7;
//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
wire mem_wen;
wire signed [127:0] mem1_out,mem1_d;
wire [8:0] m_square;
wire [4:0] m_size_plus;
reg [8:0] mem1_a;
//reg [12:0] last_mem_a;
reg [3:0] current_state,next_state;
reg [1:0] m_mode;
reg [3:0] m_size;
reg [12:0] count;
//reg [3:0] count_b,count_c;
reg[3:0] count_input;
reg [8:0]count_time_input;
reg [4:0] count_col;
reg [4:0] matrix_a,matrix_b,matrix_c;
reg signed [20:0] sum[0:15];
reg signed [28:0] total_sum[0:15];
reg signed [35:0] p_answer;
reg signed [7:0] r_a[0:15][0:15];
reg signed [7:0] r_in[0:15];
reg  signed  [7:0] r_out;
reg [3:0] a_iadress[0:15],a_jadress[0:15];
reg flag;
genvar i,j;
//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
//FSM
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        current_state<=IDLE;
    end
    else
    begin
        current_state<=next_state;
    end
end

always @(*) begin
    if (!rst_n)
        next_state=IDLE;
    else
    begin
        case (current_state)
            IDLE: begin
                if (in_valid)
                    next_state=INPUT;
                else if (in_valid2)
                    next_state=ORDER_INPUT;
                else
                    next_state=IDLE;
            end
            INPUT: begin
                if (!in_valid)
                    next_state=IDLE;
                else
                    next_state=INPUT;
            end
            ORDER_INPUT:begin
                if (!in_valid2)
                    next_state=READ_a;
                else
                    next_state=ORDER_INPUT;
            end
            READ_a:begin
                if(count[4:0]==m_size+1)
                    next_state=READ_b;
                else
                    next_state=READ_a;
            end
            READ_b:begin
                if(count[3:0]==0)
                    next_state=READ_c;
                else
                    next_state=READ_b;
            end
            READ_c:begin
                if(flag)
                begin
                    if(count_col==m_size+1)
                        next_state=BUFF;
                    else
                        next_state=READ_b;
                end
                else
                    next_state=READ_c;
            end
            BUFF:begin
                next_state=OUTPUT;
            end
            OUTPUT:begin
                next_state=IDLE;
            end

            default: next_state=IDLE;
        endcase
    end

end
//memory control
assign m_size_plus=m_size+1;
assign m_square=(m_size_plus)*(m_size_plus);
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        count<=0;
    end
    else*/
    begin
        case (current_state)
            IDLE:begin
                if(in_valid)
                    count<=count+1;
                else
                    count<=0;
            end
            INPUT:begin
                if (in_valid)
                    count<=count+1;
                else
                    count<=0;
            end
            ORDER_INPUT:begin
                if(!in_valid2)
                    count<=count+1;
                else
                    count<=count;
            end
            READ_a:begin
                if (count==m_size_plus) begin
                    count<=1;
                end
                else
                    count<=count+1;
            end
            READ_b:begin
                if (count==m_size) begin
                    count<=0;
                end
                else
                    count<=count+1;
            end
            READ_c :begin
                count<=!count;
            end

            default:count<=count;
        endcase
    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        count_col<=0;
    end
    else*/
    begin
        if (current_state==IDLE) begin
            count_col<=0;
        end
        else if(current_state==READ_c&&flag==0)
            count_col<=count_col+1;
        /*else if(current_state==OUTPUT)
            count_col<=0;*/
        else
            count_col<=count_col;
    end
end
always @(posedge clk /*or negedge rst_n*/)begin
    /*if (!rst_n)
    begin
        count_input<=0;
    end
    else*/
    begin
        if (current_state==IDLE) begin
            if(in_valid)
                count_input<=count_input+1;
            else
                count_input<=0;
        end
        else if(current_state==INPUT)
        begin
            if(count_input==m_size)
                count_input<=0;
            else
                count_input<=count_input+1;
        end
        else
            count_input<=count_input;
    end
end
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
    begin
        count_time_input<=0;
    end
    else
    begin
        if(in_valid)
        begin
            if(count_input==0&&current_state==INPUT)
                count_time_input<=count_time_input+1;
            else
                count_time_input<=count_time_input;
        end
        else
            count_time_input<=0;
    end
end
always @(*) begin
    case (current_state)
        IDLE:
            mem1_a=0;
        INPUT:
            mem1_a=count_time_input;
        ORDER_INPUT:
            mem1_a=matrix_a*m_size_plus;
        READ_a:begin
            if(count[4:0]==m_size_plus)
                mem1_a=matrix_b*m_size_plus;
            else
                mem1_a=matrix_a*m_size_plus+count;
        end
        READ_b:begin
            if (m_mode==0) begin
                if(count[3:0]==0)
                    mem1_a=matrix_c*m_size_plus+count_col;
                else
                    mem1_a=matrix_b*m_size_plus+count;
            end
            else begin
                if(count[3:0]==0)
                    mem1_a=matrix_c*m_size_plus+count_col;
                else
                    mem1_a=matrix_b*m_size_plus+count;
            end
        end
        READ_c:begin
            if(count[0]==1)
                mem1_a=matrix_c*m_size_plus+count_col;
            else
                mem1_a=matrix_b*m_size_plus+count;
        end
        default:
            mem1_a=0;
    endcase

end

//assign mem1_d={r_in[15],r_in[14],r_in[13],r_in[12],r_in[11],r_in[10],r_in[9],r_in[8],r_in[7],r_in[6],r_in[5],r_in[4],r_in[3],r_in[2],r_in[1],r_in[0]};
assign mem1_d={r_a[15][0],r_a[14][0],r_a[13][0],r_a[12][0],r_a[11][0],r_a[10][0],r_a[9][0],r_a[8][0],r_a[7][0],r_a[6][0],r_a[5][0],r_a[4][0],r_a[3][0],r_a[2][0],r_a[1][0],r_a[0][0]};

//assign mem1_d={r_a[0][15],r_a[0][14],r_a[0][13],r_a[0][12],r_a[0][11],r_a[0][10],r_a[0][9],r_a[0][8],r_a[0][7],r_a[0][6],r_a[0][5],r_a[0][4],r_a[0][3],r_a[0][2],r_a[0][1],r_a[0][0]};
assign mem_wen= (current_state==IDLE&&in_valid||current_state==INPUT) ? 0 :1;

//control reg
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        flag<=0;
    end
    else*/
    begin
        if(current_state==IDLE)
            flag<=0;
        else if (current_state==ORDER_INPUT)
            flag<=1;
        else if (current_state==READ_b)
            flag<=0;
        else if(current_state==READ_c)
            flag<=1;
        else
            flag<=flag;

    end
end
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        m_size<=0;
    end
    else*/
    begin
        if(current_state==IDLE&&in_valid)
        begin
            if (matrix_size==0)
                m_size<=1;
            else if (matrix_size==1)
                m_size<=3;
            else if (matrix_size==2)
                m_size<=7;
            else if(matrix_size==3)
                m_size<=15;
            else
                m_size<=m_size;
        end
    end
end

always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        m_mode<=0;
    end
    else*/
    begin
        if(current_state==IDLE&&in_valid2)
            m_mode<=mode;
        else
            m_mode<=m_mode;
    end
end
//matrix idx
always @(posedge clk ) begin
    if(in_valid2)
    begin
        if(current_state==IDLE)
            matrix_a<=matrix_idx;
        else if (current_state==ORDER_INPUT&&flag==0&&m_mode==2)
            matrix_a<=matrix_idx;
        else if (current_state==ORDER_INPUT&&flag==1&&m_mode==3)
            matrix_a<=matrix_idx;
        else
            matrix_a<=matrix_a;
    end
    else
        matrix_a<=matrix_a;
end
always @(posedge clk ) begin
    if (in_valid2)
    begin
        if(current_state==IDLE)
            matrix_b<=matrix_idx;
        else if (current_state==ORDER_INPUT&&flag==0&&(m_mode==0||m_mode==1))
            matrix_b<=matrix_idx;
        else if (current_state==ORDER_INPUT&&flag==1&&m_mode==2)
            matrix_b<=matrix_idx;
        else
            matrix_b<=matrix_b;
    end
    else
        matrix_b<=matrix_b;
end
always @(posedge clk ) begin
    if (in_valid2)
    begin
        if(current_state==IDLE)
            matrix_c<=matrix_idx;
        else if (current_state==ORDER_INPUT&&flag==0&&(m_mode==3))
            matrix_c<=matrix_idx;
        else if (current_state==ORDER_INPUT&&flag==1&&(m_mode==0||m_mode==1))
            matrix_c<=matrix_idx;
        else
            matrix_c<=matrix_c;
    end
    else
        matrix_c<=matrix_c;
end

//receive reg
generate
    for ( i= 0;i<16 ; i=i+1) begin
        for (j = 0; j<16; j=j+1) begin
            always @(posedge clk or negedge rst_n)begin
                if (!rst_n) begin
                    r_a[i][j]<=0;
                end

                else begin
                    if(current_state==IDLE)begin
                        if(in_valid&&i==0&&j==0)
                            r_a[i][j]<=matrix;
                        else
                        begin
                            r_a[i][j]<=0;
                        end
                    end
                    else if (current_state==INPUT) begin
                        if(i==count_input&&j==0)
                            r_a[i][j]<=matrix;
                    end
                    else if (current_state==READ_a) begin
                        if(m_mode==0)
                        begin
                            if(i==count[4:0]-1)
                            begin
                                case (j)
                                    0:r_a[i][j]<=mem1_out[7:0];
                                    1:r_a[i][j]<=mem1_out[15:8];
                                    2:r_a[i][j]<=mem1_out[23:16];
                                    3:r_a[i][j]<=mem1_out[31:24];
                                    4:r_a[i][j]<=mem1_out[39:32];
                                    5:r_a[i][j]<=mem1_out[47:40];
                                    6:r_a[i][j]<=mem1_out[55:48];
                                    7:r_a[i][j]<=mem1_out[63:56];
                                    8:r_a[i][j]<=mem1_out[71:64];
                                    9:r_a[i][j]<=mem1_out[79:72];
                                    10:r_a[i][j]<=mem1_out[87:80];
                                    11:r_a[i][j]<=mem1_out[95:88];
                                    12:r_a[i][j]<=mem1_out[103:96];
                                    13:r_a[i][j]<=mem1_out[111:104];
                                    14:r_a[i][j]<=mem1_out[119:112];
                                    15: r_a[i][j]<=mem1_out[127:120];
                                    default: r_a[i][j]<=r_a[i][j];
                                endcase
                                /*r_a[i][0]<=mem1_out[7:0];
                                r_a[i][1]<=mem1_out[15:8];
                                r_a[i][2]<=mem1_out[23:16];
                                r_a[i][3]<=mem1_out[31:24];
                                r_a[i][4]<=mem1_out[39:32];
                                r_a[i][5]<=mem1_out[47:40];
                                r_a[i][6]<=mem1_out[55:48];
                                r_a[i][7]<=mem1_out[63:56];
                                r_a[i][8]<=mem1_out[71:64];
                                r_a[i][9]<=mem1_out[79:72];
                                r_a[i][10]<=mem1_out[87:80];
                                r_a[i][11]<=mem1_out[95:88];
                                r_a[i][12]<=mem1_out[103:96];
                                r_a[i][13]<=mem1_out[111:104];
                                r_a[i][14]<=mem1_out[119:112];
                                r_a[i][15]<=mem1_out[127:120];*/

                            end
                        end
                        else
                        begin
                            if(j==count[4:0]-1)
                            begin
                                case (i)
                                    0:r_a[i][j]<=mem1_out[7:0];
                                    1:r_a[i][j]<=mem1_out[15:8];
                                    2:r_a[i][j]<=mem1_out[23:16];
                                    3:r_a[i][j]<=mem1_out[31:24];
                                    4:r_a[i][j]<=mem1_out[39:32];
                                    5:r_a[i][j]<=mem1_out[47:40];
                                    6:r_a[i][j]<=mem1_out[55:48];
                                    7:r_a[i][j]<=mem1_out[63:56];
                                    8:r_a[i][j]<=mem1_out[71:64];
                                    9:r_a[i][j]<=mem1_out[79:72];
                                    10:r_a[i][j]<=mem1_out[87:80];
                                    11:r_a[i][j]<=mem1_out[95:88];
                                    12:r_a[i][j]<=mem1_out[103:96];
                                    13:r_a[i][j]<=mem1_out[111:104];
                                    14:r_a[i][j]<=mem1_out[119:112];
                                    15: r_a[i][j]<=mem1_out[127:120];
                                    default: r_a[i][j]<=r_a[i][j];
                                endcase
                                /*if(count-1==i)
                                begin

                                    r_a[0][i]<=mem1_out[7:0];
                                    r_a[1][i]<=mem1_out[15:8];
                                    r_a[2][i]<=mem1_out[23:16];
                                    r_a[3][i]<=mem1_out[31:24];
                                    r_a[4][i]<=mem1_out[39:32];
                                    r_a[5][i]<=mem1_out[47:40];
                                    r_a[6][i]<=mem1_out[55:48];
                                    r_a[7][i]<=mem1_out[63:56];
                                    r_a[8][i]<=mem1_out[71:64];
                                    r_a[9][i]<=mem1_out[79:72];
                                    r_a[10][i]<=mem1_out[87:80];
                                    r_a[11][i]<=mem1_out[95:88];
                                    r_a[12][i]<=mem1_out[103:96];
                                    r_a[13][i]<=mem1_out[111:104];
                                    r_a[14][i]<=mem1_out[119:112];
                                    r_a[15][i]<=mem1_out[127:120];*/
                            end
                        end

                    end
                end
            end
        end
    end
endgenerate

always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        r_out<=0;
    end
    else*/
    begin
        case (count_col)
            0: r_out<=mem1_out[7:0];
            1:r_out<=mem1_out[15:8];
            2:r_out<=mem1_out[23:16];
            3:r_out<=mem1_out[31:24];
            4:r_out<=mem1_out[39:32];
            5:r_out<=mem1_out[47:40];
            6: r_out<=mem1_out[55:48];
            7:r_out<=mem1_out[63:56];
            8: r_out<=mem1_out[71:64];
            9: r_out<=mem1_out[79:72];
            10:r_out<=mem1_out[87:80];
            11:r_out<=mem1_out[95:88];
            12:r_out<=mem1_out[103:96];
            13:r_out<=mem1_out[111:104];
            14:r_out<=mem1_out[119:112];
            15: r_out<=mem1_out[127:120];
            default:r_out<=r_out;
        endcase
    end
end

generate
    for (i = 0; i<16; i=i+1) begin
        always @(posedge clk /*or negedge rst_n*/) begin
            /*if(!rst_n)
            begin
                a_jadress[i]<=0;
            end
            else*/
            begin
                if(count[3:0]==0)
                    a_jadress[i]<=m_size;
                else
                    a_jadress[i]<=count-1;
            end
        end
    end
endgenerate

generate
    for (i = 0; i<16; i=i+1) begin
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)
            begin
                sum[i]<=0;
            end
            else
            begin
                /*if(current_state==READ_b&&count==1)
                    sum[i]<=0;
                else
                    sum[i]<=sum[i]+r_a[a_adress[i]]*r_out;*/
                if(current_state==IDLE)
                    sum[i]<=0;
                if(current_state==READ_b)
                begin
                    if(count[3:0]==1)
                        sum[i]<=0;
                    else
                        sum[i]<=sum[i]+r_a[i][a_jadress[i]]*r_out;
                end
                else if (current_state==READ_c&&flag==0)
                    sum[i]<=sum[i]+r_a[i][a_jadress[i]]*r_out;
                else
                    sum[i]<=sum[i];
            end
        end
    end
endgenerate
wire signed [7:0]mem_p_out [0:15];
assign mem_p_out[0]=mem1_out[7:0];
assign mem_p_out[1]=mem1_out[15:8];
assign mem_p_out[2]=mem1_out[23:16];
assign mem_p_out[3]=mem1_out[31:24];
assign mem_p_out[4]=mem1_out[39:32];
assign mem_p_out[5]=mem1_out[47:40];
assign mem_p_out[6]=mem1_out[55:48];
assign mem_p_out[7]=mem1_out[63:56];
assign mem_p_out[8]=mem1_out[71:64];
assign mem_p_out[9]=mem1_out[79:72];
assign mem_p_out[10]=mem1_out[87:80];
assign mem_p_out[11]=mem1_out[95:88];
assign mem_p_out[12]=mem1_out[103:96];
assign mem_p_out[13]=mem1_out[111:104];
assign mem_p_out[14]=mem1_out[119:112];
assign mem_p_out[15]=mem1_out[127:120];
always @(posedge clk /*or negedge rst_n*/) begin
    /*if(!rst_n)
    begin
        total_sum[0]<=0;
        total_sum[1]<=0;
        total_sum[2]<=0;
        total_sum[3]<=0;
        total_sum[4]<=0;
        total_sum[5]<=0;
        total_sum[6]<=0;
        total_sum[7]<=0;
        total_sum[8]<=0;
        total_sum[9]<=0;
        total_sum[10]<=0;
        total_sum[11]<=0;
        total_sum[12]<=0;
        total_sum[13]<=0;
        total_sum[14]<=0;
        total_sum[15]<=0;
    end
    else*/
    begin
        if(current_state==READ_c&&flag)
        begin
            total_sum[0]<=mem_p_out[0]*sum[0];
            total_sum[1]<=mem_p_out[1]*sum[1];
            total_sum[2]<=mem_p_out[2]*sum[2];
            total_sum[3]<=mem_p_out[3]*sum[3];
            total_sum[4]<=mem_p_out[4]*sum[4];
            total_sum[5]<=mem_p_out[5]*sum[5];
            total_sum[6]<=mem_p_out[6]*sum[6];
            total_sum[7]<=mem_p_out[7]*sum[7];
            total_sum[8]<=mem_p_out[8]*sum[8];
            total_sum[9]<=mem_p_out[9]*sum[9];
            total_sum[10]<=mem_p_out[10]*sum[10];
            total_sum[11]<=mem_p_out[11]*sum[11];
            total_sum[12]<=mem_p_out[12]*sum[12];
            total_sum[13]<=mem_p_out[13]*sum[13];
            total_sum[14]<=mem_p_out[14]*sum[14];
            total_sum[15]<=mem_p_out[15]*sum[15];
        end
        else
        begin
            total_sum[0]<=total_sum[0];
            total_sum[1]<=total_sum[1];
            total_sum[2]<=total_sum[2];
            total_sum[3]<=total_sum[3];
            total_sum[4]<=total_sum[4];
            total_sum[5]<=total_sum[5];
            total_sum[6]<=total_sum[6];
            total_sum[7]<=total_sum[7];
            total_sum[8]<=total_sum[8];
            total_sum[9]<=total_sum[9];
            total_sum[10]<=total_sum[10];
            total_sum[11]<=total_sum[11];
            total_sum[12]<=total_sum[12];
            total_sum[13]<=total_sum[13];
            total_sum[14]<=total_sum[14];
            total_sum[15]<=total_sum[15];
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        p_answer<=0;
    else
    begin
        /*if(current_state==IDLE)
            p_answer<=0;*/
        if (current_state==READ_b&&count[3:0]==1&&count_col!=0||current_state==BUFF) begin
            p_answer<=p_answer+total_sum[0]+total_sum[1]+total_sum[2]+total_sum[3]+total_sum[4]+total_sum[5]+total_sum[6]+total_sum[7]+total_sum[8]+total_sum[9]+total_sum[10]+total_sum[11]+total_sum[12]+total_sum[13]+total_sum[14]+total_sum[15];
        end
        else if(current_state==OUTPUT)
            p_answer<=0;
        else
            p_answer<=p_answer;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        out_valid<=0;
        out_value<=0;
    end
    else
    begin
        if(current_state==OUTPUT)
        begin
            out_valid<=1;
            out_value<=p_answer;
        end
        else
        begin
            out_valid<=0;
            out_value<=0;
        end
    end
end



NEW_MEM mem1 (.Q(mem1_out), .CLK(clk), .CEN(1'b0), .WEN(mem_wen), .A(mem1_a), .D(mem1_d), .OEN(1'b0) );

endmodule
