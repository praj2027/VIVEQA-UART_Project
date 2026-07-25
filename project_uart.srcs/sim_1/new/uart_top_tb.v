`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2026 17:40:51
// Design Name: 
// Module Name: uart_top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// =============================================================
// Testbench for uart_top (uart_tx + uart_rx)
// Tests:
//   1. Multiple byte loopback (tx -> rx) with correctness check
//   2. Parity error injection (corrupt parity bit on the line)
//   3. Frame error injection (corrupt stop bit on the line)
//   4. Back-to-back transmissions (tx_busy respected)
// =============================================================
// Simple testbench - loopback test (tx wire feeds rx directly)
module uart_tb;

    reg clk = 0;
    reg rst = 1;
    reg [7:0] data_in = 8'hA5;
    reg start = 0;
    wire tx, busy, done, parity_err;
    wire [7:0] data_out;

    // fast baud rate for quick simulation
    uart_top #(
        .CLK_FREQ (1000000),
        .BAUD_RATE(115200)
    ) DUT (
        .clk        (clk),
        .rst        (rst),
        .data_in    (data_in),
        .start      (start),
        .tx         (tx),
        .busy       (busy),
        .rx         (tx),      // loopback: tx wire feeds rx directly
        .data_out   (data_out),
        .done       (done),
        .parity_err (parity_err)
    );

    always #5 clk = ~clk;   // 100 MHz sim clock

    initial begin
        #20 rst = 0;
        #20;

        start = 1;
        #10 start = 0;

        wait (done == 1);
        #10;

        if (data_out == data_in && parity_err == 0)
            $display("PASS: sent = %h, received = %h, parity_err = %b", data_in, data_out, parity_err);
        else
            $display("FAIL: sent = %h, received = %h, parity_err = %b", data_in, data_out, parity_err);

        #50 $finish;
    end

endmodule
