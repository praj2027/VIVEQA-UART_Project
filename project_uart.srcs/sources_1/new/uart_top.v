`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2026 17:40:03
// Design Name: 
// Module Name: uart_top
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
// UART Top Module
// Instantiates a full-duplex UART (TX + RX) with parity.
// =============================================================
// Simple UART top module - connects TX and RX

module uart_top #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 9600
)(
    input        clk,
    input        rst,

    // TX side
    input  [7:0] data_in,
    input        start,
    output       tx,
    output       busy,

    // RX side
    input        rx,
    output [7:0] data_out,
    output       done,
    output       parity_err
);

    uart_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) TX (
        .clk     (clk),
        .rst     (rst),
        .data_in (data_in),
        .start   (start),
        .tx      (tx),
        .busy    (busy)
    );

    uart_rx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) RX (
        .clk        (clk),
        .rst        (rst),
        .rx         (rx),
        .data_out   (data_out),
        .done       (done),
        .parity_err (parity_err)
    );

endmodule
