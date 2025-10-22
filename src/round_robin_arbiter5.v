//////////////////////////////////////////////////////////////////////
//     design: round_robin_arbiter5.v
//////////////////////////////////////////////////////////////////////

// 5-input round-robin arbiter.
// Priority favors request0 first then flips when request is granted.
// Currently each output can be requested by four inputs at most:
// UP_OUT:    requests come from DOWN_in, LEFT_IN, RIGHT_IN, PE_IN;
// DOWN_OUT:  requests come from UP_IN, LEFT_IN, RIGHT_IN, PE_IN;
// LEFT_OUT:  requests come from UP_IN, DOWN_in, RIGHT_IN, PE_IN;
// RIGHT_OUT: requests come from UP_IN, DOWN_in, LEFT_IN, PE_IN;
// PE_OUT:    requests come from UP_IN, DOWN_in, LEFT_IN, RIGHT_IN;
// But for future work, 5-input is reserved at this moment.
// Arbitration is only done if en && output_empty && both request is present.
// en & out_free gate arbitration; rotates priority on successful conflicting grant.
// From previous version, now the round-robin arbiter is 1-hot coded.
// For instance, req = 5'b00101 means there is req[0] and req[2],
// gnt = 5'b 00100 means req[2] has been granted.

`timescale 1ns/1ps

module round_robin_arbiter5 (
	input  wire clk,
	input  wire reset, // active-high synchronous reset
	input  wire en, // indicates if current arbitrator (odd/even) is active
	// Indicates if selected output buffer is empty.
	// There is only one output buffer needs to be considered about in all three senarios.
	input  wire output_empty,
	input  wire [4:0] req, // requesters {UP, DOWN, LEFT, RIGHT, PE}
	output reg  [4:0] gnt // one-hot grant
);
	// Priority on request.
	reg [4:0] priority;

	always @(posedge clk) begin
		if (reset) priority <= 5'b00001;
		// If one arbitration is done, concatenate the grant to make it shift left.
		else if (en && output_empty && (gnt != 5'b00000)) priority <= {gnt[3:0], gnt[4]};
	end

	always @(*) begin
		gnt = 5'b00000;
		if (output_empty && en) begin
			case (priority)
				5'b00001: begin
					if      (req[0]) gnt = 5'b00001;
					else if (req[1]) gnt = 5'b00010;
					else if (req[2]) gnt = 5'b00100;
					else if (req[3]) gnt = 5'b01000;
					else if (req[4]) gnt = 5'b10000;
				end
				5'b00010: begin
					if      (req[1]) gnt = 5'b00010;
					else if (req[2]) gnt = 5'b00100;
					else if (req[3]) gnt = 5'b01000;
					else if (req[4]) gnt = 5'b10000;
					else if (req[0]) gnt = 5'b00001;
				end
				5'b00100: begin

					if      (req[2]) gnt = 5'b00100;
					else if (req[3]) gnt = 5'b01000;
					else if (req[4]) gnt = 5'b10000;
					else if (req[0]) gnt = 5'b00001;
					else if (req[1]) gnt = 5'b00010;
				end
				5'b01000: begin
					if      (req[3]) gnt = 5'b01000;
					else if (req[4]) gnt = 5'b10000;
					else if (req[0]) gnt = 5'b00001;
					else if (req[1]) gnt = 5'b00010;
					else if (req[2]) gnt = 5'b00100;
				end
				5'b10000: begin
					if      (req[4]) gnt = 5'b10000;
					else if (req[0]) gnt = 5'b00001;
					else if (req[1]) gnt = 5'b00010;
					else if (req[2]) gnt = 5'b00100;
					else if (req[3]) gnt = 5'b01000;
				end
			endcase
		end
	end

endmodule