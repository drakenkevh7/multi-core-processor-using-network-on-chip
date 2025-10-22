//////////////////////////////////////////////////////////////////////
//     design: gold_ring_two_way.v
//////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
// Top-level module connecting four cardinal_router_bidirectional instances 
// into a 4-node bidirectional ring network (clockwise and counter-clockwise).
module gold_ring_two_way(
    input  wire        clk,
    input  wire        reset,    // active-high synchronous reset

    // Node 0 local port interface signals
    input  wire        node0_pesi,  // send data from Node0 into router0 (local PE send)
    output wire        node0_peri,  // router0 ready for Node0 input 
    input  wire [63:0] node0_pedi,  // data input from Node0 into router0
    output wire        node0_peso,  // router0 send data out to Node0 (local PE output valid)
    input  wire        node0_pero,  // Node0 ready to receive data from router0
    output wire [63:0] node0_pedo,  // data output from router0 to Node0

    // Node 1 local port interface signals
    input  wire        node1_pesi,
    output wire        node1_peri,
    input  wire [63:0] node1_pedi,
    output wire        node1_peso,
    input  wire        node1_pero,
    output wire [63:0] node1_pedo,

    // Node 2 local port interface signals
    input  wire        node2_pesi,
    output wire        node2_peri,
    input  wire [63:0] node2_pedi,
    output wire        node2_peso,
    input  wire        node2_pero,
    output wire [63:0] node2_pedo,

    // Node 3 local port interface signals
    input  wire        node3_pesi,
    output wire        node3_peri,
    input  wire [63:0] node3_pedi,
    output wire        node3_peso,
    input  wire        node3_pero,
    output wire [63:0] node3_pedo
);

    // Internal wires for clockwise (CW) channel connections between routers
    wire        cw0to1_send, cw1to2_send, cw2to3_send, cw3to0_send;
    wire        cw0to1_ready, cw1to2_ready, cw2to3_ready, cw3to0_ready;
    wire [63:0] cw0to1_data, cw1to2_data, cw2to3_data, cw3to0_data;

    // Internal wires for counter-clockwise (CCW) channel connections between routers
    wire        ccw0to3_send, ccw3to2_send, ccw2to1_send, ccw1to0_send;
    wire        ccw0to3_ready, ccw3to2_ready, ccw2to1_ready, ccw1to0_ready;
    wire [63:0] ccw0to3_data, ccw3to2_data, ccw2to1_data, ccw1to0_data;

    // Internal wires to capture polarity outputs from each router (even/odd cycle indicator)
    wire pol0, pol1, pol2, pol3;

    // Instantiate four routers (node 0 through node 3) and connect their ports in a ring

    // Router 0 instance (Node0)
    cardinal_router_two_way router0 (
        .clk   (clk),
        .reset (reset),
        .polarity (pol0),  // polarity (even/odd cycle) output from router0

        // Clockwise channel (CW) ports for router0
        .cwsi (cw3to0_send),   // CW send input  (from Node3 -> Node0)
        .cwri (cw3to0_ready),  // CW ready output (ready for Node3 input)
        .cwdi (cw3to0_data),   // CW data input  (from Node3)
        .cwso (cw0to1_send),   // CW send output (to Node1 -> from Node0)
        .cwro (cw0to1_ready),  // CW ready input  (ready from Node1)
        .cwdo (cw0to1_data),   // CW data output (to Node1)

        // Counter-clockwise channel (CCW) ports for router0
        .ccwsi (ccw1to0_send),  // CCW send input  (from Node1 -> Node0)
        .ccwri (ccw1to0_ready), // CCW ready output (ready for Node1 input)
        .ccwdi (ccw1to0_data),  // CCW data input  (from Node1)
        .ccwso (ccw0to3_send),  // CCW send output (to Node3 -> from Node0)
        .ccwro (ccw0to3_ready), // CCW ready input  (ready from Node3)
        .ccwdo (ccw0to3_data),  // CCW data output (to Node3)

        // Local processing element (PE) ports for router0 (Node0 connection)
        .pesi (node0_pesi),
        .peri (node0_peri),
        .pedi (node0_pedi),
        .peso (node0_peso),
        .pero (node0_pero),
        .pedo (node0_pedo)
    );

    // Router 1 instance (Node1)
    cardinal_router_two_way router1 (
        .clk   (clk),
        .reset (reset),
        .polarity (pol1),

        // Clockwise channel ports for router1
        .cwsi (cw0to1_send),   // CW input from Node0 -> Node1
        .cwri (cw0to1_ready),  // CW ready for Node0
        .cwdi (cw0to1_data),   // CW data from Node0
        .cwso (cw1to2_send),   // CW output to Node2
        .cwro (cw1to2_ready),  // CW ready from Node2
        .cwdo (cw1to2_data),   // CW data to Node2

        // Counter-clockwise channel ports for router1
        .ccwsi (ccw2to1_send),  // CCW input from Node2 -> Node1
        .ccwri (ccw2to1_ready), // CCW ready for Node2
        .ccwdi (ccw2to1_data),  // CCW data from Node2
        .ccwso (ccw1to0_send),  // CCW output to Node0
        .ccwro (ccw1to0_ready), // CCW ready from Node0
        .ccwdo (ccw1to0_data),  // CCW data to Node0

        // Local PE ports for router1 (Node1 connection)
        .pesi (node1_pesi),
        .peri (node1_peri),
        .pedi (node1_pedi),
        .peso (node1_peso),
        .pero (node1_pero),
        .pedo (node1_pedo)
    );

    // Router 2 instance (Node2)
    cardinal_router_two_way router2 (
        .clk   (clk),
        .reset (reset),
        .polarity (pol2),

        // Clockwise channel ports for router2
        .cwsi (cw1to2_send),   // CW input from Node1 -> Node2
        .cwri (cw1to2_ready),  // CW ready for Node1
        .cwdi (cw1to2_data),   // CW data from Node1
        .cwso (cw2to3_send),   // CW output to Node3
        .cwro (cw2to3_ready),  // CW ready from Node3
        .cwdo (cw2to3_data),   // CW data to Node3

        // Counter-clockwise channel ports for router2
        .ccwsi (ccw3to2_send),  // CCW input from Node3 -> Node2
        .ccwri (ccw3to2_ready), // CCW ready for Node3
        .ccwdi (ccw3to2_data),  // CCW data from Node3
        .ccwso (ccw2to1_send),  // CCW output to Node1
        .ccwro (ccw2to1_ready), // CCW ready from Node1
        .ccwdo (ccw2to1_data),  // CCW data to Node1

        // Local PE ports for router2 (Node2 connection)
        .pesi (node2_pesi),
        .peri (node2_peri),
        .pedi (node2_pedi),
        .peso (node2_peso),
        .pero (node2_pero),
        .pedo (node2_pedo)
    );

    // Router 3 instance (Node3)
    cardinal_router_two_way router3 (
        .clk   (clk),
        .reset (reset),
        .polarity (pol3),

        // Clockwise channel ports for router3
        .cwsi (cw2to3_send),   // CW input from Node2 -> Node3
        .cwri (cw2to3_ready),  // CW ready for Node2
        .cwdi (cw2to3_data),   // CW data from Node2
        .cwso (cw3to0_send),   // CW output to Node0
        .cwro (cw3to0_ready),  // CW ready from Node0
        .cwdo (cw3to0_data),   // CW data to Node0

        // Counter-clockwise channel ports for router3
        .ccwsi (ccw0to3_send),  // CCW input from Node0 -> Node3
        .ccwri (ccw0to3_ready), // CCW ready for Node0
        .ccwdi (ccw0to3_data),  // CCW data from Node0
        .ccwso (ccw3to2_send),  // CCW output to Node2
        .ccwro (ccw3to2_ready), // CCW ready from Node2
        .ccwdo (ccw3to2_data),  // CCW data to Node2

        // Local PE ports for router3 (Node3 connection)
        .pesi (node3_pesi),
        .peri (node3_peri),
        .pedi (node3_pedi),
        .peso (node3_peso),
        .pero (node3_pero),
        .pedo (node3_pedo)
    );

endmodule
