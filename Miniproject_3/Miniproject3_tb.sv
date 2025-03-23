// Used the same test bench provided

`timescale 10ns/10ns
`include "Miniproject3.sv"

module sine_waveform_test_bench;

    logic clk = 0;
    logic _9b, _6a, _4a, _2a, _0a, _5a, _3b, _49a, _45a, _48b;

    mp3 u0 (
        .clk    (clk), 
        ._9b    (_9b), 
        ._6a    (_6a), 
        ._4a    (_4a), 
        ._2a    (_2a), 
        ._0a    (_0a), 
        ._5a    (_5a), 
        ._3b    (_3b), 
        ._49a   (_49a), 
        ._45a   (_45a), 
        ._48b   (_48b)
    );

    initial begin
        $dumpfile("Miniproject3.vcd");
        $dumpvars(0, sine_waveform_test_bench);
        #10000;
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule
