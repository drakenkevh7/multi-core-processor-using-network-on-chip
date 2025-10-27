/////////////////////////////////////////////////////////////////
//       testbench: tb_cardinal_nic.v
/////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
module tb_cardinal_nic;

    // ---------------- DUT I/O ----------------
    reg         clk;
    reg         reset;

    reg  [1:0]  addr;
    reg  [63:0] d_in;
    wire [63:0] d_out;
    reg         nicEn;
    reg         nicEnWr;

    reg         net_si;
    wire        net_ri;
    reg  [63:0] net_di;
    wire        net_so;
    reg         net_ro;
    wire [63:0] net_do;

    reg         net_polarity;

    // Device Under Test
    cardinal_nic dut (
        .clk         (clk),
        .reset       (reset),
        .addr        (addr),
        .d_in        (d_in),
        .d_out       (d_out),
        .nicEn       (nicEn),
        .nicEnWr     (nicEnWr),
        .net_si      (net_si),
        .net_ri      (net_ri),
        .net_di      (net_di),
        .net_so      (net_so),
        .net_ro      (net_ro),
        .net_do      (net_do),
        .net_polarity(net_polarity)
    );

    // ---------------- Clock / net_polarity ----------------
    initial begin clk = 1'b0; forever #5 clk = ~clk; end

    // 1) Required: net_polarity toggles on posedge, resets to 0
    always @(posedge clk) begin
        if (reset) net_polarity <= 1'b0;
        else       net_polarity <= ~net_polarity;
    end

    // ---------------- Logging ----------------
    integer fh;
    `define P0(MSG)                     begin $display(MSG);                           $fdisplay(fh, MSG); end
    `define P1(MSG,A)                   begin $display(MSG, A);                        $fdisplay(fh, MSG, A); end
    `define P2(MSG,A,B)                 begin $display(MSG, A, B);                     $fdisplay(fh, MSG, A, B); end
    `define P3(MSG,A,B,C)               begin $display(MSG, A, B, C);                  $fdisplay(fh, MSG, A, B, C); end
    `define P4(MSG,A,B,C,D)             begin $display(MSG, A, B, C, D);               $fdisplay(fh, MSG, A, B, C, D); end

    // ---------------- Helpers (Verilog-2001) ----------------
    task wait_cycles; input integer n; integer k; begin for (k=0;k<n;k=k+1) @(posedge clk); end endtask

    // Processor store to OUT buffer
    task processor_store_outbuf; input [63:0] payload;
    begin
        d_in   = payload;
        nicEn  = 1'b1; nicEnWr = 1'b1; addr = 2'b10;
        @(posedge clk);
        nicEn  = 1'b0; nicEnWr = 1'b0;
    end
    endtask

    // Processor load from IN buffer
    task processor_load_inbuf; output [63:0] val;
    begin
        nicEn = 1'b1; nicEnWr = 1'b0; addr = 2'b00;
        @(posedge clk); val = d_out; nicEn = 1'b0;
    end
    endtask

    // Processor read IN status
    task processor_read_in_status; output [63:0] val;
    begin
        nicEn = 1'b1; nicEnWr = 1'b0; addr = 2'b01;
        @(posedge clk); val = d_out; nicEn = 1'b0;
    end
    endtask

    // Processor read OUT status
    task processor_read_out_status; output [63:0] val;
    begin
        nicEn = 1'b1; nicEnWr = 1'b0; addr = 2'b11;
        @(posedge clk); val = d_out; nicEn = 1'b0;
    end
    endtask

    // Router sends one flit (1-cycle)
    task router_send_one; input [63:0] flit;
    begin
        net_di = flit;
        net_si = 1'b1;
        @(posedge clk);
        net_si = 1'b0;
    end
    endtask

    // Wait until a particular polarity is present (0=even,1=odd)
    task wait_for_polarity; input bitval;
    begin
        while (net_polarity != bitval) @(posedge clk);
    end
    endtask

    // Wait until NIC performs a send (net_so high for one cycle)
    task wait_for_send;
    begin
        while (net_so == 1'b0) @(posedge clk);
    end
    endtask

    // ---------------- Test Stimulus ----------------
    reg [63:0] vstat, vrd;

    initial begin
        fh = $fopen("tb_cardinal_nic.txt","w");
        if (fh==0) begin $display("ERROR: cannot open tb_cardinal_nic.txt"); $finish; end

        // init
        reset = 1'b1;
        nicEn = 1'b0; nicEnWr=1'b0; addr=2'b00; d_in=64'h0;
        net_si=1'b0; net_ro=1'b0; net_di=64'h0;
        wait_cycles(3);
        reset = 1'b0;
        @(posedge clk);

        `P3("After reset: net_ri=%b, net_so=%b, net_polarity=%b", net_ri, net_so, net_polarity)

        // ========================================================
        // (2) Handshakes exactly like the figure 3
        // ========================================================

        // --- A) Per-figure demo: router ready; send once on EVEN then once on ODD ---
        `P0("\n=== Handshake A (per figure): net_ro=1; inject on EVEN then on ODD ===")
        net_ro = 1'b1;

        // 1) Fill OUT buffer (\"Even\" packet). Wait for EVEN polarity → NIC should send on that window.
        processor_store_outbuf(64'hEEEE_EEEE_EEEE_EE00); // tag = EVEN
        `P0("Waiting for EVEN polarity before first send...")
        wait_for_polarity(1'b0); // even
        wait_for_send;
        `P3("EVEN send: net_so=%b  net_do=%h  net_polarity=%b", net_so, net_do, net_polarity)
        @(posedge clk);

        // 2) Fill OUT buffer again (\"Odd\" packet). Wait for ODD polarity → NIC should send.
        processor_store_outbuf(64'hDDDD_DDDD_DDDD_DD11); // tag = ODD
        `P0("Waiting for ODD polarity before second send...")
        wait_for_polarity(1'b1); // odd
        wait_for_send;
        `P3("ODD  send: net_so=%b  net_do=%h  net_polarity=%b", net_so, net_do, net_polarity)
        @(posedge clk);

        // --- B) Blocking demo: router not ready, then ready ---
        `P0("\n=== Handshake B (blocked then released): net_ro=0 -> 1 ===")
        processor_store_outbuf(64'hB10C_B10C_B10C_B10C);
        net_ro = 1'b0;  // block router
        wait_cycles(4);
        `P1("While blocked: net_so=%b (expect 0)", net_so)
        net_ro = 1'b1;  // release
        `P0("Released: router ready. NIC will send on next eligible polarity.")
        wait_for_send;
        `P3("UNBLOCK send: net_so=%b  net_do=%h  net_polarity=%b", net_so, net_do, net_polarity)
        @(posedge clk);

        // ========================================================
        // (3) Processor <-> NIC matrix (store/load × available/unavailable)
        // ========================================================
        net_ro = 1'b0;
        // --- Store when OUT available ---
        `P0("\n=== Processor STORE: OUT buffer AVAILABLE ===")
        processor_read_out_status(vstat);  `P1("OUT status before = %h", vstat)
        processor_store_outbuf(64'h0BAD_F00D_0BAD_F00D);
        processor_read_out_status(vstat);  `P1("OUT status after  = %h (expect full/LSB=1)", vstat)

        // --- Store when OUT unavailable (still full) ---
        `P0("\n=== Processor STORE: OUT buffer UNAVAILABLE ===")
        processor_store_outbuf(64'hFACE_FACE_FACE_FACE); // attempt overwrite
        processor_read_out_status(vstat);  `P1("OUT status remains = %h (should still be full)", vstat)
        // Let router take it so we can proceed
        net_ro = 1'b1; wait_for_send; @(posedge clk);

        // --- Load when IN available ---
        `P0("\n=== Processor LOAD: IN buffer AVAILABLE ===")
        router_send_one(64'hABCD_EF00_FEDC_BA00); @(posedge clk);
        processor_load_inbuf(vrd);         `P1("Processor load data = %h (should be injected word)", vrd)
        processor_read_in_status(vstat);   `P1("IN status now = %h (expect empty/0)", vstat)

        // --- Load when IN unavailable (empty) ---
        `P0("\n=== Processor LOAD: IN buffer UNAVAILABLE ===")
        processor_load_inbuf(vrd);         `P2("Processor load from empty returned %h; IN status %h (should stay empty/0)", vrd, vstat)

        // ========================================================
        `P0("\nAll tests completed. Ending simulation.")
        $fclose(fh);
        $finish;
    end

    // Timeout
    initial begin
        #100000;
        $display("TIMEOUT"); $fclose(fh); $finish;
    end

endmodule

    