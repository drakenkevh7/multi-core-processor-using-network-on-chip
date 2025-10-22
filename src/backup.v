// ============================================================================
// Cardinal Bidirectional Ring NoC Router (Verilog-2001, structural, synthesizable)
// - Follows EE577B slides & spec, with HOP FIELD **DECREMENT (binary count)**
//   rather than bit-wise shifting.
// - Two virtual channels (VCs): EVEN(0) and ODD(1) per physical channel.
// - Internal forwarding uses VC == polarity; external link uses VC == ~polarity.
// - Round-robin (rotating) arbitration per output & per VC with specified
//   initial priorities (PE: cw>ccw, CW: cw_in>pe_in, CCW: ccw_in>pe_in).
// - Single-entry 64-bit buffers per (port, VC) for both input and output.
// - Active-high **synchronous** reset.
//
// Ports (three input channels, three output channels, plus clk/reset/polarity):
//   cw:  cwsi,cwri,cwdi   | cwso,cwro,cwdo
//   ccw: ccwsi,ccwri,ccwdi| ccwso,ccwro,ccwdo
//   pe:  pesi,peri,pedi   | peso,pero,pedo
//
// Header fields (top 16 bits of packet):
//   [63]      VC-hint (ignored by router for VC selection; we use polarity)
//   [62]      DIR (0=cw, 1=ccw)   (used only for PE-injected packets)
//   [61:56]   reserved (0)
//   [55:48]   HOP (8-bit **binary count**) -> decrement by 1 on each cw/ccw hop
//
// Destination detection at cw/ccw inputs (per slides):
//   if HOP == 0 -> route to PE output; else continue in that direction and DEC hop.
// ============================================================================

`timescale 1ns/1ps

// ---------------------------------------------------------------------------
// 2-input round-robin arbiter with enable and out_free gating
// - INIT_PRI = 0 favors req0 on first tie; 1 favors req1.
// - Priority flips only when en & out_free & both request & a grant occurs.
// ---------------------------------------------------------------------------
module arb2_rr #(parameter INIT_PRI = 1'b0) (
    input  wire clk,
    input  wire reset,     // synchronous, active-high
    input  wire en,        // consider requests only when 'en' (active VC)
    input  wire out_free,  // destination buffer free
    input  wire req0,
    input  wire req1,
    output reg  gnt0,
    output reg  gnt1
);
    reg pri;  // 0 => prefer req0 on ties; 1 => prefer req1 on ties

    always @(*) begin
        gnt0 = 1'b0;
        gnt1 = 1'b0;
        if (en && out_free) begin
            if (req0 && !req1) begin
                gnt0 = 1'b1;
            end else if (!req0 && req1) begin
                gnt1 = 1'b1;
            end else if (req0 && req1) begin
                if (pri == 1'b0) gnt0 = 1'b1; else gnt1 = 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            pri <= INIT_PRI;
        end else if (en && out_free && req0 && req1 && (gnt0 ^ gnt1)) begin
            pri <= ~pri;  // rotate on conflicting grant
        end
    end
endmodule

// ---------------------------------------------------------------------------
// INPUT CONTROLLER (one physical input channel: cw/ccw/pe)
// - Two single-entry buffers (even & odd).
// - Accepts on VC that is *external* this cycle:
//     polarity==0 (even cycle): external VC = ODD  -> latch odd, r_out = ~odd_valid
//     polarity==1 (odd  cycle): external VC = EVEN -> latch even, r_out = ~even_valid
// - clear_even/clear_odd asserted by allocator when that VC was forwarded.
// ---------------------------------------------------------------------------
module input_ctrl (
    input  wire       clk,
    input  wire       reset,       // synchronous, active-high
    input  wire       s_in,
    output reg        r_out,
    input  wire [63:0] data_in,
    input  wire       clear_even,
    input  wire       clear_odd,
    input  wire       polarity,    // 0=even cycle, 1=odd cycle
    output reg [63:0] data_even,
    output reg        valid_even,
    output reg [63:0] data_odd,
    output reg        valid_odd
);
    always @(posedge clk) begin
        if (reset) begin
            data_even  <= 64'h0; valid_even <= 1'b0;
            data_odd   <= 64'h0; valid_odd  <= 1'b0;
            r_out      <= 1'b1;  // ri asserted during reset (buffers empty)
        end else begin
            // Ready reflects emptiness of the VC that will receive externally this cycle
            if (polarity == 1'b0) r_out <= ~valid_odd;   // even cycle -> external ODD
            else                  r_out <= ~valid_even;  // odd  cycle -> external EVEN

            // Latch incoming on handshake (s_in && r_out)
            if (s_in && r_out) begin
                if (polarity == 1'b0) begin
                    // even cycle externally -> ODD VC receives
                    data_odd  <= data_in;
                    valid_odd <= 1'b1;
                end else begin
                    // odd cycle externally -> EVEN VC receives
                    data_even  <= data_in;
                    valid_even <= 1'b1;
                end
            end

            // Clear VC after internal forward (allocator pulses clear)
            if (clear_even && !(s_in && r_out && (polarity==1'b1))) valid_even <= 1'b0;
            if (clear_odd  && !(s_in && r_out && (polarity==1'b0))) valid_odd  <= 1'b0;
        end
    end
endmodule

// ---------------------------------------------------------------------------
// OUTPUT CONTROLLER (one physical output channel: cw/ccw/pe)
// - Two single-entry buffers (even & odd).
// - INTERNAL writes (allocator): only into VC == polarity (even on even, odd on odd).
// - EXTERNAL send: VC == ~polarity goes on the wire if valid & r_in.
// ---------------------------------------------------------------------------
module output_ctrl (
    input  wire       clk,
    input  wire       reset,         // synchronous

	
    output wire       s_out,
    input  wire       r_in,
    output wire [63:0] data_out,
    input  wire [63:0] wr_data_even,
    input  wire       wr_en_even,    // asserted only on even cycles by allocator
    input  wire [63:0] wr_data_odd,
    input  wire       wr_en_odd,     // asserted only on odd cycles by allocator
    input  wire       polarity,      // 0=even, 1=odd
    output wire       empty_even,
    output wire       empty_odd
);
    reg [63:0] q_even, q_odd;
    reg        v_even, v_odd;

    // External VC for this cycle
    wire use_odd_ext  = (polarity == 1'b0); // even cycle -> external ODD
    wire use_even_ext = (polarity == 1'b1); // odd  cycle -> external EVEN

    assign data_out   = use_odd_ext  ? q_odd  : q_even;
    assign s_out      = use_odd_ext  ? (v_odd  & r_in) : (v_even & r_in);
    assign empty_even = ~v_even;
    assign empty_odd  = ~v_odd;

    always @(posedge clk) begin
        if (reset) begin
            q_even <= 64'h0; v_even <= 1'b0;
            q_odd  <= 64'h0; v_odd  <= 1'b0;
        end else begin
            // Internal writes from allocator (one VC per cycle)
            if (polarity == 1'b0) begin
                if (wr_en_even && ~v_even) begin
                    q_even <= wr_data_even;
                    v_even <= 1'b1;
                end
            end else begin
                if (wr_en_odd && ~v_odd) begin
                    q_odd <= wr_data_odd;
                    v_odd <= 1'b1;
                end
            end

            // External send/consume
            if (use_odd_ext && v_odd && r_in)  v_odd  <= 1'b0;
            if (use_even_ext && v_even && r_in) v_even <= 1'b0;
        end
    end
endmodule

// ---------------------------------------------------------------------------
// SWITCH ALLOCATOR for ONE VC (even or odd)
// - 'active' must be 1 when this VC is the internal phase (polarity==VC).
// - Decodes routing, arbitrates per-output, writes output VC buffers,
//   and clears the granted input buffer.
// - HOP FIELD: **binary decrement** by 1 on CW/CCW forward (min 0).
// - PE delivery: do NOT modify header (no hop update when going to PE).
// ---------------------------------------------------------------------------
module switch_alloc_vc #(
    parameter VC_BIT    = 63,
    parameter DIR_BIT   = 62,
    parameter HOP_HI    = 55,
    parameter HOP_LO    = 48,
    // Arbiter initial priorities (per slides)
    parameter PE_INIT   = 1'b0,  // PE output: cw_in over ccw_in initially
    parameter CW_INIT   = 1'b0,  // CW output: cw_in over pe_in initially
    parameter CCW_INIT  = 1'b0   // CCW output: ccw_in over pe_in initially
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       active,          // 1 when this VC is internally processed (polarity==VC)

    // Inputs from input_ctrl for this VC
    input  wire [63:0] cw_in_d,
    input  wire       cw_in_v,
    input  wire [63:0] ccw_in_d,
    input  wire       ccw_in_v,
    input  wire [63:0] pe_in_d,
    input  wire       pe_in_v,

    // Output buffer empty status (for this VC)
    input  wire       cw_out_empty,
    input  wire       ccw_out_empty,
    input  wire       pe_out_empty,

    // Writes to output_ctrl (this VC only)
    output reg  [63:0] cw_out_wd,
    output reg         cw_out_we,
    output reg  [63:0] ccw_out_wd,
    output reg         ccw_out_we,
    output reg  [63:0] pe_out_wd,
    output reg         pe_out_we,

    // Clears to input_ctrl (this VC only)
    output reg         cw_in_clr,
    output reg         ccw_in_clr,
    output reg         pe_in_clr
);
    // ---- Helper: binary decrement of HOP (saturate at 0) ----
    function [7:0] dec_hop_bin;
        input [7:0] hop;
        begin
            if (hop == 8'd0) dec_hop_bin = 8'd0;
            else             dec_hop_bin = hop - 8'd1;
        end
    endfunction

    // ---- Decode requests (combinational) ----
    // PE input uses DIR_BIT to choose CW/CCW (only on injection).
    wire pe_req_cw  = pe_in_v  & (pe_in_d[DIR_BIT]  == 1'b0) & cw_out_empty;
    wire pe_req_ccw = pe_in_v  & (pe_in_d[DIR_BIT]  == 1'b1) & ccw_out_empty;

    // CW input: if HOP==0 -> request PE; else request CW (and DEC hop on write)
    wire [7:0] cw_hop  = cw_in_d[HOP_HI:HOP_LO];
    wire cw_req_pe     = cw_in_v & (cw_hop == 8'd0) & pe_out_empty;
    wire cw_req_cw     = cw_in_v & (cw_hop != 8'd0) & cw_out_empty;

    // CCW input: if HOP==0 -> request PE; else request CCW (and DEC hop on write)
    wire [7:0] ccw_hop = ccw_in_d[HOP_HI:HOP_LO];
    wire ccw_req_pe    = ccw_in_v & (ccw_hop == 8'd0) & pe_out_empty;
    wire ccw_req_ccw   = ccw_in_v & (ccw_hop != 8'd0) & ccw_out_empty;

    // ---- Per-output arbiters (2 requestors each) ----
    // PE output: cw_in vs ccw_in   (INIT: cw > ccw)
    wire g_pe_cw, g_pe_ccw;
    arb2_rr #(PE_INIT) ARB_PE (
        .clk(clk), .reset(reset), .en(active), .out_free(pe_out_empty),
        .req0(cw_req_pe), .req1(ccw_req_pe),
        .gnt0(g_pe_cw),   .gnt1(g_pe_ccw)
    );

    // CW output: cw_in (continue) vs pe_in (inject cw)   (INIT: cw_in > pe_in)
    wire g_cw_cw_in, g_cw_pe_in;
    arb2_rr #(CW_INIT) ARB_CW (
        .clk(clk), .reset(reset), .en(active), .out_free(cw_out_empty),
        .req0(cw_req_cw), .req1(pe_req_cw),	
        .gnt0(g_cw_cw_in), .gnt1(g_cw_pe_in)
    );

    // CCW output: ccw_in (continue) vs pe_in (inject ccw) (INIT: ccw_in > pe_in)
    wire g_ccw_ccw_in, g_ccw_pe_in;
    arb2_rr #(CCW_INIT) ARB_CCW (
        .clk(clk), .reset(reset), .en(active), .out_free(ccw_out_empty),
        .req0(ccw_req_ccw), .req1(pe_req_ccw),
        .gnt0(g_ccw_ccw_in), .gnt1(g_ccw_pe_in)
    );

    // ---- Build write data / enables & input clears (combinational) ----
    always @(*) begin
        // defaults
        cw_out_wd  = 64'h0; cw_out_we  = 1'b0;
        ccw_out_wd = 64'h0; ccw_out_we = 1'b0;
        pe_out_wd  = 64'h0; pe_out_we  = 1'b0;
        cw_in_clr  = 1'b0;  ccw_in_clr = 1'b0; pe_in_clr = 1'b0;

        if (active) begin
            // PE output grants (no hop change)
            if (g_pe_cw) begin
                pe_out_wd  = cw_in_d;  // deliver to local
                pe_out_we  = 1'b1;
                cw_in_clr  = 1'b1;
            end else if (g_pe_ccw) begin
                pe_out_wd  = ccw_in_d; // deliver to local
                pe_out_we  = 1'b1;
                ccw_in_clr = 1'b1;
            end

            // CW output grants (DEC hop)
            if (g_cw_cw_in) begin
                cw_out_wd                 = cw_in_d;
                cw_out_wd[HOP_HI:HOP_LO]  = dec_hop_bin(cw_in_d[HOP_HI:HOP_LO]);
                cw_out_we                 = 1'b1;
                cw_in_clr                 = 1'b1;
            end else if (g_cw_pe_in) begin
                cw_out_wd                 = pe_in_d;
                cw_out_wd[HOP_HI:HOP_LO]  = dec_hop_bin(pe_in_d[HOP_HI:HOP_LO]);
                cw_out_we                 = 1'b1;
                pe_in_clr                 = 1'b1;
            end

            // CCW output grants (DEC hop)
            if (g_ccw_ccw_in) begin
                ccw_out_wd                = ccw_in_d;
                ccw_out_wd[HOP_HI:HOP_LO] = dec_hop_bin(ccw_in_d[HOP_HI:HOP_LO]);
                ccw_out_we                = 1'b1;
                ccw_in_clr                = 1'b1;
            end else if (g_ccw_pe_in) begin
                ccw_out_wd                = pe_in_d;
                ccw_out_wd[HOP_HI:HOP_LO] = dec_hop_bin(pe_in_d[HOP_HI:HOP_LO]);
                ccw_out_we                = 1'b1;
                pe_in_clr                 = 1'b1;
            end
        end
    end
endmodule

// ---------------------------------------------------------------------------
// TOP-LEVEL ROUTER
// - Generates polarity (synchronous reset -> even during reset; toggles every clk).
// - Instantiates 3x input_ctrl, 3x output_ctrl, and 2x switch_alloc_vc (even/odd).
// ---------------------------------------------------------------------------
module cardinal_router (
    input  wire       clk,
    input  wire       reset,   // synchronous, active-high

    // CW input
    input  wire       cwsi,
    output wire       cwri,
    input  wire [63:0] cwdi,
    // CCW input
    input  wire       ccwsi,
    output wire       ccwri,
    input  wire [63:0] ccwdi,
    // PE input
    input  wire       pesi,
    output wire       peri,
    input  wire [63:0] pedi,

    // CW output
    output wire       cwso,
    input  wire       cwro,
    output wire [63:0] cwdo,
    // CCW output
    output wire       ccwso,
    input  wire       ccwro,
    output wire [63:0] ccwdo,
    // PE output
    output wire       peso,
    input  wire       pero,
    output wire [63:0] pedo,

    output reg        polarity  // 0=even, 1=odd
);
    // --------- Polarity (synchronous) ---------
    always @(posedge clk) begin
        if (reset) polarity <= 1'b0;  // even during reset
        else       polarity <= ~polarity; // first full cycle after reset is odd
    end

    // --------- Wires between blocks ---------
    // Input buffers
    wire [63:0] cw_in_even_d, cw_in_odd_d;
    wire        cw_in_even_v, cw_in_odd_v;
    wire        cw_clr_even_e, cw_clr_odd_o;  // clears from VC even/odd allocators (one per VC)
    wire        cw_clr_even_o_unused, cw_clr_odd_e_unused; // unused splits to OR later if needed

    wire [63:0] ccw_in_even_d, ccw_in_odd_d;
    wire        ccw_in_even_v, ccw_in_odd_v;
    wire        ccw_clr_even_e, ccw_clr_odd_o;
    wire        ccw_clr_even_o_unused, ccw_clr_odd_e_unused;

    wire [63:0] pe_in_even_d, pe_in_odd_d;
    wire        pe_in_even_v, pe_in_odd_v;
    wire        pe_clr_even_e, pe_clr_odd_o;
    wire        pe_clr_even_o_unused, pe_clr_odd_e_unused;

    // Output buffers
    wire        cw_empty_even,  cw_empty_odd;
    wire [63:0] cw_wd_even,     cw_wd_odd;
    wire        cw_we_even,     cw_we_odd;

    wire        ccw_empty_even, ccw_empty_odd;
    wire [63:0] ccw_wd_even,    ccw_wd_odd;
    wire        ccw_we_even,    ccw_we_odd;

    wire        pe_empty_even,  pe_empty_odd;
    wire [63:0] pe_wd_even,     pe_wd_odd;
    wire        pe_we_even,     pe_we_odd;

    // --------- Input Controllers ---------
    input_ctrl IN_CW (
        .clk(clk), .reset(reset),
        .s_in(cwsi), .r_out(cwri), .data_in(cwdi),
        .clear_even(cw_clr_even_e /*| cw_clr_even_o_unused*/),
        .clear_odd (cw_clr_odd_o  /*| cw_clr_odd_e_unused */),
        .polarity(polarity),
        .data_even(cw_in_even_d), .valid_even(cw_in_even_v),
        .data_odd (cw_in_odd_d),  .valid_odd (cw_in_odd_v)
    );
    input_ctrl IN_CCW (
        .clk(clk), .reset(reset),
        .s_in(ccwsi), .r_out(ccwri), .data_in(ccwdi),
        .clear_even(ccw_clr_even_e /*| ccw_clr_even_o_unused*/),
        .clear_odd (ccw_clr_odd_o  /*| ccw_clr_odd_e_unused */),
        .polarity(polarity),
        .data_even(ccw_in_even_d), .valid_even(ccw_in_even_v),
        .data_odd (ccw_in_odd_d),  .valid_odd (ccw_in_odd_v)
    );
    input_ctrl IN_PE (
        .clk(clk), .reset(reset),
        .s_in(pesi), .r_out(peri), .data_in(pedi),
        .clear_even(pe_clr_even_e /*| pe_clr_even_o_unused*/),
        .clear_odd (pe_clr_odd_o  /*| pe_clr_odd_e_unused */),
        .polarity(polarity),
        .data_even(pe_in_even_d), .valid_even(pe_in_even_v),
        .data_odd (pe_in_odd_d),  .valid_odd (pe_in_odd_v)
    );

    // --------- Output Controllers ---------
    output_ctrl OUT_CW (
        .clk(clk), .reset(reset),
        .s_out(cwso), .r_in(cwro), .data_out(cwdo),
        .wr_data_even(cw_wd_even), .wr_en_even(cw_we_even),
        .wr_data_odd (cw_wd_odd),  .wr_en_odd (cw_we_odd),
        .polarity(polarity),
        .empty_even(cw_empty_even), .empty_odd(cw_empty_odd)
    );
    output_ctrl OUT_CCW (
        .clk(clk), .reset(reset),
        .s_out(ccwso), .r_in(ccwro), .data_out(ccwdo),
        .wr_data_even(ccw_wd_even), .wr_en_even(ccw_we_even),
        .wr_data_odd (ccw_wd_odd),  .wr_en_odd (ccw_we_odd),
        .polarity(polarity),
        .empty_even(ccw_empty_even), .empty_odd(ccw_empty_odd)
    );
    output_ctrl OUT_PE (
        .clk(clk), .reset(reset),
        .s_out(peso), .r_in(pero), .data_out(pedo),
        .wr_data_even(pe_wd_even), .wr_en_even(pe_we_even),
        .wr_data_odd (pe_wd_odd),  .wr_en_odd (pe_we_odd),
        .polarity(polarity),
        .empty_even(pe_empty_even), .empty_odd(pe_empty_odd)
    );

    // --------- SWITCH ALLOCATOR: EVEN VC (active when polarity==0) ---------
    switch_alloc_vc #(
        .VC_BIT(63), .DIR_BIT(62), .HOP_HI(55), .HOP_LO(48),
        .PE_INIT(1'b0), .CW_INIT(1'b0), .CCW_INIT(1'b0)
    ) SA_EVEN (
        .clk(clk), .reset(reset), .active(~polarity),
        .cw_in_d(cw_in_even_d),   .cw_in_v(cw_in_even_v),
        .ccw_in_d(ccw_in_even_d), .ccw_in_v(ccw_in_even_v),
        .pe_in_d(pe_in_even_d),   .pe_in_v(pe_in_even_v),
        .cw_out_empty(cw_empty_even),
        .ccw_out_empty(ccw_empty_even),
        .pe_out_empty(pe_empty_even),
        .cw_out_wd(cw_wd_even),   .cw_out_we(cw_we_even),
        .ccw_out_wd(ccw_wd_even), .ccw_out_we(ccw_we_even),
        .pe_out_wd(pe_wd_even),   .pe_out_we(pe_we_even),
        .cw_in_clr(cw_clr_even_e),
        .ccw_in_clr(ccw_clr_even_e),
        .pe_in_clr(pe_clr_even_e)
    );

    // --------- SWITCH ALLOCATOR: ODD VC (active when polarity==1) ---------
    switch_alloc_vc #(
        .VC_BIT(63), .DIR_BIT(62), .HOP_HI(55), .HOP_LO(48),
        .PE_INIT(1'b0), .CW_INIT(1'b0), .CCW_INIT(1'b0)
    ) SA_ODD (
        .clk(clk), .reset(reset), .active(polarity),
        .cw_in_d(cw_in_odd_d),   .cw_in_v(cw_in_odd_v),
        .ccw_in_d(ccw_in_odd_d), .ccw_in_v(ccw_in_odd_v),
        .pe_in_d(pe_in_odd_d),   .pe_in_v(pe_in_odd_v),
        .cw_out_empty(cw_empty_odd),
        .ccw_out_empty(ccw_empty_odd),
        .pe_out_empty(pe_empty_odd),
        .cw_out_wd(cw_wd_odd),   .cw_out_we(cw_we_odd),
        .ccw_out_wd(ccw_wd_odd), .ccw_out_we(ccw_we_odd),
        .pe_out_wd(pe_wd_odd),   .pe_out_we(pe_we_odd),
        .cw_in_clr(cw_clr_odd_o),
        .ccw_in_clr(ccw_clr_odd_o),
        .pe_in_clr(pe_clr_odd_o)
    );

endmodule
