// Built and tested with Icarus Verilog

module SE #(
    parameter [7:0] DATAWIDTH = 8,
    parameter [7:0] ARRAYLENGTH = 10
)
(
    input clk,
    input [(DATAWIDTH * ARRAYLENGTH) - 1 : 0] array_in,
    input valid_in,
    output [(DATAWIDTH * ARRAYLENGTH) - 1 : 0] array_out,
    output valid_out
);
    parameter EVEN_ARR_LEN = ARRAYLENGTH % 2 == 0;

    reg [DATAWIDTH - 1: 0] r [0 : ARRAYLENGTH - 1]; // Registers for use between stages

    wire [DATAWIDTH - 1: 0] input_array [0 : ARRAYLENGTH - 1]; // Input represented as array of vectors
    wire [DATAWIDTH - 1 : 0] even_cas_out [0 : ARRAYLENGTH - 1]; // compare and swap output 1 array
    wire [DATAWIDTH - 1 : 0] odd_cas_out [0 : ARRAYLENGTH - 1]; // compare and swap output 2 array

    reg output_valid = 1'b0;
    integer counter = 0; // Handles state of the sorting module

    always@(posedge clk)
    begin
        if (0 == counter) begin // Stage for when sorter has not been given any valid data.
            output_valid <= 0;
            if (1 == valid_in) begin
                // Clock the inputs if we have valid data.
                for (integer i = 0; i < ARRAYLENGTH; i = i + 1) begin
                    r[i] <= input_array[i];
                end
                counter <= 1; // Move to next stage.
            end
        end
        else if (1 == valid_in) begin
            counter <= 0;
        end
        else begin
            // Clock the output from even stage at end of each cycle
            for (integer i = 0; i < ARRAYLENGTH; i = i + 1) begin
                r[i] <= even_cas_out[i];
            end

            // Reset state and indicate that output is valid
            if (((ARRAYLENGTH + 1) / 2) == counter) begin
                counter <= 0;
                output_valid <= 1;
            end
            else
                counter <= counter + 1; // Need more clock cycles to sort
        end
    end

    // Generate odd stage compare and swap elements
    genvar odd;
    generate
        // Odd length arrays pass first element through odd CAS stage
        if (!EVEN_ARR_LEN) assign odd_cas_out[0] = r[0];

        for (odd = EVEN_ARR_LEN ? 0 : 1; odd < ARRAYLENGTH - 1; odd = odd + 2) begin : g_odd
            compare_and_swap #(.SIZE(DATAWIDTH)) u1 (.i1(r[odd]), .i2(r[odd + 1]),
                .o1(odd_cas_out[odd]), .o2(odd_cas_out[odd + 1]));
        end
    endgenerate

    // Generate even stage compare and swap elements
    genvar even;
    generate
        // Even length arrays pass first element through even CAS stage
        if (EVEN_ARR_LEN) assign even_cas_out[0] = odd_cas_out[0];

        // Last element always passed directly through even CAS stage
        assign even_cas_out[ARRAYLENGTH - 1] = odd_cas_out[ARRAYLENGTH - 1];

        for (even = EVEN_ARR_LEN ? 1 : 0; even < ARRAYLENGTH - 2; even = even + 2)
            begin : g_even
                compare_and_swap #(.SIZE(DATAWIDTH)) u1 (.i1(odd_cas_out[even]),
                    .i2(odd_cas_out[even + 1]), .o1(even_cas_out[even]), .o2(even_cas_out[even + 1]));
            end
    endgenerate

    // Get an array of vectors out of the large input vector
    genvar i;
    generate
        for (i = 0; i < ARRAYLENGTH; i = i + 1)
            begin : g1
                assign input_array[i] = array_in[(i * DATAWIDTH) + DATAWIDTH - 1 : i * DATAWIDTH];
                assign array_out[(i * DATAWIDTH) + DATAWIDTH - 1 : i * DATAWIDTH] = r[i];
            end
    endgenerate

    assign valid_out = output_valid;
endmodule

// Module to implement compare and swap behaviour
module compare_and_swap #(
    parameter [7:0] SIZE = 8
)
(
    input [SIZE - 1 : 0] i1,
    input [SIZE - 1 : 0] i2,
    output [SIZE - 1: 0] o1,
    output [SIZE - 1: 0] o2
);
    assign o1 = i1 > i2 ? i1 : i2;
    assign o2 = i1 > i2 ? i2 : i1;
endmodule
