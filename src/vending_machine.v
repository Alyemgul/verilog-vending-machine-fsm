module vending_machine(
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] coin,      // 00=no coin, 01=5, 10=10
    output reg        dispense,
    output reg        change
);

    reg [1:0] state, next_state;
    reg overpaid, next_overpaid;

    parameter S0  = 2'b00;  // 0 inserted
    parameter S5  = 2'b01;  // 5 inserted
    parameter S10 = 2'b10;  // 10 inserted
    parameter S15 = 2'b11;  // dispense state

    // State and registered flag update
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= S0;
            overpaid  <= 1'b0;
        end else begin
            state     <= next_state;
            overpaid  <= next_overpaid;
        end
    end

    // Next-state logic and next_overpaid logic
    always @(*) begin
        next_state    = state;
        next_overpaid = overpaid;

        case (state)
            S0: begin
                next_overpaid = 1'b0;
                case (coin)
                    2'b01: next_state = S5;
                    2'b10: next_state = S10;
                    default: next_state = S0;
                endcase
            end

            S5: begin
                next_overpaid = 1'b0;
                case (coin)
                    2'b01: next_state = S10; // 5 + 5 = 10
                    2'b10: begin
                        next_state    = S15; // 5 + 10 = 15
                        next_overpaid = 1'b0;
                    end
                    default: next_state = S5;
                endcase
            end

            S10: begin
                case (coin)
                    2'b01: begin
                        next_state    = S15; // 10 + 5 = 15
                        next_overpaid = 1'b0;
                    end
                    2'b10: begin
                        next_state    = S15; // 10 + 10 = 20
                        next_overpaid = 1'b1; // return 5 as change
                    end
                    default: begin
                        next_state    = S10;
                        next_overpaid = 1'b0;
                    end
                endcase
            end

            S15: begin
                next_state    = S0;
                next_overpaid = 1'b0;
            end

            default: begin
                next_state    = S0;
                next_overpaid = 1'b0;
            end
        endcase
    end

    // Output logic
    // Moore-style: outputs depend on current registered state/flag
    always @(*) begin
        dispense = 1'b0;
        change   = 1'b0;

        if (state == S15) begin
            dispense = 1'b1;
            change   = overpaid;
        end
    end

endmodule