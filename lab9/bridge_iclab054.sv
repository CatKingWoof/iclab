module bridge(input clk, INF.bridge_inf inf);

//parameter


//to dram
//read
always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.AR_VALID <= 0; 
        inf.AR_ADDR <=0;
	end 
    else
    begin
        if(inf.C_in_valid && inf.C_r_wb ==1)
        begin
            inf.AR_VALID <= 1;
            inf.AR_ADDR <= inf.C_addr*8 + 'h10000 ;
        end  
        else if (inf.AR_VALID && inf.AR_READY)
        begin
            inf.AR_VALID <= 0;
            inf.AR_ADDR <= 0;
        end    
    end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.R_READY  <= 0 ; 
	end else
    begin
        if(inf.AR_VALID && inf.AR_READY)
            inf.R_READY  <= 1  ; 
        else if(inf.R_VALID && inf.R_READY)
            inf.R_READY  <= 0  ;
    end
end
//write
always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.AW_VALID <= 0 ; 
        inf.AW_ADDR <= 0;
	end else
    begin
        if(inf.C_in_valid && inf.C_r_wb == 'd0)
        begin
            inf.AW_VALID <= 1 ; 
            inf.AW_ADDR <= inf.C_addr*8 + 'h10000 ;
        end
        else if(inf.AW_READY && inf.AW_VALID)
        begin
            inf.AW_VALID <= 0 ;
            inf.AW_ADDR <= 0 ;
        end
    end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.W_VALID <= 0 ; 
        inf.W_DATA <= 0 ;
	end 
    else  
    begin
        if(inf.AW_VALID && inf.AW_READY)
        begin
            inf.W_VALID <= 1 ; 
            inf.W_DATA <= inf.C_data_w ;
        end
        else if(inf.W_VALID && inf.W_READY)
        begin
            inf.W_VALID <= 0 ; 
            inf.W_DATA <= 0 ;
        end
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.B_READY <= 0 ; 
	end 
    else  
    begin
		inf.B_READY <= 1 ; 
	end
end


//to os
always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.C_out_valid  <= 0 ; 
	end else
    begin
        if((inf.R_VALID && inf.R_READY) || (inf.B_VALID && inf.B_READY))begin
            inf.C_out_valid<=1;
        end
        else
            inf.C_out_valid<=0;
           
    end
end
always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.C_data_r	<= 0 ;
	end else if ((inf.R_VALID && inf.R_READY) || (inf.B_VALID && inf.B_READY))begin
		inf.C_data_r	<= inf.R_DATA ;
	end
end



endmodule