`timescale 1ns/1ps

module vending_machine_tb;

    reg clk;
    reg rst;
    reg [1:0] coin;
    wire dispense;
    wire change;

    vending_machine dut (
        .clk(clk),
        .rst(rst),
        .coin(coin),
        .dispense(dispense),
        .change(change)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, vending_machine_tb);
    end

    initial begin
        clk  = 1'b0;
        rst  = 1'b1;
        coin = 2'b00;

        // Reset
        #12;
        rst = 1'b0;

        // ------------------------------------
        // Test 1: 5 + 10 => dispense, no change
        // S0 -> S5 -> S15 -> S0
        // ------------------------------------
        #10 coin = 2'b01;   // insert 5
        #10 coin = 2'b10;   // insert 10
        #10 coin = 2'b00;   // no coin

        // ------------------------------------
        // Test 2: 10 + 10 => dispense, change
        // S0 -> S10 -> S15 -> S0
        // ------------------------------------
        #10 coin = 2'b10;   // insert 10
        #10 coin = 2'b10;   // insert 10
        #10 coin = 2'b00;   // no coin

        // ------------------------------------
        // Test 3: 5 + 5 + 5 => dispense, no change
        // S0 -> S5 -> S10 -> S15 -> S0
        // ------------------------------------
        #10 coin = 2'b01;
        #10 coin = 2'b01;
        #10 coin = 2'b01;
        #10 coin = 2'b00;

        // ------------------------------------
        // Test 4: idle / no input
        // ------------------------------------
        #20 coin = 2'b00;

        #40;
        $finish;
    end

    initial begin
        $monitor("T=%0t rst=%b coin=%b state=%b dispense=%b change=%b",
                 $time, rst, coin, dut.state, dispense, change);
    end

endmodule