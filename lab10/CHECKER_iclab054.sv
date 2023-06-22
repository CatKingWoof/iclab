
module Checker(input clk, INF.CHECKER inf);
import usertype::*;

covergroup money_cover @(posedge clk iff(inf.amnt_valid));
    option.per_instance=1;
    Money : coverpoint inf.D.d_money
    {
        option.at_least=10;
        bins m0 = {[0:12000]};
        bins m1 = {[12001:24000]};
        bins m2 = {[24001:36000]};
        bins m3 = {[36001:48000]};
        bins m4 = {[48001:60000]};
    }
endgroup

covergroup id_cover @(posedge clk iff(inf.id_valid));
    option.per_instance=1;
    id : coverpoint inf.D.d_id[0]
    {
        option.at_least=2;
        option.auto_bin_max=256;
    }
endgroup

covergroup act_cover @(posedge clk iff(inf.act_valid));
    option.per_instance=1;
    act : coverpoint inf.D.d_act[0]
    {
        option.at_least=10;
        bins a00 = (Buy => Buy);
        bins a01 = (Buy => Check);
        bins a02 = (Buy => Deposit);
        bins a03 = (Buy => Return);

        bins a10 = (Check => Buy);
        bins a11 = (Check => Check);
        bins a12 = (Check => Deposit);
        bins a13 = (Check => Return);

        bins a20 = (Deposit => Buy);
        bins a21 = (Deposit => Check);
        bins a22 = (Deposit => Deposit);
        bins a23 = (Deposit => Return);

        bins a30 = (Return => Buy);
        bins a31 = (Return => Check);
        bins a32 = (Return => Deposit);
        bins a33 = (Return => Return);
    }
endgroup

covergroup item_cover @(posedge clk iff(inf.item_valid));
    option.per_instance=1;
    item : coverpoint inf.D.d_item[0]
    {
        option.at_least=20;
        bins L = {Large};
        bins M = {Medium};
        bins S = {Small};
    }
endgroup

covergroup err_cover @(negedge clk iff(inf.out_valid));
    option.per_instance=1;
    err : coverpoint inf.err_msg
    {
        option.at_least=20;
        bins E1 = {INV_Not_Enough};
        bins E2 = {Out_of_money};
        bins E3 = {INV_Full};
        bins E4 = {Wallet_is_Full};
        bins E5 = {Wrong_ID};
        bins E6 = {Wrong_Num};
        bins E7 = {Wrong_Item};
        bins E8 = {Wrong_act};
    }
endgroup

covergroup comp_cover @(negedge clk iff(inf.out_valid));
    option.per_instance=1;
    comp : coverpoint inf.complete
    {
        option.at_least=200;
        bins C0={0};
        bins C1={1};
    }
endgroup


//declare the cover group 
//Spec1 cov_inst_1 = new();

money_cover conv_inst_1 = new();
id_cover conv_inst_2 =new();
act_cover conv_inst_3 =new();
item_cover conv_inst_4 =new();
err_cover conv_inst_5 =new();
comp_cover conv_inst_6 =new();




//************************************ below assertion is to check your pattern ***************************************** 
//                                          Please finish and hand in it
// This is an example assertion given by TA, please write other assertions at the below
// assert_interval : assert property ( @(posedge clk)  inf.out_valid |=> inf.id_valid == 0)
// else
// begin
// 	$display("Assertion X is violated");
// 	$fatal; 
// end

//write other assertions


always @(negedge inf.rst_n) begin
    #1;
    assert_1: assert(
        inf.err_msg===0 &&
        inf.complete===0 &&
        inf.out_valid===0 &&
        inf.out_info===0 &&
        inf.C_addr===0 &&
        inf.C_r_wb===0 &&
        inf.C_in_valid===0 &&
        inf.C_data_w===0 &&
        inf.C_out_valid===0 &&
        inf.C_data_r===0 &&
        inf.AR_VALID=== 0 &&
		inf.AR_ADDR=== 0 &&
		inf.R_READY=== 0 &&
		inf.AW_VALID=== 0 &&
		inf.AW_ADDR === 0 &&
		inf.W_VALID === 0 &&
		inf.W_DATA  === 0 &&
		inf.B_READY === 0
    )
    else
    begin
        $display("Assertion 1 is violated");
        $fatal;
    end
end


assert_2 : assert property(complete_property)
else
begin
    $display("Assertion 2 is violated");
    $fatal;
end
property complete_property;
    @(negedge clk) (inf.out_valid&&inf.complete) |-> inf.err_msg===0;
endproperty: complete_property


assert_3 : assert property(not_complete_property)
else
begin
    $display("Assertion 3 is violated");
    $fatal;
end
property not_complete_property;
    @(negedge clk) (inf.out_valid&& !inf.complete) |-> inf.out_info===0;
endproperty: not_complete_property


assert_4_id :assert property(id_valid_property)
else begin $display("Assertion 4 is violated"); $fatal; end
assert_4_act :assert property(act_valid_property)
else begin $display("Assertion 4 is violated"); $fatal; end
assert_4_item :assert property(item_valid_property)
else begin $display("Assertion 4 is violated"); $fatal; end
assert_4_num :assert property(num_valid_property)
else begin $display("Assertion 4 is violated"); $fatal; end
assert_4_amnt :assert property(amnt_valid_property)
else begin $display("Assertion 4 is violated"); $fatal; end
property id_valid_property;
    @(posedge clk) inf.id_valid |=> (inf.id_valid===0);
endproperty: id_valid_property

property act_valid_property;
    @(posedge clk) inf.act_valid |=> (inf.act_valid===0);
endproperty: act_valid_property

property item_valid_property;
    @(posedge clk) inf.item_valid |=> (inf.item_valid===0);
endproperty: item_valid_property

property num_valid_property;
    @(posedge clk) inf.num_valid |=> (inf.num_valid===0);
endproperty : num_valid_property

property amnt_valid_property;
    @(posedge clk) inf.amnt_valid |=> (inf.amnt_valid===0);
endproperty: amnt_valid_property

assert_5_id :assert property(@(posedge clk) inf.id_valid |-> (!inf.act_valid && !inf.item_valid && !inf.num_valid && !inf.amnt_valid))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end
assert_5_act :assert property(@(posedge clk) inf.act_valid |-> (!inf.id_valid && !inf.item_valid && !inf.num_valid && !inf.amnt_valid))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end
assert_5_item :assert property(@(posedge clk) inf.item_valid |-> (!inf.id_valid && !inf.act_valid && !inf.num_valid && !inf.amnt_valid))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end
assert_5_num :assert property(@(posedge clk) inf.num_valid |-> (!inf.id_valid && !inf.act_valid && !inf.item_valid && !inf.amnt_valid))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end
assert_5_amnt :assert property(@(posedge clk) inf.amnt_valid |-> (!inf.id_valid && !inf.act_valid && !inf.item_valid && !inf.num_valid))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end


logic id_enable,act_enable,item_enable,num_enable,amnt_enable;
logic [2:0] check_count;
Action cur_act;

assert_6_one_cylcle: assert property(@(negedge clk) (inf.id_valid || inf.act_valid || inf.item_valid || inf.num_valid || inf.amnt_valid) |=> (!inf.id_valid && !inf.act_valid && !inf.item_valid && !inf.num_valid && !inf.amnt_valid) )
else begin $display("Assertion 6 is violated"); $fatal; end
assert_6_no_act:assert property
     (@(negedge clk) (cur_act===0 && inf.id_valid) |=>(##[1:5] inf.act_valid))
else begin $display("Assertion 6 is violated"); $fatal; end
assert_6_buy:assert property
     (@(negedge clk) (cur_act===Buy && (inf.act_valid || inf.item_valid || inf.num_valid)) |=>(##[1:5] (inf.item_valid || inf.num_valid || inf.id_valid)))
else begin $display("Assertion 6 is violated"); $fatal; end
assert_6_deposit:assert property
     (@(negedge clk) (cur_act===Deposit && inf.act_valid ) |=>(##[1:5] inf.amnt_valid))
else begin $display("Assertion 6 is violated"); $fatal; end
assert_6_return:assert property
     (@(negedge clk) (cur_act===Return && (inf.act_valid || inf.item_valid || inf.num_valid)) |=>(##[1:5] (inf.item_valid || inf.num_valid || inf.id_valid)))
else begin $display("Assertion 6 is violated"); $fatal; end


assert_6_seq_id : assert property
    (@(negedge clk) id_enable ==0 |=> ##1 $stable(inf.id_valid))
    else begin $display("Assertion 6 is violated"); $fatal; end
assert_6_seq_act : assert property
    (@(negedge clk) act_enable ==0 |=> ##1 $stable(inf.act_valid))
    else begin $display("Assertion 6 is violated"); $fatal; end
assert_6_seq_item : assert property
    (@(posedge clk) item_enable ==0 |=> $stable(inf.item_valid))
    else begin $display("Assertion 6 is violated"); $fatal; end
assert_6_seq_num : assert property
    (@(posedge clk) num_enable ==0 |=> $stable(inf.num_valid))
    else begin $display("Assertion 6 is violated"); $fatal; end
assert_6_seq_amnt : assert property
    (@(posedge clk) amnt_enable ==0 |=> $stable(inf.amnt_valid))
    else begin $display("Assertion 6 is violated"); $fatal; end

logic first_i;
logic first_c,second_c;
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(!inf.rst_n)
        first_i<=0;
    else if(inf.id_valid )
        first_i<=1;
end
always_ff @( posedge clk or negedge inf.rst_n ) begin 
    if(!inf.rst_n)
        first_c<=0;
    else
        first_c<=1;
end
/*assert_6_reset_first:assert property
     (@(posedge clk) first_c===0 |-> $stable(inf.id_valid))
else begin $display("Assertion 6 is violated"); $fatal; end*/

assert_6_first_u:assert property
     (@(posedge clk) (first_c===0) |->(##[0:5] inf.id_valid))
else begin $display("Assertion 6 is violated"); $fatal; end
assert_6_first_c:assert property
     (@(posedge clk) first_i ==0 |=> $stable(inf.act_valid))
else begin $display("Assertion 6 is violated"); $fatal; end

always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(!inf.rst_n)
        cur_act<=0;
    else if(inf.act_valid)
        cur_act<=inf.D.d_act[0];
    else if(inf.out_valid)
        cur_act<=0;
end
always_ff @( posedge clk or negedge inf.rst_n) begin 
    if(!inf.rst_n)
        check_count<=0;
	else if(inf.out_valid)
		check_count <= 0;
    else if(inf.act_valid && inf.D.d_act[0]===Check)
        check_count<=0;
    else if(check_count<6 && cur_act===Check)
        check_count<=check_count+1;
	else
		check_count <= 0;
end

logic change_user_flag;

always_ff @(posedge clk or negedge inf.rst_n) begin 
	if(!inf.rst_n)begin
		change_user_flag <= 0;
	end
	else if(cur_act === Check && inf.id_valid)
		change_user_flag <= 1;
	else if(inf.out_valid)
		change_user_flag <= 0;
end

always_ff @( posedge clk or negedge inf.rst_n) begin
if(!inf.rst_n)
    id_enable <=1;
else if(inf.id_valid)
    id_enable<=0;
else if(inf.num_valid)
    id_enable<=1;
else if(inf.act_valid && inf.D.d_act[0]===Check)
    id_enable<=1;
else if(inf.out_valid)
    id_enable<=1;
else if(check_count==5 && cur_act===Check)
    id_enable<=0;
end
always_ff @( posedge clk or negedge inf.rst_n ) begin 
    if(!inf.rst_n)
        act_enable<=1;
    else if(inf.act_valid)
        act_enable<=0;
    else if(inf.out_valid)
        act_enable<=1;
    
end

always_ff @( posedge clk or negedge inf.rst_n ) begin 
    if(!inf.rst_n)
        item_enable<=0;
    else if(inf.act_valid && (inf.D.d_act[0]===Buy||inf.D.d_act[0]===Return))
        item_enable<=1;
    else if(inf.item_valid)
        item_enable<=0;
end
always_ff @( posedge clk or negedge inf.rst_n ) begin 
    if(!inf.rst_n)
        num_enable<=0;
    else if(inf.item_valid)
        num_enable<=1;
    else if(inf.num_valid)
        num_enable<=0;
end
always_ff @( posedge clk or negedge inf.rst_n ) begin 
    if(!inf.rst_n)
        amnt_enable<=0;
    else if(inf.act_valid && inf.D.d_act[0]===Deposit)
        amnt_enable<=1;
    else if(inf.amnt_valid)
        amnt_enable<=0;
end


assert_7 : assert property(@(negedge clk) inf.out_valid |=> inf.out_valid===0)
else begin
    $display("Assertion 7 is violated");
    $fatal;
end
assert_8_one_cycle :assert property (@(posedge clk) inf.out_valid |=> (!inf.id_valid && !inf.act_valid && !inf.item_valid && !inf.num_valid && !inf.amnt_valid))
else begin $display("Assertion 8 is violated"); $fatal; end
assert_8 : assert property(@(posedge clk) inf.out_valid |-> ##[2:10] (inf.id_valid || inf.act_valid))
else begin $display("Assertion 8 is violated"); $fatal; end

assert_9_buy : assert property(@(posedge clk) (cur_act==Buy && inf.id_valid) |=> (##[0:9999] inf.out_valid))
else begin $display("Assertion 9 is violated"); $fatal; end
assert_9_check : assert property(@(posedge clk) (cur_act==Check &&  inf.id_valid) |=> (##[0:9999] inf.out_valid))
else begin $display("Assertion 9 is violated"); $fatal; end
assert_9_check_2 : assert property(@(posedge clk) (cur_act==Check && check_count==6 && !change_user_flag) |=> (##[0:9992] inf.out_valid))
else begin $display("Assertion 9 is violated"); $fatal; end

assert_9_deposit : assert property(@(posedge clk) (cur_act==Deposit && inf.amnt_valid) |=> (##[0:9999] inf.out_valid))
else begin $display("Assertion 9 is violated"); $fatal; end
assert_9_return : assert property(@(posedge clk) (cur_act==Return && inf.id_valid) |=> (##[0:9999] inf.out_valid))
else begin $display("Assertion 9 is violated"); $fatal; end
endmodule



