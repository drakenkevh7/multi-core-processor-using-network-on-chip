//////////////////////////////////////////////////////////////////////
//     design: switch_arbiter_four_way.v
//////////////////////////////////////////////////////////////////////

// Arbitrator for one virtual channel (even/odd).
// Decodes routing, arbitrates per-output, writes output buffers, and clears input buffer.
// Purely combinational, so no need to reset outputs.
// This is a four-way arbitrator that supports UP, DOWN, LEFT, RIGHT, and process elements.

`timescale 1ns/1ps
`include "design/round_robin_arbitrator5.v"

module switch_arbiter_four_way (
	input  wire        clk,
	input  wire        reset, // active-high synchronous reset
	input  wire        en, // indicates if current arbitrator (odd/even) is active

	// Inputs from input_ctrl.
	input  wire        up_in_valid,
	input  wire        down_in_valid,
	input  wire        left_in_valid,
	input  wire        right_in_valid,
	input  wire        pe_in_valid,

	input  wire [63:0] up_in_data,
	input  wire [63:0] down_in_data,
	input  wire [63:0] left_in_data,
	input  wire [63:0] right_in_data,
	input  wire [63:0] pe_in_data,

	// Inputs from output_ctrl.
	input  wire        up_out_empty,
	input  wire        down_out_empty,
	input  wire        left_out_empty,
	input  wire        right_out_empty,
	input  wire        pe_out_empty,

	// Outputs to input_ctrl.
	output reg         up_in_clear,
	output reg         down_in_clear,
	output reg         left_in_clear,
	output reg         right_in_clear,
	output reg         pe_in_clear,

	// Outputs to output_ctrl.
	output reg         up_out_enable,
	output reg         down_out_enable,
	output reg         left_out_enable,
	output reg         right_out_enable,
	output reg         pe_out_enable,

	output reg  [63:0] up_out_data,
	output reg  [63:0] down_out_data,
	output reg  [63:0] left_out_data,
	output reg  [63:0] right_out_data,
	output reg  [63:0] pe_out_data
);

	localparam VC_BIT     = 63;
    localparam DIR_X_BIT  = 62;
	localparam DIR_Y_BIT  = 61;
    localparam HOP_X_HI   = 55; // unsigned hop field for x hop count
	localparam HOP_X_LO   = 52;
	localparam HOP_Y_HI   = 51; // unsigned hop field for y hop count
    localparam HOP_Y_LO   = 48;

	// Original input data and valid from input VCs.
	// 0 - UP
	// 1 - DOWN
	// 2 - LEFT
	// 3 - RIGHT
	// 4 - PE

	wire        valid_in [0:4]; 
	wire [63:0] data_in  [0:4];

	assign data_in [0] = up_in_data;
	assign data_in [1] = down_in_data;
	assign data_in [2] = left_in_data;
	assign data_in [3] = right_in_data;
	assign data_in [4] = pe_in_data;

	assign valid_in [0] = up_in_valid;
	assign valid_in [1] = down_in_valid;
	assign valid_in [2] = left_in_valid;
	assign valid_in [3] = right_in_valid;
	assign valid_in [4] = pe_in_valid;
	
	// Handling the hop count decrementation, and building target output channel vector.
	reg        valid [0:4]; 
	reg [63:0] data  [0:4];
	integer i;
	// Target is a one-hot encoded vector saying it is going to which channel.
	// 5'b00001 - UP
	// 5'b00010 - DOWN
	// 5'b00100 - LEFT
	// 5'b01000 - RIGHT
	// 5'b10000 - PE
	// 5'b00000 - NO TARGET
	localparam GOING_UP      = 5'b00001;
	localparam GOING_DOWN    = 5'b00010;
	localparam GOING_LEFT    = 5'b00100;
	localparam GOING_RIGHT   = 5'b01000;
	localparam GOING_PE      = 5'b10000;
	localparam GOING_NOWHERE = 5'b00000;

	reg [4:0] target [0:4];

	// Unsigned x and y offeset, will be extracted from hop field.
	reg [3:0] x_offset, y_offset;
	reg       x_dir,    y_dir;

    // Helper Function to sign-extend 4-bit to 8-bit signed.
	// Without signed extention, verilog will treat it as unsigned arithmetics.
    function [7:0] signed_ext4;
        input [3:0] val;
        begin
			signed_ext4 = { { 4{val[3]} }, val};
			end
    endfunction

	// Building target vector, showing which output buffer is going, with modified hop field.
    always @(*) begin
        for (i = 0; i < 5; i = i + 1) begin
            valid[i] = valid_in[i];
            data[i] = data_in[i];
            // default: no target
            target[i] = GOING_NOWHERE;

            // only decode when valid
            if (valid[i]) begin
				x_dir = data[i][DIR_X_BIT];
				y_dir = data[i][DIR_Y_BIT];
                x_offset = data[i][HOP_X_HI:HOP_X_LO];
                y_offset = data[i][HOP_Y_HI:HOP_Y_LO];

                if     (x_offset != 0) begin
                    // Take a step on X axis in indicated direction and decrement X hops.
                    data[i][HOP_X_HI:HOP_X_LO] = x_offset - 4'd1;
                    target[i] = (x_dir ? GOING_LEFT : GOING_RIGHT);
                end
                else if (y_offset != 0) begin
                    // Take a step on Y axis in indicated direction and decrement Y hops.
                    data[i][HOP_Y_HI:HOP_Y_LO] = y_offset - 4'd1;
                    target[i] = (y_dir ? GOING_UP : GOING_DOWN);
                end

				else begin
                    // at destination
                    target[i] = GOING_PE; // PE
                    // (no hop modification for delivery)
                end
            end
        end
    end

	// Request vector for each output buffer.
	wire [4:0] req_up;
	wire [4:0] req_down;
	wire [4:0] req_left;
	wire [4:0] req_right;
	wire [4:0] req_pe;

	// Building request vector for each output buffer.
    // TBD: Mask out the “same port” bit for each output’s request vector.
	assign req_up = {
		((target[4] == GOING_UP)   & valid[4]), // If it is going up and it is valid, then a request is set.
		((target[3] == GOING_UP)   & valid[3]),
		((target[2] == GOING_UP)   & valid[2]),
		((target[1] == GOING_UP)   & valid[1]),
		((target[0] == GOING_UP)   & valid[0])
	};

	assign req_down = {
		((target[4] == GOING_DOWN) & valid[4]),
		((target[3] == GOING_DOWN) & valid[3]),
		((target[2] == GOING_DOWN) & valid[2]),
		((target[1] == GOING_DOWN) & valid[1]),
		((target[0] == GOING_DOWN) & valid[0])
	};

	assign req_left = {
		((target[4] == GOING_LEFT) & valid[4]),
		((target[3] == GOING_LEFT) & valid[3]),
		((target[2] == GOING_LEFT) & valid[2]),
		((target[1] == GOING_LEFT) & valid[1]),
		((target[0] == GOING_LEFT) & valid[0])
	};

	assign req_right = {
		((target[4] == GOING_RIGHT) & valid[4]),
		((target[3] == GOING_RIGHT) & valid[3]),
		((target[2] == GOING_RIGHT) & valid[2]),
		((target[1] == GOING_RIGHT) & valid[1]),
		((target[0] == GOING_RIGHT) & valid[0])
	};

	assign req_pe = {
		((target[4] == GOING_PE) & valid[4]),
		((target[3] == GOING_PE) & valid[3]),
		((target[2] == GOING_PE) & valid[2]),
		((target[1] == GOING_PE) & valid[1]),
		((target[0] == GOING_PE) & valid[0])
	};

	// Handling round-robin grant.
	wire [4:0] gnt_up;
	wire [4:0] gnt_down;
	wire [4:0] gnt_left;
	wire [4:0] gnt_right;
	wire [4:0] gnt_pe;

	round_robin_arbitrator5 RRARB_UP(
		.clk(clk), .reset(reset), .en(en),
		.output_empty(up_out_empty),
		.req(req_up),
		.gnt(gnt_up)
	);

	round_robin_arbitrator5 RRARB_DOWN(
		.clk(clk), .reset(reset), .en(en),
		.output_empty(down_out_empty),
		.req(req_down),
		.gnt(gnt_down)
	);
	round_robin_arbitrator5 RRARB_LEFT(
		.clk(clk), .reset(reset), .en(en),
		.output_empty(left_out_empty),
		.req(req_left),
		.gnt(gnt_left)
	);
	round_robin_arbitrator5 RRARB_RIGHT(
		.clk(clk), .reset(reset), .en(en),
		.output_empty(right_out_empty),
		.req(req_right),
		.gnt(gnt_right)
	);
	round_robin_arbitrator5 RRARB_PE(
		.clk(clk), .reset(reset), .en(en),
		.output_empty(pe_out_empty),
		.req(req_pe),
		.gnt(gnt_pe)
	);

	// With grant, we can determine each output's data and enable.

	localparam UP_GRANTED      = 5'b00001;
	localparam DOWN_GRANTED    = 5'b00010;
	localparam LEFT_GRANTED    = 5'b00100;
	localparam RIGHT_GRANTED   = 5'b01000;
	localparam PE_GRANTED      = 5'b10000;
	localparam NONE_GRANTED    = 5'b00000;

	always @(*) begin
		// Default.
		up_in_clear    = 1'b0;
		down_in_clear  = 1'b0;
		left_in_clear  = 1'b0;
		right_in_clear = 1'b0;
		pe_in_clear    = 1'b0;

		up_out_enable    = 1'b0;
		down_out_enable  = 1'b0;
		left_out_enable  = 1'b0;
		right_out_enable = 1'b0;
		pe_out_enable    = 1'b0;

		up_out_data    = 64'b0;
		down_out_data  = 64'b0;
		left_out_data  = 64'b0;
		right_out_data = 64'b0;
		pe_out_data    = 64'b0;

		if (en) begin

			// UP output.
			case (gnt_up)
				UP_GRANTED: begin
					up_out_data   = data[0];
					up_out_enable = 1'b1;
					up_in_clear   = 1'b1;
				end
				DOWN_GRANTED: begin
					up_out_data   = data[1];
					up_out_enable = 1'b1;
					down_in_clear   = 1'b1;
				end
				LEFT_GRANTED: begin
					up_out_data   = data[2];
					up_out_enable = 1'b1;
					left_in_clear   = 1'b1;
				end
				RIGHT_GRANTED: begin
					up_out_data   = data[3];
					up_out_enable = 1'b1;
					right_in_clear   = 1'b1;
				end
				PE_GRANTED: begin
					up_out_data   = data[4];
					up_out_enable = 1'b1;
					pe_in_clear   = 1'b1;
				end
				default: ;
			endcase

			// DOWN output.
			case (gnt_down)
				UP_GRANTED: begin
					down_out_data   = data[0];
					down_out_enable = 1'b1;
					up_in_clear   = 1'b1;
				end
				DOWN_GRANTED: begin
					down_out_data   = data[1];
					down_out_enable = 1'b1;
					down_in_clear   = 1'b1;
				end
				LEFT_GRANTED: begin
					down_out_data   = data[2];
					down_out_enable = 1'b1;
					left_in_clear   = 1'b1;
				end
				RIGHT_GRANTED: begin
					down_out_data   = data[3];
					down_out_enable = 1'b1;
					right_in_clear   = 1'b1;
				end
				PE_GRANTED: begin
					down_out_data   = data[4];
					down_out_enable = 1'b1;
					pe_in_clear   = 1'b1;
				end
				default: ;
			endcase

			// LEFT output.
			case (gnt_left)
				UP_GRANTED: begin
					left_out_data   = data[0];
					left_out_enable = 1'b1;
					up_in_clear   = 1'b1;
				end
				DOWN_GRANTED: begin
					left_out_data   = data[1];
					left_out_enable = 1'b1;
					down_in_clear   = 1'b1;
				end
				LEFT_GRANTED: begin
					left_out_data   = data[2];
					left_out_enable = 1'b1;
					left_in_clear   = 1'b1;
				end
				RIGHT_GRANTED: begin
					left_out_data   = data[3];
					left_out_enable = 1'b1;
					right_in_clear   = 1'b1;
				end
				PE_GRANTED: begin
					left_out_data   = data[4];
					left_out_enable = 1'b1;
					pe_in_clear   = 1'b1;
				end
				default: ;
			endcase

			// RIGHT output.
			case (gnt_right)
				UP_GRANTED: begin
					right_out_data   = data[0];
					right_out_enable = 1'b1;
					up_in_clear   = 1'b1;
				end
				DOWN_GRANTED: begin
					right_out_data   = data[1];
					right_out_enable = 1'b1;
					down_in_clear   = 1'b1;
				end
				LEFT_GRANTED: begin
					right_out_data   = data[2];
					right_out_enable = 1'b1;
					left_in_clear   = 1'b1;
				end
				RIGHT_GRANTED: begin
					right_out_data   = data[3];
					right_out_enable = 1'b1;
					right_in_clear   = 1'b1;
				end
				PE_GRANTED: begin
					right_out_data   = data[4];
					right_out_enable = 1'b1;
					pe_in_clear   = 1'b1;
				end
				default: ;
			endcase

			// PE output.
			case (gnt_pe)
				UP_GRANTED: begin
					pe_out_data   = data[0];
					pe_out_enable = 1'b1;
					up_in_clear   = 1'b1;
				end
				DOWN_GRANTED: begin
					pe_out_data   = data[1];
					pe_out_enable = 1'b1;
					down_in_clear   = 1'b1;
				end
				LEFT_GRANTED: begin
					pe_out_data   = data[2];
					pe_out_enable = 1'b1;
					left_in_clear   = 1'b1;
				end
				RIGHT_GRANTED: begin
					pe_out_data   = data[3];
					pe_out_enable = 1'b1;
					right_in_clear   = 1'b1;
				end
				PE_GRANTED: begin
					pe_out_data   = data[4];
					pe_out_enable = 1'b1;
					pe_in_clear   = 1'b1;
				end
				default: ;
			endcase
		end
	end
endmodule