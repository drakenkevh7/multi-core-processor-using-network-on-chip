/////////////////////////////////////////////////////////////////
//       testbench: tb_cardinal_router_four_way.v
/////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_cardinal_router_four_way;

    // ---------------- Clock / Reset ----------------
    reg clk, reset;
    integer cyc;

    initial begin clk=0; forever #5 clk=~clk; end
    always @(posedge clk) cyc <= reset ? 0 : (cyc+1);

    // ---------------- DUT I/O ----------------
    wire polarity;

    reg        upsi, downsi, leftsi, rightsi, pesi;
    wire       upri, downri, leftri, rightri, peri;
    reg [63:0] updi, downdi, leftdi, rightdi, pedi;

    wire       upso, downso, leftso, rightso, peso;
    reg        upro, downro, leftro, rightro, pero;
    wire [63:0] updo, downdo, leftdo, rightdo, pedo;

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

    // ---------------- Field map (matches your RTL) ----------------
    localparam VC_BIT    = 63;
    localparam DIR_X_BIT = 62; // 1 = LEFT, 0 = RIGHT
    localparam DIR_Y_BIT = 61; // 1 = UP,   0 = DOWN
    localparam HOP_X_HI  = 55;
    localparam HOP_X_LO  = 52;
    localparam HOP_Y_HI  = 51;
    localparam HOP_Y_LO  = 48;

    // Lower 48 bits: [47:32]=source(16b), [31:0]=dest(32b) for logging
    function [63:0] mkflit_sd;
        input vc, xdir, ydir;
        input [3:0] xhops, yhops;
        input [15:0] src16;
        input [31:0] dst32;
        reg [63:0] f;
    begin
        f                       = 64'h0;
        f[VC_BIT]               = vc;
        f[DIR_X_BIT]            = xdir;
        f[DIR_Y_BIT]            = ydir;
        f[HOP_X_HI:HOP_X_LO]    = xhops[3:0];
        f[HOP_Y_HI:HOP_Y_LO]    = yhops[3:0];
        f[47:32]                = src16;
        f[31:0]                 = dst32;
        mkflit_sd               = f;
    end
    endfunction

    function [3:0] xhops_of; input [63:0] f; begin xhops_of=f[HOP_X_HI:HOP_X_LO]; end endfunction
    function [3:0] yhops_of; input [63:0] f; begin yhops_of=f[HOP_Y_HI:HOP_Y_LO]; end endfunction

    // ---------------- Negedge injection w/ ready handshake ----------------
    // port: 0=UP,1=DOWN,2=LEFT,3=RIGHT,4=PE
    task inject_one;
        input integer port;
        input [63:0] flit;
    begin
        case (port)
        0: begin while(!upri) @(posedge clk); @(negedge clk); updi<=flit; upsi<=1'b1; @(posedge clk); @(negedge clk); upsi<=1'b0; end
        1: begin while(!downri) @(posedge clk); @(negedge clk); downdi<=flit; downsi<=1'b1; @(posedge clk); @(negedge clk); downsi<=1'b0; end
        2: begin while(!leftri) @(posedge clk); @(negedge clk); leftdi<=flit; leftsi<=1'b1; @(posedge clk); @(negedge clk); leftsi<=1'b0; end
        3: begin while(!rightri) @(posedge clk); @(negedge clk); rightdi<=flit; rightsi<=1'b1; @(posedge clk); @(negedge clk); rightsi<=1'b0; end
        4: begin while(!peri)   @(posedge clk); @(negedge clk); pedi<=flit; pesi<=1'b1; @(posedge clk); @(negedge clk); pesi<=1'b0; end
        endcase
    end
    endtask

    // ---------------- Monitors (console) ----------------
    always @(posedge clk) if (upso)
        $display("[Cyc %0d] (@UP OUT)    %016h  xhop=%0d yhop=%0d pol=%0d", cyc, updo, xhops_of(updo), yhops_of(updo), polarity);
    always @(posedge clk) if (downso)
        $display("[Cyc %0d] (@DOWN OUT)  %016h  xhop=%0d yhop=%0d pol=%0d", cyc, downdo, xhops_of(downdo), yhops_of(downdo), polarity);
    always @(posedge clk) if (leftso)
        $display("[Cyc %0d] (@LEFT OUT)  %016h  xhop=%0d yhop=%0d pol=%0d", cyc, leftdo, xhops_of(leftdo), yhops_of(leftdo), polarity);
    always @(posedge clk) if (rightso)
        $display("[Cyc %0d] (@RIGHT OUT) %016h  xhop=%0d yhop=%0d pol=%0d", cyc, rightdo, xhops_of(rightdo), yhops_of(rightdo), polarity);
    always @(posedge clk) if (peso)
        $display("[Cyc %0d] (@PE OUT)    %016h  xhop=%0d yhop=%0d pol=%0d", cyc, pedo, xhops_of(pedo), yhops_of(pedo), polarity);


    // ---------------- Introspection for contention demo ----------------
    wire [4:0] req_up_even, gnt_up_even, prio_up_even;
    assign req_up_even  = DUT.ARB_EVEN.req_up;
    assign gnt_up_even  = DUT.ARB_EVEN.gnt_up;
    assign prio_up_even = DUT.ARB_EVEN.RRARB_UP.priority;

    always @(posedge clk) if (polarity==1'b0) begin
        if (gnt_up_even!=5'b0)
        $display("[Cyc %0d] EVEN-ARB UP: prio=%05b req=%05b gnt=%05b", cyc, prio_up_even, req_up_even, gnt_up_even);
    end

    // ---------------- Stimulus ----------------
    task wait_cycles; input integer n; integer k; begin for(k=0;k<n;k=k+1) @(posedge clk); end endtask

    initial begin
        // init
        upsi=0; downsi=0; leftsi=0; rightsi=0; pesi=0;
        updi=0; downdi=0; leftdi=0; rightdi=0; pedi=0;
        upro=1; downro=1; leftro=1; rightro=1; pero=1;

        reset=1; cyc=0; wait_cycles(4); reset=0;
        $display(">> Reset deasserted @ cycle %0d", cyc);

        // ---------------- TC1: LEFT -> RIGHT ----------------
        $display("\n===== TC1: LEFT->RIGHT (xh=1, dir=RIGHT) =====");
        inject_one(2, mkflit_sd(1'b0, 1'b0/*RIGHT*/, 1'b0, 4'd1, 4'd0, 16'd2, 32'd16));
        wait_cycles(8);

        // ---------------- TC2: UP -> DOWN ----------------
        $display("\n===== TC2: UP->DOWN (yh=1, dir=DOWN) =====");
        inject_one(0, mkflit_sd(1'b0, 1'b0, 1'b0/*DOWN*/, 4'd0, 4'd1, 16'd0, 32'd8));
        wait_cycles(8);

        // ---------------- TC3: RIGHT -> PE (at dest) ----------------
        $display("\n===== TC3: RIGHT->PE (xh=0,yh=0) =====");
        inject_one(3, mkflit_sd(1'b0, 1'b0, 1'b0, 4'd0, 4'd0, 16'd3, 32'd3));
        wait_cycles(8);

        // ---------------- TC4: UP -> RIGHT (xh=2 -> 1) ----------------
        $display("\n===== TC4: UP->RIGHT xh=2 (verify decrement) =====");
        inject_one(0, mkflit_sd(1'b0, 1'b0/*RIGHT*/, 1'b0, 4'd2, 4'd0, 16'd0, 32'd4));
        wait_cycles(12);

        // ---------------- TC5: Contention on UP (LEFT vs RIGHT), show RR rotate ----------------
        $display("\n===== TC5: Contention on UP output (RR rotates) =====");
        // Wait until external=EVEN next cycle (inject on negedge when polarity==1)
        while (polarity != 1'b1) @(posedge clk);
        // Drive both in same negedge
        while (!(leftri && rightri)) @(posedge clk);
        @(negedge clk);
        leftdi  <= mkflit_sd(1'b0, 1'b0, 1'b1/*UP*/, 4'd0, 4'd1, 16'd2, 32'd100);
        rightdi <= mkflit_sd(1'b0, 1'b0, 1'b1/*UP*/, 4'd0, 4'd1, 16'd3, 32'd101);
        leftsi  <= 1'b1;
        rightsi <= 1'b1;
        @(posedge clk); @(negedge clk);
        leftsi  <= 1'b0;
        rightsi <= 1'b0;

        // Let first EVEN arbitration happen (observe grant/priority line)
        @(posedge clk);
        // Before next EVEN arbitration, re-arm LEFT only; RIGHT still pending → RR should rotate
        while (polarity != 1'b1) @(posedge clk);
        while (!leftri) @(posedge clk);
        inject_one(2, mkflit_sd(1'b0, 1'b0, 1'b1/*UP*/, 4'd0, 4'd1, 16'd2, 32'd102));
        wait_cycles(8);

        // ---------------- TC6: Backpressure LEFT output ----------------
        $display("\n===== TC6: Backpressure LEFT output; RIGHT proceeds =====");
        leftro = 1'b0; // stall LEFT
        inject_one(1, mkflit_sd(1'b0, 1'b1/*LEFT*/, 1'b0, 4'd1, 4'd0, 16'd1, 32'd200)); // DOWN->LEFT (blocked)
        inject_one(0, mkflit_sd(1'b0, 1'b0/*RIGHT*/,1'b0, 4'd1, 4'd0, 16'd0, 32'd201)); // UP->RIGHT (free)
        wait_cycles(9);
        $display("[Cyc %0d] Releasing LEFT backpressure", cyc);
        leftro = 1'b1;
        wait_cycles(8);

        $display("\nAll testcases executed. Stopping.");
        $finish;
    end

    // ---------------- Timeout ----------------
    initial begin
        #50000;
        $display("TIMEOUT"); $finish;
    end

endmodule
