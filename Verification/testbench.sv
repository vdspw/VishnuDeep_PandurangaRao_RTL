`timescale 1ns / 1ps
// Interface 
interface uart_if;
  logic clk;
  logic rst;
  logic [7:0] s_axis_tdata;
  logic s_axis_tvalid;
  logic s_axis_tready;
  logic [7:0] m_axis_tdata;
  logic m_axis_tvalid;
  logic m_axis_tready;
  logic rxd;
  logic txd;
  logic tx_busy;
  logic rx_busy;
  logic rx_overrun_error;
  logic rx_frame_error;
  logic [15:0] prescale;
endinterface

// TB
module tb;
  uart_if vif();
  logic [7:0] rec_bits; // store the tx data

  
  uart #(.DATA_WIDTH(8)) dut (
    .clk(vif.clk),
    .rst(vif.rst),
    .s_axis_tdata(vif.s_axis_tdata),
    .s_axis_tvalid(vif.s_axis_tvalid),
    .s_axis_tready(vif.s_axis_tready),
    .m_axis_tdata(vif.m_axis_tdata),
    .m_axis_tvalid(vif.m_axis_tvalid),
    .m_axis_tready(vif.m_axis_tready),
    .rxd(vif.txd), // Loopback: txd -> rxd
    .txd(vif.txd),
    .tx_busy(vif.tx_busy),
    .rx_busy(vif.rx_busy),
    .rx_overrun_error(vif.rx_overrun_error),
    .rx_frame_error(vif.rx_frame_error),
    .prescale(vif.prescale)
  );

  initial begin //clocking block
    vif.clk = 0;
    forever #5 vif.clk = ~vif.clk;
  end

  initial begin
    
    $display("Starting Communication");
    vif.rst = 1;
    vif.s_axis_tdata = 8'h00;
    vif.s_axis_tvalid = 0;
    vif.m_axis_tready = 0;
    vif.prescale = 16'd868; // for 115200 baud 
    $display("Applying reset at %t", $time);
    $display(" vif.s_axis_tdata = %h\n, vif.s_axis_tvalid = %b\n, vif.m_axis_tready = %b\n",
             vif.s_axis_tdata, vif.s_axis_tvalid, vif.m_axis_tready);
    $display("--------------------------------------------------------------------");

    #5;
    vif.rst = 0; // Deassert reset
    $display("Reset deasserted at %t", $time);
    $display("--------------------------------------------------------------------");

    $display("Test to check active HIGH txd & rxd");

    if (vif.txd == 1'b0) begin
      $display("PASS: TXD is low in IDLE \n");
    end else begin
      $display("FAIL: TXD is high in IDLE \n");
    end
    $display("--------------------------------------------------------------------");
    #10;

    $display("Check Tx and Rx operation");
    vif.s_axis_tdata = 8'h10;
    vif.s_axis_tvalid = 1; // AXI handshake signals
    vif.m_axis_tready = 1; // --
    $display("Data to be sent: %0h \n", vif.s_axis_tdata);
    #10;
    wait (vif.s_axis_tready);
    vif.s_axis_tvalid = 0; // handshake done
    #40;

    fork
      begin
        @(posedge vif.txd);
        $display("TXD is 1 -- indicates start");
        $display("----------------------------------------------------------------");

        for (int i = 0; i < 8; i++) begin
          #8680; // set up time
          
          rec_bits[i] = vif.txd;
        end
        @(negedge vif.txd);  // asserting the stop bit.
        #10; 
        if (vif.txd == 1'b1) begin 
          $display("PASS: Stop bit is LOW");
        end else begin
          $display("FAIL: Stop is HIGH");
        end
		#10;
        if (rec_bits == vif.s_axis_tdata) begin
          $display("PASS: txd transmitted correct data ||matches s_axis_tdata = %h", rec_bits);
        end else begin
          $display("FAIL: txd transmitted incorrect data ||expected s_axis_tdata = %h, got %h", vif.s_axis_tdata, rec_bits);
          $display("----------------------------------------------------------------------");
        end
      end

      begin
        wait (vif.m_axis_tvalid); // Wait-- recieved data
        $display("Received data on m_axis_tdata: %h ", vif.m_axis_tdata);
        if (vif.m_axis_tdata == vif.s_axis_tdata) begin
          $display("PASS: rxd correctly received data ||matches s_axis_tdata = %h", vif.m_axis_tdata);
        end else begin
          $display("FAIL: rxd received incorrect data ||expected s_axis_tdata = %h, got %h", vif.s_axis_tdata, vif.m_axis_tdata);
        end
      end
      
    join
	
    
    
    
  end
  initial begin
    #90000000;  
    $display("Simulation finished at %0t", $time);
    $finish; 
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule
