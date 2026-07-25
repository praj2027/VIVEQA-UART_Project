`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2026 17:36:52
// Design Name: 
// Module Name: uart_tx
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
// UART Transmitter with Parity
// Frame format: START(0) + 8 DATA bits (LSB first) + PARITY + STOP(1)
// =============================================================
// Simple UART Transmitter with parity bit
// Frame: START(0) + 8 data bits + PARITY + STOP(1)

module uart_tx #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 9600
)(
    input        clk,
    input        rst,
    input  [7:0] data_in,
    input        start,
    output reg   tx,
    output reg   busy
);

    localparam BIT_TIME = CLK_FREQ / BAUD_RATE;

    localparam IDLE   = 0,
               START   = 1,
               DATA    = 2,
               PARITY  = 3,
               STOP    = 4;

    reg [2:0] state = IDLE;
    reg [15:0] count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] data = 0;
    reg parity = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx    <= 1;
            busy  <= 0;
            count <= 0;
            bit_index <= 0;
        end else begin
            case (state)

                IDLE: begin
                    tx <= 1;
                    if (start) begin
                        data   <= data_in;
                        parity <= ^data_in;   // even parity
                        busy   <= 1;
                        count  <= 0;
                        state  <= START;
                    end
                end

                START: begin
                    tx <= 0;
                    if (count == BIT_TIME-1) begin
                        count <= 0;
                        state <= DATA;
                    end else
                        count <= count + 1;
                end

                DATA: begin
                    tx <= data[bit_index];
                    if (count == BIT_TIME-1) begin
                        count <= 0;
                        if (bit_index == 7) begin
                            bit_index <= 0;
                            state <= PARITY;
                        end else
                            bit_index <= bit_index + 1;
                    end else
                        count <= count + 1;
                end

                PARITY: begin
                    tx <= parity;
                    if (count == BIT_TIME-1) begin
                        count <= 0;
                        state <= STOP;
                    end else
                        count <= count + 1;
                end

                STOP: begin
                    tx <= 1;
                    if (count == BIT_TIME-1) begin
                        count <= 0;
                        busy  <= 0;
                        state <= IDLE;
                    end else
                        count <= count + 1;
                end

            endcase
        end
    end

endmodule
