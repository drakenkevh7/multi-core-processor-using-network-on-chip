/////////////////////////////////////////////////////////////////
// tb_cardinal_mesh4x4.v  (Verilog-2001 compliant)
/////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_cardinal_mesh4x4;
    // Clock & reset
    reg clk, reset;
    integer cyc;

    // Local PE interfaces
    reg pesi_0_0; reg  [63:0] pedi_0_0; wire peri_0_0; wire peso_0_0; reg  pero_0_0; wire [63:0] pedo_0_0;
    reg pesi_0_1; reg  [63:0] pedi_0_1; wire peri_0_1; wire peso_0_1; reg  pero_0_1; wire [63:0] pedo_0_1;
    reg pesi_0_2; reg  [63:0] pedi_0_2; wire peri_0_2; wire peso_0_2; reg  pero_0_2; wire [63:0] pedo_0_2;
    reg pesi_0_3; reg  [63:0] pedi_0_3; wire peri_0_3; wire peso_0_3; reg  pero_0_3; wire [63:0] pedo_0_3;

    reg pesi_1_0; reg  [63:0] pedi_1_0; wire peri_1_0; wire peso_1_0; reg  pero_1_0; wire [63:0] pedo_1_0;
    reg pesi_1_1; reg  [63:0] pedi_1_1; wire peri_1_1; wire peso_1_1; reg  pero_1_1; wire [63:0] pedo_1_1;
    reg pesi_1_2; reg  [63:0] pedi_1_2; wire peri_1_2; wire peso_1_2; reg  pero_1_2; wire [63:0] pedo_1_2;
    reg pesi_1_3; reg  [63:0] pedi_1_3; wire peri_1_3; wire peso_1_3; reg  pero_1_3; wire [63:0] pedo_1_3;

    reg pesi_2_0; reg  [63:0] pedi_2_0; wire peri_2_0; wire peso_2_0; reg  pero_2_0; wire [63:0] pedo_2_0;
    reg pesi_2_1; reg  [63:0] pedi_2_1; wire peri_2_1; wire peso_2_1; reg  pero_2_1; wire [63:0] pedo_2_1;
    reg pesi_2_2; reg  [63:0] pedi_2_2; wire peri_2_2; wire peso_2_2; reg  pero_2_2; wire [63:0] pedo_2_2;
    reg pesi_2_3; reg  [63:0] pedi_2_3; wire peri_2_3; wire peso_2_3; reg  pero_2_3; wire [63:0] pedo_2_3;

    reg pesi_3_0; reg  [63:0] pedi_3_0; wire peri_3_0; wire peso_3_0; reg  pero_3_0; wire [63:0] pedo_3_0;
    reg pesi_3_1; reg  [63:0] pedi_3_1; wire peri_3_1; wire peso_3_1; reg  pero_3_1; wire [63:0] pedo_3_1;
    reg pesi_3_2; reg  [63:0] pedi_3_2; wire peri_3_2; wire peso_3_2; reg  pero_3_2; wire [63:0] pedo_3_2;
    reg pesi_3_3; reg  [63:0] pedi_3_3; wire peri_3_3; wire peso_3_3; reg  pero_3_3; wire [63:0] pedo_3_3;

    // Polarity outputs
    wire polarity_0_0, polarity_0_1, polarity_0_2, polarity_0_3;
    wire polarity_1_0, polarity_1_1, polarity_1_2, polarity_1_3;
    wire polarity_2_0, polarity_2_1, polarity_2_2, polarity_2_3;
    wire polarity_3_0, polarity_3_1, polarity_3_2, polarity_3_3;

    // DUT
    cardinal_mesh4x4 DUT (
        .clk(clk), .reset(reset),

        .pesi_0_0(pesi_0_0), .pedi_0_0(pedi_0_0), .peri_0_0(peri_0_0), .peso_0_0(peso_0_0), .pero_0_0(pero_0_0), .pedo_0_0(pedo_0_0),
        .pesi_0_1(pesi_0_1), .pedi_0_1(pedi_0_1), .peri_0_1(peri_0_1), .peso_0_1(peso_0_1), .pero_0_1(pero_0_1), .pedo_0_1(pedo_0_1),
        .pesi_0_2(pesi_0_2), .pedi_0_2(pedi_0_2), .peri_0_2(peri_0_2), .peso_0_2(peso_0_2), .pero_0_2(pero_0_2), .pedo_0_2(pedo_0_2),
        .pesi_0_3(pesi_0_3), .pedi_0_3(pedi_0_3), .peri_0_3(peri_0_3), .peso_0_3(peso_0_3), .pero_0_3(pero_0_3), .pedo_0_3(pedo_0_3),

        .pesi_1_0(pesi_1_0), .pedi_1_0(pedi_1_0), .peri_1_0(peri_1_0), .peso_1_0(peso_1_0), .pero_1_0(pero_1_0), .pedo_1_0(pedo_1_0),
        .pesi_1_1(pesi_1_1), .pedi_1_1(pedi_1_1), .peri_1_1(peri_1_1), .peso_1_1(peso_1_1), .pero_1_1(pero_1_1), .pedo_1_1(pedo_1_1),
        .pesi_1_2(pesi_1_2), .pedi_1_2(pedi_1_2), .peri_1_2(peri_1_2), .peso_1_2(peso_1_2), .pero_1_2(pero_1_2), .pedo_1_2(pedo_1_2),
        .pesi_1_3(pesi_1_3), .pedi_1_3(pedi_1_3), .peri_1_3(peri_1_3), .peso_1_3(peso_1_3), .pero_1_3(pero_1_3), .pedo_1_3(pedo_1_3),

        .pesi_2_0(pesi_2_0), .pedi_2_0(pedi_2_0), .peri_2_0(peri_2_0), .peso_2_0(peso_2_0), .pero_2_0(pero_2_0), .pedo_2_0(pedo_2_0),
        .pesi_2_1(pesi_2_1), .pedi_2_1(pedi_2_1), .peri_2_1(peri_2_1), .peso_2_1(peso_2_1), .pero_2_1(pero_2_1), .pedo_2_1(pedo_2_1),
        .pesi_2_2(pesi_2_2), .pedi_2_2(pedi_2_2), .peri_2_2(peri_2_2), .peso_2_2(peso_2_2), .pero_2_2(pero_2_2), .pedo_2_2(pedo_2_2),
        .pesi_2_3(pesi_2_3), .pedi_2_3(pedi_2_3), .peri_2_3(peri_2_3), .peso_2_3(peso_2_3), .pero_2_3(pero_2_3), .pedo_2_3(pedo_2_3),

        .pesi_3_0(pesi_3_0), .pedi_3_0(pedi_3_0), .peri_3_0(peri_3_0), .peso_3_0(peso_3_0), .pero_3_0(pero_3_0), .pedo_3_0(pedo_3_0),
        .pesi_3_1(pesi_3_1), .pedi_3_1(pedi_3_1), .peri_3_1(peri_3_1), .peso_3_1(peso_3_1), .pero_3_1(pero_3_1), .pedo_3_1(pedo_3_1),
        .pesi_3_2(pesi_3_2), .pedi_3_2(pedi_3_2), .peri_3_2(peri_3_2), .peso_3_2(peso_3_2), .pero_3_2(pero_3_2), .pedo_3_2(pedo_3_2),
        .pesi_3_3(pesi_3_3), .pedi_3_3(pedi_3_3), .peri_3_3(peri_3_3), .peso_3_3(peso_3_3), .pero_3_3(pero_3_3), .pedo_3_3(pedo_3_3),

        .polarity_0_0(polarity_0_0), .polarity_0_1(polarity_0_1), .polarity_0_2(polarity_0_2), .polarity_0_3(polarity_0_3),
        .polarity_1_0(polarity_1_0), .polarity_1_1(polarity_1_1), .polarity_1_2(polarity_1_2), .polarity_1_3(polarity_1_3),
        .polarity_2_0(polarity_2_0), .polarity_2_1(polarity_2_1), .polarity_2_2(polarity_2_2), .polarity_2_3(polarity_2_3),
        .polarity_3_0(polarity_3_0), .polarity_3_1(polarity_3_1), .polarity_3_2(polarity_3_2), .polarity_3_3(polarity_3_3)
    );

    // Clock: 250 MHz
    initial begin
        clk = 1'b0;
        forever #2 clk = ~clk;
    end

    // Cycle counter
    always @(posedge clk) begin
        if (reset) cyc <= 0;
        else       cyc <= cyc + 1;
    end

    // Header bit positions
    localparam VC_BIT      = 63;
    localparam DIR_X_BIT   = 62; // 1: LEFT,  0: RIGHT
    localparam DIR_Y_BIT   = 61; // 1: UP,    0: DOWN
    localparam HOP_X_HI    = 55;
    localparam HOP_X_LO    = 52; // 4-bit unsigned
    localparam HOP_Y_HI    = 51;
    localparam HOP_Y_LO    = 48; // 4-bit unsigned
    localparam SRC_X_HI    = 47;
    localparam SRC_X_LO    = 40; // 8 bits
    localparam SRC_Y_HI    = 39;
    localparam SRC_Y_LO    = 33; // 7 bits (bit 32 unused)
    integer error_count = 0;

    // Compute flit header directly from (src_i,src_j) and (dst_i,dst_j)
  // Compute flit header directly from (src_i,src_j) and (dst_i,dst_j)
    function [63:0] mk_xy_flit_xy;
    input integer src_i, src_j;  // row, col  (i = 0..3, j = 0..3)
    input integer dst_i, dst_j;
    input [31:0]  tag;

    reg        dirx, diry;       // 1: LEFT/UP, 0: RIGHT/DOWN
    reg  [3:0] dx, dy;           // unsigned hop counts (<= 15)
    reg  [7:0] src_x8;           // SRC_X field (j)
    reg  [6:0] src_y7;           // SRC_Y field (i)
    begin
        // X direction & magnitude
        if (dst_j < src_j) begin
            dirx = 1'b1;               // LEFT
            dx   = (src_j - dst_j);    // truncates to 4 bits
        // dx = (src_j - dst_j) & 4'hF; // alternative, explicit mask
        end else begin
            dirx = 1'b0;               // RIGHT
            dx   = (dst_j - src_j);
        // dx = (dst_j - src_j) & 4'hF;
        end

        // Y direction & magnitude
        // Mesh convention in your TB: row 0 bottom, row increases upward
        // UP when dst_i > src_i, DOWN when dst_i < src_i
        if (dst_i > src_i) begin
            diry = 1'b1;               // UP
            dy   = (dst_i - src_i);
        // dy = (dst_i - src_i) & 4'hF;
        end else begin
            diry = 1'b0;               // DOWN
            dy   = (src_i - dst_i);
        // dy = (src_i - dst_i) & 4'hF;
        end

        // SRC fields (carried through; not used by arbitrator)
        src_x8 = src_j[7:0];
        src_y7 = src_i[6:0];

        // Pack: {VC, DIR_X, DIR_Y, 5'b0, HOP_X[3:0], HOP_Y[3:0], SRC_X[7:0], SRC_Y[6:0], 1'b0, TAG[31:0]}
        mk_xy_flit_xy = {1'b0, dirx, diry, 5'b0, dx, dy, src_x8, src_y7, 1'b0, tag};
    end
    endfunction

    function integer rand4;
    input integer dummy;
    integer r;
    begin
        r = $random;
        if (r < 0) r = -r;
        rand4 = r % 4;
    end
    endfunction

    // ---------- Setters / Getters ----------
    task set_pesi;
    input integer i, j;
    input v;
    begin case ({i[3:0],j[3:0]})
        8'h00: pesi_0_0=v; 8'h01: pesi_0_1=v; 8'h02: pesi_0_2=v; 8'h03: pesi_0_3=v;
        8'h10: pesi_1_0=v; 8'h11: pesi_1_1=v; 8'h12: pesi_1_2=v; 8'h13: pesi_1_3=v;
        8'h20: pesi_2_0=v; 8'h21: pesi_2_1=v; 8'h22: pesi_2_2=v; 8'h23: pesi_2_3=v;
        8'h30: pesi_3_0=v; 8'h31: pesi_3_1=v; 8'h32: pesi_3_2=v; 8'h33: pesi_3_3=v;
    endcase end
    endtask

    task set_pedi;
    input integer i, j;
    input [63:0] d;
    begin case ({i[3:0],j[3:0]})
        8'h00: pedi_0_0=d; 8'h01: pedi_0_1=d; 8'h02: pedi_0_2=d; 8'h03: pedi_0_3=d;
        8'h10: pedi_1_0=d; 8'h11: pedi_1_1=d; 8'h12: pedi_1_2=d; 8'h13: pedi_1_3=d;
        8'h20: pedi_2_0=d; 8'h21: pedi_2_1=d; 8'h22: pedi_2_2=d; 8'h23: pedi_2_3=d;
        8'h30: pedi_3_0=d; 8'h31: pedi_3_1=d; 8'h32: pedi_3_2=d; 8'h33: pedi_3_3=d;
    endcase end
    endtask

    function get_peri;
    input integer i, j;
    begin case ({i[3:0],j[3:0]})
        8'h00: get_peri=peri_0_0; 8'h01: get_peri=peri_0_1; 8'h02: get_peri=peri_0_2; 8'h03: get_peri=peri_0_3;
        8'h10: get_peri=peri_1_0; 8'h11: get_peri=peri_1_1; 8'h12: get_peri=peri_1_2; 8'h13: get_peri=peri_1_3;
        8'h20: get_peri=peri_2_0; 8'h21: get_peri=peri_2_1; 8'h22: get_peri=peri_2_2; 8'h23: get_peri=peri_2_3;
        8'h30: get_peri=peri_3_0; 8'h31: get_peri=peri_3_1; 8'h32: get_peri=peri_3_2; 8'h33: get_peri=peri_3_3;
        default: get_peri=1'b0;
    endcase end
    endfunction

    function get_peso;
    input integer i, j;
    begin case ({i[3:0],j[3:0]})
        8'h00: get_peso=peso_0_0; 8'h01: get_peso=peso_0_1; 8'h02: get_peso=peso_0_2; 8'h03: get_peso=peso_0_3;
        8'h10: get_peso=peso_1_0; 8'h11: get_peso=peso_1_1; 8'h12: get_peso=peso_1_2; 8'h13: get_peso=peso_1_3;
        8'h20: get_peso=peso_2_0; 8'h21: get_peso=peso_2_1; 8'h22: get_peso=peso_2_2; 8'h23: get_peso=peso_2_3;
        8'h30: get_peso=peso_3_0; 8'h31: get_peso=peso_3_1; 8'h32: get_peso=peso_3_2; 8'h33: get_peso=peso_3_3;
        default: get_peso=1'b0;
    endcase end
    endfunction

    function [63:0] get_pedo;
    input integer i, j;
    begin case ({i[3:0],j[3:0]})
        8'h00: get_pedo=pedo_0_0; 8'h01: get_pedo=pedo_0_1; 8'h02: get_pedo=pedo_0_2; 8'h03: get_pedo=pedo_0_3;
        8'h10: get_pedo=pedo_1_0; 8'h11: get_pedo=pedo_1_1; 8'h12: get_pedo=pedo_1_2; 8'h13: get_pedo=pedo_1_3;
        8'h20: get_pedo=pedo_2_0; 8'h21: get_pedo=pedo_2_1; 8'h22: get_pedo=pedo_2_2; 8'h23: get_pedo=pedo_2_3;
        8'h30: get_pedo=pedo_3_0; 8'h31: get_pedo=pedo_3_1; 8'h32: get_pedo=pedo_3_2; 8'h33: get_pedo=pedo_3_3;
        default: get_pedo=64'h0;
    endcase end
    endfunction

    // Handshake-correct injection
    task inject_local;
    input integer i, j;
    input [63:0] flit;
    begin
        set_pedi(i,j, flit);
        set_pesi(i,j, 1'b1);
        while (!get_peri(i,j)) @(posedge clk);
        @(posedge clk);
        set_pesi(i,j, 1'b0);
        $display("[Cyc %3d] Injected @(%0d,%0d): %h", cyc, i, j, flit);
    end
    endtask

    // Wait for delivery with timeout
    task wait_delivery;
    input integer i, j, timeout;
    output success;
    integer t;
    begin
        success = 1'b0;
        t = 0;
        while (!get_peso(i,j) && t < timeout) begin t = t + 1; @(posedge clk); end
        success = get_peso(i,j);
        end
    endtask

    // Check offsets cleared and tag matches
    task check_zero_hops_and_tag;
    input integer i, j;
    input [31:0] tag;
    reg [63:0] f;
    begin
        f = get_pedo(i,j);
        if (f[31:0] === tag && f[55:52] == 4'h0 && f[51:48] == 4'h0)
        $display("      PASS: (@%0d,%0d) flit ok: %h", i, j, f);
        else begin
            $display("      FAIL: (@%0d,%0d) got %h (tag/offsets mismatch)", i, j, f);
            error_count = error_count + 1;
        end
    end
    endtask

    // Inject two sources in the SAME cycle (when both PERI are high)
    task inject_two_same_cycle;
    input integer i1, j1; input [63:0] flit1;
    input integer i2, j2; input [63:0] flit2;
    begin
        set_pedi(i1, j1, flit1);
        set_pedi(i2, j2, flit2);
        // Wait until BOTH local inputs are ready
        while (!(get_peri(i1,j1) && get_peri(i2,j2))) @(posedge clk);
        @(posedge clk);
        set_pesi(i1, j1, 1'b1);
        set_pesi(i2, j2, 1'b1);
        $display("[Cyc %3d] Injected2 @(%0d,%0d) %h  &&  @(%0d,%0d) %h",
                cyc, i1,j1,flit1, i2,j2,flit2);
        @(posedge clk);
        set_pesi(i1, j1, 1'b0);
        set_pesi(i2, j2, 1'b0);
    end
    endtask

    // Wait for two arrivals at (di,dj), capture both flits exactly when peso is asserted
    task wait_two_at;
    input  integer di, dj, timeout;
    input  [31:0] taga, tagb;
    output integer first_is_a;     // 1 if A first; 0 if B first; -1 on timeout
    output [63:0] f_first, f_second;
    integer t;
    reg [63:0] f;
    begin
        first_is_a = -1;
        f_first  = 64'h0;
        f_second = 64'h0;

        // First arrival
        t = 0;
        while (!get_peso(di,dj) && t < timeout) begin t = t + 1; @(posedge clk); end
        if (!get_peso(di,dj)) begin
        $display("ERROR: timeout waiting first arrival @(%0d,%0d)", di,dj);
        disable wait_two_at;
        end
        // SAMPLE IMMEDIATELY on the arrival cycle
        f = get_pedo(di,dj);
        f_first = f;
        if      (f[31:0] == taga) first_is_a = 1;
        else if (f[31:0] == tagb) first_is_a = 0;
        else $display("WARN: unexpected first tag @(%0d,%0d): %h", di,dj,f);

        // Advance one cycle so sink consumes it
        @(posedge clk);

        // Second arrival
        t = 0;
        while (!get_peso(di,dj) && t < timeout) begin t = t + 1; @(posedge clk); end
        if (!get_peso(di,dj)) begin
        $display("ERROR: timeout waiting second arrival @(%0d,%0d)", di,dj);
        disable wait_two_at;
        end
        // SAMPLE IMMEDIATELY on the arrival cycle
        f_second = get_pedo(di,dj);
    end
    endtask

    reg [31:0] tagaA, tagbA;
    integer firstA;
    reg [63:0] fA_first, fA_second;

    task check_flit_word;
    input integer di, dj;
    input [63:0] f;
    input [31:0] tag;
    begin
        if (f[31:0] === tag && f[HOP_X_HI:HOP_X_LO] == 4'h0 && f[HOP_Y_HI:HOP_Y_LO] == 4'h0)
        $display("      PASS: (@%0d,%0d) flit ok: %h", di, dj, f);
        else begin
        $display("      FAIL: (@%0d,%0d) got %h (tag/offsets mismatch)", di, dj, f);
        error_count = error_count + 1;
        end
    end
    endtask


    // ========== Stimulus ==========

    integer i, j, dst_i, dst_j, tries, si, sj;
    reg [31:0] tag;
    reg ok;

    // Monitor local ejections (optional)
    always @(posedge clk) begin
        if (peso_0_0) $display("[Cyc %3d] (@0,0) OUT %h", cyc, pedo_0_0);
        if (peso_0_1) $display("[Cyc %0d] (@0,1) OUT %h", cyc, pedo_0_1);
        if (peso_0_2) $display("[Cyc %0d] (@0,2) OUT %h", cyc, pedo_0_2);
        if (peso_0_3) $display("[Cyc %0d] (@0,3) OUT %h", cyc, pedo_0_3);
        if (peso_1_0) $display("[Cyc %0d] (@1,0) OUT %h", cyc, pedo_1_0);
        if (peso_1_1) $display("[Cyc %0d] (@1,1) OUT %h", cyc, pedo_1_1);
        if (peso_1_2) $display("[Cyc %0d] (@1,2) OUT %h", cyc, pedo_1_2);
        if (peso_1_3) $display("[Cyc %0d] (@1,3) OUT %h", cyc, pedo_1_3);
        if (peso_2_0) $display("[Cyc %0d] (@2,0) OUT %h", cyc, pedo_2_0);
        if (peso_2_1) $display("[Cyc %0d] (@2,1) OUT %h", cyc, pedo_2_1);
        if (peso_2_2) $display("[Cyc %0d] (@2,2) OUT %h", cyc, pedo_2_2);
        if (peso_2_3) $display("[Cyc %0d] (@2,3) OUT %h", cyc, pedo_2_3);
        if (peso_3_0) $display("[Cyc %0d] (@3,0) OUT %h", cyc, pedo_3_0);
        if (peso_3_1) $display("[Cyc %0d] (@3,1) OUT %h", cyc, pedo_3_1);
        if (peso_3_2) $display("[Cyc %0d] (@3,2) OUT %h", cyc, pedo_3_2);
        if (peso_3_3) $display("[Cyc %0d] (@3,3) OUT %h", cyc, pedo_3_3);
    end

    initial begin

        // Init
        reset = 1; cyc = 0;

        pesi_0_0=0; pedi_0_0=64'd0; pero_0_0=1;
        pesi_0_1=0; pedi_0_1=64'd0; pero_0_1=1;
        pesi_0_2=0; pedi_0_2=64'd0; pero_0_2=1;
        pesi_0_3=0; pedi_0_3=64'd0; pero_0_3=1;

        pesi_1_0=0; pedi_1_0=64'd0; pero_1_0=1;
        pesi_1_1=0; pedi_1_1=64'd0; pero_1_1=1;
        pesi_1_2=0; pedi_1_2=64'd0; pero_1_2=1;
        pesi_1_3=0; pedi_1_3=64'd0; pero_1_3=1;

        pesi_2_0=0; pedi_2_0=64'd0; pero_2_0=1;
        pesi_2_1=0; pedi_2_1=64'd0; pero_2_1=1;
        pesi_2_2=0; pedi_2_2=64'd0; pero_2_2=1;
        pesi_2_3=0; pedi_2_3=64'd0; pero_2_3=1;

        pesi_3_0=0; pedi_3_0=64'd0; pero_3_0=1;
        pesi_3_1=0; pedi_3_1=64'd0; pero_3_1=1;
        pesi_3_2=0; pedi_3_2=64'd0; pero_3_2=1;
        pesi_3_3=0; pedi_3_3=64'd0; pero_3_3=1;

        // Reset
        repeat (6) @(posedge clk);
        reset = 0;
        $display(">> Reset deasserted @ cycle %0d", cyc);

        // 1) Corner (0,0)->(3,3)
        tag = 32'hA000_0001;
        inject_local(0,0, mk_xy_flit_xy(0,0, 3,3, tag));
        wait_delivery(3,3, 240, ok);
        if (!ok) $display("ERROR: corner timeout");
        else     check_zero_hops_and_tag(3,3, tag);

        // 2) Row (1,0)->(1,3)
        tag = 32'hA000_0002;
        inject_local(1,0, mk_xy_flit_xy(1,0, 1,3, tag));
        wait_delivery(1,3, 240, ok);
        if (!ok) $display("ERROR: row timeout");
        else     check_zero_hops_and_tag(1,3, tag);

        // 3) Column (0,2)->(3,2)
        tag = 32'hA000_0003;
        inject_local(0,2, mk_xy_flit_xy(0,2, 3,2, tag));
        wait_delivery(3,2, 240, ok);
        if (!ok) $display("ERROR: column timeout");
        else     check_zero_hops_and_tag(3,2, tag);

        // 4) Local loopback (all nodes)
        $display(">> Local loopback (all 16 nodes)");
        for (i=0;i<4;i=i+1) begin
            for (j=0;j<4;j=j+1) begin
                tag = 32'hB000_0000 | (i*4 + j);
                inject_local(i, j, mk_xy_flit_xy(i, j, i, j, tag));
                wait_delivery(i,j, 100, ok);
                if (!ok) $display("ERROR: loopback timeout @(%0d,%0d)", i,j);
                else     check_zero_hops_and_tag(i,j, tag);
            end
        end

        // 5) Random pairs
        $display(">> Randomized tests");
        for (tries=0; tries<8; tries=tries+1) begin
            si = rand4(0); sj = rand4(0); dst_i = rand4(0); dst_j = rand4(0);
            if (dst_i==si && dst_j==sj) dst_j = (dst_j+1)%4;
            tag = 32'hC000_0000 + tries;
            $display("  rnd%0d: (%0d,%0d)->(%0d,%0d)", tries, si,sj, dst_i,dst_j);
            inject_local(si, sj, mk_xy_flit_xy(si, sj, dst_i, dst_j, tag));
            wait_delivery(dst_i, dst_j, 300, ok);
            if (!ok) $display("ERROR: random%0d timeout", tries);
            else     check_zero_hops_and_tag(dst_i, dst_j, tag);
        end

        // 6) Link sweep: exercise every neighbor link (both directions)
        $display(">> Link sweep (1-hop across every link)");

        // 6a) Horizontal: rightward (j -> j+1)
        for (i=0;i<4;i=i+1) begin
            for (j=0;j<3;j=j+1) begin
                tag = 32'hB100_0000 | (i*8 + j); // unique-ish
                inject_local(i, j, mk_xy_flit_xy(i, j, i, j+1, tag));
                wait_delivery(i, j+1, 120, ok);
                if (!ok) $display("ERROR: horiz right timeout @(%0d,%0d)->(%0d,%0d)", i,j,i,j+1);
                else     check_zero_hops_and_tag(i, j+1, tag);
            end
        end

        // 6b) Horizontal: leftward (j -> j-1)
        for (i=0;i<4;i=i+1) begin
            for (j=1;j<4;j=j+1) begin
                tag = 32'hB101_0000 | (i*8 + j);
                inject_local(i, j, mk_xy_flit_xy(i, j, i, j-1, tag));
                wait_delivery(i, j-1, 120, ok);
                if (!ok) $display("ERROR: horiz left timeout @(%0d,%0d)->(%0d,%0d)", i,j,i,j-1);
                else     check_zero_hops_and_tag(i, j-1, tag);
            end
        end

        // 6c) Vertical: “up” in the mesh sense (i -> i+1, dy < 0 because row0 is bottom)
        for (i=0;i<3;i=i+1) begin
            for (j=0;j<4;j=j+1) begin
                tag = 32'hB102_0000 | (i*8 + j);
                inject_local(i, j, mk_xy_flit_xy(i, j, i+1, j, tag));
                wait_delivery(i+1, j, 120, ok);
                if (!ok) $display("ERROR: vert up timeout @(%0d,%0d)->(%0d,%0d)", i,j,i+1,j);
                else     check_zero_hops_and_tag(i+1, j, tag);
            end
        end

        // 6d) Vertical: “down” (i -> i-1, dy > 0)
        for (i=1;i<4;i=i+1) begin
            for (j=0;j<4;j=j+1) begin
                tag = 32'hB103_0000 | (i*8 + j);
                inject_local(i, j, mk_xy_flit_xy(i, j, i-1, j, tag));
                wait_delivery(i-1, j, 120, ok);
                if (!ok) $display("ERROR: vert down timeout @(%0d,%0d)->(%0d,%0d)", i,j,i-1,j);
                else     check_zero_hops_and_tag(i-1, j, tag);
            end
        end

        // 7) Contention: RIGHT output of router (1,1)
        $display(">> Contention test A: (1,1).RIGHT  from (1,0) & (2,1) -> (1,3)");
        tagaA = 32'hD000_00A1;
        tagbA = 32'hD000_00A2;

        inject_two_same_cycle(
        1,0, mk_xy_flit_xy(1,0, 1,3, tagaA),
        2,1, mk_xy_flit_xy(2,1, 1,3, tagbA)
        );

        wait_two_at(1,3, 200, tagaA, tagbA, firstA, fA_first, fA_second);
        if (firstA == 1) $display("   (A) First delivered: taga=%h then tagb=%h", tagaA, tagbA);
        else if (firstA == 0) $display("   (A) First delivered: tagb=%h then taga=%h", tagbA, tagaA);
        else $display("   (A) Unknown order due to timeout");

        // Verify both captured flits (no re-reads!)
        if (firstA == 1) begin
            check_flit_word(1,3, fA_first,  tagaA);
            check_flit_word(1,3, fA_second, tagbA);
        end else if (firstA == 0) begin
            check_flit_word(1,3, fA_first,  tagbA);
            check_flit_word(1,3, fA_second, tagaA);
        end

        // inject again
        inject_two_same_cycle(
        1,0, mk_xy_flit_xy(1,0, 1,3, tagaA),
        2,1, mk_xy_flit_xy(2,1, 1,3, tagbA)
        );

        wait_two_at(1,3, 200, tagaA, tagbA, firstA, fA_first, fA_second);
        if (firstA == 1) $display("   (A) First delivered: taga=%h then tagb=%h", tagaA, tagbA);
        else if (firstA == 0) $display("   (A) First delivered: tagb=%h then taga=%h", tagbA, tagaA);
        else $display("   (A) Unknown order due to timeout");

        // Verify both captured flits (no re-reads!)
        if (firstA == 1) begin
            check_flit_word(1,3, fA_first,  tagaA);
            check_flit_word(1,3, fA_second, tagbA);
        end else if (firstA == 0) begin
            check_flit_word(1,3, fA_first,  tagbA);
            check_flit_word(1,3, fA_second, tagaA);
        end



        $display("All tests done.");
        if (error_count == 0) $display("All tests passed.");
        else $display("%3d failed.", error_count);
        repeat (20) @(posedge clk); $finish;
    end
endmodule
