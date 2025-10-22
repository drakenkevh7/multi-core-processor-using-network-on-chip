//////////////////////////////////////////////////////////////////////
//     design: cardinal_mesh4x4.v
//////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "design/cardinal_router_four_way.v"

module cardinal_mesh4x4 (
    input wire clk,
    input wire reset,
    // Local interface ports for router (0,0)
    input wire        pesi_0_0,
    input wire [63:0] pedi_0_0,
    output wire       peri_0_0,
    output wire       peso_0_0,
    input wire        pero_0_0,
    output wire [63:0] pedo_0_0,
    // Local interface ports for router (0,1)
    input wire        pesi_0_1,
    input wire [63:0] pedi_0_1,
    output wire       peri_0_1,
    output wire       peso_0_1,
    input wire        pero_0_1,
    output wire [63:0] pedo_0_1,
    // Local interface ports for router (0,2)
    input wire        pesi_0_2,
    input wire [63:0] pedi_0_2,
    output wire       peri_0_2,
    output wire       peso_0_2,
    input wire        pero_0_2,
    output wire [63:0] pedo_0_2,
    // Local interface ports for router (0,3)
    input wire        pesi_0_3,
    input wire [63:0] pedi_0_3,
    output wire       peri_0_3,
    output wire       peso_0_3,
    input wire        pero_0_3,
    output wire [63:0] pedo_0_3,
    // Local interface ports for router (1,0)
    input wire        pesi_1_0,
    input wire [63:0] pedi_1_0,
    output wire       peri_1_0,
    output wire       peso_1_0,
    input wire        pero_1_0,
    output wire [63:0] pedo_1_0,
    // Local interface ports for router (1,1)
    input wire        pesi_1_1,
    input wire [63:0] pedi_1_1,
    output wire       peri_1_1,
    output wire       peso_1_1,
    input wire        pero_1_1,
    output wire [63:0] pedo_1_1,
    // Local interface ports for router (1,2)
    input wire        pesi_1_2,
    input wire [63:0] pedi_1_2,
    output wire       peri_1_2,
    output wire       peso_1_2,
    input wire        pero_1_2,
    output wire [63:0] pedo_1_2,
    // Local interface ports for router (1,3)
    input wire        pesi_1_3,
    input wire [63:0] pedi_1_3,
    output wire       peri_1_3,
    output wire       peso_1_3,
    input wire        pero_1_3,
    output wire [63:0] pedo_1_3,
    // Local interface ports for router (2,0)
    input wire        pesi_2_0,
    input wire [63:0] pedi_2_0,
    output wire       peri_2_0,
    output wire       peso_2_0,
    input wire        pero_2_0,
    output wire [63:0] pedo_2_0,
    // Local interface ports for router (2,1)
    input wire        pesi_2_1,
    input wire [63:0] pedi_2_1,
    output wire       peri_2_1,
    output wire       peso_2_1,
    input wire        pero_2_1,
    output wire [63:0] pedo_2_1,
    // Local interface ports for router (2,2)
    input wire        pesi_2_2,
    input wire [63:0] pedi_2_2,
    output wire       peri_2_2,
    output wire       peso_2_2,
    input wire        pero_2_2,
    output wire [63:0] pedo_2_2,
    // Local interface ports for router (2,3)
    input wire        pesi_2_3,
    input wire [63:0] pedi_2_3,
    output wire       peri_2_3,
    output wire       peso_2_3,
    input wire        pero_2_3,
    output wire [63:0] pedo_2_3,
    // Local interface ports for router (3,0)
    input wire        pesi_3_0,
    input wire [63:0] pedi_3_0,
    output wire       peri_3_0,
    output wire       peso_3_0,
    input wire        pero_3_0,
    output wire [63:0] pedo_3_0,
    // Local interface ports for router (3,1)
    input wire        pesi_3_1,
    input wire [63:0] pedi_3_1,
    output wire       peri_3_1,
    output wire       peso_3_1,
    input wire        pero_3_1,
    output wire [63:0] pedo_3_1,
    // Local interface ports for router (3,2)
    input wire        pesi_3_2,
    input wire [63:0] pedi_3_2,
    output wire       peri_3_2,
    output wire       peso_3_2,
    input wire        pero_3_2,
    output wire [63:0] pedo_3_2,
    // Local interface ports for router (3,3)
    input wire        pesi_3_3,
    input wire [63:0] pedi_3_3,
    output wire       peri_3_3,
    output wire       peso_3_3,
    input wire        pero_3_3,
    output wire [63:0] pedo_3_3,

    output wire polarity_0_0,
    output wire polarity_0_1,
    output wire polarity_0_2,
    output wire polarity_0_3,
    output wire polarity_1_0,
    output wire polarity_1_1,
    output wire polarity_1_2,
    output wire polarity_1_3,
    output wire polarity_2_0,
    output wire polarity_2_1,
    output wire polarity_2_2,
    output wire polarity_2_3,
    output wire polarity_3_0,
    output wire polarity_3_1,
    output wire polarity_3_2,
    output wire polarity_3_3



);
    // Internal wires for inter-router links (send, ready, data for each direction)
    // Vertical links:
    wire        down_send_0_0, down_send_0_1, down_send_0_2, down_send_0_3;
    wire        down_send_1_0, down_send_1_1, down_send_1_2, down_send_1_3;
    wire        down_send_2_0, down_send_2_1, down_send_2_2, down_send_2_3;

    wire        down_ready_0_0, down_ready_0_1, down_ready_0_2, down_ready_0_3;
    wire        down_ready_1_0, down_ready_1_1, down_ready_1_2, down_ready_1_3;
    wire        down_ready_2_0, down_ready_2_1, down_ready_2_2, down_ready_2_3;
    wire [63:0] down_data_0_0, down_data_0_1, down_data_0_2, down_data_0_3;
    wire [63:0] down_data_1_0, down_data_1_1, down_data_1_2, down_data_1_3;
    wire [63:0] down_data_2_0, down_data_2_1, down_data_2_2, down_data_2_3;

    wire        up_send_0_0, up_send_0_1, up_send_0_2, up_send_0_3;    
    wire        up_send_1_0, up_send_1_1, up_send_1_2, up_send_1_3;
    wire        up_send_2_0, up_send_2_1, up_send_2_2, up_send_2_3;

    wire        up_ready_0_0, up_ready_0_1, up_ready_0_2, up_ready_0_3;
    wire        up_ready_1_0, up_ready_1_1, up_ready_1_2, up_ready_1_3;
    wire        up_ready_2_0, up_ready_2_1, up_ready_2_2, up_ready_2_3;

    wire [63:0] up_data_0_0, up_data_0_1, up_data_0_2, up_data_0_3;
    wire [63:0] up_data_1_0, up_data_1_1, up_data_1_2, up_data_1_3;
    wire [63:0] up_data_2_0, up_data_2_1, up_data_2_2, up_data_2_3;

    // Horizontal links:
    wire        right_send_0_0, right_send_0_1, right_send_0_2;
    wire        right_send_1_0, right_send_1_1, right_send_1_2;
    wire        right_send_2_0, right_send_2_1, right_send_2_2;
    wire        right_send_3_0, right_send_3_1, right_send_3_2;

    wire        right_ready_0_0, right_ready_0_1, right_ready_0_2;
    wire        right_ready_1_0, right_ready_1_1, right_ready_1_2;
    wire        right_ready_2_0, right_ready_2_1, right_ready_2_2;
    wire        right_ready_3_0, right_ready_3_1, right_ready_3_2;

    wire [63:0] right_data_0_0, right_data_0_1, right_data_0_2;
    wire [63:0] right_data_1_0, right_data_1_1, right_data_1_2;
    wire [63:0] right_data_2_0, right_data_2_1, right_data_2_2;
    wire [63:0] right_data_3_0, right_data_3_1, right_data_3_2;

    wire        left_send_0_0, left_send_0_1, left_send_0_2;
    wire        left_send_1_0, left_send_1_1, left_send_1_2;
    wire        left_send_2_0, left_send_2_1, left_send_2_2;
    wire        left_send_3_0, left_send_3_1, left_send_3_2;

    wire        left_ready_0_0, left_ready_0_1, left_ready_0_2;
    wire        left_ready_1_0, left_ready_1_1, left_ready_1_2;
    wire        left_ready_2_0, left_ready_2_1, left_ready_2_2;
    wire        left_ready_3_0, left_ready_3_1, left_ready_3_2;

    wire [63:0] left_data_0_0, left_data_0_1, left_data_0_2;
    wire [63:0] left_data_1_0, left_data_1_1, left_data_1_2;
    wire [63:0] left_data_2_0, left_data_2_1, left_data_2_2;
    wire [63:0] left_data_3_0, left_data_3_1, left_data_3_2;

    // Instantiate each router with appropriate neighbor connections
    // Row 0
    cardinal_router_four_way router_0_0 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_0_0),
        // Inputs from neighbors or local
        .upsi(down_send_0_0),     .upri(down_ready_0_0),     .updi(down_data_0_0),      // From router (1,0)
        .downsi(1'b0),            .downri(/* none */),       .downdi(64'b0),            // No down neighbor
        .leftsi(1'b0),            .leftri(/* none */),       .leftdi(64'b0),            // No left neighbor
        .rightsi(left_send_0_0),  .rightri(left_ready_0_0),  .rightdi(left_data_0_0),   // From router (0,1)
        .pesi(pesi_0_0),          .peri(peri_0_0),           .pedi(pedi_0_0),           // Local injection
        // Outputs to neighbors or local
        .upso(up_send_0_0),       .upro(up_ready_0_0),       .updo(up_data_0_0),        // To router (1,0)         
        .downso(/* none */),      .downro(1'b1),             .downdo(/* none */),       // No down neighbor
        .leftso(/* none */),      .leftro(1'b1),             .leftdo(/* none */),       // No left neighbor
        .rightso(right_send_0_0), .rightro(right_ready_0_0), .rightdo(right_data_0_0),  // To router (0,1)
        .peso(peso_0_0),          .pero(pero_0_0),           .pedo(pedo_0_0)            // Local ejection
    );

    cardinal_router_four_way router_0_1 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_0_1),
        // Inputs from neighbors or local
        .upsi(down_send_0_1),     .upri(down_ready_0_1),     .updi(down_data_0_1),      // From router (1,1)
        .downsi(1'b0),            .downri(/* none */),       .downdi(64'b0),            // No down neighbor
        .leftsi(right_send_0_0),  .leftri(right_ready_0_0),  .leftdi(right_data_0_0),   // From router (0,0)
        .rightsi(left_send_0_1),  .rightri(left_ready_0_1),  .rightdi(left_data_0_1),   // From router (0,2)
        .pesi(pesi_0_1),          .peri(peri_0_1),           .pedi(pedi_0_1),           // Local injection
        // Outputs to neighbors or local
        .upso(up_send_0_1),       .upro(up_ready_0_1),       .updo(up_data_0_1),        // To router (1,1)         
        .downso(/* none */),      .downro(1'b1),             .downdo(/* none */),       // No down neighbor
        .leftso(left_send_0_0),   .leftro(left_ready_0_0),   .leftdo(left_data_0_0),    // To router (0,0)
        .rightso(right_send_0_1), .rightro(right_ready_0_1), .rightdo(right_data_0_1),  // To router (0,2)
        .peso(peso_0_1),          .pero(pero_0_1),           .pedo(pedo_0_1)            // Local ejection
    );

    cardinal_router_four_way router_0_2 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_0_2),
        // Inputs from neighbors or local
        .upsi(down_send_0_2),     .upri(down_ready_0_2),     .updi(down_data_0_2),      // From router (1,2)
        .downsi(1'b0),            .downri(/* none */),       .downdi(64'b0),            // No down neighbor
        .leftsi(right_send_0_1),  .leftri(right_ready_0_1),  .leftdi(right_data_0_1),   // From router (0,1)
        .rightsi(left_send_0_2),  .rightri(left_ready_0_2),  .rightdi(left_data_0_2),   // From router (0,3)
        .pesi(pesi_0_2),          .peri(peri_0_2),           .pedi(pedi_0_2),           // Local injection
        // Outputs to neighbors or local
        .upso(up_send_0_2),       .upro(up_ready_0_2),       .updo(up_data_0_2),        // To router (2,1)         
        .downso(/* none */),      .downro(1'b1),             .downdo(/* none */),       // No down neighbor
        .leftso(left_send_0_1),   .leftro(left_ready_0_1),   .leftdo(left_data_0_1),    // To router (0,1)
        .rightso(right_send_0_2), .rightro(right_ready_0_2), .rightdo(right_data_0_2),  // To router (0,3)
        .peso(peso_0_2),          .pero(pero_0_2),           .pedo(pedo_0_2)            // Local ejection
    );

    cardinal_router_four_way router_0_3 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_0_3),
        // Inputs from neighbors or local
        .upsi(down_send_0_3),     .upri(down_ready_0_3),     .updi(down_data_0_3),      // From router (1,3)
        .downsi(1'b0),            .downri(/* none */),       .downdi(64'b0),            // No down neighbor
        .leftsi(right_send_0_2),  .leftri(right_ready_0_2),   .leftdi(right_data_0_2),  // From router (0,2)
        .rightsi(1'b0),           .rightri(/* none */),      .rightdi(64'b0),           // No right neighbor
        .pesi(pesi_0_3),          .peri(peri_0_3),           .pedi(pedi_0_3),           // Local injection
        // Outputs to neighbors or local
        .upso(up_send_0_3),       .upro(up_ready_0_3),       .updo(up_data_0_3),        // To router (3,1)         
        .downso(/* none */),      .downro(1'b1),             .downdo(/* none */),       // No down neighbor
        .leftso(left_send_0_2),   .leftro(left_ready_0_2),   .leftdo(left_data_0_2),    // To router (0,2)
        .rightso(/* none */),     .rightro(1'b1),            .rightdo(/* none */),      // No right neighbor
        .peso(peso_0_3),          .pero(pero_0_3),           .pedo(pedo_0_3)            // Local ejection
    );

    // Row 1
    cardinal_router_four_way router_1_0 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_1_0),
        // Inputs from neighbors or local
        .upsi(down_send_1_0),     .upri(down_ready_1_0),     .updi(down_data_1_0),      // From router (2,0)
        .downsi(up_send_0_0),     .downri(up_ready_0_0),     .downdi(up_data_0_0),      // From router (0,0)
        .leftsi(1'b0),            .leftri(/* none */),       .leftdi(64'b0),            // No left neighbor
        .rightsi(left_send_1_0),  .rightri(left_ready_1_0),  .rightdi(left_data_1_0),   // From router (1,1)
        .pesi(pesi_1_0),          .peri(peri_1_0),           .pedi(pedi_1_0),           // Local injection
        // Outputs to neighbors or local
        .upso(up_send_1_0),       .upro(up_ready_1_0),       .updo(up_data_1_0),        // To router (2,0)         
        .downso(down_send_0_0),   .downro(down_ready_0_0),   .downdo(down_data_0_0),    // To router (0,0)
        .leftso(/* none */),      .leftro(1'b1),             .leftdo(/* none */),       // No left neighbor
        .rightso(right_send_1_0), .rightro(right_ready_1_0), .rightdo(right_data_1_0),  // To router (1,1)
        .peso(peso_1_0),          .pero(pero_1_0),           .pedo(pedo_1_0)            // Local ejection
    );

    cardinal_router_four_way router_1_1 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_1_1),
        // Inputs from neighbors or local
        .upsi(down_send_1_1),     .upri(down_ready_1_1),     .updi(down_data_1_1),      // From router (2,1)
        .downsi(up_send_0_1),     .downri(up_ready_0_1),     .downdi(up_data_0_1),      // From router (0,1)
        .leftsi(right_send_1_0),  .leftri(right_ready_1_0),  .leftdi(right_data_1_0),   // From router (1,0)
        .rightsi(left_send_1_1),  .rightri(left_ready_1_1),  .rightdi(left_data_1_1),   // From router (1,2)
        .pesi(pesi_1_1),          .peri(peri_1_1),           .pedi(pedi_1_1),           // Local injection
        // Outputs to neighbors or local
        .upso(up_send_1_1),       .upro(up_ready_1_1),       .updo(up_data_1_1),        // To router (2,1)         
        .downso(down_send_0_1),   .downro(down_ready_0_1),   .downdo(down_data_0_1),    // To router (0,1)
        .leftso(left_send_1_0),   .leftro(left_ready_1_0),   .leftdo(left_data_1_0),    // To router (1,0)
        .rightso(right_send_1_1), .rightro(right_ready_1_1), .rightdo(right_data_1_1),  // To router (1,2)
        .peso(peso_1_1),          .pero(pero_1_1),           .pedo(pedo_1_1)            // Local ejection
    );

    cardinal_router_four_way router_1_2 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_1_2),
        // Inputs from neighbors or local
        .upsi(down_send_1_2),     .upri(down_ready_1_2),     .updi(down_data_1_2),      // From router (2,2)
        .downsi(up_send_0_2),     .downri(up_ready_0_2),     .downdi(up_data_0_2),      // From router (0,2)
        .leftsi(right_send_1_1),  .leftri(right_ready_1_1),  .leftdi(right_data_1_1),   // From router (1,1)
        .rightsi(left_send_1_2),  .rightri(left_ready_1_2),  .rightdi(left_data_1_2),   // From router (1,3)
        .pesi(pesi_1_2),          .peri(peri_1_2),           .pedi(pedi_1_2),           // Local injection
        // Outputs to neighbors or local
        .upso(up_send_1_2),       .upro(up_ready_1_2),       .updo(up_data_1_2),        // To router (2,2)         
        .downso(down_send_0_2),   .downro(down_ready_0_2),   .downdo(down_data_0_2),    // To router (0,2)
        .leftso(left_send_1_1),   .leftro(left_ready_1_1),   .leftdo(left_data_1_1),    // To router (1,1)
        .rightso(right_send_1_2), .rightro(right_ready_1_2), .rightdo(right_data_1_2),  // To router (1,3)
        .peso(peso_1_2),          .pero(pero_1_2),           .pedo(pedo_1_2)            // Local ejection
    );

    cardinal_router_four_way router_1_3 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_1_3),
        // Inputs from neighbors or local
        .upsi(down_send_1_3),     .upri(down_ready_1_3),     .updi(down_data_1_3),      // From router (2,3)
        .downsi(up_send_0_3),     .downri(up_ready_0_3),     .downdi(up_data_0_3),      // From router (0,3)
        .leftsi(right_send_1_2),  .leftri(right_ready_1_2),  .leftdi(right_data_1_2),   // From router (1,2)
        .rightsi(1'b0),           .rightri(/* none */),      .rightdi(64'b0),           // No right neighbor
        .pesi(pesi_1_3),          .peri(peri_1_3),           .pedi(pedi_1_3),           // Local injection
        // Outputs to neighbors or local
        .upso(up_send_1_3),       .upro(up_ready_1_3),       .updo(up_data_1_3),        // To router (2,3)         
        .downso(down_send_0_3),   .downro(down_ready_0_3),   .downdo(down_data_0_3),    // To router (0,3)
        .leftso(left_send_1_2),   .leftro(left_ready_1_2),   .leftdo(left_data_1_2),    // To router (1,2)
        .rightso(/* none */),     .rightro(1'b1),            .rightdo(/* none */),      // No right neighbor
        .peso(peso_1_3),          .pero(pero_1_3),           .pedo(pedo_1_3)            // Local ejection
    );

    // Row 2
    cardinal_router_four_way router_2_0 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_2_0),
        // Inputs from neighbors or local
        .upsi(down_send_2_0),     .upri(down_ready_2_0),     .updi(down_data_2_0),      // From router (3,0)
        .downsi(up_send_1_0),     .downri(up_ready_1_0),     .downdi(up_data_1_0),      // From router (1,0)
        .leftsi(1'b0),            .leftri(/* none */),       .leftdi(64'b0),            // No left neighbor
        .rightsi(left_send_2_0),  .rightri(left_ready_2_0),  .rightdi(left_data_2_0),   // From router (2,1)
        .pesi(pesi_2_0),          .peri(peri_2_0),           .pedi(pedi_2_0),           // Local injection
        // Outputs to neighbors or local
        .upso(up_send_2_0),       .upro(up_ready_2_0),       .updo(up_data_2_0),        // To router (3,0)         
        .downso(down_send_1_0),   .downro(down_ready_1_0),   .downdo(down_data_1_0),    // To router (1,0)
        .leftso(/* none */),      .leftro(1'b1),             .leftdo(/* none */),       // No left neighbor
        .rightso(right_send_2_0), .rightro(right_ready_2_0), .rightdo(right_data_2_0),  // To router (2,1)
        .peso(peso_2_0),          .pero(pero_2_0),           .pedo(pedo_2_0)            // Local ejection
    );

    cardinal_router_four_way router_2_1 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_2_1),
        // Inputs from neighbors or local
        .upsi(down_send_2_1),     .upri(down_ready_2_1),     .updi(down_data_2_1),      // From router (3,1)
        .downsi(up_send_1_1),     .downri(up_ready_1_1),     .downdi(up_data_1_1),      // From router (1,1)
        .leftsi(right_send_2_0),  .leftri(right_ready_2_0),  .leftdi(right_data_2_0),   // From router (2,0)
        .rightsi(left_send_2_1),  .rightri(left_ready_2_1),  .rightdi(left_data_2_1),   // From router (2,2)
        .pesi(pesi_2_1),          .peri(peri_2_1),           .pedi(pedi_2_1),           // Local injection
        // Outputs to neighbors or local
        .upso(up_send_2_1),       .upro(up_ready_2_1),       .updo(up_data_2_1),        // To router (3,1)         
        .downso(down_send_1_1),   .downro(down_ready_1_1),   .downdo(down_data_1_1),    // To router (1,1)
        .leftso(left_send_2_0),   .leftro(left_ready_2_0),   .leftdo(left_data_2_0),    // To router (2,0)
        .rightso(right_send_2_1), .rightro(right_ready_2_1), .rightdo(right_data_2_1),  // To router (2,2)
        .peso(peso_2_1),          .pero(pero_2_1),           .pedo(pedo_2_1)            // Local ejection
    );

    cardinal_router_four_way router_2_2 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_2_2),
        // Inputs from neighbors or local
        .upsi(down_send_2_2),     .upri(down_ready_2_2),     .updi(down_data_2_2),      // From router (3,2)
        .downsi(up_send_1_2),     .downri(up_ready_1_2),     .downdi(up_data_1_2),      // From router (1,2)
        .leftsi(right_send_2_1),  .leftri(right_ready_2_1),  .leftdi(right_data_2_1),   // From router (2,1)
        .rightsi(left_send_2_2),  .rightri(left_ready_2_2),  .rightdi(left_data_2_2),   // From router (2,3)
        .pesi(pesi_2_2),          .peri(peri_2_2),           .pedi(pedi_2_2),           // Local injection
        // Outputs to neighbors or local
        .upso(up_send_2_2),       .upro(up_ready_2_2),       .updo(up_data_2_2),        // To router (3,2)         
        .downso(down_send_1_2),   .downro(down_ready_1_2),   .downdo(down_data_1_2),    // To router (1,2)
        .leftso(left_send_2_1),   .leftro(left_ready_2_1),   .leftdo(left_data_2_1),    // To router (2,1)
        .rightso(right_send_2_2), .rightro(right_ready_2_2), .rightdo(right_data_2_2),  // To router (2,3)
        .peso(peso_2_2),          .pero(pero_2_2),           .pedo(pedo_2_2)            // Local ejection
    );

    cardinal_router_four_way router_2_3 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_2_3),
        // Inputs from neighbors or local
        .upsi(down_send_2_3),     .upri(down_ready_2_3),     .updi(down_data_2_3),      // From router (3,3)
        .downsi(up_send_1_3),     .downri(up_ready_1_3),     .downdi(up_data_1_3),      // From router (1,3)
        .leftsi(right_send_2_2),  .leftri(right_ready_2_2),  .leftdi(right_data_2_2),   // From router (2,2)
        .rightsi(1'b0),           .rightri(/* none */),      .rightdi(64'b0),           // No right neighbor
        .pesi(pesi_2_3),          .peri(peri_2_3),           .pedi(pedi_2_3),           // Local injection
        // Outputs to neighbors or local
        .upso(up_send_2_3),       .upro(up_ready_2_3),       .updo(up_data_2_3),        // To router (3,3)         
        .downso(down_send_1_3),   .downro(down_ready_1_3),   .downdo(down_data_1_3),    // To router (1,3)
        .leftso(left_send_2_2),   .leftro(left_ready_2_2),   .leftdo(left_data_2_2),    // To router (2,2)
        .rightso(/* none */),     .rightro(1'b1),            .rightdo(/* none */),      // No right neighbor
        .peso(peso_2_3),          .pero(pero_2_3),           .pedo(pedo_2_3)            // Local ejection
    );

    // Row 3
    cardinal_router_four_way router_3_0 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_3_0),
        // Inputs from neighbors or local
        .upsi(1'b0),              .upri(/* none */),         .updi(64'b0),              // No up neighbor
        .downsi(up_send_2_0),     .downri(up_ready_2_0),     .downdi(up_data_2_0),      // From router (2,0)
        .leftsi(1'b0),            .leftri(/* none */),       .leftdi(64'd0),            // No left neighbor
        .rightsi(left_send_3_0),  .rightri(left_ready_3_0),  .rightdi(left_data_3_0),   // From router (3,1)
        .pesi(pesi_3_0),          .peri(peri_3_0),           .pedi(pedi_3_0),           // Local injection
        // Outputs to neighbors or local
        .upso(/* none */),        .upro(1'b1),               .updo(/* none */),         // No up neighbor         
        .downso(down_send_2_0),   .downro(down_ready_2_0),   .downdo(down_data_2_0),    // To router (2,0)
        .leftso(/* none */),      .leftro(1'b1),             .leftdo(/* none */),       // No left neighbor
        .rightso(right_send_3_0), .rightro(right_ready_3_0), .rightdo(right_data_3_0),  // To router (3,1)
        .peso(peso_3_0),          .pero(pero_3_0),           .pedo(pedo_3_0)            // Local ejection
    );

    cardinal_router_four_way router_3_1 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_3_1),
        // Inputs from neighbors or local
        .upsi(1'b0),              .upri(/* none */),         .updi(64'b0),              // No up neighbor
        .downsi(up_send_2_1),     .downri(up_ready_2_1),     .downdi(up_data_2_1),      // From router (2,1)
        .leftsi(right_send_3_0),  .leftri(right_ready_3_0),  .leftdi(right_data_3_0),   // From router (3,0)
        .rightsi(left_send_3_1),  .rightri(left_ready_3_1),  .rightdi(left_data_3_1),   // From router (3,2)
        .pesi(pesi_3_1),          .peri(peri_3_1),           .pedi(pedi_3_1),           // Local injection
        // Outputs to neighbors or local
        .upso(/* none */),        .upro(1'b1),               .updo(/* none */),         // No up neighbor         
        .downso(down_send_2_1),   .downro(down_ready_2_1),   .downdo(down_data_2_1),    // To router (2,1)
        .leftso(left_send_3_0),   .leftro(left_ready_3_0),   .leftdo(left_data_3_0),    // To router (3,0)
        .rightso(right_send_3_1), .rightro(right_ready_3_1), .rightdo(right_data_3_1),  // To router (3,2)
        .peso(peso_3_1),          .pero(pero_3_1),           .pedo(pedo_3_1)            // Local ejection
    );

    cardinal_router_four_way router_3_2 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_3_2),
        // Inputs from neighbors or local
        .upsi(1'b0),              .upri(/* none */),         .updi(64'b0),              // No up neighbor
        .downsi(up_send_2_2),     .downri(up_ready_2_2),     .downdi(up_data_2_2),      // From router (2,2)
        .leftsi(right_send_3_1),  .leftri(right_ready_3_1),  .leftdi(right_data_3_1),   // From router (3,1)
        .rightsi(left_send_3_2),  .rightri(left_ready_3_2),  .rightdi(left_data_3_2),   // From router (3,3)
        .pesi(pesi_3_2),          .peri(peri_3_2),           .pedi(pedi_3_2),           // Local injection
        // Outputs to neighbors or local
        .upso(/* none */),        .upro(1'b1),               .updo(/* none */),         // No up neighbor         
        .downso(down_send_2_2),   .downro(down_ready_2_2),   .downdo(down_data_2_2),    // To router (2,2)
        .leftso(left_send_3_1),   .leftro(left_ready_3_1),   .leftdo(left_data_3_1),    // To router (3,1)
        .rightso(right_send_3_2), .rightro(right_ready_3_2), .rightdo(right_data_3_2),  // To router (3,3)
        .peso(peso_3_2),          .pero(pero_3_2),           .pedo(pedo_3_2)            // Local ejection
    );

    cardinal_router_four_way router_3_3 (
        .clk(clk),
        .reset(reset),
        .polarity(polarity_3_3),
        // Inputs from neighbors or local
        .upsi(1'b0),              .upri(/* none */),         .updi(64'b0),              // No up neighbor
        .downsi(up_send_2_3),     .downri(up_ready_2_3),     .downdi(up_data_2_3),      // From router (2,3)
        .leftsi(right_send_3_2),  .leftri(right_ready_3_2),  .leftdi(right_data_3_2),   // From router (3,2)
        .rightsi(1'b0),           .rightri(/* none */),      .rightdi(64'b0),           // No right neighbor
        .pesi(pesi_3_3),          .peri(peri_3_3),           .pedi(pedi_3_3),           // Local injection
        // Outputs to neighbors or local
        .upso(/* none */),        .upro(1'b1),               .updo(/* none */),         // No up neighbor         
        .downso(down_send_2_3),   .downro(down_ready_2_3),   .downdo(down_data_2_3),    // To router (2,3)
        .leftso(left_send_3_2),   .leftro(left_ready_3_2),   .leftdo(left_data_3_2),    // To router (3,2)
        .rightso(/* none */),     .rightro(1'b1),            .rightdo(/* none */),      // No right neighbor
        .peso(peso_3_3),          .pero(pero_3_3),           .pedo(pedo_3_3)            // Local ejection
    );


endmodule
