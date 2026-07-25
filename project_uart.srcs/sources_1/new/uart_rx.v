`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2026 17:39:14
// Design Name: 
// Module Name: uart_rx
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
// UART Receiver with Parity Checking
// Frame format: START(0) + 8 DATA bits (LSB first) + PARITY + STOP(1)
// =============================================================
// Simple UART Receiver with parity check
// Frame: START(0) + 8 data bits + PARITY + STOP(1)

module uart_rx #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 9600
)(
    input        clk,
    input        rst,
    input        rx,
    output reg [7:0] data_out,
    output reg   done,
    output reg   parity_err
);

    localparam BIT_TIME  = CLK_FREQ / BAUD_RATE;
    localparam HALF_BIT   = BIT_TIME / 2;

    localparam IDLE   = 0,
               START   = 1,
               DATA    = 2,
               PARITY  = 3,
               STOP    = 4;

    reg [2:0] state = IDLE;
    reg [15:0] count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] data = 0;
    reg rx_parity = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done  <= 0;
            count <= 0;
            bit_index <= 0;
        end else begin
            done <= 0;

            case (state)

                IDLE: begin
                    if (rx == 0) begin      // start bit detected
                        count <= 0;
                        state <= START;
                    end
                end

                START: begin
                    if (count == HALF_BIT-1) begin  // confirm mid-way through start bit
                        count <= 0;
                        state <= DATA;
                    end else
                        count <= count + 1;
                end

                DATA: begin
                    if (count == BIT_TIME-1) begin
                        count <= 0;
                        data[bit_index] <= rx;
                        if (bit_index == 7) begin
                            bit_index <= 0;
                            state <= PARITY;
                        end else
                            bit_index <= bit_index + 1;
                    end else
                        count <= count + 1;
                end

                PARITY: begin
                    if (count == BIT_TIME-1) begin
                        count <= 0;
                        rx_parity <= rx;
                        state <= STOP;
                    end else
                        count <= count + 1;
                end

                STOP: begin
                    if (count == BIT_TIME-1) begin
                        data_out   <= data;
                        parity_err <= (rx_parity != ^data);
                        done       <= 1;
                        state      <= IDLE;
                    end else
                        count <= count + 1;
                end

            endcase
        end
    end

endmodule
