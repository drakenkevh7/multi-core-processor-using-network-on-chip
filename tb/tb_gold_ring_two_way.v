/////////////////////////////////////////////////////////////////
//       testbench: tb_gold_ring_two_way.v
/////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
// Testbench for the gold_ring module. It generates a 250 MHz clock (4 ns period),
// drives input patterns into the ring, and checks that data emerges at expected nodes.
module tb_gold_ring_two_way;
    reg clk;
    reg reset;

    // Node 0 interface regs/wires
    reg        node0_pesi;
    wire       node0_peri;
    reg [63:0] node0_pedi;
    wire       node0_peso;
    reg        node0_pero;
    wire [63:0] node0_pedo;

    // Node 1 interface regs/wires
    reg        node1_pesi;
    wire       node1_peri;
    reg [63:0] node1_pedi;
    wire       node1_peso;
    reg        node1_pero;
    wire [63:0] node1_pedo;

    // Node 2 interface regs/wires
    reg        node2_pesi;
    wire       node2_peri;
    reg [63:0] node2_pedi;
    wire       node2_peso;
    reg        node2_pero;
    wire [63:0] node2_pedo;

    // Node 3 interface regs/wires
    reg        node3_pesi;
    wire       node3_peri;
    reg [63:0] node3_pedi;
    wire       node3_peso;
    reg        node3_pero;
    wire [63:0] node3_pedo;

    // Instantiate the Device Under Test (DUT)
    gold_ring_two_way DUT (
        .clk(clk),
        .reset(reset),
        // Connect Node0 I/O
        .node0_pesi(node0_pesi), .node0_peri(node0_peri), .node0_pedi(node0_pedi),
        .node0_peso(node0_peso), .node0_pero(node0_pero), .node0_pedo(node0_pedo),
        // Connect Node1 I/O
        .node1_pesi(node1_pesi), .node1_peri(node1_peri), .node1_pedi(node1_pedi),
        .node1_peso(node1_peso), .node1_pero(node1_pero), .node1_pedo(node1_pedo),
        // Connect Node2 I/O
        .node2_pesi(node2_pesi), .node2_peri(node2_peri), .node2_pedi(node2_pedi),
        .node2_peso(node2_peso), .node2_pero(node2_pero), .node2_pedo(node2_pedo),
        // Connect Node3 I/O
        .node3_pesi(node3_pesi), .node3_peri(node3_peri), .node3_pedi(node3_pedi),
        .node3_peso(node3_peso), .node3_pero(node3_pero), .node3_pedo(node3_pedo)
    );

    // Generate a 250 MHz clock (4 ns period)
    initial begin
        clk = 1'b0;
        forever #2 clk = ~clk;
    end

    reg [63:0] expected_data;  // will hold expected output data for checks

    initial begin
        // Initialize inputs
        node0_pesi = 0; node0_pedi = 64'd0; node0_pero = 1;
        node1_pesi = 0; node1_pedi = 64'd0; node1_pero = 1;
        node2_pesi = 0; node2_pedi = 64'd0; node2_pero = 1;
        node3_pesi = 0; node3_pedi = 64'd0; node3_pero = 1;
        reset = 1;
        // Hold reset for a couple of cycles
        @(posedge clk);
        @(posedge clk);
        reset = 0;
        $display(">> Reset deasserted at time %t <<", $time);

        // Scenario 1: Node0 sends one flit clockwise with hop count = 1 (expect delivery at Node1)
        $display("Scenario 1: Node0 -> Node1 (CW, hop=1)");
        node0_pedi = 64'h0001_0001_1111_2222;  // [62]=0 (CW), Hop=0x01, payload pattern 0x11112222
        node0_pesi = 1'b1;
        @(posedge clk); 
        node0_pesi = 1'b0;  // pulse send for one cycle
        // Wait for Node1 to receive a packet (Node1's local output valid goes high)
        @(posedge node1_peso);
        expected_data = node0_pedi;
        expected_data[55:48] = 8'h00;  // hop count should decrement to 0 upon delivery
        if (node1_pedo === expected_data) 
            $display("Scenario 1 PASSED: Node1 received data %h as expected", node1_pedo);
        else 
            $display("Scenario 1 FAILED: Node1 output %h, expected %h", node1_pedo, expected_data);
        @(posedge clk);  // small delay to allow output handshake to complete

        // Scenario 2: Node0 sends one flit clockwise with hop count = 3 (expect delivery at Node3)
        $display("Scenario 2: Node0 -> Node3 (CW, hop=3)");
        node0_pedi = 64'h0003_0002_3333_4444;  // [62]=0 (CW), Hop=0x03, payload 0x33334444
        node0_pesi = 1'b1;
        @(posedge clk);
        node0_pesi = 1'b0;
        @(posedge node3_peso);  // wait for Node3's local output valid
        expected_data = node0_pedi;
        expected_data[55:48] = 8'h00;
        if (node3_pedo === expected_data)
            $display("Scenario 2 PASSED: Node3 received data %h as expected", node3_pedo);
        else 
            $display("Scenario 2 FAILED: Node3 output %h, expected %h", node3_pedo, expected_data);
        @(posedge clk);

        // Scenario 3: Node2 sends one flit counter-clockwise with hop count = 1 (expect delivery at Node1)
        $display("Scenario 3: Node2 -> Node1 (CCW, hop=1)");
        node2_pedi = 64'h4001_0003_5555_6666;  // [62]=1 (CCW), Hop=0x01, payload 0x55556666
        node2_pesi = 1'b1;
        @(posedge clk);
        node2_pesi = 1'b0;
        @(posedge node1_peso);  // Node1 should receive from Node2 CCW
        expected_data = node2_pedi;
        expected_data[55:48] = 8'h00;
        if (node1_pedo === expected_data)
            $display("Scenario 3 PASSED: Node1 received data %h as expected", node1_pedo);
        else 
            $display("Scenario 3 FAILED: Node1 output %h, expected %h", node1_pedo, expected_data);
        @(posedge clk);

        // Scenario 4: Node0 sends one flit counter-clockwise with hop count = 2 (expect delivery at Node2)
        $display("Scenario 4: Node0 -> Node2 (CCW, hop=2)");
        node0_pedi = 64'h4002_0004_7777_8888;  // [62]=1 (CCW), Hop=0x02, payload 0x77778888
        node0_pesi = 1'b1;
        @(posedge clk);
        node0_pesi = 1'b0;
        @(posedge node2_peso);  // Node2 local output valid when flit arrives
        expected_data = node0_pedi;
        expected_data[55:48] = 8'h00;
        if (node2_pedo === expected_data)
            $display("Scenario 4 PASSED: Node2 received data %h as expected", node2_pedo);
        else 
            $display("Scenario 4 FAILED: Node2 output %h, expected %h", node2_pedo, expected_data);
        @(posedge clk);

        // Scenario 5: Node0 sends one flit clockwise with hop count = 4 (full ring, expect it returns to Node0)
        $display("Scenario 5: Node0 -> Node0 (CW, hop=4)");
        node0_pedi = 64'h0004_0005_9999_AAAA;  // [62]=0 (CW), Hop=0x04, payload 0x9999AAAA
        node0_pesi = 1'b1;
        @(posedge clk);
        node0_pesi = 1'b0;
        @(posedge node0_peso);  // flit should circle back to Node0
        expected_data = node0_pedi;
        expected_data[55:48] = 8'h00;
        if (node0_pedo === expected_data)
            $display("Scenario 5 PASSED: Node0 received its own data %h as expected", node0_pedo);
        else 
            $display("Scenario 5 FAILED: Node0 output %h, expected %h", node0_pedo, expected_data);
        @(posedge clk);

        $finish;
    end
endmodule
