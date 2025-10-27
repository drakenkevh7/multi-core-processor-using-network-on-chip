/////////////////////////////////////////////////////////////////
//       testbench: tb_cardinal_mesh4x4.v
/////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_cardinal_mesh4x4;
    // Clock & reset
    reg clk, reset;
    integer cyc;
    reg polarity;

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

    // Optional polarity taps (unused here, but wired)
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

    // 250 MHz clock
    initial begin
        clk = 1'b0;
        forever #2 clk = ~clk;
    end
	always @(posedge clk) begin
		if (reset) polarity <= 1'b0;
		else       polarity <= ~polarity;
	end

    // Cycle counter
    always @(posedge clk) begin
        if (reset) cyc <= 0;
        else       cyc <= cyc + 1;
    end

    // Header bit positions (for logging decode)
    localparam VC_BIT    = 63;
    localparam DIR_X_BIT = 62;
    localparam DIR_Y_BIT = 61;
    localparam HOP_X_HI  = 55;
    localparam HOP_X_LO  = 52;
    localparam HOP_Y_HI  = 51;
    localparam HOP_Y_LO  = 48;
    localparam SRC_X_HI  = 47;
    localparam SRC_X_LO  = 40;
    localparam SRC_Y_HI  = 39;
    localparam SRC_Y_LO  = 32;

    // Timeouts
    parameter PHASE_TIMEOUT = 24; // cycles per phase (adjust if needed)

    // ---------- Helpers ----------
    function [63:0] mk_xy_flit_xy;
        input integer src_i, src_j;
        input integer dst_i, dst_j;
        input [31:0] tag;   // payload (we put PhaseID in tag[7:0])
        reg dirx, diry;
        reg [3:0] dx, dy;
        reg [7:0] src_x8;
        reg [7:0] src_y8;
    begin
        if (dst_j < src_j) begin dirx = 1'b1; dx = (src_j - dst_j); end
        else               begin dirx = 1'b0; dx = (dst_j - src_j); end
        if (dst_i > src_i) begin diry = 1'b1; dy = (dst_i - src_i); end
        else               begin diry = 1'b0; dy = (src_i - dst_i); end
        src_x8 = src_j[7:0];
        src_y8 = src_i[7:0];
        mk_xy_flit_xy = {polarity, dirx, diry, 5'b0, dx, dy, src_x8, src_y8, tag};
    end
    endfunction

    // Map node id <0..15> <-> (i,j)
    function integer node_id; input integer i,j; begin node_id = i*4 + j; end endfunction
    function integer id_i;    input integer id;  begin id_i    = id/4;   end endfunction
    function integer id_j;    input integer id;  begin id_j    = id%4;   end endfunction

    // Signal accessors
    task set_pesi; input integer i,j; input v;
    begin case ({i[3:0],j[3:0]})
        8'h00: pesi_0_0=v; 8'h01: pesi_0_1=v; 8'h02: pesi_0_2=v; 8'h03: pesi_0_3=v;
        8'h10: pesi_1_0=v; 8'h11: pesi_1_1=v; 8'h12: pesi_1_2=v; 8'h13: pesi_1_3=v;
        8'h20: pesi_2_0=v; 8'h21: pesi_2_1=v; 8'h22: pesi_2_2=v; 8'h23: pesi_2_3=v;
        8'h30: pesi_3_0=v; 8'h31: pesi_3_1=v; 8'h32: pesi_3_2=v; 8'h33: pesi_3_3=v;
    endcase end
    endtask

    task set_pedi; input integer i,j; input [63:0] d;
    begin case ({i[3:0],j[3:0]})
        8'h00: pedi_0_0=d; 8'h01: pedi_0_1=d; 8'h02: pedi_0_2=d; 8'h03: pedi_0_3=d;
        8'h10: pedi_1_0=d; 8'h11: pedi_1_1=d; 8'h12: pedi_1_2=d; 8'h13: pedi_1_3=d;
        8'h20: pedi_2_0=d; 8'h21: pedi_2_1=d; 8'h22: pedi_2_2=d; 8'h23: pedi_2_3=d;
        8'h30: pedi_3_0=d; 8'h31: pedi_3_1=d; 8'h32: pedi_3_2=d; 8'h33: pedi_3_3=d;
    endcase end
    endtask

    function get_peri; input integer i,j;
    begin case ({i[3:0],j[3:0]})
        8'h00: get_peri=peri_0_0; 8'h01: get_peri=peri_0_1; 8'h02: get_peri=peri_0_2; 8'h03: get_peri=peri_0_3;
        8'h10: get_peri=peri_1_0; 8'h11: get_peri=peri_1_1; 8'h12: get_peri=peri_1_2; 8'h13: get_peri=peri_1_3;
        8'h20: get_peri=peri_2_0; 8'h21: get_peri=peri_2_1; 8'h22: get_peri=peri_2_2; 8'h23: get_peri=peri_2_3;
        8'h30: get_peri=peri_3_0; 8'h31: get_peri=peri_3_1; 8'h32: get_peri=peri_3_2; 8'h33: get_peri=peri_3_3;
        default: get_peri=1'b0;
    endcase end
    endfunction

    function get_peso; input integer i,j;
    begin case ({i[3:0],j[3:0]})
        8'h00: get_peso=peso_0_0; 8'h01: get_peso=peso_0_1; 8'h02: get_peso=peso_0_2; 8'h03: get_peso=peso_0_3;
        8'h10: get_peso=peso_1_0; 8'h11: get_peso=peso_1_1; 8'h12: get_peso=peso_1_2; 8'h13: get_peso=peso_1_3;
        8'h20: get_peso=peso_2_0; 8'h21: get_peso=peso_2_1; 8'h22: get_peso=peso_2_2; 8'h23: get_peso=peso_2_3;
        8'h30: get_peso=peso_3_0; 8'h31: get_peso=peso_3_1; 8'h32: get_peso=peso_3_2; 8'h33: get_peso=peso_3_3;
        default: get_peso=1'b0;
    endcase end
    endfunction

    function [63:0] get_pedo; input integer i,j;
    begin case ({i[3:0],j[3:0]})
        8'h00: get_pedo=pedo_0_0; 8'h01: get_pedo=pedo_0_1; 8'h02: get_pedo=pedo_0_2; 8'h03: get_pedo=pedo_0_3;
        8'h10: get_pedo=pedo_1_0; 8'h11: get_pedo=pedo_1_1; 8'h12: get_pedo=pedo_1_2; 8'h13: get_pedo=pedo_1_3;
        8'h20: get_pedo=pedo_2_0; 8'h21: get_pedo=pedo_2_1; 8'h22: get_pedo=pedo_2_2; 8'h23: get_pedo=pedo_2_3;
        8'h30: get_pedo=pedo_3_0; 8'h31: get_pedo=pedo_3_1; 8'h32: get_pedo=pedo_3_2; 8'h33: get_pedo=pedo_3_3;
        default: get_pedo=64'h0;
    endcase end
    endfunction

    // ---------- Files ----------
    integer fh_time;
    integer fh_log;

    // ---------- Stimulus (Gather) ----------
    integer i, j, k, start_cyc, end_cyc;
    integer di, dj;                // destination coords for this phase
    reg [31:0] tag;

    // Buffers / bookkeeping for handshake (Verilog-2001 memories & bitmasks)
    reg [63:0] flit_buf [0:15];    // precomputed flits per source id
    reg [15:0] pending;            // 1 => this source still needs to inject
    reg [15:0] asserted;           // 1 => pesi currently asserted
    reg [15:0] accept_mask;        // who was accepted at this posedge
    integer    accepted_cnt;
    integer    recv_cnt;
    integer    phase_cycles;

    // Decode helpers for logging
    integer src_i, src_j;
    reg [63:0] f;

    integer id, si, sj;
    // 250 MHz clock already defined

    initial begin
        // Init
        reset = 1'b1; cyc = 0;

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

        // Open files
        fh_time = $fopen("start_end_time.out","w");
        fh_log  = $fopen("gather_all.txt","w");
        $fdisplay(fh_time, "Gather testbench start");

        // Reset
        repeat (6) @(posedge clk);
        reset = 1'b0;
        $display(">> Reset deasserted @ cycle %0d", cyc);

        // ---------- Phases 0..15 ----------
        // k = 0;
        for (k=0; k<16; k=k+1) begin
        di = id_i(k);
        dj = id_j(k);

        // Prepare flits and masks
        pending      = 16'h0000;
        asserted     = 16'h0000;
        accept_mask  = 16'h0000;
        accepted_cnt = 0;
        recv_cnt     = 0;
        phase_cycles = 0;

        tag = {24'b1, k[7:0]};
        // Precompute payload: tag[7:0] carries destination id (=phase number)
        
        for (i=0; i<4; i=i+1) begin
            for (j=0; j<4; j=j+1) begin
            if (!(i==di && j==dj)) begin
                flit_buf[node_id(i,j)] = mk_xy_flit_xy(i, j, di, dj, tag);
                pending[node_id(i,j)]  = 1'b1;
            end
            end
        end
        // i = 2;
        // j = 3;
        flit_buf[node_id(i,j)] = mk_xy_flit_xy(i, j, di, dj, tag);
        pending[node_id(i,j)]  = 1'b1;

        start_cyc = cyc + 1;
        $fdisplay(fh_time, "Phase %0d start_cycle=%0d (dest=(%0d,%0d))", k, start_cyc, di, dj);

        // Main per-phase loop (no fork/join)
        // Drives many sources over multiple cycles; each holds pesi until accepted.
        while ((recv_cnt < 15) && (phase_cycles < PHASE_TIMEOUT)) begin
            

            // NEGEDGE A: assert any ready sources that are pending and not yet asserted
            @(negedge clk);
            for (id=0; id<16; id=id+1) begin
            if (pending[id] && !asserted[id]) begin
                si = id_i(id); sj = id_j(id);
                // $display(si, sj);
                if (get_peri(si,sj)) begin
                set_pedi(si, sj, flit_buf[id]);
                set_pesi(si, sj, 1'b1);
                asserted[id] = 1'b1;
                end
            end
            end

            // POSEDGE: sample acceptances, log arrivals at destination
            @(posedge clk);
            phase_cycles = phase_cycles + 1;
            accept_mask  = 16'h0000;

            // Arrivals: log only when peso is asserted
            if (get_peso(di, dj)) begin
            f     = get_pedo(di, dj);
            src_j = f[SRC_X_HI:SRC_X_LO];
            src_i = f[SRC_Y_HI:SRC_Y_LO];

            $fdisplay(fh_log,
                "Phase=%2d, Time=%4d, Destination=(%0d,%0d), Source=(%0d,%0d), Packet Value=%b",
                k, cyc, di, dj, src_i, src_j, f);
            recv_cnt = recv_cnt + 1;
            end

            // Which asserted sources are accepted this cycle? (peri==1 on this posedge)
            for (id=0; id<16; id=id+1) begin
            if (pending[id] && asserted[id]) begin
                si = id_i(id); sj = id_j(id);
                if (get_peri(si,sj)) accept_mask[id] = 1'b1;
            end
            end

            // NEGEDGE B: drop pesi for the accepted set; mark them done
            @(negedge clk);
            for (id=0; id<16; id=id+1) begin
            if (accept_mask[id]) begin
                si = id_i(id); sj = id_j(id);
                set_pesi(si, sj, 1'b0);
                asserted[id]    = 1'b0;
                pending[id]     = 1'b0;
                accepted_cnt    = accepted_cnt + 1;
            end
            end
        end // while

        if (recv_cnt < 15) begin
            $display("ERROR: Phase %0d timeout after %0d cycles (%0d/15 arrivals, %0d accepted)",
                    k, phase_cycles, recv_cnt, accepted_cnt);
        end

        end_cyc = cyc;
        $fdisplay(fh_time, "Phase %0d end_cycle=%0d", k, end_cyc);
        end // phase loop

        $fdisplay(fh_time, "Gather testbench complete at cycle %0d", cyc);
        $fclose(fh_time);
        $fclose(fh_log);

        // Drain and finish
        repeat (20) @(posedge clk);
        $finish;
    end

    // always @(posedge clk) begin

    //     // $strobe("[Cyc %2d] router_2_0.ARB_EVEN.req_down: %b", cyc, tb_cardinal_mesh4x4.DUT.router_2_0.ARB_EVEN.req_down);
    //     // $strobe("[Cyc %2d] router_2_0.ARB_EVEN.gnt_down: %b", cyc, tb_cardinal_mesh4x4.DUT.router_2_0.ARB_EVEN.gnt_down);
    //    // $strobe("[Cyc %0d] router_2_0.downdo: %64b", cyc, tb_cardinal_mesh4x4.DUT.router_2_0.downdo);
    // //    $strobe("[Cyc %2d] r2_0 upri=%0b upsi=%0b updi=%64b up_in_valid_even=%0b up_in_ext_even=%1b rightV=%0b EVEN down: req=%05b gnt=%05b emptyE=%0b emptyO=%0b vE=%0b vO=%0b",
    // //     cyc,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.upri,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.upsi,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.updi,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.UP_INPUT_CTRL.valid_even,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.UP_INPUT_CTRL.ext_even,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.RIGHT_INPUT_CTRL.valid_even,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.ARB_EVEN.req_down,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.ARB_EVEN.gnt_down,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.down_out_empty_even,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.down_out_empty_odd,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.DOWN_OUTPUT_CTRL.output_buffer_valid_even,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.DOWN_OUTPUT_CTRL.output_buffer_valid_odd);

    // // $strobe("[Cyc %2d] r2_0 upri=%0b upsi=%0b updi=%64b up_in_valid_even=%0b data_even=%64b up_in_ext_even=%1b",
    // //     cyc,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.upri,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.upsi,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.updi,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.UP_INPUT_CTRL.valid_even,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.UP_INPUT_CTRL.data_even,
    // //     tb_cardinal_mesh4x4.DUT.router_2_0.UP_INPUT_CTRL.ext_even

    // // );

    // end

endmodule
