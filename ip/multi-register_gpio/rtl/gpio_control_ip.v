`timescale 1ns / 1ps

module gpio_control_ip #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 32,
    parameter GPIO_WIDTH = 4
)(
    input                       clk,
    input                       resetn,
    // Bus Interface
    input                       i_sel,      // Chip Select
    input                       i_we,       // Write Enable
    input      [ADDR_WIDTH-1:0] i_addr,     // Address Offset
    input      [DATA_WIDTH-1:0] i_wdata,    // Data from CPU
    output reg [DATA_WIDTH-1:0] o_rdata,    // Data to CPU (Readback)
    // External Interface
    inout      [GPIO_WIDTH-1:0] gpio_pins   // Bidirectional GPIO pins
);

    // Register Map Offsets
    localparam DATA = 4'h0;
    localparam DIR  = 4'h4;
    localparam READ = 4'h8;

    // Registers
    reg [GPIO_WIDTH-1:0] gpio_data;
    reg [GPIO_WIDTH-1:0] gpio_dir;
    
    // --- Write Logic ---
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            gpio_data <= 0;
            gpio_dir  <= 0;
        end else if (i_sel && i_we) begin
                case (i_addr)
                    DATA: gpio_data <= i_wdata[GPIO_WIDTH-1:0];
                    DIR : gpio_dir  <= i_wdata[GPIO_WIDTH-1:0];
                endcase
        end
    end

    // --- Read Logic ---
    always @(*) begin
        if (i_sel && !i_we) begin
            case (i_addr)
                DATA   : o_rdata = gpio_data;                                    // Read data
                DIR    : o_rdata = gpio_dir;                                     // Read direction
                READ   : o_rdata = {{(DATA_WIDTH-GPIO_WIDTH){1'b0}}, gpio_pins}; // Read actual pin state
                default: o_rdata = 0;
            endcase
        end
    end

    // --- Output Tri-state Logic ---
    // 1 (Output mode), 0 (Input mode)
    genvar i;
    generate
        for (i = 0; i < GPIO_WIDTH; i = i + 1) begin: gpio_ctrl
            assign gpio_pins[i] = gpio_dir[i] ? gpio_data[i] : 1'bz;
        end
    endgenerate
    
endmodule
