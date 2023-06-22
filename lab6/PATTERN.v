`ifdef RTL_TOP
    `define CYCLE_TIME 60.0
`endif
`ifdef GATE_TOP
    `define CYCLE_TIME 35.0
`endif

module PATTERN(
     // Output signals
    clk, rst_n, in_valid,
    in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a,
    // input signals
    out_valid, out_Rx, out_Ry
       );


output reg clk, rst_n, in_valid;
output reg[6-1:0] in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a;
input out_valid;
input [6-1:0] out_Rx, out_Ry;

reg[6-1:0] s_Px, s_Py, s_Qx, s_Qy, s_prime, s_a;

//global
integer latency;
integer total_cycle;
integer total_latency;
integer i_pat;
integer random_number;

integer answer_count;
parameter PATNUM=10000;
parameter IS_RUN_ALL=0;
parameter IP_WIDTH=6;
parameter MAX_IN_RANGE = 2**IP_WIDTH;
parameter CYCLE        = `CYCLE_TIME;
integer   SEED         = 122;

// PATTERN CONTROL
integer         k;
integer         m;
integer      stop;
integer       pat;
integer pat_prime;
integer   pat_num;
integer   exe_lat;
integer   out_lat;
integer   tot_lat;

/* define clock cycle */
always #(CYCLE/2.0) clk = ~clk;
integer  i,j;

// Prime list
// Construct list of prime number
integer prime_list[0:MAX_IN_RANGE-1];
integer        prime_flag; // show whether the number is prime or not
integer         num_prime; // how many prime number
integer sel_prime, sel_num;
integer     gold_x, gold_y;


// Prime checker
//    Check whether the "in_num" is prime or not
//    0 ==> not prime
//    1 ==> prime
integer flag;
integer numIter;
task prime_check;
    input  integer in_num;
    output integer isPrime;
begin
    flag = 0;
    for(numIter=2 ; numIter*numIter<=in_num ; numIter=numIter+1) begin
        if((in_num%numIter) === 0 && flag === 0 ) begin
            flag = 1;
            isPrime = 0;
        end
    end
    if(flag == 0) isPrime = 1;
    if(in_num == 1) isPrime = 0;
end endtask

// Find the greatest common divisor
integer gcd_q, gcd_r, b_temp, a_temp;
task gcd;
    input  integer a;
    input  integer b;
    output integer c;
begin
    a_temp = a;
    b_temp = b;
    // loop till remainder is 0
    while (b_temp > 0) begin
        gcd_q = a_temp / b_temp; // quotient
        gcd_r = a_temp - gcd_q * b_temp; // remainder
        a_temp = b_temp;
        b_temp = gcd_r;
    end
    c = a_temp;
end endtask

// Find ax + by = gcd(a,b)
integer euc_q, euc_r;
integer euc_a, euc_b;

integer cur_x, cur_y;
integer pre_x, pre_y;
integer tmp_x, tmp_y;
task ext_euclid;
    input  integer isShowLog;
    input  integer a; // prime number
    input  integer b; // do inversion
    output integer x;
    output integer y;
begin
    euc_r = a%b;
    euc_q = (a-euc_r)/b;
    
    euc_a = b;
    euc_b = euc_r;
    
    cur_x = 1;
    cur_y = -euc_q;
    pre_x = 0;
    pre_y = 1;
    if(isShowLog == 1) begin
        $display("[Info] Show the calculation process");
        $display("[Rem], [Quo], [X], [Y]");
        $display("[%1d], [-], [1], [0]", a);
        $display("[%1d], [-], [0], [1]", b);
        $display("[%1d], [%1d], [%1d], [%1d]", euc_r, euc_q, cur_x, cur_y);
    end
    while(euc_r !== 0) begin
        euc_r = euc_a%euc_b;
        euc_q = (euc_a-euc_r)/euc_b;
        
        euc_a = euc_b;
        euc_b = euc_r;
        
        tmp_x = cur_x;
        tmp_y = cur_y;
        cur_x = pre_x - cur_x*euc_q;
        cur_y = pre_y - cur_y*euc_q;
        pre_x = tmp_x;
        pre_y = tmp_y;
        if(isShowLog == 1) begin
            $display("[%1d], [%1d], [%1d], [%1d]", euc_r, euc_q, cur_x, cur_y);
        end
    end
    if(pre_x < 0) x = pre_x + b;
    else          x = pre_x;
    if(pre_y < 0) y = pre_y + a;
    else          y = pre_y;
end endtask
task prime_task; begin
    // $display("[Info] IP_WIDHT : %-1d, MAXIMUM of this width %-1d", IP_WIDTH, MAX_IN_RANGE);

    // Construct the list of prime number
    num_prime = 0;
    for(i=2 ; i<MAX_IN_RANGE ; i=i+1) begin
        prime_check(i, prime_flag);
        if(prime_flag == 1) begin
            prime_list[num_prime] = i;
            num_prime = num_prime + 1;
            // $display("[Info] (Prime, idx) = (%-1d, %-1d)", i, num_prime);
        end
    end
end endtask

//**************************************
//      Data Task
//**************************************
task data_task; begin
    if(IS_RUN_ALL == 1) begin
        sel_prime=prime_list[pat_prime];
        sel_num=pat_num;
        
    end
    else begin
        sel_prime = prime_list[ {$random(SEED)}%num_prime ];
        sel_num = {$random(SEED)}%(sel_prime-1) + 1;
    end
    // Randomize the prime num and inversion num
    /*if({$random(SEED)}%2 == 1) begin
        IN_1 = sel_prime;
        IN_2 = sel_num;
    end
    else begin
        IN_1 = sel_num;
        IN_2 = sel_prime;
    end*/
    //ext_euclid(0, sel_prime, sel_num, gold_x, gold_y);
    //$display("[Info] (IN_1, IN_2) = (%-1d, %-1d), (%1d)", IN_1, IN_2, gold_y);
    @(posedge clk);
end endtask









initial begin
    //max_latency = 0;
    reset_task;//spec3
    prime_task;
    total_cycle = 0;
    if(IS_RUN_ALL==1) begin
        for (pat_prime=0 ; pat_prime<num_prime ; pat_prime=pat_prime+1) begin
            for (pat_num=1 ; pat_num<prime_list[pat_prime] ; pat_num=pat_num+1) begin
                data_task;
		input_task;
		wait_out_valid_task;
                //check_ans_task;
                
            end
        end
    end
    else begin
        for (pat=0 ; pat<PATNUM ; pat=pat+1) begin
            data_task;
	    input_task;
	    wait_out_valid_task;
            check_ans_task;
            
        end
    end
    YOU_PASS_task;
end


task reset_task; begin
        rst_n = 'b1;
        in_valid = 'b0;
        in_Px='bx;
	in_Py='bx;
	in_Qx='bx; 
	in_Qy='bx; 
	in_prime='bx; 
	in_a='bx;
        
        total_latency = 0;
        force clk = 0;
        #CYCLE; rst_n = 0;
        #CYCLE; rst_n = 1;
        if(out_valid !== 1'b0 || out_Rx !=='b0) begin //out!==0
            $display("SPEC 3 IS FAIL!");
            $finish;
        end
        #CYCLE; release clk;
    end endtask

integer t;
task input_task; begin
	if (out_valid === 'b0) begin
                if(out_Rx !== 'b0) begin
                    $display ("SPEC 4 IS FAIL!");
                    $finish;
                end
            end
        if(out_valid !== 'b0||out_Rx!==0) begin  //spec7
            $display ("SPEC 7 IS FAIL!");
            $finish;
        end
        t = $urandom_range(1, 3);
        for(i = 0; i < t; i = i + 1)begin
            if (out_valid === 'b0) begin
                if(out_Rx !== 'b0) begin
                    $display ("SPEC 4 IS FAIL!");
                    $finish;
                end
            end
			if (in_valid === 'b1) begin
                    if(out_valid === 'b1) begin
                        $display ("SPEC 5 IS FAIL!");
                        $finish;
                    end
                end
            @(negedge clk);
        end
	in_Px={$random(SEED)}%(sel_prime-1) + 1;
	in_Py={$random(SEED)}%(sel_prime-1) + 1;
	in_Qx={$random(SEED)}%(sel_prime-1) + 1;
	in_Qy={$random(SEED)}%(sel_prime-1) + 1;
	//in_Qx=in_Px;
	in_Qy=in_Py;
	in_prime=sel_prime;
	in_a={$random(SEED)}%(sel_prime-1) + 1;
	in_valid=1;
	s_Px=in_Px;
	s_Py=in_Py;
	s_Qx=in_Qx;
	s_Qy=in_Qy;	
	s_prime=in_prime;
	s_a=in_a;
        //$display("%d  %d  %d  %d  %d   %d",in_Px,in_Py,in_Qx,in_Qy,in_prime,in_a );
        @(negedge clk);
        in_valid = 1'b0;
        in_Px='bx;
	in_Py='bx;
	in_Qx='bx;
	in_Qy='bx;
	in_prime='bx;
	in_a='bx;
    end endtask

task wait_out_valid_task; begin
        latency = 0;
        while(out_valid !== 1'b1) begin
            latency = latency + 1;
            if (out_valid === 'b0) begin
                if(out_Rx !== 'b0) begin
                    $display ("SPEC 4 IS FAIL!");
                    $finish;
                end
            end
			if (in_valid === 'b1) begin
                    if(out_valid === 'b1) begin
                        $display ("SPEC 5 IS FAIL!");
                        $finish;
                    end
                end
            if( latency == 100) begin
                $display("SPEC 6 IS FAIL!");
                $finish;
            end
            @(negedge clk);
        end
        total_latency = total_latency + latency;
    end endtask
integer golden_out;
integer s,p_out,g_x,g_y;
task check_ans_task; begin
	if(s_Px==s_Qx||s_Py+s_Qy==s_prime)
		@(negedge clk);
	else begin
	if(s_Px!=s_Qx||s_Py!=s_Qy)
		begin
			ext_euclid(0, sel_prime, (s_Qx-s_Px+s_prime)%s_prime, gold_x, p_out);
			s=(p_out*(s_Qy-s_Py+s_prime))%s_prime;
		end
		else
		begin
			ext_euclid(0, sel_prime, (2*s_Py)%s_prime, gold_x, p_out);
			s=(p_out*(3*s_Px*s_Px+s_a))%s_prime;
		end
		g_x=(s*s-s_Px-s_Qx+2*+s_prime)%s_prime;
		g_y=(s*(s_Px-g_x+s_prime)-s_Py+s_prime)%s_prime;
		if(out_Rx!=g_x|| out_Ry!=g_y)
		begin
			$display("FFFFFFFFFAAAAIIIIIIILLLLLLLLL");
			$display("p_out%d  s%d",p_out,s);
			$display("gold answer x %d  y  %d",g_x,g_y);
			$display("your answer x %d  y  %d",out_Rx,out_Ry);
			$finish;

		end
		@(negedge clk);
        end
    end endtask
task YOU_PASS_task; begin
        $display ("--------------------------------------------------------------------");
        $display ("                         Congratulations!                           ");
        $display ("                  You have passed all patterns!                     ");
        $display ("--------------------------------------------------------------------");
        repeat(2)@(negedge clk);
        $finish;
    end endtask

endmodule

