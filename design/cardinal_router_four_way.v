//////////////////////////////////////////////////////////////////////
//     design: cardinal_router_four_way.v
//////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "design/input_ctrl.v"
`include "design/output_ctrl.v"
`include "design/arbitrator_four_way.v"

module cardinal_router_four_way (
	input  wire        clk,
	input  wire        reset, // active-high synchronous reset
	output reg         polarity, // indicates if current clk cycle is even (0) or odd (1)

	// total six channels, three for input, three for output
	// each channels contains one data signal and two control signals

	// input up
	input  wire        upsi, // up send input
	output wire        upri, // up ready input
	input  wire [63:0] updi, // up data input
	// input down
	input  wire        downsi, // down send input
	output wire        downri, // down ready input
	input  wire [63:0] downdi, // down data input
	// input left
	input  wire        leftsi, // left send input
	output wire        leftri, // left ready input
	input  wire [63:0] leftdi, // left data input
	// input right
	input  wire        rightsi, // right send input
	output wire        rightri, // right ready input
	input  wire [63:0] rightdi, // right data input
	// input processing element
	input  wire        pesi, // processing element send input
	output wire        peri, // processing element ready input
	input  wire [63:0] pedi, // processing element data input


	// output up
	output wire        upso, // up send output
	input  wire        upro, // up ready output
	output wire [63:0] updo, // up data output
	// output down
	output wire        downso, // down send output
	input  wire        downro, // down ready output
	output wire [63:0] downdo, // down data output
	// output left
	output wire        leftso, // left send output
	input  wire        leftro, // left ready output
	output wire [63:0] leftdo, // left data output
	// output right
	output wire        rightso, // right send output
	input  wire        rightro, // right ready output
	output wire [63:0] rightdo, // right data output
	// output processing element
	output wire        peso, // processing element send output
	input  wire        pero, // processing element ready output
	output wire [63:0] pedo  // processing element data output
);

	always @(posedge clk) begin
		if (reset) polarity <= 1'b0;
		else       polarity <= ~polarity;
	end

	// Input Controller
	// UP_INPUT_CTRL.
	wire        up_in_clear_even,  up_in_clear_odd;
	wire        up_in_valid_even,  up_in_valid_odd;
	wire [63:0] up_in_data_even,   up_in_data_odd;

	input_ctrl UP_INPUT_CTRL (
		.clk(clk), .reset(reset), .polarity(polarity),
		.send_in    (upsi),
		.ready_in   (upri),
		.data_in    (updi),
		.clear_even (up_in_clear_even),
		.clear_odd  (up_in_clear_odd),
		.valid_even (up_in_valid_even),
		.valid_odd  (up_in_valid_odd),
		.data_even  (up_in_data_even),
		.data_odd   (up_in_data_odd)
	);

	// DOWN_INPUT_CTRL.
	wire        down_in_clear_even,  down_in_clear_odd;
	wire        down_in_valid_even,  down_in_valid_odd;
	wire [63:0] down_in_data_even,   down_in_data_odd;

	input_ctrl DOWN_INPUT_CTRL (
		.clk(clk), .reset(reset), .polarity(polarity),
		.send_in    (downsi),
		.ready_in   (downri),
		.data_in    (downdi),
		.clear_even (down_in_clear_even),
		.clear_odd  (down_in_clear_odd),
		.valid_even (down_in_valid_even),
		.valid_odd  (down_in_valid_odd),
		.data_even  (down_in_data_even),
		.data_odd   (down_in_data_odd)
	);

	// LEFT_INPUT_CTRL.
	wire        left_in_clear_even,  left_in_clear_odd;
	wire        left_in_valid_even,  left_in_valid_odd;
	wire [63:0] left_in_data_even,   left_in_data_odd;

	input_ctrl LEFT_INPUT_CTRL (
		.clk(clk), .reset(reset), .polarity(polarity),
		.send_in    (leftsi),
		.ready_in   (leftri),
		.data_in    (leftdi),
		.clear_even (left_in_clear_even),
		.clear_odd  (left_in_clear_odd),
		.valid_even (left_in_valid_even),
		.valid_odd  (left_in_valid_odd),
		.data_even  (left_in_data_even),
		.data_odd   (left_in_data_odd)
	);

	// RIGHT_INPUT_CTRL.
	wire        right_in_clear_even,  right_in_clear_odd;
	wire        right_in_valid_even,  right_in_valid_odd;
	wire [63:0] right_in_data_even,   right_in_data_odd;

	input_ctrl RIGHT_INPUT_CTRL (
		.clk(clk), .reset(reset), .polarity(polarity),
		.send_in    (rightsi),
		.ready_in   (rightri),
		.data_in    (rightdi),
		.clear_even (right_in_clear_even),
		.clear_odd  (right_in_clear_odd),
		.valid_even (right_in_valid_even),
		.valid_odd  (right_in_valid_odd),
		.data_even  (right_in_data_even),
		.data_odd   (right_in_data_odd)
	);

	// PE_INPUT_CTRL.
	wire        pe_in_clear_even,  pe_in_clear_odd;
	wire        pe_in_valid_even,  pe_in_valid_odd;
	wire [63:0] pe_in_data_even,   pe_in_data_odd;

	input_ctrl PE_INPUT_CTRL (
		.clk(clk), .reset(reset), .polarity(polarity),
		.send_in    (pesi),
		.ready_in   (peri),
		.data_in    (pedi),
		.clear_even (pe_in_clear_even),
		.clear_odd  (pe_in_clear_odd),
		.valid_even (pe_in_valid_even),
		.valid_odd  (pe_in_valid_odd),
		.data_even  (pe_in_data_even),
		.data_odd   (pe_in_data_odd)
	);

	// Output Controller
	// UP_OUTPUT_CTRL.
	wire        up_out_empty_even,  up_out_empty_odd;
	wire        up_out_en_even,  up_out_en_odd;
	wire [63:0] up_out_data_even,   up_out_data_odd;

	output_ctrl UP_OUTPUT_CTRL (
		.clk(clk), .reset(reset), .polarity(polarity),
		.ready_out  (upro),
		.send_out   (upso),
		.data_out   (updo),
		.empty_even (up_out_empty_even),
		.empty_odd  (up_out_empty_odd),
		.en_even    (up_out_en_even),
		.en_odd     (up_out_en_odd),
		.data_even  (up_out_data_even),
		.data_odd   (up_out_data_odd)
	);

	// DOWN_OUTPUT_CTRL.
	wire        down_out_empty_even,  down_out_empty_odd;
	wire        down_out_en_even,  down_out_en_odd;
	wire [63:0] down_out_data_even,   down_out_data_odd;

	output_ctrl DOWN_OUTPUT_CTRL (
		.clk(clk), .reset(reset), .polarity(polarity),
		.ready_out  (downro),
		.send_out   (downso),
		.data_out   (downdo),
		.empty_even (down_out_empty_even),
		.empty_odd  (down_out_empty_odd),
		.en_even    (down_out_en_even),
		.en_odd     (down_out_en_odd),
		.data_even  (down_out_data_even),
		.data_odd   (down_out_data_odd)
	);

	// LEFT_OUTPUT_CTRL.
	wire        left_out_empty_even,  left_out_empty_odd;
	wire        left_out_en_even,  left_out_en_odd;
	wire [63:0] left_out_data_even,   left_out_data_odd;

	output_ctrl LEFT_OUTPUT_CTRL (
		.clk(clk), .reset(reset), .polarity(polarity),
		.ready_out  (leftro),
		.send_out   (leftso),
		.data_out   (leftdo),
		.empty_even (left_out_empty_even),
		.empty_odd  (left_out_empty_odd),
		.en_even    (left_out_en_even),
		.en_odd     (left_out_en_odd),
		.data_even  (left_out_data_even),
		.data_odd   (left_out_data_odd)
	);

	// RIGHT_OUTPUT_CTRL.
	wire        right_out_empty_even,  right_out_empty_odd;
	wire        right_out_en_even,  right_out_en_odd;
	wire [63:0] right_out_data_even,   right_out_data_odd;

	output_ctrl RIGHT_OUTPUT_CTRL (
		.clk(clk), .reset(reset), .polarity(polarity),
		.ready_out  (rightro),
		.send_out   (rightso),
		.data_out   (rightdo),
		.empty_even (right_out_empty_even),
		.empty_odd  (right_out_empty_odd),
		.en_even    (right_out_en_even),
		.en_odd     (right_out_en_odd),
		.data_even  (right_out_data_even),
		.data_odd   (right_out_data_odd)
	);

	// PE_OUTPUT_CTRL.
	wire        pe_out_empty_even,  pe_out_empty_odd;
	wire        pe_out_en_even,  pe_out_en_odd;
	wire [63:0] pe_out_data_even,   pe_out_data_odd;

	output_ctrl PE_OUTPUT_CTRL (
		.clk(clk), .reset(reset), .polarity(polarity),
		.ready_out  (pero),
		.send_out   (peso),
		.data_out   (pedo),
		.empty_even (pe_out_empty_even),
		.empty_odd  (pe_out_empty_odd),
		.en_even    (pe_out_en_even),
		.en_odd     (pe_out_en_odd),
		.data_even  (pe_out_data_even),
		.data_odd   (pe_out_data_odd)
	);

	// Arbitrator (even/odd).
	arbitrator_four_way ARB_EVEN (
        .clk(clk), .reset(reset), .en(!polarity),

		// Inputs from input_ctrl.
		.up_in_valid    (up_in_valid_even),
		.down_in_valid  (down_in_valid_even),
		.left_in_valid  (left_in_valid_even),
		.right_in_valid (right_in_valid_even),
		.pe_in_valid    (pe_in_valid_even),

		.up_in_data    (up_in_data_even),
		.down_in_data  (down_in_data_even),
		.left_in_data  (left_in_data_even),
		.right_in_data (right_in_data_even),
		.pe_in_data    (pe_in_data_even),

		// Inputs from output_ctrl.
        .up_out_empty    (up_out_empty_even),
		.down_out_empty  (down_out_empty_even),
		.left_out_empty  (left_out_empty_even),
		.right_out_empty (right_out_empty_even),
        .pe_out_empty    (pe_out_empty_even),

		// Outputs to input_ctrl.
		.up_in_clear    (up_in_clear_even),
		.down_in_clear  (down_in_clear_even),
		.left_in_clear  (left_in_clear_even),
		.right_in_clear (right_in_clear_even),
		.pe_in_clear    (pe_in_clear_even),

		// Outputs to output_ctrl.
		.up_out_enable    (up_out_en_even),
		.down_out_enable  (down_out_en_even),
		.left_out_enable  (left_out_en_even),
		.right_out_enable (right_out_en_even),
		.pe_out_enable    (pe_out_en_even),

		.up_out_data    (up_out_data_even),
		.down_out_data  (down_out_data_even),
		.left_out_data  (left_out_data_even),
		.right_out_data (right_out_data_even),
		.pe_out_data     (pe_out_data_even)
    );

	arbitrator_four_way ARB_ODD (
        .clk(clk), .reset(reset), .en(polarity),

		// Inputs from input_ctrl.
		.up_in_valid    (up_in_valid_odd),
		.down_in_valid  (down_in_valid_odd),
		.left_in_valid  (left_in_valid_odd),
		.right_in_valid (right_in_valid_odd),
		.pe_in_valid    (pe_in_valid_odd),

		.up_in_data    (up_in_data_odd),
		.down_in_data  (down_in_data_odd),
		.left_in_data  (left_in_data_odd),
		.right_in_data (right_in_data_odd),
		.pe_in_data    (pe_in_data_odd),

		// Inputs from output_ctrl.
        .up_out_empty    (up_out_empty_odd),
		.down_out_empty  (down_out_empty_odd),
		.left_out_empty  (left_out_empty_odd),
		.right_out_empty (right_out_empty_odd),
        .pe_out_empty    (pe_out_empty_odd),

		// Outputs to input_ctrl.
		.up_in_clear    (up_in_clear_odd),
		.down_in_clear  (down_in_clear_odd),
		.left_in_clear  (left_in_clear_odd),
		.right_in_clear (right_in_clear_odd),
		.pe_in_clear    (pe_in_clear_odd),

		// Outputs to output_ctrl.
		.up_out_enable    (up_out_en_odd),
		.down_out_enable  (down_out_en_odd),
		.left_out_enable  (left_out_en_odd),
		.right_out_enable (right_out_en_odd),
		.pe_out_enable    (pe_out_en_odd),

		.up_out_data    (up_out_data_odd),
		.down_out_data  (down_out_data_odd),
		.left_out_data  (left_out_data_odd),
		.right_out_data (right_out_data_odd),
		.pe_out_data     (pe_out_data_odd)
    );


endmodule