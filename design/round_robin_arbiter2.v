//////////////////////////////////////////////////////////////////////
//     design: round_robin_arbiter2.v
//////////////////////////////////////////////////////////////////////

// 2-input round-robin arbiter.
// Priority favors request0 first then flips when request is granted.
// It is 2-input because each output (cw/ccw/pe) can be requested by two inputs at most:
// PE_out:  requests come from CW_in  (deliver)  or CCW_in (deliver)
// CW_out:  requests come from CW_in  (continue) or PE_in  (inject CW)
// CCW_out: requests come from CCW_in (continue) or PE_in  (inject CCW)
// Arbitration is only done if en && output_empty && both request is present.

`timescale 1ns/1ps

module round_robin_arbiter2 #(
	parameter INIT_PRIORITY = 1'b0
)(
	input  wire clk,
	input  wire reset, // active-high synchronous reset
	input  wire en, // indicates if current arbitrator (odd/even) is active
	// Indicates if selected output buffer is empty.
	// There is only one output buffer needs to be considered about in all three senarios.
	input  wire output_empty,
	input  wire req0,
	input  wire req1,
	output reg  win0,
	output reg  win1
);
	// Priority on request. 0 prefer req0, 1 pefer req1
	reg priority;

	always @(posedge clk) begin
		if (reset) priority <= INIT_PRIORITY;
		// If one arbitration is done, flip priority
		else if (en && output_empty && req0 && req1) priority <= !priority;
	end

	always @(*) begin
		win0 = 1'b0;
		win1 = 1'b0;
		if (en && output_empty) begin
			if (req0 ^ req1) begin
				win0 = req0;
				win1 = req1;
			end
			else if (req0 && req1) begin
				if (priority) win1 = 1'b1;
				else          win0 = 1'b1;
			end
		end
	end

endmodule