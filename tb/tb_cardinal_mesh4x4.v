/////////////////////////////////////////////////////////////////
// tb_cardinal_mesh4x4.v  (Verilog-2001 compliant)
/////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_cardinal_mesh4x4;
  // Clock & reset
  reg clk, reset;
  integer cyc;

  // ---- Local PE interfaces
  reg        pesi_0_0; reg  [63:0] pedi_0_0; wire peri_0_0; wire peso_0_0; reg  pero_0_0; wire [63:0] pedo_0_0;
  reg        pesi_0_1; reg  [63:0] pedi_0_1; wire peri_0_1; wire peso_0_1; reg  pero_0_1; wire [63:0] pedo_0_1;
  reg        pesi_0_2; reg  [63:0] pedi_0_2; wire peri_0_2; wire peso_0_2; reg  pero_0_2; wire [63:0] pedo_0_2;
  reg        pesi_0_3; reg  [63:0] pedi_0_3; wire peri_0_3; wire peso_0_3; reg  pero_0_3; wire [63:0] pedo_0_3;

  reg        pesi_1_0; reg  [63:0] pedi_1_0; wire peri_1_0; wire peso_1_0; reg  pero_1_0; wire [63:0] pedo_1_0;
  reg        pesi_1_1; reg  [63:0] pedi_1_1; wire peri_1_1; wire peso_1_1; reg  pero_1_1; wire [63:0] pedo_1_1;
  reg        pesi_1_2; reg  [63:0] pedi_1_2; wire peri_1_2; wire peso_1_2; reg  pero_1_2; wire [63:0] pedo_1_2;
  reg        pesi_1_3; reg  [63:0] pedi_1_3; wire peri_1_3; wire peso_1_3; reg  pero_1_3; wire [63:0] pedo_1_3;

  reg        pesi_2_0; reg  [63:0] pedi_2_0; wire peri_2_0; wire peso_2_0; reg  pero_2_0; wire [63:0] pedo_2_0;
  reg        pesi_2_1; reg  [63:0] pedi_2_1; wire peri_2_1; wire peso_2_1; reg  pero_2_1; wire [63:0] pedo_2_1;
  reg        pesi_2_2; reg  [63:0] pedi_2_2; wire peri_2_2; wire peso_2_2; reg  pero_2_2; wire [63:0] pedo_2_2;
  reg        pesi_2_3; reg  [63:0] pedi_2_3; wire peri_2_3; wire peso_2_3; reg  pero_2_3; wire [63:0] pedo_2_3;

  reg        pesi_3_0; reg  [63:0] pedi_3_0; wire peri_3_0; wire peso_3_0; reg  pero_3_0; wire [63:0] pedo_3_0;
  reg        pesi_3_1; reg  [63:0] pedi_3_1; wire peri_3_1; wire peso_3_1; reg  pero_3_1; wire [63:0] pedo_3_1;
  reg        pesi_3_2; reg  [63:0] pedi_3_2; wire peri_3_2; wire peso_3_2; reg  pero_3_2; wire [63:0] pedo_3_2;
  reg        pesi_3_3; reg  [63:0] pedi_3_3; wire peri_3_3; wire peso_3_3; reg  pero_3_3; wire [63:0] pedo_3_3;

  // ---- Polarity taps (from DUT)
  wire polarity_0_0, polarity_0_1, polarity_0_2, polarity_0_3;
  wire polarity_1_0, polarity_1_1, polarity_1_2, polarity_1_3;
  wire polarity_2_0, polarity_2_1, polarity_2_2, polarity_2_3;
  wire polarity_3_0, polarity_3_1, polarity_3_2, polarity_3_3;

  // ---- UUT
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

  // ---- Clock: 100 MHz
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // ---- Cycle counter
  always @(posedge clk) begin
    if (reset) cyc <= 0;
    else       cyc <= cyc + 1;
  end

  // ========== Helpers (2001 style) ==========

  function [63:0] mk_xy_flit;
    input [3:0] x_off;
    input [3:0] y_off;
    input [31:0] tag;
    begin
      mk_xy_flit = {8'h00, x_off[3:0], y_off[3:0], 16'h0000, tag};
    end
  endfunction

  // Return (dst_j - src_j)[3:0]
  function [3:0] dx_for;
    input integer src_j, dst_j;
    integer t;
    begin
      t = dst_j - src_j;
      dx_for = t[3:0];
    end
  endfunction

  // Row 0 bottom -> Row 3 top: Y < 0 means go UP
  function [3:0] dy_for;
    input integer src_i, dst_i;
    integer t;
    begin
      t = src_i - dst_i;
      dy_for = t[3:0];
    end
  endfunction

  // Verilog-2001 requires at least one input arg
  function integer rand4;
    input integer dummy;
    integer r;
    begin
      r = $random;
      if (r < 0) r = -r;
      rand4 = r % 4;
    end
  endfunction

  // ---------- Setters / Getters ----------
  task set_pesi;
    input integer i, j;
    input v;
    begin case ({i[3:0],j[3:0]})
      8'h00: pesi_0_0=v; 8'h01: pesi_0_1=v; 8'h02: pesi_0_2=v; 8'h03: pesi_0_3=v;
      8'h10: pesi_1_0=v; 8'h11: pesi_1_1=v; 8'h12: pesi_1_2=v; 8'h13: pesi_1_3=v;
      8'h20: pesi_2_0=v; 8'h21: pesi_2_1=v; 8'h22: pesi_2_2=v; 8'h23: pesi_2_3=v;
      8'h30: pesi_3_0=v; 8'h31: pesi_3_1=v; 8'h32: pesi_3_2=v; 8'h33: pesi_3_3=v;
    endcase end
  endtask

  task set_pedi;
    input integer i, j;
    input [63:0] d;
    begin case ({i[3:0],j[3:0]})
      8'h00: pedi_0_0=d; 8'h01: pedi_0_1=d; 8'h02: pedi_0_2=d; 8'h03: pedi_0_3=d;
      8'h10: pedi_1_0=d; 8'h11: pedi_1_1=d; 8'h12: pedi_1_2=d; 8'h13: pedi_1_3=d;
      8'h20: pedi_2_0=d; 8'h21: pedi_2_1=d; 8'h22: pedi_2_2=d; 8'h23: pedi_2_3=d;
      8'h30: pedi_3_0=d; 8'h31: pedi_3_1=d; 8'h32: pedi_3_2=d; 8'h33: pedi_3_3=d;
    endcase end
  endtask

  function get_peri;
    input integer i, j;
    begin case ({i[3:0],j[3:0]})
      8'h00: get_peri=peri_0_0; 8'h01: get_peri=peri_0_1; 8'h02: get_peri=peri_0_2; 8'h03: get_peri=peri_0_3;
      8'h10: get_peri=peri_1_0; 8'h11: get_peri=peri_1_1; 8'h12: get_peri=peri_1_2; 8'h13: get_peri=peri_1_3;
      8'h20: get_peri=peri_2_0; 8'h21: get_peri=peri_2_1; 8'h22: get_peri=peri_2_2; 8'h23: get_peri=peri_2_3;
      8'h30: get_peri=peri_3_0; 8'h31: get_peri=peri_3_1; 8'h32: get_peri=peri_3_2; 8'h33: get_peri=peri_3_3;
      default: get_peri=1'b0;
    endcase end
  endfunction

  function get_peso;
    input integer i, j;
    begin case ({i[3:0],j[3:0]})
      8'h00: get_peso=peso_0_0; 8'h01: get_peso=peso_0_1; 8'h02: get_peso=peso_0_2; 8'h03: get_peso=peso_0_3;
      8'h10: get_peso=peso_1_0; 8'h11: get_peso=peso_1_1; 8'h12: get_peso=peso_1_2; 8'h13: get_peso=peso_1_3;
      8'h20: get_peso=peso_2_0; 8'h21: get_peso=peso_2_1; 8'h22: get_peso=peso_2_2; 8'h23: get_peso=peso_2_3;
      8'h30: get_peso=peso_3_0; 8'h31: get_peso=peso_3_1; 8'h32: get_peso=peso_3_2; 8'h33: get_peso=peso_3_3;
      default: get_peso=1'b0;
    endcase end
  endfunction

  function [63:0] get_pedo;
    input integer i, j;
    begin case ({i[3:0],j[3:0]})
      8'h00: get_pedo=pedo_0_0; 8'h01: get_pedo=pedo_0_1; 8'h02: get_pedo=pedo_0_2; 8'h03: get_pedo=pedo_0_3;
      8'h10: get_pedo=pedo_1_0; 8'h11: get_pedo=pedo_1_1; 8'h12: get_pedo=pedo_1_2; 8'h13: get_pedo=pedo_1_3;
      8'h20: get_pedo=pedo_2_0; 8'h21: get_pedo=pedo_2_1; 8'h22: get_pedo=pedo_2_2; 8'h23: get_pedo=pedo_2_3;
      8'h30: get_pedo=pedo_3_0; 8'h31: get_pedo=pedo_3_1; 8'h32: get_pedo=pedo_3_2; 8'h33: get_pedo=pedo_3_3;
      default: get_pedo=64'h0;
    endcase end
  endfunction

  // Handshake-correct injection
  task inject_local;
    input integer i, j;
    input [63:0] flit;
    begin
      set_pedi(i,j, flit);
      set_pesi(i,j, 1'b1);
      while (!get_peri(i,j)) @(posedge clk);
      @(posedge clk);
      set_pesi(i,j, 1'b0);
      $display("[Cyc %0d] Injected @(%0d,%0d): %h", cyc, i, j, flit);
    end
  endtask

  // Wait for delivery with timeout
  task wait_delivery;
    input integer i, j, timeout;
    output success;
    integer t;
    begin
      success = 1'b0;
      t = 0;
      while (!get_peso(i,j) && t < timeout) begin t = t + 1; @(posedge clk); end
      success = get_peso(i,j);
    end
  endtask

  // Check offsets cleared and tag matches
  task check_zero_hops_and_tag;
    input integer i, j;
    input [31:0] tag;
    reg [63:0] f;
    begin
      f = get_pedo(i,j);
      if (f[31:0] === tag && f[55:52] == 4'h0 && f[51:48] == 4'h0)
        $display("      PASS: (@%0d,%0d) flit ok: %h", i, j, f);
      else
        $display("      FAIL: (@%0d,%0d) got %h (tag/offsets mismatch)", i, j, f);
    end
  endtask

  // ========== Stimulus ==========

  integer i, j, dst_i, dst_j, tries, si, sj;
  reg [31:0] tag;
  reg ok;

  // Optional: polarity debug
  //always @(posedge clk) $display("[Cyc %0d] pol(0,0)=%0d pol(3,3)=%0d", cyc, polarity_0_0, polarity_3_3);

  // Monitor local ejections (optional)
  always @(posedge clk) begin
    if (peso_0_0) $display("[Cyc %0d] (@0,0) OUT %h", cyc, pedo_0_0);
    if (peso_0_1) $display("[Cyc %0d] (@0,1) OUT %h", cyc, pedo_0_1);
    if (peso_0_2) $display("[Cyc %0d] (@0,2) OUT %h", cyc, pedo_0_2);
    if (peso_0_3) $display("[Cyc %0d] (@0,3) OUT %h", cyc, pedo_0_3);
    if (peso_1_0) $display("[Cyc %0d] (@1,0) OUT %h", cyc, pedo_1_0);
    if (peso_1_1) $display("[Cyc %0d] (@1,1) OUT %h", cyc, pedo_1_1);
    if (peso_1_2) $display("[Cyc %0d] (@1,2) OUT %h", cyc, pedo_1_2);
    if (peso_1_3) $display("[Cyc %0d] (@1,3) OUT %h", cyc, pedo_1_3);
    if (peso_2_0) $display("[Cyc %0d] (@2,0) OUT %h", cyc, pedo_2_0);
    if (peso_2_1) $display("[Cyc %0d] (@2,1) OUT %h", cyc, pedo_2_1);
    if (peso_2_2) $display("[Cyc %0d] (@2,2) OUT %h", cyc, pedo_2_2);
    if (peso_2_3) $display("[Cyc %0d] (@2,3) OUT %h", cyc, pedo_2_3);
    if (peso_3_0) $display("[Cyc %0d] (@3,0) OUT %h", cyc, pedo_3_0);
    if (peso_3_1) $display("[Cyc %0d] (@3,1) OUT %h", cyc, pedo_3_1);
    if (peso_3_2) $display("[Cyc %0d] (@3,2) OUT %h", cyc, pedo_3_2);
    if (peso_3_3) $display("[Cyc %0d] (@3,3) OUT %h", cyc, pedo_3_3);
  end

  initial begin
    // $dumpfile("mesh.vcd"); $dumpvars(0, tb_cardinal_mesh4x4);

    // Init
    reset = 1; cyc = 0;

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

    // Reset
    repeat (6) @(posedge clk);
    reset = 0;
    $display(">> Reset deasserted @ cycle %0d", cyc);

    // 1) Corner (0,0)->(3,3)
    tag = 32'hA000_0001;
    inject_local(0,0, mk_xy_flit(dx_for(0,3), dy_for(0,3), tag));
    wait_delivery(3,3, 240, ok);
    if (!ok) $display("ERROR: corner timeout");
    else     check_zero_hops_and_tag(3,3, tag);

    // 2) Row (1,0)->(1,3)
    tag = 32'hA000_0002;
    inject_local(1,0, mk_xy_flit(dx_for(0,3), dy_for(1,1), tag));
    wait_delivery(1,3, 240, ok);
    if (!ok) $display("ERROR: row timeout");
    else     check_zero_hops_and_tag(1,3, tag);

    // 3) Column (0,2)->(3,2)
    tag = 32'hA000_0003;
    inject_local(0,2, mk_xy_flit(dx_for(2,2), dy_for(0,3), tag));
    wait_delivery(3,2, 240, ok);
    if (!ok) $display("ERROR: column timeout");
    else     check_zero_hops_and_tag(3,2, tag);

    // 4) Local loopback (all nodes)
    $display(">> Local loopback (all 16 nodes)");
    for (i=0;i<4;i=i+1) begin
      for (j=0;j<4;j=j+1) begin
        tag = 32'hB000_0000 | (i*4 + j);
        inject_local(i,j, mk_xy_flit(4'h0, 4'h0, tag));
        wait_delivery(i,j, 100, ok);
        if (!ok) $display("ERROR: loopback timeout @(%0d,%0d)", i,j);
        else     check_zero_hops_and_tag(i,j, tag);
      end
    end

    // 5) Random pairs
    $display(">> Randomized tests");
    for (tries=0; tries<8; tries=tries+1) begin
      si = rand4(0); sj = rand4(0); dst_i = rand4(0); dst_j = rand4(0);
      if (dst_i==si && dst_j==sj) dst_j = (dst_j+1)%4;
      tag = 32'hC000_0000 + tries;
      $display("  rnd%0d: (%0d,%0d)->(%0d,%0d)", tries, si,sj, dst_i,dst_j);
      inject_local(si, sj, mk_xy_flit(dx_for(sj,dst_j), dy_for(si,dst_i), tag));
      wait_delivery(dst_i, dst_j, 300, ok);
      if (!ok) $display("ERROR: random%0d timeout", tries);
      else     check_zero_hops_and_tag(dst_i, dst_j, tag);
    end

    // 4) Link sweep: exercise every neighbor link (both directions)
    $display(">> Link sweep (1-hop across every link)");

    // 4a) Horizontal: rightward (j -> j+1)
    for (i=0;i<4;i=i+1) begin
      for (j=0;j<3;j=j+1) begin
        tag = 32'hB100_0000 | (i*8 + j); // unique-ish
        inject_local(i, j, mk_xy_flit(dx_for(j, j+1), dy_for(i, i), tag));
        wait_delivery(i, j+1, 120, ok);
        if (!ok) $display("ERROR: horiz right timeout @(%0d,%0d)->(%0d,%0d)", i,j,i,j+1);
        else     check_zero_hops_and_tag(i, j+1, tag);
      end
    end

    // 4b) Horizontal: leftward (j -> j-1)
    for (i=0;i<4;i=i+1) begin
      for (j=1;j<4;j=j+1) begin
        tag = 32'hB101_0000 | (i*8 + j);
        inject_local(i, j, mk_xy_flit(dx_for(j, j-1), dy_for(i, i), tag));
        wait_delivery(i, j-1, 120, ok);
        if (!ok) $display("ERROR: horiz left timeout @(%0d,%0d)->(%0d,%0d)", i,j,i,j-1);
        else     check_zero_hops_and_tag(i, j-1, tag);
      end
    end

    // 4c) Vertical: “up” in the mesh sense (i -> i+1, dy < 0 because row0 is bottom)
    for (i=0;i<3;i=i+1) begin
      for (j=0;j<4;j=j+1) begin
        tag = 32'hB102_0000 | (i*8 + j);
        inject_local(i, j, mk_xy_flit(dx_for(j, j), dy_for(i, i+1), tag));
        wait_delivery(i+1, j, 120, ok);
        if (!ok) $display("ERROR: vert up timeout @(%0d,%0d)->(%0d,%0d)", i,j,i+1,j);
        else     check_zero_hops_and_tag(i+1, j, tag);
      end
    end

    // 4d) Vertical: “down” (i -> i-1, dy > 0)
    for (i=1;i<4;i=i+1) begin
      for (j=0;j<4;j=j+1) begin
        tag = 32'hB103_0000 | (i*8 + j);
        inject_local(i, j, mk_xy_flit(dx_for(j, j), dy_for(i, i-1), tag));
        wait_delivery(i-1, j, 120, ok);
        if (!ok) $display("ERROR: vert down timeout @(%0d,%0d)->(%0d,%0d)", i,j,i-1,j);
        else     check_zero_hops_and_tag(i-1, j, tag);
      end
    end


    $display("All tests done.");
    repeat (20) @(posedge clk); $finish;
  end
endmodule
