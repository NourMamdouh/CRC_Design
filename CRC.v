module CRC #(
parameter 	[3:0]					crc_bits='d8, //up to 15 bits crc
parameter 	[crc_bits-1:0]	 	poly='b1100_0100 , // 1+ x^(1)+x^(5) --> in general, starting from order zero on the left to the highest on the right
parameter 	[1:0]					data_bytes='d1) // up to 4 bytes	
(
input			wire					CLK,
input 		wire					RST,
input 		wire					ACTIVE,
input 		wire					DATA,
output 		reg 					Valid,
output		reg					CRC
 );
	 
	 //parameters
	 localparam [crc_bits-1:0] SEED = 'hD8; //initial LFSR value
	 localparam  max_count = crc_bits;
	 localparam cntr_width=4;
	 

	 
	 reg [crc_bits-1:0] LFSR; 
	 integer i; // for loop iterator
	 wire feed_back;
	 reg [cntr_width-1:0] counter;

	 
	 //LFSR 
	 always @(posedge CLK, negedge RST)begin
		if(!RST)begin
				LFSR <= SEED;
				Valid <= 'd0;
				CRC <= 'd0;
		end
		else if(ACTIVE) begin
				Valid <= 'd0;
				LFSR[crc_bits-1] <= feed_back;
				for(i=crc_bits-2; i>=0; i=i-1)begin
						if(poly[i])begin
							LFSR[i] <= LFSR [i+1] ^ feed_back;
						end
						else begin
							LFSR[i] <= LFSR [i+1];
						end
				end
		end
		else if(counter!='d0)begin
				Valid <= 'd1;
				{LFSR[crc_bits-2:0] , CRC} <= LFSR;
		end
		else begin
				Valid <= 'd0;
				CRC <= 'd0;
		end
	 end
	 
	 
	 //counter
	 always @(posedge CLK,negedge RST)begin
		if(!RST)begin
				counter <= 'd0;
		end
		else if(ACTIVE)begin
				counter <= max_count;
		end
		else if (counter!='d0)begin
				counter <= counter-'d1;
		end
	 end
	 
	 
	 //feed_back logic
	 assign feed_back = LFSR[0] ^ DATA ;

endmodule
