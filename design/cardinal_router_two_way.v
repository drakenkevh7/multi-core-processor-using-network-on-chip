//////////////////////////////////////////////////////////////////////
//     design: cardinal_router_two_way.v
//////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "design/input_ctrl.v"
`include "design/output_ctrl.v"
`include "design/arbitrator_two_way.v"

module cardinal_router_two_way (
	input  wire        clk,
	input  wire        reset, // active-high synchronous reset
	output reg         polarity, // indicates if current clk cycle is even (0) or odd (1)

	// total six channels, three for input, three for output
	// each channels contains one data signal and two control signals

	// input  clockwise
	input  wire        cwsi, // clockwise send input
	output wire        cwri, // clockwise ready input
	input  wire [63:0] cwdi, // clockwise data input

	// input  counter-clockwise
	input  wire        ccwsi, // counter-clockwise send input
	output wire        ccwri, // counter-clockwise ready input
	input  wire [63:0] ccwdi, // counter-clockwise data input

	// input  processing element
	input  wire        pesi, // processing element send input
	output wire        peri, // processing element ready input
	input  wire [63:0] pedi, // processing element data input

	// output clockwise
	output wire        cwso, // clockwise send output
	input  wire        cwro, // clockwise ready output
	output wire [63:0] cwdo, // clockwise data output

	// output counter-clockwise
	output wire        ccwso, // counter-clockwise send output
	input  wire        ccwro, // counter-clockwise ready output
	output wire [63:0] ccwdo, // counter-clockwise data output

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
	// CW_INPUT_CTRL.
	wire        cw_in_clear_even,  cw_in_clear_odd;
	wire        cw_in_valid_even,  cw_in_valid_odd;
	wire [63:0] cw_in_data_even,   cw_in_data_odd;

	input_ctrl CW_INPUT_CTRL (
		.clk(clk), .reset(reset), .polarity(polarity),
		.send_in    (cwsi),
		.ready_in   (cwri),
		.data_in    (cwdi),
		.clear_even (cw_in_clear_even),
		.clear_odd  (cw_in_clear_odd),
		.valid_even (cw_in_valid_even),
		.valid_odd  (cw_in_valid_odd),
		.data_even  (cw_in_data_even),
		.data_odd   (cw_in_data_odd)
	);

	// CCW_INPUT_CTRL.
	wire        ccw_in_clear_even, ccw_in_clear_odd;
	wire        ccw_in_valid_even, ccw_in_valid_odd;
	wire [63:0] ccw_in_data_even,  ccw_in_data_odd;

	input_ctrl CCW_INPUT_CTRL (
		.clk(clk), .reset(reset), .polarity(polarity),
		.send_in    (ccwsi),
		.ready_in   (ccwri),
		.data_in    (ccwdi),
		.clear_even (ccw_in_clear_even),
		.clear_odd  (ccw_in_clear_odd),
		.valid_even (ccw_in_valid_even),
		.valid_odd  (ccw_in_valid_odd),
		.data_even  (ccw_in_data_even),
		.data_odd   (ccw_in_data_odd)
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
	// CW_OUTPUT_CTRL.
	wire        cw_out_empty_even,  cw_out_empty_odd;
	wire        cw_out_en_even,  cw_out_en_odd;
	wire [63:0] cw_out_data_even,   cw_out_data_odd;

	output_ctrl CW_OUTPUT_CTRL (
		.clk(clk), .reset(reset), .polarity(polarity),
		.ready_out  (cwro),
		.send_out   (cwso),
		.data_out   (cwdo),
		.empty_even (cw_out_empty_even),
		.empty_odd  (cw_out_empty_odd),
		.en_even    (cw_out_en_even),
		.en_odd     (cw_out_en_odd),
		.data_even  (cw_out_data_even),
		.data_odd   (cw_out_data_odd)
	);

	// CCW_OUTPUT_CTRL.
	wire        ccw_out_empty_even,  ccw_out_empty_odd;
	wire        ccw_out_en_even,  ccw_out_en_odd;
	wire [63:0] ccw_out_data_even,   ccw_out_data_odd;

	output_ctrl CCW_OUTPUT_CTRL (
		.clk(clk), .reset(reset), .polarity(polarity),
		.ready_out  (ccwro),
		.send_out   (ccwso),
		.data_out   (ccwdo),
		.empty_even (ccw_out_empty_even),
		.empty_odd  (ccw_out_empty_odd),
		.en_even    (ccw_out_en_even),
		.en_odd     (ccw_out_en_odd),
		.data_even  (ccw_out_data_even),
		.data_odd   (ccw_out_data_odd)
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
	arbitrator_two_way ARB_EVEN (
        .clk(clk), .reset(reset), .en(!polarity),

		// Inputs from input_ctrl.
        .cw_in_data  (cw_in_data_even),  .cw_in_valid  (cw_in_valid_even),
        .ccw_in_data (ccw_in_data_even), .ccw_in_valid (ccw_in_valid_even),
        .pe_in_data  (pe_in_data_even),  .pe_in_valid  (pe_in_valid_even),

		// Inputs from output_ctrl.
        .cw_out_empty  (cw_out_empty_even),
        .ccw_out_empty (ccw_out_empty_even),
        .pe_out_empty  (pe_out_empty_even),

		// Outputs to input_ctrl.
		.cw_in_clear  (cw_in_clear_even),
		.ccw_in_clear (ccw_in_clear_even),
		.pe_in_clear  (pe_in_clear_even),

		// Outputs to output_ctrl.
		.cw_out_data  (cw_out_data_even),  .cw_out_enable  (cw_out_en_even),
		.ccw_out_data (ccw_out_data_even), .ccw_out_enable (ccw_out_en_even),
		.pe_out_data  (pe_out_data_even),  .pe_out_enable  (pe_out_en_even)
    );

	arbitrator_two_way ARB_ODD (
        .clk(clk), .reset(reset), .en(polarity),

		// Inputs from input_ctrl.
        .cw_in_data  (cw_in_data_odd),  .cw_in_valid (cw_in_valid_odd),
        .ccw_in_data (ccw_in_data_odd), .ccw_in_valid (ccw_in_valid_odd),
        .pe_in_data  (pe_in_data_odd),  .pe_in_valid  (pe_in_valid_odd),

		// Inputs from output_ctrl.
        .cw_out_empty  (cw_out_empty_odd),
        .ccw_out_empty (ccw_out_empty_odd),
        .pe_out_empty  (pe_out_empty_odd),

		// Outputs to input_ctrl.
		.cw_in_clear  (cw_in_clear_odd),
		.ccw_in_clear (ccw_in_clear_odd),
		.pe_in_clear  (pe_in_clear_odd),

		// Outputs to output_ctrl.
		.cw_out_data  (cw_out_data_odd),  .cw_out_enable  (cw_out_en_odd),
		.ccw_out_data (ccw_out_data_odd), .ccw_out_enable (ccw_out_en_odd),
		.pe_out_data  (pe_out_data_odd),  .pe_out_enable  (pe_out_en_odd)
    );
endmodule