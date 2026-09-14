`timescale 1ns / 1ps

module tb_axi_handshake_counter;

    // Inputs to DUT (Device Under Test)
    reg        clk;
    reg        rst_n;
    reg        axi_valid;
    reg        axi_ready;

    // Outputs from DUT
    wire [31:0] handshake_count;

    // Instantiate the Unit Under Test (DUT)
    axi_handshake_counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .axi_valid(axi_valid),
        .axi_ready(axi_ready),
        .handshake_count(handshake_count)
    );

    // 100MHz Clock Generation (10ns period)
    always #5 clk = ~clk;

    // Stimulus process
    initial begin
        // Initialize Inputs
        clk       = 0;
        rst_n     = 0;
        axi_valid = 0;
        axi_ready = 0;

        // Apply Reset
        #20;
        rst_n = 1;
        #10;

        // Scenario 1: VALID high, READY low (Stall - Should NOT count)
        axi_valid = 1;
        axi_ready = 0;
        #20;

        // Scenario 2: READY high, VALID low (Stall - Should NOT count)
        axi_valid = 0;
        axi_ready = 1;
        #20;

        // Scenario 3: Single successful handshake (VALID & READY high)
        axi_valid = 1;
        axi_ready = 1;
        #10; // 1 clock cycle -> count = 1

        // Scenario 4: Deassert VALID (Pause transfers)
        axi_valid = 0;
        #20;

        // Scenario 5: Continuous handshakes for 5 clock cycles
        axi_valid = 1;
        axi_ready = 1;
        #50; // 5 clock cycles -> count = 6

        // Scenario 6: Stop transfers
        axi_valid = 0;
        axi_ready = 0;
        #20;

        // Scenario 7: Test active-low reset functionality
        rst_n = 0;
        #10;
        rst_n = 1;
        #20;

        // End simulation
        $display("Final Handshake Count = %d (Expected: 0 after reset)", handshake_count);
        $finish;
    end

    // Monitor outputs in simulation console
    initial begin
        $monitor("Time=%0t | rst_n=%b | VALID=%b | READY=%b | Count=%d", 
                 $time, rst_n, axi_valid, axi_ready, handshake_count);
    end

endmodule
