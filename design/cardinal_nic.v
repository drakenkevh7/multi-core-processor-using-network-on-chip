//////////////////////////////////////////////////////////////////////
//     design: cardinal_nic.v
//////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module cardinal_nic (
    input  wire        clk,        // system clock
    input  wire        reset,      // synchronous reset (active high)

    // Process side.
    input  wire [1:0]  addr,       // 2-bit address for NIC registers
    input  wire [63:0] d_in,       // data input from processor (write)
    output reg  [63:0] d_out,      // data output to processor (read)
    input  wire        nicEn,      // NIC enable (chip-select)
    input  wire        nicEnWr,    // NIC write enable (1 for write, 0 for read)

    // Router side.
    input  wire        net_si,     // Send handshake input from router (input channel)
    output reg         net_ri,     // Ready handshake output to router (input channel)
    input  wire [63:0] net_di,     // Data from router to NIC (input channel)
    output reg         net_so,     // Send handshake output to router (output channel)
    input  wire        net_ro,     // Ready handshake input from router (output channel)
    output wire [63:0] net_do,     // Data from NIC to router (output channel)
    input  wire        net_polarity// Polarity signal from router (for VC handshake)
);

    // Local parameters for register address decoding.
    localparam [1:0] ADDR_IN_BUF     = 2'b00,  // Input channel buffer address
                     ADDR_IN_STATUS  = 2'b01,  // Input status register address
                     ADDR_OUT_BUF    = 2'b10,  // Output channel buffer address
                     ADDR_OUT_STATUS = 2'b11;  // Output status register address

	// Internal registers for channel buffers and status
    reg [63:0] input_buffer;   // 64-bit input channel buffer (router -> CPU)
    reg [63:0] output_buffer;  // 64-bit output channel buffer (CPU -> router)
    reg        input_status;   // 1-bit status: 1 if input_buffer full (new packet available)
    reg        output_status;  // 1-bit status: 1 if output_buffer full (packet waiting to send)

    // Assume packet's VC (virtual channel) bit is bit 0 of the 64-bit packet.
    // This bit will be compared with net_polarity for sending.
    localparam integer VC_BIT = 0;

    // Connect output data to router from the internal output buffer.
    // The data is continuously driven from output_buffer; it is valid when net_so=1.
    assign net_do = output_buffer;

    // Synchronous sequential logic for NIC operation
    always @(posedge clk) begin
        if (reset) begin
            // Reset all internal state: buffers empty, status flags cleared
            input_buffer  <= 64'b0;
            output_buffer <= 64'b0;
            input_status  <= 1'b0;
            output_status <= 1'b0;
            // Initialize handshake outputs after reset
            net_ri <= 1'b1;   // input buffer is empty -> ready to receive
            net_so <= 1'b0;   // no packet to send on output -> send negated
            d_out  <= 64'b0;  // clear data output
        end else begin
            // Default outputs each cycle.
            net_so <= 1'b0;  // do not send by default (assert only when conditions met)
            if (!nicEn) begin
                // If NIC not enabled by processor, drive d_out as 0 (tri-state behavior)
                d_out <= 64'b0;
            end else if (nicEnWr) begin
                // Processor Store operation (write to NIC).
                case (addr)
                    ADDR_OUT_BUF: begin
                        // Write to network output buffer (allowed if buffer is free).
                        if (!output_status) begin
                            output_buffer <= d_in;    // latch outgoing packet data
                            output_status <= 1'b1;    // mark output buffer as full
                        end
                        // If output_status is already 1 (buffer occupied), ignore the write
                        // (Buffer remains unchanged to preserve the existing packet)
                    end
                    default: begin
                        // Writes to other addresses are illegal (read-only registers)
                        // Ignore these writes (do nothing)
                    end
                endcase
                // Note: On a write, d_out remains unchanged (stays at last value or zero). It is only updated on reads.
            end else begin
                // Processor Load operation (read from NIC).
                case (addr)
                    ADDR_IN_BUF: begin
                        // Read from input channel buffer
                        if (input_status) begin
                            // Buffer has a valid packet
                            d_out <= input_buffer;    // put the 64-bit packet on d_out
                            input_status <= 1'b0;     // mark input buffer as empty (packet consumed)
                            net_ri <= 1'b1;           // ready for new router packet
                            input_buffer <= 64'b0;    // clear buffer data after read
                        end else begin
                            // Buffer is empty – undefined read
                            d_out <= input_buffer;
                            // input_status stays 0, net_ri stays 1 (no change)
                        end
                    end
                    ADDR_IN_STATUS: begin
                        // Read input status register (1-bit)
                        // Place status bit in LSB of d_out, others = 0
                        d_out <= {63'b0, input_status};
                        // (Reading status does not modify it)
                    end
                    ADDR_OUT_BUF: begin
                        // Read from output buffer (illegal, write-only)
                        // Ignore the read: do not alter buffer or status
                        d_out <= 64'b0;  // return 0
                    end
                    ADDR_OUT_STATUS: begin
                        // Read output status register (1-bit)
                        d_out <= {63'b0, output_status};  // status bit in d_out[0], rest 0
                        // (No state change on reading status)
                    end
                endcase
            end  // end of NIC read/write handling

            // Router Input Channel Handshake
            if (net_si && !input_status) begin
                // Router is sending a new packet and NIC input buffer is free
                input_buffer <= net_di;   // latch incoming packet data from router
                input_status <= 1'b1;     // mark input buffer as full (new packet available)
                net_ri <= 1'b0;           // buffer occupied -> not ready for more data
            end
            // If net_si is asserted while input_status=1 (buffer full), NIC ignores the new packet (cannot overwrite existing data).

            // Router Output Channel Handshake
            if (output_status && net_ro && (output_buffer[VC_BIT] == net_polarity)) begin
                // NIC has a packet to send, router is ready, and polarity matches packet's VC
                net_so <= 1'b1;          // assert send-out to router (packet valid on net_do)
                // Packet data is already on net_do via continuous assign from output_buffer.
                output_status <= 1'b0;   // clear output buffer (packet sent, now buffer free)
                // (After this cycle, net_so will be deasserted by default, and processor can write a new packet into output_buffer)
            end
            // If router not ready (net_ro=0) or polarity mismatch, net_so remains 0 and output_status stays 1 (NIC holds packet).
        end
    end
endmodule