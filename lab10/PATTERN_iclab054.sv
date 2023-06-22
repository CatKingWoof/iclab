`include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype_OS.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================
parameter PATNUM               = 160;
integer   SEED                 = 587;
//================================================================
// wire & registers 
//================================================================
integer       i;
integer       j;
integer       k;
integer       m;
integer    stop;
integer     pat;
integer exe_lat;
integer out_lat;
integer out_check_idx;
integer tot_lat;
integer input_delay;
integer each_delay;

Action golden_action;
Msg golden_msg;
Item_id golden_item;
User_id golden_user_id,golden_seller_id;
Item_num golden_num;
Money golden_money;

Item_num golden_user_large,golden_user_mid,golden_user_small,golden_seller_large,golden_seller_mid,golden_seller_small;
User_Level golden_user_level,golden_seller_level;
EXP golden_user_exp,golden_seller_exp;
Money golden_user_money,golden_seller_money;
Item_id golden_user_shop_item,golden_seller_shop_item;
Item_num golden_user_shop_num,golden_seller_shop_num;
User_id golden_user_shop_seller,golden_seller_shop_seller;
logic [31:0] golden_out;
logic golden_complete,comp;
logic [255:0] is_buyer,is_seller;
logic is_Check_Seller;
int b_user,c_user,d_user,r_user,b_seller,c_seller,r_seller;
//================================================================
// initial
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
logic [7:0] golden_DRAM[ ('h10000) : (('h10000+256*8)-1) ];
initial $readmemh( DRAM_p_r, golden_DRAM );
initial exe_task;

task exe_task; begin
    reset_task;
    dram_task;
    #(10);
    b_user=0;
    b_seller=80;
    c_user=190;
    c_seller=255;
    d_user=160;
    r_user=0;
    r_seller=80;
    @(negedge clk);
    for (pat=0 ; pat<20 ; pat=pat+2) begin
        b_task(b_user,Small,1,b_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;
        c_task(c_user,c_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;

        b_user=b_user+1;
        b_seller=b_seller+1;
        c_user=c_user+1;
        c_seller=c_seller-1;
    end
    for(pat=0 ; pat<20 ; pat=pat+2)begin
        b_task(b_user,Small,1,b_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;

        d_task(d_user,50000);
        complete_task;
        wb_task;
        wait_task;
        check_task;

        b_user=b_user+1;
        b_seller=b_seller+1;
        d_user=d_user+1;
    end
    for(pat=0 ; pat<20 ; pat=pat+2)begin
        b_task(b_user,Medium,1,b_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;

        r_task(r_user,Medium,1,r_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;

        b_user=b_user+1;
        b_seller=b_seller+1;
        r_user=r_user+1;
        r_seller=r_seller+1;
    end
    for(pat=0 ; pat<50 ; pat=pat+1)begin
        b_task(b_user,Large,1,b_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;

        b_user=b_user+1;
        b_seller=b_seller+1;
    end
    b_task(10,Large,1,90);
    complete_task;
    wb_task;
    wait_task;
    check_task;
    b_task(11,Large,1,91);
    complete_task;
    wb_task;
    wait_task;
    check_task;
    c_task2(10);
    complete_task;
    wb_task;
    wait_task;
    check_task;
    c_task2(91);
    complete_task;
    wb_task;
    wait_task;
    check_task;

    for(pat=0 ; pat<50 ; pat=pat+1)begin
        r_task(r_user,Large,1,r_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;

        r_user=r_user+1;
        r_seller=r_seller+1;
    end

    r_user=60;
    r_seller=140;
    for(pat=0 ; pat<20 ; pat=pat+2)begin
        c_task(c_user,c_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;

        d_task(d_user,40000);
        complete_task;
        wb_task;
        wait_task;
        check_task;

        c_user=c_user+1;
        c_seller=c_seller-1;
        d_user=d_user+1;
    end
    for(pat=0 ; pat<20 ; pat=pat+2)begin
        c_task(c_user,c_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;
        r_task(r_user,Large,1,r_seller-1);
        complete_task;
        wb_task;
        wait_task;
        check_task;
        r_task(r_user,Medium,1,r_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;
        r_task(r_user,Large,2,r_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;

        /*r_task(r_user,Large,1,r_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;*/

        c_user=c_user+1;
        c_seller=c_seller-1;
        r_user=r_user+1;
        r_seller=r_seller+1;
    end
    for(pat=220;pat<256;pat++)begin
        c_task(c_user,c_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;
        c_user=c_user+1;
        c_seller=c_seller-1;
    end
    for(pat=0 ; pat<20 ; pat=pat+2)begin
        d_task(d_user,30000);
        complete_task;
        wb_task;
        wait_task;
        check_task;
        r_task(r_user,Large,1,r_seller-1);
        complete_task;
        wb_task;
        wait_task;
        check_task;
        r_task(r_user,Medium,1,r_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;
        r_task(r_user,Large,2,r_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;

        /*r_task(r_user,Large,1,r_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;*/

        d_user=d_user+1;
        r_user=r_user+1;
        r_seller=r_seller+1;
    end
    for(pat=0 ; pat<20 ; pat=pat+1)begin
        d_task(d_user,20000);
        complete_task;
        wb_task;
        wait_task;
        check_task;
        d_user=d_user+1;
    end
    for(pat=0 ; pat<10 ; pat=pat+1)begin
        d_task(d_user,10000);
        complete_task;
        wb_task;
        wait_task;
        check_task;
        d_user=d_user+1;
    end

    c_user=100;
    c_seller=160;
    for(pat=0;pat<80;pat=pat+1)begin
        c_task2(c_user);
        complete_task;
        wb_task;
        wait_task;
        check_task;
        c_user=c_user+1;
    end
    for(pat=0;pat<50;pat=pat+1)begin
        c_task3(c_seller);
        complete_task;
        wb_task;
        wait_task;
        check_task;
        c_seller=c_seller+1;
    end
    d_task(200,20000);
    complete_task;
    wb_task;
    wait_task;
    check_task;
    b_task(200,Small,10,201);
    complete_task;
    wb_task;
    wait_task;
    check_task;
    r_task(200,Small,10,201);
    complete_task;
    wb_task;
    wait_task;
    check_task;
    b_task(200,Medium,63,201);
    complete_task;
    wb_task;
    wait_task;
    check_task;
    r_task(200,Medium,63,201);
    complete_task;
    wb_task;
    wait_task;
    check_task;
    b_task(200,Small,20,201);
    complete_task;
    wb_task;
    wait_task;
    check_task;
    b_task(200,Large,63,201);
    complete_task;
    wb_task;
    wait_task;
    check_task;
    r_task(200,Large,63,201);
    complete_task;
    wb_task;
    wait_task;
    check_task;
    c_task2(200);
    complete_task;
    wb_task;
    wait_task;
    check_task;
    c_task2(201);
    complete_task;
    wb_task;
    wait_task;
    check_task;
    $finish;
end endtask

task reset_task; begin
    for(i = 0; i<256; i=i+1)
    begin
        is_buyer[i]=0;
        is_seller[i]=0;
    end
            
    inf.rst_n      = 1;
    inf.id_valid   = 0;
    inf.act_valid  = 0;
    inf.item_valid = 0;
    inf.num_valid  = 0;
    inf.amnt_valid = 0;
    inf.D        = 'dx;
    #(10) inf.rst_n = 0;
    #(10) inf.rst_n = 1;
end endtask

task b_task(input int user,int item,int num,int seller); begin
    inf.id_valid=1;//
    
    inf.D=user;
    golden_user_id=inf.D;
    get_user_info;
    @(negedge clk);
    inf.id_valid=0;
    inf.D='bx;
    @(negedge clk);
    inf.act_valid=1;//
    inf.D=Buy;
    golden_action=inf.D;
    @(negedge clk);
    inf.act_valid=0;
    inf.D='bx;
    @(negedge clk);
    inf.item_valid=1;//
    inf.D=item;
    golden_item=inf.D;
    @(negedge clk);
    inf.item_valid=0;
    inf.D='bx;
    @(negedge clk);
    inf.num_valid=1;//
    inf.D=num;
    golden_num=inf.D;
    @(negedge clk);
    inf.num_valid=0;
    inf.D='bx;
    @(negedge clk);
    inf.id_valid=1;
    inf.D=seller;
    golden_seller_id=inf.D;
    get_seller_info;
    @(negedge clk);
    inf.id_valid=0;
    inf.D='bx;
end endtask

task c_task(input int user,int seller); begin
    is_Check_Seller=1;
    inf.id_valid=1;
    inf.D=user;
    golden_user_id=inf.D;
    get_user_info;
    @(negedge clk);
    inf.id_valid=0;
    inf.D='bx;
    @(negedge clk);
    inf.act_valid=1;
    inf.D=Check;
    golden_action=inf.D;
    @(negedge clk);
    inf.act_valid=0;
    inf.D='bx;
    @(negedge clk);
    inf.id_valid=1;
    inf.D=seller;
    golden_seller_id=inf.D;
    get_seller_info;
    @(negedge clk);
    inf.id_valid=0;
    inf.D='bx;
end endtask

task c_task2(input int user); begin
    is_Check_Seller=0;
    inf.id_valid=1;
    inf.D=user;
    golden_user_id=inf.D;
    get_user_info;
    @(negedge clk);
    inf.id_valid=0;
    inf.D='bx;
    @(negedge clk);
    inf.act_valid=1;
    inf.D=Check;
    golden_action=inf.D;
    @(negedge clk);
    inf.act_valid=0;
    inf.D='bx;
end endtask
task c_task3(input int seller); begin
    is_Check_Seller=1;
    inf.act_valid=1;
    inf.D=Check;
    golden_action=inf.D;
    @(negedge clk);
    inf.act_valid=0;
    inf.D='bx;
    @(negedge clk);
    inf.id_valid=1;
    inf.D=seller;
    golden_seller_id=inf.D;
    get_seller_info;
    @(negedge clk);
    inf.id_valid=0;
    inf.D='bx;
end endtask

task d_task(input int user,int money); begin
    inf.id_valid=1;
    inf.D=user;
    golden_user_id=inf.D;
    get_user_info;
    @(negedge clk);
    inf.id_valid=0;
    inf.D='bx;
    @(negedge clk);
    inf.act_valid=1;
    inf.D=Deposit;
    golden_action=inf.D;
    @(negedge clk);
    inf.act_valid=0;
    inf.D='bx;
    @(negedge clk);
    inf.amnt_valid=1;//
    inf.D=money;
    golden_money=inf.D;
    @(negedge clk);
    inf.amnt_valid=0;
    inf.D='bx;
end endtask

task r_task(input int user,int item,int num,int seller); begin
    inf.id_valid=1;
    inf.D=user;
    golden_user_id=inf.D;
    get_user_info;
    get_shop_seller_info;
    @(negedge clk);
    inf.id_valid=0;
    inf.D='bx;
    @(negedge clk);
    inf.act_valid=1;
    inf.D=Return;
    golden_action=inf.D;
    @(negedge clk);
    inf.act_valid=0;
    inf.D='bx;
    @(negedge clk);
    inf.item_valid=1;
    inf.D=item;
    golden_item=inf.D;
    @(negedge clk);
    inf.item_valid=0;
    inf.D='bx;
    @(negedge clk);
    inf.num_valid=1;
    inf.D=num;
    golden_num=inf.D;
    @(negedge clk);
    inf.num_valid=0;
    inf.D='bx;
    @(negedge clk);
    inf.id_valid=1;
    inf.D=seller;
    golden_seller_id=inf.D;
    @(negedge clk);
    inf.id_valid=0;
    inf.D='bx;
end endtask



task complete_task; begin 
    if(golden_action==Buy)
    begin
        if(golden_item==Large)
        begin
            if(golden_user_large+golden_num > 63)
            begin
                 comp=0;  
                 golden_msg= INV_Full; 
            end
            else if(golden_seller_large<golden_num)
            begin
               comp=0;
               golden_msg= INV_Not_Enough;
            end
            else
            begin
                if(golden_user_level==Platinum)
                begin
                    if(golden_user_money < golden_num*300+10)
                    begin
                        comp=0;
                        golden_msg=Out_of_money;
                    end
                    else
                        comp=1;
                end
                else if(golden_user_level==Gold)
                begin
                    if(golden_user_money < golden_num*300+30)
                    begin
                        comp=0;
                        golden_msg=Out_of_money;
                    end
                    else
                        comp=1;
                end
                else if(golden_user_level==Silver)
                begin
                    if(golden_user_money < golden_num*300+50)
                    begin
                        comp=0;
                        golden_msg=Out_of_money;
                    end
                    else
                        comp=1;
                end
                else if(golden_user_level==Copper)
                begin
                    if(golden_user_money < golden_num*300+70)
                    begin
                        comp=0;
                        golden_msg=Out_of_money;
                    end
                    else
                        comp=1;
                end
                else 
                    comp=1;
            end 
        end
        else if(golden_item==Medium)
        begin
            if(golden_user_mid+golden_num > 63)
            begin
                 comp=0; 
                  golden_msg= INV_Full;
            end
            else if(golden_seller_mid<golden_num)
            begin
               comp=0;
               golden_msg= INV_Not_Enough;
            end
            else
            begin
                if(golden_user_level==Platinum)
                begin
                    if(golden_user_money < golden_num*200+10)
                    begin
                        comp=0;
                        golden_msg=Out_of_money;
                    end
                    else   
                        comp=1;
                end
                else if(golden_user_level==Gold)
                begin
                    if(golden_user_money < golden_num*200+30)
                    begin
                        comp=0;
                        golden_msg=Out_of_money;
                    end
                    else
                        comp=1;
                end
                else if(golden_user_level==Silver)
                begin
                    if(golden_user_money < golden_num*200+50)
                    begin
                        comp=0;
                        golden_msg=Out_of_money;
                    end
                    else
                        comp=1;
                end
                else if(golden_user_level==Copper)
                begin
                    if(golden_user_money < golden_num*200+70)
                    begin
                        comp=0;
                        golden_msg=Out_of_money;
                    end
                    else 
                        comp=1;
                end
                else
                    comp=1;
            end 
        end 
        else if(golden_item==Small)
        begin
            if(golden_user_small+golden_num > 63)
            begin
                 comp=0;  
                 golden_msg= INV_Full;
            end
            else if(golden_seller_small<golden_num)
            begin
               comp=0;
               golden_msg= INV_Not_Enough;
            end
            else
            begin
                if(golden_user_level==Platinum)
                begin
                    if(golden_user_money < golden_num*100+10)
                    begin
                        comp=0;
                        golden_msg=Out_of_money;
                    end
                    else
                        comp=1;
                end
                else if(golden_user_level==Gold)
                begin
                    if(golden_user_money < golden_num*100+30)
                    begin
                        comp=0;
                        golden_msg=Out_of_money;
                    end
                    else
                        comp=1;
                end
                else if(golden_user_level==Silver)
                begin
                    if(golden_user_money < golden_num*100+50)
                    begin
                        comp=0;
                        golden_msg=Out_of_money;
                    end
                    else
                        comp=1;
                end
                else if(golden_user_level==Copper)
                begin
                    if(golden_user_money < golden_num*100+70)
                    begin
                        comp=0;
                        golden_msg=Out_of_money;
                    end
                    else
                        comp=1;
                end
                else
                    comp=1;
            end 
        end
        else
            comp=1;
    end
    else if(golden_action==Deposit)
    begin
        if(golden_user_money+golden_money > 65535 )
        begin
            comp=0;
            golden_msg=Wallet_is_Full;
        end
        else
            comp=1;
    end
    else if(golden_action==Return)
    begin
        if(is_buyer[golden_user_id]!=1 || is_seller[golden_user_shop_seller]!=1 || (golden_seller_shop_seller!=golden_user_id))
        begin
            comp=0;
            golden_msg=Wrong_act;
        end
        else if((golden_user_shop_seller != golden_seller_id) )
        begin
            comp=0;
            golden_msg=Wrong_ID;
        end
        else if(golden_num!=golden_user_shop_num)
        begin
            comp=0;
            golden_msg=Wrong_Num;
        end
        else if(golden_item != golden_user_shop_item)
        begin
            comp=0;
            golden_msg=Wrong_Item;
        end
        else
            comp=1;
    end
    else
        comp=1;
end endtask

task wb_task;begin
    if(golden_action==Buy&&comp==1)
    begin
        is_buyer[golden_user_id]=1;
        is_buyer[golden_seller_id]=0;
        is_seller[golden_user_id]=0;
        is_seller[golden_seller_id]=1;
        wb_buy_user;
        wb_buy_seller;
    end 
    else if(golden_action==Check&&comp==1)
    begin
        is_buyer[golden_user_id]=0;
        if(is_Check_Seller)
        begin
            is_buyer[golden_seller_id]=0;
        end
        is_seller[golden_user_id]=0;
        if(is_Check_Seller)
        begin
            is_seller[golden_seller_id]=0;
        end
    end 
    else if(golden_action==Deposit&&comp==1)
    begin
        is_buyer[golden_user_id]=0;
        is_seller[golden_user_id]=0;
        wb_deposit;
    end 
    else if(golden_action==Return&&comp==1)
    begin
        is_buyer[golden_user_id]=0;
        is_buyer[golden_seller_id]=0;
        is_seller[golden_user_id]=0;
        is_seller[golden_seller_id]=0;
        wb_return_user;
        wb_return_seller;
    end 
end endtask

task wb_buy_user;begin
    if(golden_item==Large)
    begin
        golden_user_large= golden_user_large +golden_num;
        golden_user_mid=golden_user_mid;
        golden_user_small= golden_user_small;
        if(golden_user_level==Platinum)
        begin
            golden_user_level=Platinum;
            golden_user_exp=0;
            golden_user_money= golden_user_money-300*golden_num -10;
        end
        else if(golden_user_level==Gold)
        begin
            if(golden_user_exp + 60*golden_num >=4000)
            begin
                golden_user_level=Platinum;
                golden_user_exp=0;
            end
            else
            begin
                golden_user_level=Gold;
                golden_user_exp=golden_user_exp + 60*golden_num;
            end
            golden_user_money=golden_user_money -300*golden_num -30;
        end
        else if(golden_user_level==Silver)
        begin
            if(golden_user_exp + 60*golden_num >=2500)
            begin
                golden_user_level=Gold;
                golden_user_exp=0;
            end
            else
            begin
                golden_user_level=Silver;
                golden_user_exp=golden_user_exp + 60*golden_num;
            end
            golden_user_money=golden_user_money -300*golden_num -50;
        end
        else if(golden_user_level==Copper)
        begin
            if(golden_user_exp + 60*golden_num >=1000)
            begin
                golden_user_level=Silver;
                golden_user_exp=0;
            end
            else
            begin
                golden_user_level=Copper;
                golden_user_exp=golden_user_exp + 60*golden_num;
            end
            golden_user_money=golden_user_money -300*golden_num -70;
        end
    end
    else if(golden_item==Medium)
    begin
        golden_user_large= golden_user_large;
        golden_user_mid=golden_user_mid+golden_num;
        golden_user_small= golden_user_small;
        if(golden_user_level==Platinum)
        begin
            golden_user_level=Platinum;
            golden_user_exp=0;
            golden_user_money= golden_user_money-200*golden_num -10;
        end
        else if(golden_user_level==Gold)
        begin
            if(golden_user_exp + 40*golden_num >=4000)
            begin
                golden_user_level=Platinum;
                golden_user_exp=0;
            end
            else
            begin
                golden_user_level=Gold;
                golden_user_exp=golden_user_exp + 40*golden_num;
            end
            golden_user_money=golden_user_money -200*golden_num -30;
        end
        else if(golden_user_level==Silver)
        begin
            if(golden_user_exp + 40*golden_num >=2500)
            begin
                golden_user_level=Gold;
                golden_user_exp=0;
            end
            else
            begin
                golden_user_level=Silver;
                golden_user_exp=golden_user_exp + 40*golden_num;
            end
            golden_user_money=golden_user_money -200*golden_num -50;
        end
        else if(golden_user_level==Copper)
        begin
            if(golden_user_exp + 40*golden_num >=1000)
            begin
                golden_user_level=Silver;
                golden_user_exp=0;
            end
            else
            begin
                golden_user_level=Copper;
                golden_user_exp=golden_user_exp + 40*golden_num;
            end
            golden_user_money=golden_user_money -200*golden_num -70;
        end
    end
    else if(golden_item==Small)
    begin
        golden_user_large= golden_user_large;
        golden_user_mid=golden_user_mid;
        golden_user_small= golden_user_small+golden_num;
        if(golden_user_level==Platinum)
        begin
            golden_user_level=Platinum;
            golden_user_exp=0;
            golden_user_money= golden_user_money-100*golden_num -10;
        end
        else if(golden_user_level==Gold)
        begin
            if(golden_user_exp + 20*golden_num >=4000)
            begin
                golden_user_level=Platinum;
                golden_user_exp=0;
            end
            else
            begin
                golden_user_level=Gold;
                golden_user_exp=golden_user_exp + 20*golden_num;
            end
            golden_user_money=golden_user_money -100*golden_num -30;
        end
        else if(golden_user_level==Silver)
        begin
            if(golden_user_exp + 20*golden_num >=2500)
            begin
                golden_user_level=Gold;
                golden_user_exp=0;
            end
            else
            begin
                golden_user_level=Silver;
                golden_user_exp=golden_user_exp + 20*golden_num;
            end
            golden_user_money=golden_user_money -100*golden_num -50;
        end
        else if(golden_user_level==Copper)
        begin
            if(golden_user_exp + 20*golden_num >=1000)
            begin
                golden_user_level=Silver;
                golden_user_exp=0;
            end
            else
            begin
                golden_user_level=Copper;
                golden_user_exp=golden_user_exp + 20*golden_num;
            end
            golden_user_money=golden_user_money -100*golden_num -70;
        end
    end
    golden_user_shop_item=golden_item;
    golden_user_shop_num=golden_num;
    golden_user_shop_seller=golden_seller_id;
    golden_DRAM['h10000+golden_user_id*8][7:2] =golden_user_large;                                                   
    {golden_DRAM['h10000+golden_user_id*8][1:0],golden_DRAM['h10000+golden_user_id*8+1][7:4]} =golden_user_mid;
    {golden_DRAM['h10000+golden_user_id*8+1][3:0],golden_DRAM['h10000+golden_user_id*8+2][7:6]} =golden_user_small;
    golden_DRAM['h10000+golden_user_id*8+2][5:4]  =golden_user_level;
    {golden_DRAM['h10000+golden_user_id*8+2][3:0],golden_DRAM['h10000+golden_user_id*8+3]} =golden_user_exp;
    {golden_DRAM['h10000+golden_user_id*8+4],golden_DRAM['h10000+golden_user_id*8+5]} =golden_user_money;
    golden_DRAM['h10000+golden_user_id*8+6][7:6] =golden_user_shop_item;
    golden_DRAM['h10000+golden_user_id*8+6][5:0] =golden_user_shop_num;
    golden_DRAM['h10000+golden_user_id*8+7] =golden_user_shop_seller;
end endtask

task wb_buy_seller;begin
    if(golden_item==Large)
    begin
        golden_seller_large= golden_seller_large-golden_num;
        golden_seller_mid=golden_seller_mid;
        golden_user_small= golden_user_small;
        if(golden_seller_money+300*golden_num >= 65535)
            golden_seller_money=65535;
        else 
            golden_seller_money=golden_seller_money +300*golden_num;
    end
    else if(golden_item==Medium)
    begin
        golden_seller_large= golden_seller_large;
        golden_seller_mid=golden_seller_mid-golden_num;
        golden_seller_small= golden_seller_small;
        if(golden_seller_money+200*golden_num >= 65535)
            golden_seller_money=65535;
        else 
            golden_seller_money=golden_seller_money +200*golden_num;
    end
    else if(golden_item==Small)
    begin
        golden_seller_large= golden_seller_large;
        golden_seller_mid=golden_seller_mid;
        golden_seller_small= golden_seller_small-golden_num;
        if(golden_seller_money+100*golden_num >= 65535)
            golden_seller_money=65535;
        else 
            golden_seller_money=golden_seller_money +100*golden_num;
    end
    golden_seller_shop_seller=golden_user_id;
    golden_DRAM['h10000+golden_seller_id*8][7:2] =golden_seller_large;                                                   
    {golden_DRAM['h10000+golden_seller_id*8][1:0],golden_DRAM['h10000+golden_seller_id*8+1][7:4]} =golden_seller_mid;
    {golden_DRAM['h10000+golden_seller_id*8+1][3:0],golden_DRAM['h10000+golden_seller_id*8+2][7:6]} =golden_seller_small;
    golden_DRAM['h10000+golden_seller_id*8+2][5:4]  =golden_seller_level;
    {golden_DRAM['h10000+golden_seller_id*8+2][3:0],golden_DRAM['h10000+golden_seller_id*8+3]} =golden_seller_exp;
    {golden_DRAM['h10000+golden_seller_id*8+4],golden_DRAM['h10000+golden_seller_id*8+5]} =golden_seller_money;
    golden_DRAM['h10000+golden_seller_id*8+6][7:6] =golden_seller_shop_item;
    golden_DRAM['h10000+golden_seller_id*8+6][5:0] =golden_seller_shop_num;
    golden_DRAM['h10000+golden_seller_id*8+7] =golden_seller_shop_seller;
end endtask

task wb_deposit;begin
    golden_user_money=golden_user_money+golden_money;

    golden_DRAM['h10000+golden_user_id*8][7:2] =golden_user_large;                                                   
    {golden_DRAM['h10000+golden_user_id*8][1:0],golden_DRAM['h10000+golden_user_id*8+1][7:4]} =golden_user_mid;
    {golden_DRAM['h10000+golden_user_id*8+1][3:0],golden_DRAM['h10000+golden_user_id*8+2][7:6]} =golden_user_small;
    golden_DRAM['h10000+golden_user_id*8+2][5:4]  =golden_user_level;
    {golden_DRAM['h10000+golden_user_id*8+2][3:0],golden_DRAM['h10000+golden_user_id*8+3]} =golden_user_exp;
    {golden_DRAM['h10000+golden_user_id*8+4],golden_DRAM['h10000+golden_user_id*8+5]} =golden_user_money;
    golden_DRAM['h10000+golden_user_id*8+6][7:6] =golden_user_shop_item;
    golden_DRAM['h10000+golden_user_id*8+6][5:0] =golden_user_shop_num;
    golden_DRAM['h10000+golden_user_id*8+7] =golden_user_shop_seller;
end endtask

task wb_return_user;begin
    if(golden_item==Large)
    begin
        golden_user_large= golden_user_large-golden_num;
        golden_user_mid=golden_user_mid;
        golden_user_small= golden_user_small;
        if(golden_user_money+300*golden_num >= 65535)
            golden_user_money=65535;
        else 
            golden_user_money=golden_user_money +300*golden_num;
    end
    else if(golden_item==Medium)
    begin
        golden_user_large= golden_user_large;
        golden_user_mid=golden_user_mid-golden_num;
        golden_user_small= golden_user_small;
        if(golden_user_money+200*golden_num >= 65535)
            golden_user_money=65535;
        else 
            golden_user_money=golden_user_money +200*golden_num;
    end
    else if(golden_item==Small)
    begin
        golden_user_large= golden_user_large;
        golden_user_mid=golden_user_mid;
        golden_user_small= golden_user_small-golden_num;
        if(golden_user_money+100*golden_num >= 65535)
            golden_user_money=65535;
        else 
            golden_user_money=golden_user_money +100*golden_num;
    end
    golden_DRAM['h10000+golden_user_id*8][7:2] =golden_user_large;                                                   
    {golden_DRAM['h10000+golden_user_id*8][1:0],golden_DRAM['h10000+golden_user_id*8+1][7:4]} =golden_user_mid;
    {golden_DRAM['h10000+golden_user_id*8+1][3:0],golden_DRAM['h10000+golden_user_id*8+2][7:6]} =golden_user_small;
    golden_DRAM['h10000+golden_user_id*8+2][5:4]  =golden_user_level;
    {golden_DRAM['h10000+golden_user_id*8+2][3:0],golden_DRAM['h10000+golden_user_id*8+3]} =golden_user_exp;
    {golden_DRAM['h10000+golden_user_id*8+4],golden_DRAM['h10000+golden_user_id*8+5]} =golden_user_money;
    golden_DRAM['h10000+golden_user_id*8+6][7:6] =golden_user_shop_item;
    golden_DRAM['h10000+golden_user_id*8+6][5:0] =golden_user_shop_num;
    golden_DRAM['h10000+golden_user_id*8+7] =golden_user_shop_seller;
end endtask

task wb_return_seller;begin
    if(golden_item==Large)
    begin
        golden_seller_large= golden_seller_large+golden_num;
        golden_seller_mid=golden_seller_mid;
        golden_user_small= golden_user_small;
        golden_seller_money=golden_seller_money -300*golden_num;
    end
    else if(golden_item==Medium)
    begin
        golden_seller_large= golden_seller_large;
        golden_seller_mid=golden_seller_mid+golden_num;
        golden_seller_small= golden_seller_small;
        golden_seller_money=golden_seller_money -200*golden_num;
    end
    else if(golden_item==Small)
    begin
        golden_seller_large= golden_seller_large;
        golden_seller_mid=golden_seller_mid;
        golden_seller_small= golden_seller_small+golden_num;
        golden_seller_money=golden_seller_money -100*golden_num;
    end
    golden_DRAM['h10000+golden_seller_id*8][7:2] =golden_seller_large;                                                   
    {golden_DRAM['h10000+golden_seller_id*8][1:0],golden_DRAM['h10000+golden_seller_id*8+1][7:4]} =golden_seller_mid;
    {golden_DRAM['h10000+golden_seller_id*8+1][3:0],golden_DRAM['h10000+golden_seller_id*8+2][7:6]} =golden_seller_small;
    golden_DRAM['h10000+golden_seller_id*8+2][5:4]  =golden_seller_level;
    {golden_DRAM['h10000+golden_seller_id*8+2][3:0],golden_DRAM['h10000+golden_seller_id*8+3]} =golden_seller_exp;
    {golden_DRAM['h10000+golden_seller_id*8+4],golden_DRAM['h10000+golden_seller_id*8+5]} =golden_seller_money;
    golden_DRAM['h10000+golden_seller_id*8+6][7:6] =golden_seller_shop_item;
    golden_DRAM['h10000+golden_seller_id*8+6][5:0] =golden_seller_shop_num;
    golden_DRAM['h10000+golden_seller_id*8+7] =golden_seller_shop_seller;
end endtask


task wait_task; begin
    while(inf.out_valid !== 1)
    begin
        @(negedge clk);
    end
end endtask

task check_task; begin
    if(inf.out_valid === 1) begin
            if(golden_action==Buy)
            begin
                if(comp)
                begin
                    if(inf.err_msg !== 0 || inf.complete!==1 || inf.out_info !== {golden_user_money,golden_item,golden_num,golden_seller_id})
                    begin
                        $display("Wrong Answer");
                        $fatal;
                    end
                end
                else if(!comp)
                begin
                    if(inf.err_msg !== golden_msg || inf.complete !==0 || inf.out_info !== 0)
                    begin
                        $display("Wrong Answer");
                        $fatal;
                    end
                end
            end
            else if(golden_action==Check)
            begin
                if(is_Check_Seller)
                begin
                    if(inf.err_msg !== 0 || inf.complete!==1 || inf.out_info !== {golden_seller_large,golden_seller_mid,golden_seller_small})
                    begin
                        $display("Wrong Answer");
                        $fatal;
                    end
                end
                else if(!is_Check_Seller)
                begin
                    if(inf.err_msg !== 0 || inf.complete !==1 || inf.out_info !== {golden_user_money})
                    begin
                        $display("Wrong Answer");
                        $fatal;
                    end
                end
            end
            else if (golden_action==Deposit)
            begin
                if(comp)
                begin
                    if(inf.err_msg !== 0 || inf.complete!==1 || inf.out_info !== {golden_user_money})
                    begin
                        $display("Wrong Answer");
                        $fatal;
                    end
                end
                else if(!comp)
                begin
                    if(inf.err_msg !== golden_msg || inf.complete !==0 || inf.out_info !== 0)
                    begin
                        $display("Wrong Answer");
                        $fatal;
                    end
                end
            end
            else if(golden_action==Return)
            begin
                if(comp)
                begin
                    if(inf.err_msg !== 0 || inf.complete!==1 || inf.out_info !== {golden_user_large,golden_user_mid,golden_user_small})
                    begin
                        $display("Wrong Answer");
                        $fatal;
                    end
                end
                else if(!comp)
                begin
                    if(inf.err_msg !== golden_msg || inf.complete !==0 || inf.out_info !== 0)
                    begin
                        $display("Wrong Answer");
                        $fatal;
                    end
                end
            end
        @(negedge clk);
        @(negedge clk);
    end
end endtask

task get_user_info;
begin
    golden_user_large=golden_DRAM['h10000+golden_user_id*8][7:2];
    golden_user_mid = {golden_DRAM['h10000+golden_user_id*8][1:0],golden_DRAM['h10000+golden_user_id*8+1][7:4]};
    golden_user_small= {golden_DRAM['h10000+golden_user_id*8+1][3:0],golden_DRAM['h10000+golden_user_id*8+2][7:6]};
    golden_user_level= golden_DRAM['h10000+golden_user_id*8+2][5:4];
    golden_user_exp = {golden_DRAM['h10000+golden_user_id*8+2][3:0],golden_DRAM['h10000+golden_user_id*8+3]};
    golden_user_money={golden_DRAM['h10000+golden_user_id*8+4],golden_DRAM['h10000+golden_user_id*8+5]};
    golden_user_shop_item=golden_DRAM['h10000+golden_user_id*8+6][7:6];
    golden_user_shop_num=golden_DRAM['h10000+golden_user_id*8+6][5:0];
    golden_user_shop_seller=golden_DRAM['h10000+golden_user_id*8+7];
end endtask

task get_seller_info;
begin
    golden_seller_large=golden_DRAM['h10000+golden_seller_id*8][7:2];
    golden_seller_mid = {golden_DRAM['h10000+golden_seller_id*8][1:0],golden_DRAM['h10000+golden_seller_id*8+1][7:4]};
    golden_seller_small= {golden_DRAM['h10000+golden_seller_id*8+1][3:0],golden_DRAM['h10000+golden_seller_id*8+2][7:6]};
    golden_seller_level= golden_DRAM['h10000+golden_seller_id*8+2][5:4];
    golden_seller_exp = {golden_DRAM['h10000+golden_seller_id*8+2][3:0],golden_DRAM['h10000+golden_seller_id*8+3]};
    golden_seller_money={golden_DRAM['h10000+golden_seller_id*8+4],golden_DRAM['h10000+golden_seller_id*8+5]};
    golden_seller_shop_item=golden_DRAM['h10000+golden_seller_id*8+6][7:6];
    golden_seller_shop_num=golden_DRAM['h10000+golden_seller_id*8+6][5:0];
    golden_seller_shop_seller=golden_DRAM['h10000+golden_seller_id*8+7];
end endtask
task get_shop_seller_info;
begin
    golden_seller_large=golden_DRAM['h10000+golden_user_shop_seller*8][7:2];
    golden_seller_mid = {golden_DRAM['h10000+golden_user_shop_seller*8][1:0],golden_DRAM['h10000+golden_user_shop_seller*8+1][7:4]};
    golden_seller_small= {golden_DRAM['h10000+golden_user_shop_seller*8+1][3:0],golden_DRAM['h10000+golden_user_shop_seller*8+2][7:6]};
    golden_seller_level= golden_DRAM['h10000+golden_user_shop_seller*8+2][5:4];
    golden_seller_exp = {golden_DRAM['h10000+golden_user_shop_seller*8+2][3:0],golden_DRAM['h10000+golden_user_shop_seller*8+3]};
    golden_seller_money={golden_DRAM['h10000+golden_user_shop_seller*8+4],golden_DRAM['h10000+golden_user_shop_seller*8+5]};
    golden_seller_shop_item=golden_DRAM['h10000+golden_user_shop_seller*8+6][7:6];
    golden_seller_shop_num=golden_DRAM['h10000+golden_user_shop_seller*8+6][5:0];
    golden_seller_shop_seller=golden_DRAM['h10000+golden_user_shop_seller*8+7];
end endtask

integer file_dram,addr;
logic [31:0] data;
integer  SEED_DRAM = 50;
integer id_address=0;
task dram_task; begin
    file_dram = $fopen(DRAM_p_r,"w");
    for(addr='h10000 ; addr<='h107ff ; addr=addr+'h4) begin
            $fwrite(file_dram, "@%5h\n", addr);
            
            data = {$random(SEED_DRAM)};
            if(id_address/2 <20)
            begin
                if(id_address%2 ==0)
                    data[19:14]=0;
            end
            else if(id_address/2 >=20  && id_address/2 <40)
            begin
                if(id_address%2 ==1)
                    data[31:16]=0;
            end
            else if(id_address/2 >= 40  && id_address/2 < 60)
            begin
                if(id_address%2 ==0)
                    data[31:26]=63;
            end
            else if(id_address/2 >= 60  && id_address/2 < 80)
            begin
                if(id_address%2 ==0)
                    data[31:26]=50;
            end
            else if(id_address/2 >= 80  && id_address/2 < 100)
            begin
                if(id_address%2 ==0)
                    data[19:14]=0;
            end
            else if(id_address/2 >= 140  && id_address/2 < 160)
            begin
                if(id_address%2 ==0)
                    data[31:26]=50;
            end
            else if(id_address/2 >= 160  && id_address/2 < 189)
            begin
                if(id_address%2 ==1)
                    data[31:16]=65535;
            end
            else if(id_address/2 == 200)
            begin
                if(id_address%2 ==0)
                begin
                     data[31:26]=0;
                     data[25:20]=0;
                     data[19:14]=0;
                     data[13:12]=Copper;
                     data[11:0]=900; 
                end
                else if(id_address%2 ==1)
                begin
                    data[31:16]=0;
                end
            end
            else if(id_address/2 == 201)
            begin
                if(id_address%2 ==0)
                begin
                     data[31:26]=63;
                     data[25:20]=63;
                     data[19:14]=63;
                end
                else if(id_address%2 ==1)
                begin
                    data[31:16]=65535;
                end
            end
            $fwrite(file_dram, "%h ", data[31:24]);
            $fwrite(file_dram, "%h ", data[23:16]);
            $fwrite(file_dram, "%h ", data[15:8]);
            $fwrite(file_dram, "%h\n", data[7:0]);
            id_address=id_address+1;

        end
end endtask
endprogram