
// Built and tested with icarus verilog

module PD(
    input clk,
    input reset,
    input enable,
    input [3:0] din,
    output pattern1,
    output pattern2
);

    reg _pattern1 = 0, _pattern2 = 0;

    reg [3:0] state = 4'b0000;

    parameter Idle=4'b0000, ZeroPressed=4'b1111, Pat1_05=4'b0001, Pat1_053=4'b0010,
        Pat1_0531=4'b0100, Pat2_06=4'b1110, Pat2_061=4'b1101, Pat2_0619=4'b1011;

    // Output based on the current state. Updates outputs immediatley when state changes.
    always@(state)
    begin
        case (state)
            Pat1_0531: begin
                _pattern1 <= 1;
                _pattern2 <= 0;
            end
            Pat2_0619: begin
                _pattern1 <= 0;
                _pattern2 <= 1;
            end
            default: begin
                _pattern1 <= 0;
                _pattern2 <= 0;
            end
        endcase
    end

    // Set the state based on inputs
    always@(posedge clk or posedge reset)
    begin
        if (reset)
            state <= Idle; // Revert to no keys pressed when reset.
        if(enable) begin // Only register a new keypress on clock edges and when enabled
            case(state)
                Idle:
                    if (din == 0)
                        state <= ZeroPressed;
                ZeroPressed:
                    if (din == 5)
                        state <= Pat1_05;
                    else if (din == 6)
                        state <= Pat2_06;
                    else if (din == 0)
                        state <= ZeroPressed;
                    else
                        state <= Idle;
                Pat1_05:
                    if (din == 3)
                        state <= Pat1_053;
                    else if (din == 0)
                        state <= ZeroPressed;
                    else
                        state <= Idle;
                Pat1_053:
                    if (din == 1)
                        state <= Pat1_0531;
                    else if (din == 0)
                        state <= ZeroPressed;
                    else
                        state <= Idle;
                Pat1_0531: // Correct code for pattern 1
                    if (din == 0)
                        state <= ZeroPressed;
                    else
                        state <= Idle;
                Pat2_06:
                    if (din == 1)
                        state <= Pat2_061;
                    else if (din == 0)
                        state <= ZeroPressed;
                    else
                        state <= Idle;
                Pat2_061:
                    if (din == 9)
                        state <= Pat2_0619;
                    else if (din == 0)
                        state <= ZeroPressed;
                    else
                        state <= Idle;
                Pat2_0619: // Correct code for pattern 2
                    if (din == 0)
                        state <= ZeroPressed;
                    else
                        state <= Idle;
                default:
                    state <= Idle;
            endcase
        end
    end

    // Drive wire outputs with internal registers holding output for state
    assign pattern1 = _pattern1;
    assign pattern2 = _pattern2;

endmodule