module OS(input clk, INF.OS_inf inf);
import usertype::*;
//parameter
parameter IDLE = 0,
          CHANGE_USER=1,
          CHANGE_ACT=2,

          B_WAIT=3,
          B_USER=4,
          B_SELL=5,
          B_ERR=6,
          B_WB_SELL=7,
          B_WB_USER=8,
          B_OUT=9,

          C_WAIT=10,
          C_SELL=11,
          C_OUT1=12,
          C_USER=13,
          C_OUT2=14,
          D_WAIT=15,
          D_USER=16,
          D_ERR=17,
          D_WB=18,
          D_OUT=19,
          R_WAIT=20,
          R_USER=21,
          R_SELL=22,
          R_ERR=23,
          R_WB_SELL=24,
          R_WB_USER=25,
          R_OUT=26,
          ERR_OUT=27;


//logic
Action cur_act ;
User_id cur_id,sell_id ;
Item_id cur_item_id;
Item_num cur_item_num;
Msg  Err_message;
logic [5:0] current_state,next_state;
logic [2:0] count;
logic first_ask_n;
Money deposit_money;
logic comp;
logic is_buyer[255:0],is_seller[255:0];
logic [17:0] d_money;
logic [6:0] d_inv;
logic [13:0] d_exp;
//reg amnt_ready,out_valid_ready,seller_ready;


Item_num large_num,mid_num,small_num,shop_item_num;
User_Level user_level;
EXP exp;
Money money;
Item_id shop_item_id;
User_id shop_seller_id;
assign large_num= inf.C_data_r[7:2];
assign mid_num={inf.C_data_r[1:0],inf.C_data_r[15:12]};
assign small_num={inf.C_data_r[11:8],inf.C_data_r[23:22]};
assign user_level={inf.C_data_r[21:20]};
assign exp={inf.C_data_r[19:16],inf.C_data_r[31:24]};

assign money={inf.C_data_r[39:32],inf.C_data_r[47:40]};
assign shop_item_id=inf.C_data_r[55:54];
assign shop_item_num=inf.C_data_r[53:48];
assign shop_seller_id=inf.C_data_r[63:56];

Item_num buyer_large_num,buyer_mid_num,buyer_small_num,buyer_shop_item_num;
User_Level buyer_user_level;
EXP buyer_exp;
Money buyer_money;
Item_id buyer_shop_item_id;
User_id buyer_shop_seller_id;

always_ff @( posedge clk or negedge inf.rst_n) begin
              if(!inf.rst_n)
              begin
                  buyer_large_num<=0;
                  buyer_mid_num<=0;
                  buyer_small_num<=0;
                  buyer_user_level<=0;
                  buyer_exp<=0;
                  buyer_money<=0;
                  buyer_shop_item_id<=0;
                  buyer_shop_item_num<=0;
                  buyer_shop_seller_id<=0;
              end
              else
                  if((current_state==B_SELL||current_state==R_SELL) && !first_ask_n)
                  begin
                      buyer_large_num<=large_num;
                      buyer_mid_num<=mid_num;
                      buyer_small_num<=small_num;
                      buyer_user_level<=user_level;
                      buyer_exp<=exp;
                      buyer_money<=money;
                      buyer_shop_item_id<=shop_item_id;
                      buyer_shop_item_num<=shop_item_num;
                      buyer_shop_seller_id<=shop_seller_id;
                  end
                  else if(current_state==B_ERR)
                  begin
                      if(cur_item_id==1)
                      begin
                          buyer_large_num<=buyer_large_num+cur_item_num;
                          buyer_mid_num<=buyer_mid_num;
                          buyer_small_num<=buyer_small_num;

                          if(buyer_user_level==0)
                          begin
                              buyer_user_level<=Platinum;
                              buyer_exp<=0;
                              buyer_money<=buyer_money - 300*cur_item_num - 10;
                          end
                          else if(buyer_user_level==1)
                          begin
                              if(d_exp >= 4000)
                              begin
                                  buyer_user_level<=Platinum;
                                  buyer_exp<=0;
                              end
                              else
                              begin
                                  buyer_user_level<=Gold;
                                  buyer_exp<=d_exp;
                              end
                              buyer_money<=buyer_money - 300*cur_item_num  -30;
                          end
                          else if(buyer_user_level==2)
                          begin
                              if(d_exp >= 2500)
                              begin
                                  buyer_user_level<=Gold;
                                  buyer_exp<=0;
                              end
                              else
                              begin
                                  buyer_user_level<=Silver;
                                  buyer_exp<=d_exp;
                              end
                              buyer_money<=buyer_money - 300*cur_item_num  - 50;
                          end
                          else if(buyer_user_level==3)
                          begin
                              if(d_exp >= 1000)
                              begin
                                  buyer_user_level<=Silver;
                                  buyer_exp<=0;
                              end
                              else
                              begin
                                  buyer_user_level<=Copper;
                                  buyer_exp<=d_exp;
                              end
                              buyer_money<=buyer_money - 300*cur_item_num  -70;
                          end

                          buyer_shop_item_id<=buyer_shop_item_id;
                          buyer_shop_item_num<=buyer_shop_item_num;
                          buyer_shop_seller_id<=buyer_shop_seller_id;
                      end
                      else if(cur_item_id==2)
                      begin
                          buyer_large_num<=buyer_large_num;
                          buyer_mid_num<=buyer_mid_num+cur_item_num;
                          buyer_small_num<=buyer_small_num;

                          if(buyer_user_level==0)
                          begin
                              buyer_user_level<=Platinum;
                              buyer_exp<=0;
                              buyer_money<=buyer_money - 200*cur_item_num  - 10;
                          end
                          else if(buyer_user_level==1)
                          begin
                              if(d_exp >= 4000)
                              begin
                                  buyer_user_level<=Platinum;
                                  buyer_exp<=0;
                              end
                              else
                              begin
                                  buyer_user_level<=Gold;
                                  buyer_exp<=d_exp;
                              end
                              buyer_money<=buyer_money - 200*cur_item_num  -30;
                          end
                          else if(buyer_user_level==2)
                          begin
                              if(d_exp >= 2500)
                              begin
                                  buyer_user_level<=Gold;
                                  buyer_exp<=0;
                              end
                              else
                              begin
                                  buyer_user_level<=Silver;
                                  buyer_exp<=d_exp;
                              end
                              buyer_money<=buyer_money - 200*cur_item_num  - 50;
                          end
                          else if(buyer_user_level==3)
                          begin
                              if(d_exp >= 1000)
                              begin
                                  buyer_user_level<=Silver;
                                  buyer_exp<=0;
                              end
                              else
                              begin
                                  buyer_user_level<=Copper;
                                  buyer_exp<=d_exp;
                              end
                              buyer_money<=buyer_money - 200*cur_item_num  -70;
                          end

                          buyer_shop_item_id<=buyer_shop_item_id;
                          buyer_shop_item_num<=buyer_shop_item_num;
                          buyer_shop_seller_id<=buyer_shop_seller_id;
                      end
                      else if(cur_item_id==3)
                      begin
                          buyer_large_num<=buyer_large_num;
                          buyer_mid_num<=buyer_mid_num;
                          buyer_small_num<=buyer_small_num+cur_item_num;

                          if(buyer_user_level==0)
                          begin
                              buyer_user_level<=Platinum;
                              buyer_exp<=buyer_exp;
                              buyer_money<=buyer_money - 100*cur_item_num  - 10;
                          end
                          else if(buyer_user_level==1)
                          begin
                              if(d_exp >= 4000)
                              begin
                                  buyer_user_level<=Platinum;
                                  buyer_exp<=0;
                              end
                              else
                              begin
                                  buyer_user_level<=Gold;
                                  buyer_exp<=d_exp;
                              end
                              buyer_money<=buyer_money - 100*cur_item_num  -30;
                          end
                          else if(buyer_user_level==2)
                          begin
                              if(d_exp >= 2500)
                              begin
                                  buyer_user_level<=Gold;
                                  buyer_exp<=0;
                              end
                              else
                              begin
                                  buyer_user_level<=Silver;
                                  buyer_exp<=d_exp;
                              end
                              buyer_money<=buyer_money - 100*cur_item_num  - 50;
                          end
                          else if(buyer_user_level==3)
                          begin
                              if(d_exp >= 1000)
                              begin
                                  buyer_user_level<=Silver;
                                  buyer_exp<=0;
                              end
                              else
                              begin
                                  buyer_user_level<=Copper;
                                  buyer_exp<=d_exp;
                              end
                              buyer_money<=buyer_money - 100*cur_item_num  -70;
                          end

                          buyer_shop_item_id<=buyer_shop_item_id;
                          buyer_shop_item_num<=buyer_shop_item_num;
                          buyer_shop_seller_id<=buyer_shop_seller_id;
                      end
                  end
                  else if(current_state==D_ERR)
                  begin
                      buyer_large_num<=large_num;
                      buyer_mid_num<=mid_num;
                      buyer_small_num<=small_num;
                      buyer_user_level<=user_level;
                      buyer_exp<=exp;
                      buyer_money<=d_money;
                      buyer_shop_item_id<=shop_item_id;
                      buyer_shop_item_num<=shop_item_num;
                      buyer_shop_seller_id<=shop_seller_id;
                  end
                  else if(current_state==R_ERR)
                  begin
                      if(cur_item_id==1)
                      begin
                          buyer_large_num<=buyer_large_num-cur_item_num;
                          buyer_mid_num<=buyer_mid_num;
                          buyer_small_num<=buyer_small_num;
                          buyer_user_level<=buyer_user_level;
                          buyer_exp<=buyer_exp;
                          buyer_money<=buyer_money+300*cur_item_num;
                          buyer_shop_item_id<=buyer_shop_item_id;
                          buyer_shop_item_num<=buyer_shop_item_num;
                          buyer_shop_seller_id<=buyer_shop_seller_id;
                      end
                      else if(cur_item_id==2)
                      begin
                          buyer_large_num<=buyer_large_num;
                          buyer_mid_num<=buyer_mid_num-cur_item_num;
                          buyer_small_num<=buyer_small_num;
                          buyer_user_level<=buyer_user_level;
                          buyer_exp<=buyer_exp;
                          buyer_money<=buyer_money+200*cur_item_num;
                          buyer_shop_item_id<=buyer_shop_item_id;
                          buyer_shop_item_num<=buyer_shop_item_num;
                          buyer_shop_seller_id<=buyer_shop_seller_id;
                      end
                      else if(cur_item_id==3)
                      begin
                          buyer_large_num<=buyer_large_num;
                          buyer_mid_num<=buyer_mid_num;
                          buyer_small_num<=buyer_small_num-cur_item_num;
                          buyer_user_level<=buyer_user_level;
                          buyer_exp<=buyer_exp;
                          buyer_money<=buyer_money+100*cur_item_num;
                          buyer_shop_item_id<=buyer_shop_item_id;
                          buyer_shop_item_num<=buyer_shop_item_num;
                          buyer_shop_seller_id<=buyer_shop_seller_id;
                      end
                  end
          end

          always_ff @( posedge clk or negedge inf.rst_n ) begin
                        if(!inf.rst_n)
                            current_state<=0;
                        else
                            current_state<=next_state;
                    end
                    always_comb begin
                                    case (current_state)
                                        IDLE:begin
                                            if(inf.id_valid)
                                                next_state=CHANGE_USER;
                                            else if(inf.act_valid)
                                                next_state=CHANGE_ACT;
                                            else
                                                next_state=IDLE;
                                        end
                                        CHANGE_USER:begin
                                            if(inf.act_valid)
                                                next_state=CHANGE_ACT;
                                            else
                                                next_state=CHANGE_USER;
                                        end
                                        CHANGE_ACT:begin
                                            case (cur_act)
                                                No_action: next_state=IDLE;
                                                Buy: next_state=B_WAIT;
                                                Check: next_state=C_WAIT;
                                                Deposit: next_state=D_WAIT;
                                                Return: next_state=R_WAIT;
                                                default: next_state=IDLE;
                                            endcase
                                        end
                                        B_WAIT:begin
                                            if(inf.id_valid)
                                                next_state=B_USER;
                                            else
                                                next_state=B_WAIT;
                                        end
                                        B_USER:begin
                                            if(inf.C_out_valid)
                                                next_state=B_SELL;
                                            else
                                                next_state=B_USER;
                                        end
                                        B_SELL:begin
                                            if(inf.C_out_valid)
                                                next_state=B_ERR;
                                            else
                                                next_state=B_SELL;
                                        end
                                        B_ERR:begin
                                            if(comp)
                                                next_state=B_WB_SELL;
                                            else
                                                next_state=ERR_OUT;
                                        end
                                        B_WB_SELL:begin
                                            if(inf.C_out_valid)
                                                next_state=B_WB_USER;
                                            else
                                                next_state=B_WB_SELL;
                                        end
                                        B_WB_USER:begin
                                            if(inf.C_out_valid)
                                                next_state=B_OUT;
                                            else
                                                next_state=B_WB_USER;
                                        end
                                        B_OUT:
                                            next_state=IDLE;
                                        C_WAIT:begin
                                            if(inf.id_valid)
                                                next_state=C_SELL;
                                            else if(count==5)
                                                next_state=C_USER;
                                            else
                                                next_state=C_WAIT;
                                        end
                                        C_SELL:begin
                                            if(inf.C_out_valid)
                                                next_state=C_OUT1;
                                            else
                                                next_state=C_SELL;
                                        end
                                        C_USER:begin
                                            if(inf.C_out_valid)
                                                next_state=C_OUT2;
                                            else
                                                next_state=C_USER;
                                        end
                                        C_OUT1:
                                            next_state=IDLE;
                                        C_OUT2:
                                            next_state=IDLE;
                                        D_WAIT:begin
                                            if(inf.amnt_valid)
                                                next_state=D_USER;
                                            else
                                                next_state=D_WAIT;
                                        end
                                        D_USER:begin
                                            if(inf.C_out_valid)
                                                next_state=D_ERR;
                                            else
                                                next_state=D_USER;
                                        end
                                        D_ERR:begin
                                            if(comp)
                                                next_state=D_WB;
                                            else
                                                next_state=ERR_OUT;
                                        end
                                        D_WB:begin
                                            if(inf.C_out_valid)
                                                next_state=D_OUT;
                                            else
                                                next_state=D_WB;
                                        end
                                        D_OUT:
                                            next_state=IDLE;
                                        R_WAIT:begin
                                            if(inf.id_valid)
                                                next_state=R_USER;
                                            else
                                                next_state=R_WAIT;
                                        end
                                        R_USER:begin
                                            if(inf.C_out_valid)
                                                next_state=R_SELL;
                                            else
                                                next_state=R_USER;
                                        end
                                        R_SELL:begin
                                            if(inf.C_out_valid)
                                                next_state=R_ERR;
                                            else
                                                next_state=R_SELL;
                                        end
                                        R_ERR:begin
                                            if(comp)
                                                next_state=R_WB_SELL;
                                            else
                                                next_state=ERR_OUT;
                                        end
                                        R_WB_SELL:begin
                                            if(inf.C_out_valid)
                                                next_state=R_WB_USER;
                                            else
                                                next_state=R_WB_SELL;
                                        end
                                        R_WB_USER:begin
                                            if(inf.C_out_valid)
                                                next_state=R_OUT;
                                            else
                                                next_state=R_WB_USER;
                                        end
                                        R_OUT:
                                            next_state=IDLE;

                                        default: next_state=IDLE;
                                    endcase

                                end
                                always_ff @( posedge clk or negedge inf.rst_n) begin
                                              if(!inf.rst_n)
                                                  cur_id<=0;
                                              else
                                                  if(current_state==IDLE&&inf.id_valid)
                                                      cur_id<=inf.D;
                                          end
                                          always_ff @( posedge clk or negedge inf.rst_n) begin
                                                        if(!inf.rst_n)
                                                            sell_id<=0;
                                                        else
                                                            if(current_state==C_WAIT&&inf.id_valid || current_state==B_WAIT&&inf.id_valid || current_state==R_WAIT&&inf.id_valid)
                                                                sell_id<=inf.D;
                                                    end
                                                    always_ff @( posedge clk or negedge inf.rst_n) begin
                                                                  if(!inf.rst_n)
                                                                      cur_act<=0;
                                                                  else
                                                                      if(inf.act_valid)
                                                                          cur_act<=inf.D;
                                                              end
                                                              always_ff @( posedge clk or negedge inf.rst_n) begin
                                                                            if(!inf.rst_n)
                                                                                deposit_money<=0;
                                                                            else
                                                                                if(inf.amnt_valid)
                                                                                    deposit_money<=inf.D;
                                                                        end
                                                                        always_ff @( posedge clk or negedge inf.rst_n) begin
                                                                                      if(!inf.rst_n)
                                                                                          cur_item_id<=0;
                                                                                      else
                                                                                          if(inf.item_valid)
                                                                                              cur_item_id<=inf.D;
                                                                                  end
                                                                                  always_ff @( posedge clk or negedge inf.rst_n) begin
                                                                                                if(!inf.rst_n)
                                                                                                    cur_item_num<=0;
                                                                                                else
                                                                                                    if(inf.num_valid)
                                                                                                        cur_item_num<=inf.D;
                                                                                            end



                                                                                            always_ff @( posedge clk or negedge inf.rst_n) begin
                                                                                                          if(!inf.rst_n)
                                                                                                              count<=0;
                                                                                                          else
                                                                                                              if(current_state==CHANGE_ACT)
                                                                                                                  count<=0;
                                                                                                              else if(current_state==C_WAIT)
                                                                                                                  count<=count+1;
                                                                                                      end
                                                                                                      always_ff @( posedge clk or negedge inf.rst_n) begin
                                                                                                                    if(!inf.rst_n)
                                                                                                                        first_ask_n<=0;
                                                                                                                    else
                                                                                                                        if(current_state==IDLE || inf.C_out_valid )
                                                                                                                            first_ask_n<=0;
                                                                                                                        else if(current_state==C_USER || current_state==C_SELL || current_state==D_USER || current_state==D_WB || current_state==B_USER ||current_state==B_SELL||current_state==B_WB_SELL||current_state==B_WB_USER||current_state==R_USER||current_state==R_SELL||current_state==R_WB_SELL||current_state==R_WB_USER)
                                                                                                                            first_ask_n<=1;
                                                                                                                end

                                                                                                                always_comb begin
                                                                                                                                if(current_state==IDLE)
                                                                                                                                begin
                                                                                                                                    comp=1;
                                                                                                                                end
                                                                                                                                else if(current_state==B_ERR)
                                                                                                                                begin
                                                                                                                                    if(cur_item_id==Large)
                                                                                                                                    begin
                                                                                                                                        if(d_inv > 63)
                                                                                                                                        begin
                                                                                                                                            comp=0;
                                                                                                                                        end
                                                                                                                                        else if(large_num<cur_item_num)
                                                                                                                                        begin
                                                                                                                                            comp=0;
                                                                                                                                        end
                                                                                                                                        else
                                                                                                                                        begin
                                                                                                                                            if(buyer_user_level==Platinum)
                                                                                                                                            begin
                                                                                                                                                if(buyer_money < cur_item_num*300+10)
                                                                                                                                                begin
                                                                                                                                                    comp=0;
                                                                                                                                                end
                                                                                                                                                else
                                                                                                                                                    comp=1;
                                                                                                                                            end
                                                                                                                                            else if(buyer_user_level==Gold)
                                                                                                                                            begin
                                                                                                                                                if(buyer_money < cur_item_num*300+30)
                                                                                                                                                begin
                                                                                                                                                    comp=0;
                                                                                                                                                end
                                                                                                                                                else
                                                                                                                                                    comp=1;
                                                                                                                                            end
                                                                                                                                            else if(buyer_user_level==Silver)
                                                                                                                                            begin
                                                                                                                                                if(buyer_money < cur_item_num*300+50)
                                                                                                                                                begin
                                                                                                                                                    comp=0;
                                                                                                                                                end
                                                                                                                                                else
                                                                                                                                                    comp=1;
                                                                                                                                            end
                                                                                                                                            else if(buyer_user_level==Copper)
                                                                                                                                            begin
                                                                                                                                                if(buyer_money < cur_item_num*300+70)
                                                                                                                                                begin
                                                                                                                                                    comp=0;
                                                                                                                                                end
                                                                                                                                                else
                                                                                                                                                    comp=1;
                                                                                                                                            end
                                                                                                                                            else
                                                                                                                                                comp=1;
                                                                                                                                        end
                                                                                                                                    end
                                                                                                                                    else if(cur_item_id==Medium)
                                                                                                                                    begin
                                                                                                                                        if(d_inv > 63)
                                                                                                                                        begin
                                                                                                                                            comp=0;
                                                                                                                                        end
                                                                                                                                        else if(mid_num<cur_item_num)
                                                                                                                                        begin
                                                                                                                                            comp=0;
                                                                                                                                        end
                                                                                                                                        else
                                                                                                                                        begin
                                                                                                                                            if(buyer_user_level==Platinum)
                                                                                                                                            begin
                                                                                                                                                if(buyer_money < cur_item_num*200+10)
                                                                                                                                                begin
                                                                                                                                                    comp=0;
                                                                                                                                                end
                                                                                                                                                else
                                                                                                                                                    comp=1;
                                                                                                                                            end
                                                                                                                                            else if(buyer_user_level==Gold)
                                                                                                                                            begin
                                                                                                                                                if(buyer_money < cur_item_num*200+30)
                                                                                                                                                begin
                                                                                                                                                    comp=0;
                                                                                                                                                end
                                                                                                                                                else
                                                                                                                                                    comp=1;
                                                                                                                                            end
                                                                                                                                            else if(buyer_user_level==Silver)
                                                                                                                                            begin
                                                                                                                                                if(buyer_money < cur_item_num*200+50)
                                                                                                                                                begin
                                                                                                                                                    comp=0;
                                                                                                                                                end
                                                                                                                                                else
                                                                                                                                                    comp=1;
                                                                                                                                            end
                                                                                                                                            else if(buyer_user_level==Copper)
                                                                                                                                            begin
                                                                                                                                                if(buyer_money < cur_item_num*200+70)
                                                                                                                                                begin
                                                                                                                                                    comp=0;
                                                                                                                                                end
                                                                                                                                                else
                                                                                                                                                    comp=1;
                                                                                                                                            end
                                                                                                                                            else
                                                                                                                                                comp=1;
                                                                                                                                        end
                                                                                                                                    end
                                                                                                                                    else if(cur_item_id==Small)
                                                                                                                                    begin
                                                                                                                                        if(d_inv > 63)
                                                                                                                                        begin
                                                                                                                                            comp=0;
                                                                                                                                        end
                                                                                                                                        else if(small_num<cur_item_num)
                                                                                                                                        begin
                                                                                                                                            comp=0;
                                                                                                                                        end
                                                                                                                                        else
                                                                                                                                        begin
                                                                                                                                            if(buyer_user_level==Platinum)
                                                                                                                                            begin
                                                                                                                                                if(buyer_money < cur_item_num*100+10)
                                                                                                                                                begin
                                                                                                                                                    comp=0;
                                                                                                                                                end
                                                                                                                                                else
                                                                                                                                                    comp=1;
                                                                                                                                            end
                                                                                                                                            else if(buyer_user_level==Gold)
                                                                                                                                            begin
                                                                                                                                                if(buyer_money < cur_item_num*100+30)
                                                                                                                                                begin
                                                                                                                                                    comp=0;
                                                                                                                                                end
                                                                                                                                                else
                                                                                                                                                    comp=1;
                                                                                                                                            end
                                                                                                                                            else if(buyer_user_level==Silver)
                                                                                                                                            begin
                                                                                                                                                if(buyer_money < cur_item_num*100+50)
                                                                                                                                                begin
                                                                                                                                                    comp=0;
                                                                                                                                                end
                                                                                                                                                else
                                                                                                                                                    comp=1;
                                                                                                                                            end
                                                                                                                                            else if(buyer_user_level==Copper)
                                                                                                                                            begin
                                                                                                                                                if(buyer_money < cur_item_num*100+70)
                                                                                                                                                begin
                                                                                                                                                    comp=0;
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
                                                                                                                                else if(current_state==D_ERR)
                                                                                                                                begin
                                                                                                                                    if(d_money > 65535 )
                                                                                                                                    begin
                                                                                                                                        comp=0;
                                                                                                                                    end
                                                                                                                                    else
                                                                                                                                        comp=1;
                                                                                                                                end
                                                                                                                                else if(current_state==R_ERR)
                                                                                                                                begin
                                                                                                                                    if(is_buyer[cur_id]!=1 || is_seller[sell_id]!=1)
                                                                                                                                    begin
                                                                                                                                        comp=0;
                                                                                                                                    end
                                                                                                                                    else if((buyer_shop_seller_id != sell_id) || (shop_seller_id!=cur_id) )
                                                                                                                                    begin
                                                                                                                                        comp=0;
                                                                                                                                    end
                                                                                                                                    else if(cur_item_num!=buyer_shop_item_num)
                                                                                                                                    begin
                                                                                                                                        comp=0;
                                                                                                                                    end
                                                                                                                                    else if(cur_item_id != buyer_shop_item_id)
                                                                                                                                    begin
                                                                                                                                        comp=0;
                                                                                                                                    end
                                                                                                                                    else
                                                                                                                                        comp=1;
                                                                                                                                end
                                                                                                                                else
                                                                                                                                    comp=1;
                                                                                                                            end
                                                                                                                            always_ff @( posedge clk or negedge inf.rst_n) begin
                                                                                                                                          if(!inf.rst_n)
                                                                                                                                              Err_message<=0;
                                                                                                                                          else
                                                                                                                                              if(current_state==IDLE)
                                                                                                                                              begin
                                                                                                                                                  Err_message<=No_Err;
                                                                                                                                              end
                                                                                                                                              else if(current_state==B_ERR)
                                                                                                                                              begin
                                                                                                                                                  if(cur_item_id==Large)
                                                                                                                                                  begin
                                                                                                                                                      if(d_inv > 63)
                                                                                                                                                      begin
                                                                                                                                                          Err_message<= INV_Full;
                                                                                                                                                      end
                                                                                                                                                      else if(large_num<cur_item_num)
                                                                                                                                                      begin
                                                                                                                                                          Err_message<= INV_Not_Enough;
                                                                                                                                                      end
                                                                                                                                                      else
                                                                                                                                                      begin
                                                                                                                                                          if(buyer_user_level==Platinum)
                                                                                                                                                          begin
                                                                                                                                                              if(buyer_money < cur_item_num*300+10)
                                                                                                                                                              begin
                                                                                                                                                                  Err_message<=Out_of_money;
                                                                                                                                                              end
                                                                                                                                                          end
                                                                                                                                                          else if(buyer_user_level==Gold)
                                                                                                                                                          begin
                                                                                                                                                              if(buyer_money < cur_item_num*300+30)
                                                                                                                                                              begin
                                                                                                                                                                  Err_message<=Out_of_money;
                                                                                                                                                              end
                                                                                                                                                          end
                                                                                                                                                          else if(buyer_user_level==Silver)
                                                                                                                                                          begin
                                                                                                                                                              if(buyer_money < cur_item_num*300+50)
                                                                                                                                                              begin
                                                                                                                                                                  Err_message<=Out_of_money;
                                                                                                                                                              end
                                                                                                                                                          end
                                                                                                                                                          else if(buyer_user_level==Copper)
                                                                                                                                                          begin
                                                                                                                                                              if(buyer_money < cur_item_num*300+70)
                                                                                                                                                              begin
                                                                                                                                                                  Err_message<=Out_of_money;
                                                                                                                                                              end
                                                                                                                                                          end
                                                                                                                                                      end
                                                                                                                                                  end
                                                                                                                                                  else if(cur_item_id==Medium)
                                                                                                                                                  begin
                                                                                                                                                      if(d_inv > 63)
                                                                                                                                                      begin
                                                                                                                                                          Err_message<= INV_Full;
                                                                                                                                                      end
                                                                                                                                                      else if(mid_num<cur_item_num)
                                                                                                                                                      begin
                                                                                                                                                          Err_message<= INV_Not_Enough;
                                                                                                                                                      end
                                                                                                                                                      else
                                                                                                                                                      begin
                                                                                                                                                          if(buyer_user_level==Platinum)
                                                                                                                                                          begin
                                                                                                                                                              if(buyer_money < cur_item_num*200+10)
                                                                                                                                                              begin
                                                                                                                                                                  Err_message<=Out_of_money;
                                                                                                                                                              end
                                                                                                                                                          end
                                                                                                                                                          else if(buyer_user_level==Gold)
                                                                                                                                                          begin
                                                                                                                                                              if(buyer_money < cur_item_num*200+30)
                                                                                                                                                              begin
                                                                                                                                                                  Err_message<=Out_of_money;
                                                                                                                                                              end
                                                                                                                                                          end
                                                                                                                                                          else if(buyer_user_level==Silver)
                                                                                                                                                          begin
                                                                                                                                                              if(buyer_money < cur_item_num*200+50)
                                                                                                                                                              begin
                                                                                                                                                                  Err_message<=Out_of_money;
                                                                                                                                                              end
                                                                                                                                                          end
                                                                                                                                                          else if(buyer_user_level==Copper)
                                                                                                                                                          begin
                                                                                                                                                              if(buyer_money < cur_item_num*200+70)
                                                                                                                                                              begin
                                                                                                                                                                  Err_message<=Out_of_money;
                                                                                                                                                              end
                                                                                                                                                          end
                                                                                                                                                      end
                                                                                                                                                  end
                                                                                                                                                  else if(cur_item_id==Small)
                                                                                                                                                  begin
                                                                                                                                                      if(d_inv > 63)
                                                                                                                                                      begin
                                                                                                                                                          Err_message<= INV_Full;
                                                                                                                                                      end
                                                                                                                                                      else if(small_num<cur_item_num)
                                                                                                                                                      begin
                                                                                                                                                          Err_message<= INV_Not_Enough;
                                                                                                                                                      end
                                                                                                                                                      else
                                                                                                                                                      begin
                                                                                                                                                          if(buyer_user_level==Platinum)
                                                                                                                                                          begin
                                                                                                                                                              if(buyer_money < cur_item_num*100+10)
                                                                                                                                                              begin
                                                                                                                                                                  Err_message<=Out_of_money;
                                                                                                                                                              end
                                                                                                                                                          end
                                                                                                                                                          else if(buyer_user_level==Gold)
                                                                                                                                                          begin
                                                                                                                                                              if(buyer_money < cur_item_num*100+30)
                                                                                                                                                              begin
                                                                                                                                                                  Err_message<=Out_of_money;
                                                                                                                                                              end
                                                                                                                                                          end
                                                                                                                                                          else if(buyer_user_level==Silver)
                                                                                                                                                          begin
                                                                                                                                                              if(buyer_money < cur_item_num*100+50)
                                                                                                                                                              begin
                                                                                                                                                                  Err_message<=Out_of_money;
                                                                                                                                                              end
                                                                                                                                                          end
                                                                                                                                                          else if(buyer_user_level==Copper)
                                                                                                                                                          begin
                                                                                                                                                              if(buyer_money < cur_item_num*100+70)
                                                                                                                                                              begin
                                                                                                                                                                  Err_message<=Out_of_money;
                                                                                                                                                              end
                                                                                                                                                          end
                                                                                                                                                      end
                                                                                                                                                  end
                                                                                                                                              end
                                                                                                                                              else if(current_state==D_ERR)
                                                                                                                                              begin
                                                                                                                                                  if(d_money > 65535 )
                                                                                                                                                  begin
                                                                                                                                                      Err_message<=Wallet_is_Full;
                                                                                                                                                  end
                                                                                                                                              end
                                                                                                                                              else if(current_state==R_ERR)
                                                                                                                                              begin
                                                                                                                                                  if(is_buyer[cur_id]!=1 || is_seller[buyer_shop_seller_id]!=1 || (shop_seller_id!=cur_id) )
                                                                                                                                                  begin
                                                                                                                                                      Err_message<=Wrong_act;
                                                                                                                                                  end
                                                                                                                                                  else if((buyer_shop_seller_id != sell_id) )
                                                                                                                                                  begin
                                                                                                                                                      Err_message<=Wrong_ID;
                                                                                                                                                  end
                                                                                                                                                  else if(cur_item_num!=buyer_shop_item_num)
                                                                                                                                                  begin
                                                                                                                                                      Err_message<=Wrong_Num;
                                                                                                                                                  end
                                                                                                                                                  else if(cur_item_id != buyer_shop_item_id)
                                                                                                                                                  begin
                                                                                                                                                      Err_message<=Wrong_Item;
                                                                                                                                                  end
                                                                                                                                              end
                                                                                                                                      end
                                                                                                                                      genvar i;
generate
    for (i = 0; i<256; i=i+1) begin
        always_ff @( posedge clk or negedge inf.rst_n) begin
                      if(!inf.rst_n)
                          is_buyer[i]<=0;
                      else
                      begin
                          if(current_state==B_WB_SELL && i==cur_id)
                              is_buyer[i]<=1;
                          else if(current_state==B_WB_SELL && i==sell_id)
                              is_buyer[i]<=0;
                          else if(current_state==C_WAIT && i==cur_id)
                              is_buyer[i]<=0;
                          else if(current_state==C_SELL && i==sell_id)
                              is_buyer[i]<=0;
                          else if(current_state==D_WB && i==cur_id)
                              is_buyer[i]<=0;
                          else if(current_state==R_WB_SELL && i==cur_id)
                              is_buyer[i]<=0;
                          else if(current_state==R_WB_SELL && i==sell_id)
                              is_buyer[i]<=0;
                      end
                  end
              end
          endgenerate
          generate
              for (i = 0; i<256; i=i+1) begin
                  always_ff @( posedge clk or negedge inf.rst_n) begin
                                if(!inf.rst_n)
                                    is_seller[i]<=0;
                                else
                                begin
                                    if(current_state==B_WB_SELL && i==sell_id)
                                        is_seller[i]<=1;
                                    else if(current_state==B_WB_SELL && i==cur_id)
                                        is_seller[i]<=0;
                                    else if(current_state==C_WAIT && i==cur_id)
                                        is_seller[i]<=0;
                                    else if(current_state==C_SELL && i==sell_id)
                                        is_seller[i]<=0;
                                    else if(current_state==D_WB && i==cur_id)
                                        is_seller[i]<=0;
                                    else if(current_state==R_WB_SELL && i==sell_id)
                                        is_seller[i]<=0;
                                    else if(current_state==R_WB_SELL && i==cur_id)
                                        is_seller[i]<=0;
                                end
                            end
                        end
                    endgenerate
                    always_comb begin
                                    if(current_state==D_ERR)
                                        d_money=money+deposit_money;
                                    else if(current_state==B_WB_SELL)
                                    begin
                                        if(cur_item_id==Large)
                                        begin
                                            d_money=money + cur_item_num*300;
                                        end
                                        else if(cur_item_id==Medium)
                                        begin
                                            d_money=money + cur_item_num*200;
                                        end
                                        else
                                        begin
                                            d_money=money + cur_item_num*100;
                                        end
                                    end
                                    else
                                        d_money=0;
                                end
                                always_comb begin
                                                if(current_state==B_ERR)
                                                begin
                                                    if(cur_item_id==Large)
                                                    begin
                                                        d_inv=buyer_large_num+cur_item_num;
                                                    end
                                                    else if(cur_item_id==Medium)
                                                    begin
                                                        d_inv=buyer_mid_num+cur_item_num;
                                                    end
                                                    else
                                                        d_inv=buyer_small_num+cur_item_num;
                                                end
                                                else
                                                    d_inv=0;
                                            end
                                            always_comb begin
                                                            if(current_state==B_ERR)
                                                            begin
                                                                if(cur_item_id==Large)
                                                                begin
                                                                    d_exp=buyer_exp+cur_item_num*60;
                                                                end
                                                                else if(cur_item_id==Medium)
                                                                begin
                                                                    d_exp=buyer_exp+cur_item_num*40;
                                                                end
                                                                else
                                                                    d_exp=buyer_exp+cur_item_num*20;
                                                            end
                                                            else
                                                                d_exp=0;
                                                        end

                                                        //output bridge
                                                        always_ff @( posedge clk or negedge inf.rst_n ) begin
                                                                      if(!inf.rst_n)
                                                                          inf.C_addr<=0;
                                                                      else
                                                                      begin
                                                                          if((current_state==C_USER || current_state==D_USER  || current_state==D_WB || current_state== B_USER || current_state==B_WB_USER || current_state== R_USER || current_state==R_WB_USER) && !first_ask_n)
                                                                              inf.C_addr<=cur_id;
                                                                          else if((current_state==C_SELL||current_state==B_SELL || current_state==B_WB_SELL || current_state==R_WB_SELL) && !first_ask_n)
                                                                              inf.C_addr<=sell_id;
                                                                          else if(current_state==R_SELL)
                                                                              inf.C_addr<=shop_seller_id;
                                                                      end
                                                                  end
                                                                  always_ff @( posedge clk or negedge inf.rst_n ) begin
                                                                                if(!inf.rst_n)
                                                                                    inf.C_r_wb<=0;
                                                                                else
                                                                                begin
                                                                                    if((current_state==C_USER || current_state==C_SELL || current_state==D_USER || current_state==B_SELL || current_state==B_USER || current_state==R_SELL || current_state==R_USER) && !first_ask_n)
                                                                                        inf.C_r_wb<=1;
                                                                                    else if((current_state==D_WB ||current_state==B_WB_SELL || current_state==B_WB_USER ||current_state==R_WB_SELL || current_state==R_WB_USER)&& !first_ask_n)
                                                                                        inf.C_r_wb<=0;
                                                                                end
                                                                            end
                                                                            always_ff @( posedge clk or negedge inf.rst_n ) begin
                                                                                          if(!inf.rst_n)
                                                                                              inf.C_in_valid<=0;
                                                                                          else
                                                                                          begin
                                                                                              if((current_state==C_USER || current_state==C_SELL || current_state==D_USER || current_state==D_WB || current_state==B_SELL || current_state==B_USER||current_state==B_WB_SELL||current_state==B_WB_USER || current_state==R_SELL || current_state==R_USER||current_state==R_WB_SELL||current_state==R_WB_USER) && !first_ask_n)
                                                                                                  inf.C_in_valid<=1;
                                                                                              else
                                                                                                  inf.C_in_valid<=0;
                                                                                          end
                                                                                      end

                                                                                      logic [63:0] wb_buffer;
Item_num wb_big_item,wb_mid_item,wb_small_item;
Money  wb_money;
always_comb begin
                if(current_state==B_WB_SELL)
                begin
                    if(cur_item_id==Large)
                        wb_big_item= large_num-cur_item_num;
                    else
                        wb_big_item= large_num;
                end
                else if(current_state==R_WB_SELL)
                begin
                    if(cur_item_id==Large)
                        wb_big_item= large_num+cur_item_num;
                    else
                        wb_big_item= large_num;
                end

                else
                    wb_big_item= large_num;
            end
            always_comb begin
                            if(current_state==B_WB_SELL)
                            begin
                                if(cur_item_id==Medium)
                                    wb_mid_item= mid_num-cur_item_num;
                                else
                                    wb_mid_item= mid_num;
                            end
                            else if(current_state==R_WB_SELL)
                            begin
                                if(cur_item_id==Medium)
                                    wb_mid_item= mid_num+cur_item_num;
                                else
                                    wb_mid_item= mid_num;
                            end
                            else
                                wb_mid_item= mid_num;
                        end
                        always_comb begin
                                        if(current_state==B_WB_SELL)
                                        begin
                                            if(cur_item_id==Small)
                                                wb_small_item= small_num-cur_item_num;
                                            else
                                                wb_small_item= small_num;
                                        end
                                        else if(current_state==R_WB_SELL)
                                        begin
                                            if(cur_item_id==Small)
                                                wb_small_item= small_num+cur_item_num;
                                            else
                                                wb_small_item= small_num;
                                        end
                                        else
                                            wb_small_item= small_num;
                                    end
                                    always_comb begin
                                                    if(current_state==B_WB_SELL)
                                                    begin
                                                        if(cur_item_id==Large)
                                                        begin
                                                            if(d_money > 65535)
                                                                wb_money=65535;
                                                            else
                                                                wb_money=money + cur_item_num*300;
                                                        end
                                                        else if(cur_item_id==Medium)
                                                        begin
                                                            if(d_money > 65535)
                                                                wb_money=65535;
                                                            else
                                                                wb_money=money + cur_item_num*200;
                                                        end
                                                        else
                                                        begin
                                                            if(d_money > 65535)
                                                                wb_money=65535;
                                                            else
                                                                wb_money=money + cur_item_num*100;
                                                        end
                                                    end
                                                    else if(current_state==R_WB_SELL)
                                                    begin
                                                        if(cur_item_id==Large)
                                                            wb_money=money - cur_item_num*300;
                                                        else if(cur_item_id==Medium)
                                                            wb_money=money - cur_item_num*200;
                                                        else
                                                            wb_money=money - cur_item_num*100;
                                                    end
                                                    else
                                                        wb_money=0;
                                                end
                                                always_comb begin
                                                                if(current_state==D_WB)
                                                                    wb_buffer={buyer_large_num,buyer_mid_num,buyer_small_num,buyer_user_level,buyer_exp,buyer_money,cur_item_id,cur_item_num,sell_id};
                                                                else if(current_state==B_WB_SELL || current_state==R_WB_SELL)
                                                                    wb_buffer={wb_big_item,wb_mid_item,wb_small_item,user_level,exp,wb_money,cur_item_id,cur_item_num,cur_id};
                                                                else if(current_state==B_WB_USER||current_state==R_WB_USER)
                                                                    wb_buffer={buyer_large_num,buyer_mid_num,buyer_small_num,buyer_user_level,buyer_exp,buyer_money,cur_item_id,cur_item_num,sell_id};
                                                                else
                                                                    wb_buffer=0;
                                                            end
                                                            always_ff @( posedge clk or negedge inf.rst_n ) begin
                                                                          if(!inf.rst_n)
                                                                              inf.C_data_w<=0;
                                                                          else
                                                                          begin
                                                                              inf.C_data_w<={wb_buffer[7:0],wb_buffer[15:8],wb_buffer[23:16],wb_buffer[31:24],wb_buffer[39:32],wb_buffer[47:40],wb_buffer[55:48],wb_buffer[63:56]};

                                                                          end
                                                                      end

                                                                      //output  os
                                                                      always_ff @( posedge clk or negedge inf.rst_n ) begin
                                                                                    if(!inf.rst_n)
                                                                                    begin
                                                                                        inf.err_msg<=0;
                                                                                        inf.complete<=0;
                                                                                        inf.out_valid<=0;
                                                                                        inf.out_info<=0;
                                                                                    end
                                                                                    else
                                                                                    begin
                                                                                        if(current_state==C_OUT1)
                                                                                        begin
                                                                                            inf.err_msg<=0;
                                                                                            inf.complete<=1;
                                                                                            inf.out_valid<=1;
                                                                                            inf.out_info<={large_num,mid_num,small_num};
                                                                                        end
                                                                                        else if(current_state==C_OUT2)
                                                                                        begin
                                                                                            inf.err_msg<=0;
                                                                                            inf.complete<=1;
                                                                                            inf.out_valid<=1;
                                                                                            inf.out_info<=money;
                                                                                        end
                                                                                        else if(current_state==D_OUT)
                                                                                        begin
                                                                                            inf.err_msg<=0;
                                                                                            inf.complete<=1;
                                                                                            inf.out_valid<=1;
                                                                                            inf.out_info<=buyer_money;
                                                                                        end
                                                                                        else if(current_state==B_OUT)
                                                                                        begin
                                                                                            inf.err_msg<=0;
                                                                                            inf.complete<=1;
                                                                                            inf.out_valid<=1;
                                                                                            inf.out_info<={buyer_money,cur_item_id,cur_item_num,sell_id};
                                                                                        end
                                                                                        else if(current_state==R_OUT)
                                                                                        begin
                                                                                            inf.err_msg<=0;
                                                                                            inf.complete<=1;
                                                                                            inf.out_valid<=1;
                                                                                            inf.out_info<={buyer_large_num,buyer_mid_num,buyer_small_num};
                                                                                        end
                                                                                        else if(current_state==ERR_OUT)
                                                                                        begin
                                                                                            inf.err_msg<=Err_message;
                                                                                            inf.complete<=0;
                                                                                            inf.out_valid<=1;
                                                                                            inf.out_info<=0;
                                                                                        end
                                                                                        else
                                                                                        begin
                                                                                            inf.err_msg<=0;
                                                                                            inf.complete<=0;
                                                                                            inf.out_valid<=0;
                                                                                            inf.out_info<=0;
                                                                                        end
                                                                                    end
                                                                                end
                                                                                endmodule
