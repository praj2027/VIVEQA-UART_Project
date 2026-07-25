# UART TX/RX with Parity (Verilog)

A simple, synthesizable UART (Universal Asynchronous Receiver/Transmitter) implementation in Verilog, featuring configurable baud rate and even-parity error checking. Includes a self-checking testbench for loopback simulation.

## Features

- Standard asynchronous serial frame: **1 start bit + 8 data bits + 1 parity bit + 1 stop bit**
- Even parity generation (TX) and checking (RX)
- Configurable clock frequency and baud rate via module parameters
- Simple FSM-based design, easy to read and modify
- Includes a loopback testbench for quick simulation and verification

## Frame Format

```
 ______                                                   ______
|      |     |     |     |     |     |     |     |     |     |     |      |
| IDLE | STRT| D0  | D1  | D2  | D3  | D4  | D5  | D6  | D7  | PAR | STOP |
|______|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|______|
   1        0    LSB ------ 8 data bits ------ MSB     P      1
```

- **Start bit:** always `0`
- **Data bits:** 8 bits, transmitted LSB first
- **Parity bit:** even parity, computed as XOR of all data bits
- **Stop bit:** always `1`

## Project Structure

```
.
├── uart_tx.v    # UART transmitter module
├── uart_rx.v    # UART receiver module
├── uart_top.v   # Top module (connects TX + RX)
├── uart_tb.v    # Self-checking loopback testbench
└── README.md
```

## Module Overview

### `uart_tx` 

| Port       | Direction | Width | Description                          |
|------------|-----------|-------|---------------------------------------|
| `clk`      | input     | 1     | System clock                          |
| `rst`      | input     | 1     | Synchronous reset (active high)       |
| `data_in`  | input     | 8     | Byte to transmit                      |
| `start`    | input     | 1     | Pulse high for 1 clock to start a send|
| `tx`       | output    | 1     | Serial output line                    |
| `busy`     | output    | 1     | High while a transmission is active   |

**Parameters:** `CLK_FREQ` (default `50_000_000`), `BAUD_RATE` (default `9600`)

### `uart_rx` 

| Port         | Direction | Width | Description                        |
|--------------|-----------|-------|-------------------------------------|
| `clk`        | input     | 1     | System clock                        |
| `rst`        | input     | 1     | Synchronous reset (active high)     |
| `rx`         | input     | 1     | Serial input line                   |
| `data_out`   | output    | 8     | Received byte                       |
| `done`       | output    | 1     | Pulses high for 1 clock when a byte has been received |
| `parity_err` | output    | 1     | High if the received parity bit doesn't match the computed parity (valid when `done` pulses) |

**Parameters:** `CLK_FREQ` (default `50_000_000`), `BAUD_RATE` (default `9600`)

### `uart_top` (uart_top_simple.v)

Instantiates `uart_tx` and `uart_rx` and exposes both sides for full-duplex use — connect `tx`/`rx` to your board's physical UART pins.

## Simulation

The testbench (`uart_tb.v`) loops the `tx` output directly back into `rx`, sends the byte `0xA5`, and checks that the received byte and parity match.

Using [Icarus Verilog](http://iverilog.icarus.com/):

```bash
iverilog -o sim uart_tb_simple.v uart_top_simple.v uart_tx_simple.v uart_rx_simple.v
vvp sim
```

Expected output:

```
PASS: sent = a5, received = a5, parity_err = 0
```

You can view waveforms by adding `$dumpfile`/`$dumpvars` to the testbench and opening the resulting `.vcd` in a viewer such as GTKWave.

## Usage in Your Design

```verilog
uart_top #(
    .CLK_FREQ  (50_000_000),   // your system clock
    .BAUD_RATE (9600)          // desired baud rate
) uart_inst (
    .clk        (clk),
    .rst        (rst),
    .data_in    (tx_byte),
    .start      (tx_start),
    .tx         (uart_tx_pin),
    .busy       (tx_busy),
    .rx         (uart_rx_pin),
    .data_out   (rx_byte),
    .done       (rx_done),
    .parity_err (rx_parity_err)
);
```



## License

MIT — feel free to use and modify.
