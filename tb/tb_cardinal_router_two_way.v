/////////////////////////////////////////////////////////////////
//       testbench: tb_cardinal_router_two_way.v
/////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_cardinal_router_two_way;
    reg clk, reset;

    // CW
    reg  cwsi; wire cwri; reg  [63:0] cwdi;
    wire cwso; reg  cwro;  wire [63:0] cwdo;
    // CCW
    reg  ccwsi; wire ccwri; reg  [63:0] ccwdi;
    wire ccwso; reg  ccwro;  wire [63:0] ccwdo;
    // PE
    reg  pesi; wire peri; reg  [63:0] pedi;
    wire peso; reg  pero;  wire [63:0] pedo;

    wire polarity;

    cardinal_router_two_way DUT (
        .clk(clk), .reset(reset), .polarity(polarity),
        .cwsi(cwsi), .cwri(cwri), .cwdi(cwdi),
        .cwso(cwso), .cwro(cwro), .cwdo(cwdo),
        .ccwsi(ccwsi), .ccwri(ccwri), .ccwdi(ccwdi),
        .ccwso(ccwso), .ccwro(ccwro), .ccwdo(ccwdo),
        .pesi(pesi), .peri(peri), .pedi(pedi),
        .peso(peso), .pero(pero), .pedo(pedo)
    );

    // 100MHz clock
    initial begin 
        clk = 1'b0;
        forever #5 clk = ~clk; 
    end

    integer cyc;
    always @(posedge clk) begin
        cyc <= cyc + 1;
        if (cwso)  $display("[Cyc %0d | pol=%0d] CW send  : %h", cyc, polarity, cwdo);
        if (ccwso) $display("[Cyc %0d | pol=%0d] CCW send : %h", cyc, polarity, ccwdo);
        if (peso)  $display("[Cyc %0d | pol=%0d] PE  send : %h", cyc, polarity, pedo);
    end

    initial begin
        // init
        cwsi=0; cwdi=0; cwro=1;
        ccwsi=0; ccwdi=0; ccwro=1;
        pesi=0; pedi=0; pero=1;
        reset=1; cyc=0;

        // hold reset two cycles
        @(posedge clk);
        @(posedge clk);
        reset=0;
        $display(">> Reset deasserted at cyc=%0d", cyc);

        // Scenario 1: inject PE -> CW (dir=0), hop=0x07
        pedi = 64'h0007_0001_AAAABBCC; // [55:48]=0x07, [62]=0 for cw
        pesi = 1;
        @(posedge clk); pesi=0;
        repeat(6) @(posedge clk);

        // Scenario 2: inject PE -> CCW (dir=1), hop=0x03
        pedi = 64'h4003_0002_DDCCBBAA; // bit62=1, hop=0x03
        pesi = 1;
        @(posedge clk); pesi=0;
        repeat(6) @(posedge clk);

        // Scenario 3: CW input continue (hop LSB=1)
        cwdi = 64'h0001_00AA_12345678;
        cwsi = 1; @(posedge clk); cwsi=0;
        repeat(6) @(posedge clk);

        // Scenario 4: CW input to local (hop LSB=0)
        cwdi = 64'h0000_00BB_87654321;
        cwsi = 1; @(posedge clk); cwsi=0;
        repeat(6) @(posedge clk);

        // Scenario 5: CCW input continue (hop LSB=1)
        ccwdi = 64'h0001_00CC_F0E1D2C3;
        ccwsi = 1; @(posedge clk); ccwsi=0;
        repeat(6) @(posedge clk);

        // Scenario 6: CCW input to local (hop LSB=0)
        ccwdi = 64'h0000_00DD_C3D2E1F0;
        ccwsi = 1; @(posedge clk); ccwsi=0;
        repeat(6) @(posedge clk);

        // Scenario 7: Arbitration on CW (CW-in vs PE-in cw)
        pedi = 64'h0007_00EE_AA00AA00; // inject cw
        cwdi = 64'h0001_00EE_BB11BB11; // cw continue
        pesi = 1; cwsi = 1; @(posedge clk); pesi=0; cwsi=0;
        repeat(8) @(posedge clk);

        // Scenario 8: Repeat same conflict to observe priority flip
        pedi = 64'h0007_00FF_CC00CC00; // inject cw
        cwdi = 64'h0001_00FF_DD11DD11; // cw continue
        pesi = 1; cwsi = 1; @(posedge clk); pesi=0; cwsi=0;
        repeat(8) @(posedge clk);

        $finish;
    end
endmodule
