/////////////////////////////////////////////////////////////////
//       testbench: tb_cardinal_router_four_way.v
/////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_cardinal_router_four_way;

    // Clock / reset
    reg clk, reset;

    // INPUTS to DUT (from neighbors / PE)
    reg        upsi;    wire upri;    reg  [63:0] updi;
    reg        downsi;  wire downri;  reg  [63:0] downdi;
    reg        leftsi;  wire leftri;  reg  [63:0] leftdi;
    reg        rightsi; wire rightri; reg  [63:0] rightdi;
    reg        pesi;    wire peri;    reg  [63:0] pedi;

    // OUTPUTS from DUT (to neighbors / PE)
    wire       upso;    reg  upro;    wire [63:0] updo;
    wire       downso;  reg  downro;  wire [63:0] downdo;
    wire       leftso;  reg  leftro;  wire [63:0] leftdo;
    wire       rightso; reg  rightro; wire [63:0] rightdo;
    wire       peso;    reg  pero;    wire [63:0] pedo;

    // Router polarity
    wire polarity;

    // DUT
    cardinal_router_four_way DUT (
        .clk(clk), .reset(reset), .polarity(polarity),
        .upsi(upsi), .upri(upri), .updi(updi),
        .downsi(downsi), .downri(downri), .downdi(downdi),
        .leftsi(leftsi), .leftri(leftri), .leftdi(leftdi),
        .rightsi(rightsi), .rightri(rightri), .rightdi(rightdi),
        .pesi(pesi), .peri(peri), .pedi(pedi),
        .upso(upso), .upro(upro), .updo(updo),
        .downso(downso), .downro(downro), .downdo(downdo),
        .leftso(leftso), .leftro(leftro), .leftdo(leftdo),
        .rightso(rightso), .rightro(rightro), .rightdo(rightdo),
        .peso(peso), .pero(pero), .pedo(pedo)
    );

    // 100 MHz clock
    initial begin clk = 1'b0; forever #5 clk = ~clk; end

    // Cycle counter
    integer cyc;
    always @(posedge clk) cyc <= cyc + 1;

    // Print helper: sign-extend nibble to integer
    function integer sx4_to_int;
        input [3:0] n;
        begin
            sx4_to_int = $signed({{28{n[3]}}, n});  // 4->32 bits with sign
        end
    endfunction

    // Monitor sends (external VC = ~polarity)
    always @(posedge clk) begin
        if (upso)    $display("[Cyc %0d | pol=%0d] UP    send : %h (X=%0d, Y=%0d)",   cyc, polarity, updo,
            sx4_to_int(updo[55:52]), sx4_to_int(updo[51:48]));
        if (downso)  $display("[Cyc %0d | pol=%0d] DOWN  send : %h (X=%0d, Y=%0d)",   cyc, polarity, downdo,
            sx4_to_int(downdo[55:52]), sx4_to_int(downdo[51:48]));
        if (leftso)  $display("[Cyc %0d | pol=%0d] LEFT  send : %h (X=%0d, Y=%0d)",   cyc, polarity, leftdo,
            sx4_to_int(leftdo[55:52]), sx4_to_int(leftdo[51:48]));
        if (rightso) $display("[Cyc %0d | pol=%0d] RIGHT send : %h (X=%0d, Y=%0d)",   cyc, polarity, rightdo,
            sx4_to_int(rightdo[55:52]), sx4_to_int(rightdo[51:48]));
        if (peso)    $display("[Cyc %0d | pol=%0d] PE    send : %h (X=%0d, Y=%0d)",   cyc, polarity, pedo,
            sx4_to_int(pedo[55:52]), sx4_to_int(pedo[51:48]));
    end

    // Build a flit with XY hop nibbles
    function [63:0] mk_xy_flit;
        input [3:0] x4; // signed nibble
        input [3:0] y4; // signed nibble
        input [31:0] tag;
        begin
            mk_xy_flit = {8'h00, x4, y4, 16'h0000, tag};
        end
    endfunction

    // Handshake-safe inject tasks
    task inject_up;    input [63:0] flit; begin updi   <= flit; upsi   <= 1'b1; while(!upri)   @(posedge clk); @(posedge clk); upsi   <= 1'b0; end endtask
    task inject_down;  input [63:0] flit; begin downdi <= flit; downsi <= 1'b1; while(!downri) @(posedge clk); @(posedge clk); downsi <= 1'b0; end endtask
    task inject_left;  input [63:0] flit; begin leftdi <= flit; leftsi <= 1'b1; while(!leftri) @(posedge clk); @(posedge clk); leftsi <= 1'b0; end endtask
    task inject_right; input [63:0] flit; begin rightdi<= flit; rightsi<= 1'b1; while(!rightri)@(posedge clk); @(posedge clk); rightsi<= 1'b0; end endtask
    task inject_pe;    input [63:0] flit; begin pedi   <= flit; pesi   <= 1'b1; while(!peri)   @(posedge clk); @(posedge clk); pesi   <= 1'b0; end endtask

    // Stimulus
    initial begin
        cyc = 0;
        reset = 1;
        upsi=0;   updi=0;    upro=1;
        downsi=0; downdi=0;  downro=1;
        leftsi=0; leftdi=0;  leftro=1;
        rightsi=0; rightdi=0; rightro=1;
        pesi=0;   pedi=0;    pero=1;

        // reset two cycles
        repeat(2) @(posedge clk);
        reset = 0;
        $display(">> Reset deasserted at cyc=%0d", cyc);

        // SCEN 1: PE → RIGHT (X=+2, Y=+1)  tag=0xA000_0001
        inject_pe   (mk_xy_flit( 4'sd2,  4'sd1, 32'hA000_0001));
        repeat(6) @(posedge clk);

        // SCEN 2: PE → LEFT (X=-3, Y=0)    tag=0xA000_0002
        inject_pe   (mk_xy_flit(-4'sd3,  4'sd0, 32'hA000_0002));
        repeat(6) @(posedge clk);

        // SCEN 3: UP  → DOWN (X=0,  Y=+2)  tag=0xA000_0003
        inject_up   (mk_xy_flit( 4'sd0,  4'sd2, 32'hA000_0003));
        repeat(6) @(posedge clk);

        // SCEN 4: DOWN→ UP   (X=0,  Y=-1)  tag=0xA000_0004
        inject_down (mk_xy_flit( 4'sd0, -4'sd1, 32'hA000_0004));
        repeat(6) @(posedge clk);

        // SCEN 5: Contention on RIGHT (same VC window)
        fork
        inject_pe  (mk_xy_flit( 4'sd1,  4'sd0, 32'hA000_0011));
        inject_left(mk_xy_flit( 4'sd2,  4'sd0, 32'hA000_0012));
        join
        repeat(10) @(posedge clk);

        // SCEN 6: Backpressure on RIGHT
        rightro = 0;
        inject_pe  (mk_xy_flit( 4'sd1,  4'sd0, 32'hA000_0021));
        repeat(8) @(posedge clk);
        rightro = 1;
        repeat(8) @(posedge clk);

        // SCEN 7: Local delivery X=0,Y=0 from RIGHT and LEFT
        inject_right(mk_xy_flit( 4'sd0,  4'sd0, 32'hA000_0031));
        inject_left (mk_xy_flit( 4'sd0,  4'sd0, 32'hA000_0032));
        repeat(10) @(posedge clk);

        $display(">> TB finished at cyc=%0d", cyc);
        $finish;
    end

endmodule