// ============================================================================
// 5-input Round-Robin Arbiter (one-hot pointer, one-hot grant), Verilog-2001
// - NUM_REQ fixed to 5 here for simplicity
// - en & out_free gate arbitration; rotates priority on successful conflicting grant
// ============================================================================
module arb_rr5 (
    input  wire        clk,
    input  wire        reset,       // synchronous, active-high
    input  wire        en,          // only arbitrate when 1 (this VC active)
    input  wire        out_free,    // destination buffer empty
    input  wire [4:0]  req,         // requesters: {UP,DOWN,LEFT,RIGHT,PE} ordering chosen by user
    output reg  [4:0]  gnt          // one-hot grant
);
    reg [4:0] pri; // one-hot next-starting priority; reset -> 00001 favors index 0 first

    // combinational grant with rotating priority
    always @* begin
        gnt = 5'b00000;
        if (en && out_free) begin
            case (pri)
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
                default: begin // 5'b10000
                    if      (req[4]) gnt = 5'b10000;
                    else if (req[0]) gnt = 5'b00001;
                    else if (req[1]) gnt = 5'b00010;
                    else if (req[2]) gnt = 5'b00100;
                    else if (req[3]) gnt = 5'b01000;
                end
            endcase
        end
    end

    // rotate priority on successful grant (when any req was served)
    always @(posedge clk) begin
        if (reset) begin
            pri <= 5'b00001;
        end else if (en && out_free && (gnt != 5'b00000)) begin
            // next pri = grant rotated left by 1
            pri <= {gnt[3:0], gnt[4]};
        end
    end
endmodule


// ============================================================================
// INPUT CONTROLLER (same as before; 2 VCs; external VC = ~polarity)
// ============================================================================
module input_ctrl (
    input  wire        clk,
    input  wire        reset,
    input  wire        s_in,
    output reg         r_out,
    input  wire [63:0] data_in,
    input  wire        clear_even,
    input  wire        clear_odd,
    input  wire        polarity,   // 0=even cycle, 1=odd cycle
    output reg [63:0]  data_even,
    output reg         valid_even,
    output reg [63:0]  data_odd,
    output reg         valid_odd
);
    always @(posedge clk) begin
        if (reset) begin
            data_even  <= 64'h0; valid_even <= 1'b0;
            data_odd   <= 64'h0; valid_odd  <= 1'b0;
            r_out      <= 1'b1;
        end else begin
            // ready reflects external VC emptiness
            if (polarity == 1'b0) r_out <= ~valid_odd; else r_out <= ~valid_even;

            // external latch
            if (s_in && r_out) begin
                if (polarity == 1'b0) begin
                    data_odd  <= data_in;  valid_odd  <= 1'b1;
                end else begin
                    data_even <= data_in;  valid_even <= 1'b1;
                end
            end

            // clears from allocator
            if (clear_even && !(s_in && r_out && (polarity==1'b1))) valid_even <= 1'b0;
            if (clear_odd  && !(s_in && r_out && (polarity==1'b0))) valid_odd  <= 1'b0;
        end
    end
endmodule


// ============================================================================
// OUTPUT CONTROLLER (same as before; 2 VCs; external VC = ~polarity)
// ============================================================================
module output_ctrl (
    input  wire        clk,
    input  wire        reset,
    input  wire        polarity,      // 0=even, 1=odd

    // downstream handshake
    input  wire        ready_out,     // ro
    output wire        send_out,      // so
    output wire [63:0] data_out,      // do

    // write port from allocator (internal VC only)
    input  wire [63:0] wr_data_even,
    input  wire        wr_en_even,
    input  wire [63:0] wr_data_odd,
    input  wire        wr_en_odd,

    // status back to allocator
    output wire        empty_even,
    output wire        empty_odd
);
    reg [63:0] q_even, q_odd;
    reg        v_even, v_odd;

    wire use_odd_ext  = (polarity == 1'b0); // even cycle -> external ODD
    wire use_even_ext = (polarity == 1'b1); // odd  cycle -> external EVEN

    assign data_out   = use_odd_ext ? q_odd : q_even;
    assign send_out   = use_odd_ext ? (v_odd  & ready_out) : (v_even & ready_out);
    assign empty_even = ~v_even;
    assign empty_odd  = ~v_odd;

    always @(posedge clk) begin
        if (reset) begin
            q_even <= 64'h0; v_even <= 1'b0;
            q_odd  <= 64'h0; v_odd  <= 1'b0;
        end else begin
            // internal writes
            if (polarity == 1'b0) begin
                if (wr_en_even && ~v_even) begin
                    q_even <= wr_data_even; v_even <= 1'b1;
                end
            end else begin
                if (wr_en_odd  && ~v_odd) begin
                    q_odd  <= wr_data_odd;  v_odd  <= 1'b1;
                end
            end

            // external send/consume
            if (use_odd_ext  && v_odd  && ready_out) v_odd  <= 1'b0;
            if (use_even_ext && v_even && ready_out) v_even <= 1'b0;
        end
    end
endmodule


// ============================================================================
// SWITCH ALLOCATOR for ONE VC (EVEN or ODD) — 5 inputs x 5 outputs (mesh)
// - Deterministic XY routing using signed 4-bit X and Y offsets in HOP field
// - Updates offsets toward zero when forwarding to a mesh direction
// - Delivers to PE when both offsets are zero (no header change required)
// ============================================================================
// Indices mapping (fixed):
//   inputs / outputs order = {UP(0), DOWN(1), LEFT(2), RIGHT(3), PE(4)}
// ============================================================================
module switch_alloc_mesh_vc #(
    // Hop field placement (within [55:48]): X=[55:52], Y=[51:48]
    parameter HOP_X_HI = 55,
    parameter HOP_X_LO = 52,
    parameter HOP_Y_HI = 51,
    parameter HOP_Y_LO = 48
)(
    input  wire        clk,
    input  wire        reset,
    input  wire        active,        // this VC is the internal phase this cycle

    // input VCs (this VC only)
    input  wire [63:0] in_up_d,
    input  wire        in_up_v,
    input  wire [63:0] in_down_d,
    input  wire        in_down_v,
    input  wire [63:0] in_left_d,
    input  wire        in_left_v,
    input  wire [63:0] in_right_d,
    input  wire        in_right_v,
    input  wire [63:0] in_pe_d,
    input  wire        in_pe_v,

    // output VC empties (this VC only)
    input  wire        out_up_empty,
    input  wire        out_down_empty,
    input  wire        out_left_empty,
    input  wire        out_right_empty,
    input  wire        out_pe_empty,

    // write ports to output VCs (this VC only)
    output reg  [63:0] out_up_wd,
    output reg         out_up_we,
    output reg  [63:0] out_down_wd,
    output reg         out_down_we,
    output reg  [63:0] out_left_wd,
    output reg         out_left_we,
    output reg  [63:0] out_right_wd,
    output reg         out_right_we,
    output reg  [63:0] out_pe_wd,
    output reg         out_pe_we,

    // clears back to input VCs (this VC only)
    output reg         clr_up,
    output reg         clr_down,
    output reg         clr_left,
    output reg         clr_right,
    output reg         clr_pe
);
    // ----- helper: sign-extend 4-bit nibble to 8-bit signed -----
    function [7:0] sx4;
        input [3:0] n;
        begin sx4 = {{4{n[3]}}, n}; end
    endfunction

    // ----- per-input route decode: compute target and updated-flit -----
    // targets: 0=UP,1=DOWN,2=LEFT,3=RIGHT,4=PE, 7=NONE
    reg [2:0] tgt [0:4];
    reg [63:0] upd [0:4];
    reg        val [0:4];

    // local wires to simplify (index mapping noted above)
    wire [63:0] d [0:4];
    wire        v [0:4];

    assign d[0] = in_up_d;    assign v[0] = in_up_v;
    assign d[1] = in_down_d;  assign v[1] = in_down_v;
    assign d[2] = in_left_d;  assign v[2] = in_left_v;
    assign d[3] = in_right_d; assign v[3] = in_right_v;
    assign d[4] = in_pe_d;    assign v[4] = in_pe_v;

    integer i;
    reg signed [7:0] x_off, y_off;
    always @* begin
        for (i=0;i<5;i=i+1) begin
            val[i] = v[i];
            upd[i] = d[i];
            // default: no target
            tgt[i] = 3'd7;

            // only decode when valid
            if (v[i]) begin
                x_off = sx4(d[i][HOP_X_HI:HOP_X_LO]);
                y_off = sx4(d[i][HOP_Y_HI:HOP_Y_LO]);

                if (x_off < 0) begin
                    // LEFT: increment X toward 0
                    x_off = x_off + 8'sd1;
                    upd[i][HOP_X_HI:HOP_X_LO] = x_off[3:0];
                    tgt[i] = 3'd2;
                end else if (x_off > 0) begin
                    // RIGHT: decrement X toward 0
                    x_off = x_off - 8'sd1;
                    upd[i][HOP_X_HI:HOP_X_LO] = x_off[3:0];
                    tgt[i] = 3'd3;
                end else if (y_off < 0) begin
                    // UP: increment Y toward 0
                    y_off = y_off + 8'sd1;
                    upd[i][HOP_Y_HI:HOP_Y_LO] = y_off[3:0];
                    tgt[i] = 3'd0;
                end else if (y_off > 0) begin
                    // DOWN: decrement Y toward 0
                    y_off = y_off - 8'sd1;
                    upd[i][HOP_Y_HI:HOP_Y_LO] = y_off[3:0];
                    tgt[i] = 3'd1;
                end else begin
                    // at destination
                    tgt[i] = 3'd4; // PE
                    // (no hop modification for delivery)
                end
            end
        end
    end

    // ----- build per-output request vectors (5 requesters each) -----
    wire [4:0] req_up, req_down, req_left, req_right, req_pe;

    assign req_up    = { (tgt[4]==3'd0)&val[4], (tgt[3]==3'd0)&val[3], (tgt[2]==3'd0)&val[2],
                         (tgt[1]==3'd0)&val[1], (tgt[0]==3'd0)&val[0] }; // {PE,RIGHT,LEFT,DOWN,UP}
    assign req_down  = { (tgt[4]==3'd1)&val[4], (tgt[3]==3'd1)&val[3], (tgt[2]==3'd1)&val[2],
                         (tgt[1]==3'd1)&val[1], (tgt[0]==3'd1)&val[0] };
    assign req_left  = { (tgt[4]==3'd2)&val[4], (tgt[3]==3'd2)&val[3], (tgt[2]==3'd2)&val[2],
                         (tgt[1]==3'd2)&val[1], (tgt[0]==3'd2)&val[0] };
    assign req_right = { (tgt[4]==3'd3)&val[4], (tgt[3]==3'd3)&val[3], (tgt[2]==3'd3)&val[2],
                         (tgt[1]==3'd3)&val[1], (tgt[0]==3'd3)&val[0] };
    assign req_pe    = { (tgt[4]==3'd4)&val[4], (tgt[3]==3'd4)&val[3], (tgt[2]==3'd4)&val[2],
                         (tgt[1]==3'd4)&val[1], (tgt[0]==3'd4)&val[0] };

    // ----- arbiters (5 outputs) -----
    wire [4:0] g_up, g_down, g_left, g_right, g_pe;

    arb_rr5 ARB_UP    (.clk(clk), .reset(reset), .en(active), .out_free(out_up_empty),    .req(req_up),    .gnt(g_up));
    arb_rr5 ARB_DOWN  (.clk(clk), .reset(reset), .en(active), .out_free(out_down_empty),  .req(req_down),  .gnt(g_down));
    arb_rr5 ARB_LEFT  (.clk(clk), .reset(reset), .en(active), .out_free(out_left_empty),  .req(req_left),  .gnt(g_left));
    arb_rr5 ARB_RIGHT (.clk(clk), .reset(reset), .en(active), .out_free(out_right_empty), .req(req_right), .gnt(g_right));
    arb_rr5 ARB_PE    (.clk(clk), .reset(reset), .en(active), .out_free(out_pe_empty),    .req(req_pe),    .gnt(g_pe));

    // ----- encode grant index helper -----
    function [2:0] enc5;
        input [4:0] oh;
        begin
            if      (oh[0]) enc5 = 3'd0;
            else if (oh[1]) enc5 = 3'd1;
            else if (oh[2]) enc5 = 3'd2;
            else if (oh[3]) enc5 = 3'd3;
            else if (oh[4]) enc5 = 3'd4;
            else            enc5 = 3'd7;
        end
    endfunction

    // ----- drive writes and clears (combinational) -----
    reg [2:0] gi_up, gi_down, gi_left, gi_right, gi_pe;

    always @* begin
        // defaults
        out_up_wd=64'h0;   out_up_we=1'b0;
        out_down_wd=64'h0; out_down_we=1'b0;
        out_left_wd=64'h0; out_left_we=1'b0;
        out_right_wd=64'h0;out_right_we=1'b0;
        out_pe_wd=64'h0;   out_pe_we=1'b0;
        clr_up=1'b0; clr_down=1'b0; clr_left=1'b0; clr_right=1'b0; clr_pe=1'b0;

        if (active) begin
            gi_up    = enc5(g_up);
            gi_down  = enc5(g_down);
            gi_left  = enc5(g_left);
            gi_right = enc5(g_right);
            gi_pe    = enc5(g_pe);

            // UP output
            case (gi_up)
                3'd0: begin out_up_wd = upd[0]; out_up_we=1'b1; clr_up   = 1'b1; end
                3'd1: begin out_up_wd = upd[1]; out_up_we=1'b1; clr_down = 1'b1; end
                3'd2: begin out_up_wd = upd[2]; out_up_we=1'b1; clr_left = 1'b1; end
                3'd3: begin out_up_wd = upd[3]; out_up_we=1'b1; clr_right= 1'b1; end
                3'd4: begin out_up_wd = upd[4]; out_up_we=1'b1; clr_pe   = 1'b1; end
            endcase

            // DOWN output
            case (gi_down)
                3'd0: begin out_down_wd= upd[0]; out_down_we=1'b1; clr_up   = 1'b1; end
                3'd1: begin out_down_wd= upd[1]; out_down_we=1'b1; clr_down = 1'b1; end
                3'd2: begin out_down_wd= upd[2]; out_down_we=1'b1; clr_left = 1'b1; end
                3'd3: begin out_down_wd= upd[3]; out_down_we=1'b1; clr_right= 1'b1; end
                3'd4: begin out_down_wd= upd[4]; out_down_we=1'b1; clr_pe   = 1'b1; end
            endcase

            // LEFT output
            case (gi_left)
                3'd0: begin out_left_wd= upd[0]; out_left_we=1'b1; clr_up   = 1'b1; end
                3'd1: begin out_left_wd= upd[1]; out_left_we=1'b1; clr_down = 1'b1; end
                3'd2: begin out_left_wd= upd[2]; out_left_we=1'b1; clr_left = 1'b1; end
                3'd3: begin out_left_wd= upd[3]; out_left_we=1'b1; clr_right= 1'b1; end
                3'd4: begin out_left_wd= upd[4]; out_left_we=1'b1; clr_pe   = 1'b1; end
            endcase

            // RIGHT output
            case (gi_right)
                3'd0: begin out_right_wd= upd[0]; out_right_we=1'b1; clr_up   = 1'b1; end
                3'd1: begin out_right_wd= upd[1]; out_right_we=1'b1; clr_down = 1'b1; end
                3'd2: begin out_right_wd= upd[2]; out_right_we=1'b1; clr_left = 1'b1; end
                3'd3: begin out_right_wd= upd[3]; out_right_we=1'b1; clr_right= 1'b1; end
                3'd4: begin out_right_wd= upd[4]; out_right_we=1'b1; clr_pe   = 1'b1; end
            endcase

            // PE output (local delivery; no hop change already done)
            case (gi_pe)
                3'd0: begin out_pe_wd = d[0]; out_pe_we=1'b1; clr_up    = 1'b1; end
                3'd1: begin out_pe_wd = d[1]; out_pe_we=1'b1; clr_down  = 1'b1; end
                3'd2: begin out_pe_wd = d[2]; out_pe_we=1'b1; clr_left  = 1'b1; end
                3'd3: begin out_pe_wd = d[3]; out_pe_we=1'b1; clr_right = 1'b1; end
                3'd4: begin out_pe_wd = d[4]; out_pe_we=1'b1; clr_pe    = 1'b1; end
            endcase
        end
    end
endmodule


// ============================================================================
// TOP-LEVEL: 5-port mesh router with PE, even/odd VCs, Verilog-2001
// ============================================================================
module cardinal_router_fourdirectional (
    input  wire        clk,
    input  wire        reset,     // active-high synchronous reset
    output reg         polarity,  // 0=even, 1=odd

    // INPUTS from neighbors / PE
    input  wire        upsi,      output wire upri,      input  wire [63:0] updi,
    input  wire        downsi,    output wire downri,    input  wire [63:0] downdi,
    input  wire        leftsi,    output wire leftri,    input  wire [63:0] leftdi,
    input  wire        rightsi,   output wire rightri,   input  wire [63:0] rightdi,
    input  wire        pesi,      output wire peri,      input  wire [63:0] pedi,

    // OUTPUTS to neighbors / PE
    output wire        upso,      input  wire upro,      output wire [63:0] updo,
    output wire        downso,    input  wire downro,    output wire [63:0] downdo,
    output wire        leftso,    input  wire leftro,    output wire [63:0] leftdo,
    output wire        rightso,   input  wire rightro,   output wire [63:0] rightdo,
    output wire        peso,      input  wire pero,      output wire [63:0] pedo
);
    // polarity generation
    always @(posedge clk) begin
        if (reset) polarity <= 1'b0;
        else       polarity <= ~polarity;
    end

    // ------------ wires for input_ctrls ------------
    // up
    wire [63:0] up_e_d, up_o_d; wire up_e_v, up_o_v; wire up_clr_e_e, up_clr_o_o;
    // down
    wire [63:0] down_e_d, down_o_d; wire down_e_v, down_o_v; wire down_clr_e_e, down_clr_o_o;
    // left
    wire [63:0] left_e_d, left_o_d; wire left_e_v, left_o_v; wire left_clr_e_e, left_clr_o_o;
    // right
    wire [63:0] right_e_d, right_o_d; wire right_e_v, right_o_v; wire right_clr_e_e, right_clr_o_o;
    // pe
    wire [63:0] pe_e_d, pe_o_d; wire pe_e_v, pe_o_v; wire pe_clr_e_e, pe_clr_o_o;

    // ------------ wires for output_ctrls ------------
    // up
    wire up_empty_e, up_empty_o; wire [63:0] up_wd_e, up_wd_o; wire up_we_e, up_we_o;
    // down
    wire down_empty_e, down_empty_o; wire [63:0] down_wd_e, down_wd_o; wire down_we_e, down_we_o;
    // left
    wire left_empty_e, left_empty_o; wire [63:0] left_wd_e, left_wd_o; wire left_we_e, left_we_o;
    // right
    wire right_empty_e, right_empty_o; wire [63:0] right_wd_e, right_wd_o; wire right_we_e, right_we_o;
    // pe
    wire pe_empty_e, pe_empty_o; wire [63:0] pe_wd_e, pe_wd_o; wire pe_we_e, pe_we_o;

    // ------------ instantiate input_ctrls ------------
    input_ctrl IN_UP    (.clk(clk), .reset(reset), .s_in(upsi),    .r_out(upri),    .data_in(updi),
                         .clear_even(up_clr_e_e), .clear_odd(up_clr_o_o), .polarity(polarity),
                         .data_even(up_e_d), .valid_even(up_e_v), .data_odd(up_o_d), .valid_odd(up_o_v));
    input_ctrl IN_DOWN  (.clk(clk), .reset(reset), .s_in(downsi),  .r_out(downri),  .data_in(downdi),
                         .clear_even(down_clr_e_e), .clear_odd(down_clr_o_o), .polarity(polarity),
                         .data_even(down_e_d), .valid_even(down_e_v), .data_odd(down_o_d), .valid_odd(down_o_v));
    input_ctrl IN_LEFT  (.clk(clk), .reset(reset), .s_in(leftsi),  .r_out(leftri),  .data_in(leftdi),
                         .clear_even(left_clr_e_e), .clear_odd(left_clr_o_o), .polarity(polarity),
                         .data_even(left_e_d), .valid_even(left_e_v), .data_odd(left_o_d), .valid_odd(left_o_v));
    input_ctrl IN_RIGHT (.clk(clk), .reset(reset), .s_in(rightsi), .r_out(rightri), .data_in(rightdi),
                         .clear_even(right_clr_e_e), .clear_odd(right_clr_o_o), .polarity(polarity),
                         .data_even(right_e_d), .valid_even(right_e_v), .data_odd(right_o_d), .valid_odd(right_o_v));
    input_ctrl IN_PE    (.clk(clk), .reset(reset), .s_in(pesi),    .r_out(peri),    .data_in(pedi),
                         .clear_even(pe_clr_e_e), .clear_odd(pe_clr_o_o), .polarity(polarity),
                         .data_even(pe_e_d), .valid_even(pe_e_v), .data_odd(pe_o_d), .valid_odd(pe_o_v));

    // ------------ instantiate output_ctrls ------------
    output_ctrl OUT_UP    (.clk(clk), .reset(reset), .polarity(polarity),
                           .ready_out(upro), .send_out(upso), .data_out(updo),
                           .wr_data_even(up_wd_e), .wr_en_even(up_we_e),
                           .wr_data_odd(up_wd_o),  .wr_en_odd(up_we_o),
                           .empty_even(up_empty_e), .empty_odd(up_empty_o));
    output_ctrl OUT_DOWN  (.clk(clk), .reset(reset), .polarity(polarity),
                           .ready_out(downro), .send_out(downso), .data_out(downdo),
                           .wr_data_even(down_wd_e), .wr_en_even(down_we_e),
                           .wr_data_odd(down_wd_o),  .wr_en_odd(down_we_o),
                           .empty_even(down_empty_e), .empty_odd(down_empty_o));
    output_ctrl OUT_LEFT  (.clk(clk), .reset(reset), .polarity(polarity),
                           .ready_out(leftro), .send_out(leftso), .data_out(leftdo),
                           .wr_data_even(left_wd_e), .wr_en_even(left_we_e),
                           .wr_data_odd(left_wd_o),  .wr_en_odd(left_we_o),
                           .empty_even(left_empty_e), .empty_odd(left_empty_o));
    output_ctrl OUT_RIGHT (.clk(clk), .reset(reset), .polarity(polarity),
                           .ready_out(rightro), .send_out(rightso), .data_out(rightdo),
                           .wr_data_even(right_wd_e), .wr_en_even(right_we_e),
                           .wr_data_odd(right_wd_o),  .wr_en_odd(right_we_o),
                           .empty_even(right_empty_e), .empty_odd(right_empty_o));
    output_ctrl OUT_PE    (.clk(clk), .reset(reset), .polarity(polarity),
                           .ready_out(pero), .send_out(peso), .data_out(pedo),
                           .wr_data_even(pe_wd_e), .wr_en_even(pe_we_e),
                           .wr_data_odd(pe_wd_o),  .wr_en_odd(pe_we_o),
                           .empty_even(pe_empty_e), .empty_odd(pe_empty_o));

    // ------------ switch allocator: EVEN VC (active when polarity==0) ------------
    switch_alloc_mesh_vc #(.HOP_X_HI(55), .HOP_X_LO(52), .HOP_Y_HI(51), .HOP_Y_LO(48)) SA_EVEN (
        .clk(clk), .reset(reset), .active(~polarity),
        .in_up_d(up_e_d),     .in_up_v(up_e_v),
        .in_down_d(down_e_d), .in_down_v(down_e_v),
        .in_left_d(left_e_d), .in_left_v(left_e_v),
        .in_right_d(right_e_d), .in_right_v(right_e_v),
        .in_pe_d(pe_e_d),     .in_pe_v(pe_e_v),
        .out_up_empty(up_empty_e), .out_down_empty(down_empty_e),
        .out_left_empty(left_empty_e), .out_right_empty(right_empty_e),
        .out_pe_empty(pe_empty_e),
        .out_up_wd(up_wd_e), .out_up_we(up_we_e),
        .out_down_wd(down_wd_e), .out_down_we(down_we_e),
        .out_left_wd(left_wd_e), .out_left_we(left_we_e),
        .out_right_wd(right_wd_e), .out_right_we(right_we_e),
        .out_pe_wd(pe_wd_e), .out_pe_we(pe_we_e),
        .clr_up(up_clr_e_e), .clr_down(down_clr_e_e), .clr_left(left_clr_e_e),
        .clr_right(right_clr_e_e), .clr_pe(pe_clr_e_e)
    );

    // ------------ switch allocator: ODD VC (active when polarity==1) ------------
    switch_alloc_mesh_vc #(.HOP_X_HI(55), .HOP_X_LO(52), .HOP_Y_HI(51), .HOP_Y_LO(48)) SA_ODD (
        .clk(clk), .reset(reset), .active(polarity),
        .in_up_d(up_o_d),     .in_up_v(up_o_v),
        .in_down_d(down_o_d), .in_down_v(down_o_v),
        .in_left_d(left_o_d), .in_left_v(left_o_v),
        .in_right_d(right_o_d), .in_right_v(right_o_v),
        .in_pe_d(pe_o_d),     .in_pe_v(pe_o_v),
        .out_up_empty(up_empty_o), .out_down_empty(down_empty_o),
        .out_left_empty(left_empty_o), .out_right_empty(right_empty_o),
        .out_pe_empty(pe_empty_o),
        .out_up_wd(up_wd_o), .out_up_we(up_we_o),
        .out_down_wd(down_wd_o), .out_down_we(down_we_o),
        .out_left_wd(left_wd_o), .out_left_we(left_we_o),
        .out_right_wd(right_wd_o), .out_right_we(right_we_o),
        .out_pe_wd(pe_wd_o), .out_pe_we(pe_we_o),
        .clr_up(up_clr_o_o), .clr_down(down_clr_o_o), .clr_left(left_clr_o_o),
        .clr_right(right_clr_o_o), .clr_pe(pe_clr_o_o)
    );

endmodule
