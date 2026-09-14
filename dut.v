module axi_handshake_counter (
    input  wire        clk,
    input  wire        rst_n,           // Active-low reset
    
    // AXI Handshake Signals
    input  wire        axi_valid,       // Valid signal from source
    input  wire        axi_ready,       // Ready signal from destination
    
    // Output Counter Value
    output reg  [31:0] handshake_count  // 32-bit counter output
);

    // Identify successful handshake condition
    wire handshake_occurred;
    assign handshake_occurred = axi_valid && axi_ready;

    // Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            handshake_count <= 32'd0;
        end else if (handshake_occurred) begin
            handshake_count <= handshake_count + 1'b1;
        end
    end

endmodule
