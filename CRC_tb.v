`timescale 1ns / 1ps
module CRC_tb;

	//parameters
	parameter clk_period=4;
	parameter crc_bits_tb=8;
	parameter [1:0]data_bytes_tb = 1;
	parameter [crc_bits_tb-1:0] poly_tb = 'b1100_0100;
	parameter tst_cases = 10; 
	

	// Inputs
	reg CLK_tb;
	reg RST_tb;
	reg ACTIVE_tb;
	reg DATA_tb;

	// Outputs
	wire Valid_tb;
	wire CRC_tb;
	
	//memory
	reg [(data_bytes_tb*8)-1 : 0] DATA_MEM [0:tst_cases-1] ;
	reg [crc_bits_tb-1 : 0] EXPECTED_MEM [0:tst_cases-1] ;
	
	//iterator on tst_cases
	integer i;

	// Instantiate the Unit Under Test (UUT)
	CRC #(.crc_bits(crc_bits_tb),.data_bytes(data_bytes_tb),.poly(poly_tb)) uut (
		.CLK(CLK_tb), 
		.RST(RST_tb), 
		.ACTIVE(ACTIVE_tb), 
		.DATA(DATA_tb), 
		.Valid(Valid_tb), 
		.CRC(CRC_tb)
	);
	
	
	//clock generation
	always #(clk_period/2)  CLK_tb = ~CLK_tb ;
		

	initial begin
	
		$readmemh("DATA_h.txt",DATA_MEM);
		$readmemh("Expec_Out_h.txt",EXPECTED_MEM);

	
		// Initialize Inputs
		initialize();
		
		//reseting
		//reset();
		
		crc_input_tst('h93);
		crc_check_with('h78);
		
		crc_input_tst('d93);
		crc_check_with('b01011000);
		
		for(i=0; i<tst_cases; i=i+1)begin
			crc_input_tst(DATA_MEM[i]);
			crc_check_with(EXPECTED_MEM[i]);
		end
		
		reset();
		

	end
	
	
	///////////////////////////////////////
	task initialize();begin
		CLK_tb = 0;
		RST_tb = 1;
		ACTIVE_tb = 0;
		DATA_tb = 0;
	end
	endtask
	////////////////////////////////////////////
	task reset();begin
	//	RST_tb=1;
	//	#clk_period;
		RST_tb=0;
		#clk_period;
		RST_tb=1;
	end
	endtask
	//////////////////////////////////////
	task crc_input_tst;
	input [(data_bytes_tb*8)-1:0] data_in;
	integer i;
	begin
		reset();
		ACTIVE_tb = 1;
		$display("***tst started at time=%0t***",$time);
		for(i=0; i<(data_bytes_tb*8); i=i+1)begin
			DATA_tb = data_in[i];
			#clk_period;
		end
		ACTIVE_tb = 0;
	end
	endtask
	////////////////////////////////////
	task crc_check_with;
	input [crc_bits_tb-1:0] expected;
	integer i;
	reg [crc_bits_tb-1:0] crc_rslt;
	begin
		RST_tb=1;
		ACTIVE_tb = 0;
		@(posedge Valid_tb) 
		for(i=0; i<crc_bits_tb; i=i+1)begin
			#(clk_period/2);
			crc_rslt[i]=CRC_tb;
			#(clk_period/2);
		end
		$display("expected = %b",expected);
		$display("rslt = %b",crc_rslt);
		if(expected==crc_rslt)begin
			$display("tst is successful and ended at time=%0t",$time);
		end
		else begin
			$display("tst failed and ended at time=%0t",$time);
		end
		$display("------------------------------------------");
	end
	endtask
      
endmodule

