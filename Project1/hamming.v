`timescale 1ns / 1ps

module hamming(
    input [11:0] code,
    output [7:0] data,
    output [3:0] syndrome
);
    reg [3:0] rec_check, calc_check;
    reg [11:0] corrected_code;

    always @* begin
        rec_check = { code[7], code[3], code[1], code[0] };

        calc_check[0] = code[2] ^ code[4] ^ code[6] ^ code[8] ^ code[10];
        calc_check[1] = code[2] ^ code[5] ^ code[6] ^ code[9] ^ code[10];
        calc_check[2] = code[4] ^ code[5] ^ code[6] ^ code[11];
        calc_check[3] = code[8] ^ code[9] ^ code[10] ^ code[11];
    end

    always@* begin
        corrected_code = code;
        if (syndrome > 0)
            corrected_code[syndrome - 1] = ~corrected_code[syndrome - 1];

    end

    assign syndrome = calc_check ^ rec_check;
    assign data = { corrected_code[11], corrected_code[10], corrected_code[9], corrected_code[8],
        corrected_code[6], corrected_code[5], corrected_code[4], corrected_code[2] };

endmodule
