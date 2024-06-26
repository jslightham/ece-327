`timescale 1ns / 1ps

module hammingtb(
    );

    reg [11:0] code;
    wire [7:0] data;
    wire [3:0] syndrome;

    hamming h1 (.code(code), .data(data), .syndrome(syndrome));

    initial
    begin
        $monitor ($time, " ns code=%b, data=%b, syndrome=%b", code, data, syndrome);
            code = 12'b0011_0100_1111;
        #10 code = 12'b1011_0100_1111;
        #10 code = 12'b0111_0100_1111;
        #10 code = 12'b0001_0100_1111;
        #10 code = 12'b0010_0100_1111;
        #10 code = 12'b0011_1100_1111;
        #10 code = 12'b0011_0000_1111;
        #10 code = 12'b0011_0110_1111;
        #10 code = 12'b0011_0101_1111;
        #10 code = 12'b0011_0100_0111;
        #10 code = 12'b0011_0100_1011;
        #10 code = 12'b0011_0100_1101;
        #10 code = 12'b0011_0100_1110;

        #10 code = 12'b1111_0111_0111;
        #10 code = 12'b1111_0111_0110;
        #10 code = 12'b1111_0111_0101;
        #10 code = 12'b1111_0111_0011;
        #10 code = 12'b1111_0111_1111;
        #10 code = 12'b1111_0110_0111;
        #10 code = 12'b1111_0101_0111;
        #10 code = 12'b1111_0011_0111;
        #10 code = 12'b1111_1111_0111;
        #10 code = 12'b1110_0111_0111;
        #10 code = 12'b1101_0111_0111;
        #10 code = 12'b1011_0111_0111;
        #10 code = 12'b0111_0111_0111;

        #10 code = 12'b0000_0000_0000;
        #10 $finish;
    end


endmodule
