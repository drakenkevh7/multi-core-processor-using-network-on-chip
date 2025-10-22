/////////////////////////////////////////////////////////////////
//       testbench: tb_cardinal_nic.v
/////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
module tb_cardinal_nic;
    // Testbench signals
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

    // Instantiate the NIC module (Device Under Test)
    cardinal_nic dut (
        .clk        (clk),
        .reset      (reset),
        .addr       (addr),
        .d_in       (d_in),
        .d_out      (d_out),
        .nicEn      (nicEn),
        .nicEnWr    (nicEnWr),
        .net_si     (net_si),
        .net_ri     (net_ri),
        .net_di     (net_di),
        .net_so     (net_so),
        .net_ro     (net_ro),
        .net_do     (net_do),
        .net_polarity (net_polarity)
    );

    // Clock generation: 10 time units period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize all signals
        reset = 1;
        nicEn = 0;
        nicEnWr = 0;
        addr = 2'b00;
        d_in = 64'h0;
        net_si = 0;
        net_ro = 0;
        net_polarity = 0;
        net_di = 64'h0;

        // Release reset after a few cycles
        #15 reset = 0;
        @(posedge clk);  // wait for first clock edge after reset

        // After reset, verify initial handshake outputs and status
        $display("After reset: net_ri=%b (expect 1, buffer empty), net_so=%b (expect 0, no send), d_out=%h", 
                 net_ri, net_so, d_out);

        // ** Test Output Channel (Processor to Router) **
        $display("\n--- Testing processor send to network (output channel) ---");
        // 1. Processor reads the output status register (addr=11) to check if buffer is free
        nicEn = 1; nicEnWr = 0; addr = 2'b11;  // read output status
        @(posedge clk);  // data will be available after this clock
        $display("Output status register read = %h (expected 0x0000...0000 since buffer empty)", d_out);
        nicEn = 0;

        // 2. Processor writes a packet to the output buffer (addr=10) if status was 0 (free)
        d_in = 64'hA5A5A5A5A5A5A5A5;
        $display("CPU writing packet %h to output buffer...", d_in);
        nicEn = 1; nicEnWr = 1; addr = 2'b10;  // write output buffer
        @(posedge clk);  // perform the write at this clock edge
        nicEn = 0; nicEnWr = 0;
        // After this write, NIC's output_status should be 1 (buffer full)
        nicEn = 1; nicEnWr = 0; addr = 2'b11;  // read output status again
        @(posedge clk);
        $display("Output status after write = %h (MSB should be 1 indicating full)", d_out);
        nicEn = 0;

        // 3. Attempt an illegal read from the output buffer (which is write-only)
        $display("CPU attempts to read from output buffer (illegal)...");
        nicEn = 1; nicEnWr = 0; addr = 2'b10;  // read output buffer (invalid operation)
        @(posedge clk);
        $display("Read from output buffer returned d_out = %h (NIC should ignore, e.g. return 0)", d_out);
        nicEn = 0;
        // Check that the output buffer still holds the packet (output_status still 1)
        nicEn = 1; nicEnWr = 0; addr = 2'b11;  // read output status
        @(posedge clk);
        $display("Output status after illegal read = %h (should remain full with MSB=1)", d_out);
        nicEn = 0;

        // 4. Router handshake: net_ro initially low (router not ready)
        $display("Router not ready (net_ro=0) -> NIC should hold packet (net_so stays 0)");
        net_ro = 0;
        net_polarity = 0;  // router polarity (doesn't matter since not ready)
        @(posedge clk);
        $display("net_so = %b (expected 0, router not ready)", net_so);

        // 5. Router becomes ready (net_ro=1) but with wrong polarity (not matching packet's VC bit)
        net_ro = 1;
        // Determine opposite polarity: if our packet's VC bit (LSB of A5...A5) is, say, 1 or 0
        net_polarity = ~d_in[0];  // set polarity opposite to packet's VC bit
        @(posedge clk);
        $display("Router ready but polarity=%b (packet VC=%b) -> NIC should not send yet", net_polarity, d_in[0]);
        $display("net_so = %b (expected 0, waiting for correct polarity)", net_so);

        // 6. Now set router polarity to match the packet's VC bit, with router still ready
        net_polarity = d_in[0];  // match polarity to packet VC
        @(posedge clk);  // NIC should send this cycle
        $display("Router ready and polarity=%b matches packet VC -> NIC should assert net_so", net_polarity);
        $display("net_so = %b, net_do = %h (packet sent on net_do)", net_so, net_do);
        @(posedge clk);  // next cycle after send
        // After sending, NIC should have cleared the output buffer (output_status = 0)
        nicEn = 1; nicEnWr = 0; addr = 2'b11;
        @(posedge clk);
        $display("Output status after send = %h (expected 0x0000...0000, buffer now free)", d_out);
        nicEn = 0;

        // 7. Test sending a second packet back-to-back
        d_in = 64'hDEADBEEFDEADBEEF;
        $display("\nSending a second packet %h after first is delivered...", d_in);
        nicEn = 1; nicEnWr = 1; addr = 2'b10;
        @(posedge clk);
        nicEn = 0; nicEnWr = 0;
        // Router is ready with correct polarity immediately
        net_ro = 1;
        net_polarity = d_in[0];  // assume polarity matches directly
        @(posedge clk);
        $display("net_so = %b, net_do = %h (second packet send)", net_so, net_do);
        @(posedge clk);
        // Confirm NIC output buffer freed again
        nicEn = 1; nicEnWr = 0; addr = 2'b11;
        @(posedge clk);
        $display("Output status after second send = %h (should be 0/empty)", d_out);
        nicEn = 0;

        // ** Test Input Channel (Router to Processor) **
        $display("\n--- Testing router send to processor (input channel) ---");
        // Ensure NIC input buffer is empty (net_ri should be 1)
        $display("Before receiving: net_ri = %b (expect 1, empty input buffer)", net_ri);
        // 1. Simulate router sending a packet when net_ri=1
        net_di = 64'hCAFEBABECAFEBABE;
        $display("Router injecting packet %h to NIC...", net_di);
        net_si = 1;  // router asserts send
        // (net_ri is 1, so NIC should accept this packet on next clock)
        @(posedge clk);
        net_si = 0;  // deassert send after one cycle
        // Now NIC should have latched the packet and marked input_status=1, net_ri=0
        $display("After router send: net_ri = %b (expected 0, input buffer full)", net_ri);

        // 2. Processor reads the input status register to check if a packet arrived
        nicEn = 1; nicEnWr = 0; addr = 2'b01;
        @(posedge clk);
        $display("Input status register read = %h (MSB reflects input_status, expect 1)", d_out);
        nicEn = 0;
        // 3. Processor reads the input buffer to retrieve the packet
        nicEn = 1; nicEnWr = 0; addr = 2'b00;
        @(posedge clk);
        $display("CPU read input buffer, got %h (expected %h)", d_out, 64'hCAFEBABECAFEBABE);
        nicEn = 0;
        // After read, NIC should clear input buffer and set net_ri=1 again (ready for next packet)
        $display("After CPU read: net_ri = %b (expect 1, buffer free again)", net_ri);

        // 4. Test reading input buffer when it's empty (should not alter state)
        $display("CPU reads empty input buffer (undefined data)...");
        nicEn = 1; nicEnWr = 0; addr = 2'b00;
        @(posedge clk);
        $display("Read empty input buffer returned %h (could be last value or 0)", d_out);
        nicEn = 0;
        $display("Input status still %b, net_ri = %b (should remain 0 and 1 respectively)", 
                 dut.input_status, net_ri);

        // ** Test Illegal Operations on Input/Status Registers **
        // 5. Attempt to write to the input buffer (illegal, should be ignored)
        $display("\nTesting illegal writes to read-only registers...");
        d_in = 64'h1234567890ABCDEF;
        $display("CPU attempts to write %h to input buffer (addr=00, read-only)", d_in);
        nicEn = 1; nicEnWr = 1; addr = 2'b00;
        @(posedge clk);
        nicEn = 0; nicEnWr = 0;
        // NIC should ignore this: input_status remains unchanged (still 0), net_ri stays 1
        $display("After illegal write: input_status=%b (expect 0 unchanged), net_ri=%b (expect 1)", 
                 dut.input_status, net_ri);

        // 6. Attempt to write to the status registers (also illegal)
        d_in = 64'hFFFFFFFFFFFFFFFF;
        $display("CPU attempts to write to input status register (addr=01, read-only)");
        nicEn = 1; nicEnWr = 1; addr = 2'b01;
        @(posedge clk);
        nicEn = 0;
        $display("Input status after illegal write = %b (should remain %b)", 
                 dut.input_status, dut.input_status);

        $display("CPU attempts to write to output status register (addr=11, read-only)");
        nicEn = 1; nicEnWr = 1; addr = 2'b11;
        @(posedge clk);
        nicEn = 0;
        $display("Output status after illegal write = %b (should remain %b)", 
                 dut.output_status, dut.output_status);

        // End of tests
        $display("\nAll tests completed.");
        $finish;
    end
endmodule
