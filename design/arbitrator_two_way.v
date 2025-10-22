//////////////////////////////////////////////////////////////////////
//     design: arbitrator_two_way.v
//////////////////////////////////////////////////////////////////////

// Arbitrator for one virtual channel (even/odd).
// Decodes routing, arbitrates per-output, writes output buffers, and clears input buffer.
// Purely combinational, so no need to reset outputs.
// This is a two-way arbitrator that supports clockwise, counter-clockwise, and process element.

`timescale 1ns/1ps
`include "design/round_robin_arbiter2.v"

module arbitrator_two_way (
	input  wire        clk,
	input  wire        reset, // active-high synchronous reset
	input  wire        en, // indicates if current arbitrator (odd/even) is active

	// Inputs from input_ctrl.
	input  wire [63:0] cw_in_data,
	input  wire        cw_in_valid,
	input  wire [63:0] ccw_in_data,
	input  wire        ccw_in_valid,
	input  wire [63:0] pe_in_data,
	input  wire        pe_in_valid,

	// Inputs from output_ctrl.
	input  wire        cw_out_empty,
	input  wire        ccw_out_empty,
	input  wire        pe_out_empty,

	// Outputs to input_ctrl.
	output reg         cw_in_clear,
	output reg         ccw_in_clear,
	output reg         pe_in_clear,

	// Outputs to output_ctrl.
	output reg  [63:0] cw_out_data,
	output reg         cw_out_enable,
	output reg  [63:0] ccw_out_data,
	output reg         ccw_out_enable,
	output reg  [63:0] pe_out_data,
	output reg         pe_out_enable
);

	localparam VC_BIT   = 63;
    localparam DIR_BIT  = 62;
    localparam HOP_HI   = 55;
    localparam HOP_LO   = 48;
    // Arbiter initial priorities (per selection)
    localparam PE_INIT  = 1'b0;  // PE output: cw_in over ccw_in initially
    localparam CW_INIT  = 1'b0;  // CW output: cw_in over pe_in initially
    localparam CCW_INIT = 1'b0;   // CCW output: ccw_in over pe_in initially

	// Preprocess to generate request
    // PE input uses DIR_BIT to choose CW/CCW (only on injection).
    wire pe_req_cw  = pe_in_valid  & (pe_in_data[DIR_BIT] == 1'b0) & cw_out_empty;
    wire pe_req_ccw = pe_in_valid  & (pe_in_data[DIR_BIT] == 1'b1) & ccw_out_empty;

    // CW input: if HOP==0 -> request PE; else request CW (and DEC hop on write)
    wire [7:0] cw_hop  = cw_in_data[HOP_HI:HOP_LO];
    wire cw_req_pe     = cw_in_valid & (cw_hop == 8'd0) & pe_out_empty;
    wire cw_req_cw     = cw_in_valid & (cw_hop != 8'd0) & cw_out_empty;

    // CCW input: if HOP==0 -> request PE; else request CCW (and DEC hop on write)
    wire [7:0] ccw_hop = ccw_in_data[HOP_HI:HOP_LO];
    wire ccw_req_pe    = ccw_in_valid & (ccw_hop == 8'd0) & pe_out_empty;
    wire ccw_req_ccw   = ccw_in_valid & (ccw_hop != 8'd0) & ccw_out_empty;

	// 2-input round-robin arbiter.
	// PE output: cw_in (deliver) vs ccw_in (deliver) (INIT: cw > ccw).
	wire win_pe_cw, win_pe_ccw;
    round_robin_arbiter2 #(PE_INIT) ARBITER_PE (
        .clk(clk), .reset(reset), .en(en), .output_empty(pe_out_empty),
        .req0(cw_req_pe), .req1(ccw_req_pe),
        .win0(win_pe_cw),   .win1(win_pe_ccw)
    );

    // CW output: cw_in (continue) vs pe_in (inject cw) (INIT: cw_in > pe_in).
    wire win_cw_cw, win_cw_pe;
    round_robin_arbiter2 #(CW_INIT) ARBITER_CW (
        .clk(clk), .reset(reset), .en(en), .output_empty(cw_out_empty),
        .req0(cw_req_cw), .req1(pe_req_cw),	
        .win0(win_cw_cw), .win1(win_cw_pe)
    );

    // CCW output: ccw_in (continue) vs pe_in (inject ccw) (INIT: ccw_in > pe_in).
    wire win_ccw_ccw, win_ccw_pe;
    round_robin_arbiter2 #(CCW_INIT) ARBITER_CCW (
        .clk(clk), .reset(reset), .en(en), .output_empty(ccw_out_empty),
        .req0(ccw_req_ccw), .req1(pe_req_ccw),
        .win0(win_ccw_ccw), .win1(win_ccw_pe)
    );

	// Helper function to decrement hop.
	function [7:0] decrement_hop;
		input [7:0] hop;
		begin
			if (hop == 8'b0) decrement_hop = 8'b0;
			else             decrement_hop = hop - 8'b1;
		end
	endfunction

	always @(*) begin
		cw_in_clear  = 1'b0;
		ccw_in_clear = 1'b0;
		pe_in_clear  = 1'b0;

		cw_out_enable  = 1'b0;
		ccw_out_enable = 1'b0;
		pe_out_enable  = 1'b0;

		cw_out_data  = 64'b0;
		ccw_out_data = 64'b0;
		pe_out_data  = 64'b0;

		if (en) begin
			// PE output.
			if (win_pe_cw) begin
				pe_out_data   = cw_in_data;
				pe_out_enable = 1'b1;
				cw_in_clear   = 1'b1;
			end
			else if (win_pe_ccw) begin
				pe_out_data   = ccw_in_data;
				pe_out_enable = 1'b1;
				ccw_in_clear  = 1'b1;
			end
			
			// CW output.
			if (win_cw_cw) begin
				cw_out_data                = cw_in_data;
				cw_out_data[HOP_HI:HOP_LO] = decrement_hop(cw_in_data[HOP_HI:HOP_LO]);
				cw_out_enable              = 1'b1;
				cw_in_clear                = 1'b1;
			end
			else if (win_cw_pe) begin
				cw_out_data                = pe_in_data;
				cw_out_data[HOP_HI:HOP_LO] = decrement_hop(pe_in_data[HOP_HI:HOP_LO]);
				cw_out_enable              = 1'b1;
				pe_in_clear                = 1'b1;
			end

			// CCW output.
			if (win_ccw_ccw) begin
				ccw_out_data                = ccw_in_data;
				ccw_out_data[HOP_HI:HOP_LO] = decrement_hop(ccw_in_data[HOP_HI:HOP_LO]);
				ccw_out_enable              = 1'b1;
				ccw_in_clear                = 1'b1;
			end
			else if (win_ccw_pe) begin
				ccw_out_data                = pe_in_data;
				ccw_out_data[HOP_HI:HOP_LO] = decrement_hop(pe_in_data[HOP_HI:HOP_LO]);
				ccw_out_enable              = 1'b1;
				pe_in_clear                 = 1'b1;
			end
		end
	end

endmodule