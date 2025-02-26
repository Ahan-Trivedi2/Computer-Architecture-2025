`timescale 1ns/1ns // We are simulating at 1ns intervals
`include "Miniproject2.sv" // Include main project file (Miniproject2.sv) so test bench can instantiate and test

module miniproject_2_tb; // Define a test bench module
    // Declare test bench signals (not inputs/outputs, just logic)
    logic clk = 0; // Logic signal used to simulate the clock for Miniproject2.sv
    logic RGB_R, RGB_G, RGB_B; // Logic signals that store RGB output from Miniproject2.sv
    // Instatiate the miniproject_2 module from the main file and connect test bench signals
    miniproject_2 uut ( // 'uut' = Unit Under Test
        .clk(clk), // Connect test bench clock to module input
        .RGB_R(RGB_R), // Recieve red output
        .RGB_G(RGB_G), // Recieve green output
        .RGB_B(RGB_B) // Recieve blue output
    );
    // Generate vcd file for visualiztion in GTKWave
    initial begin // Intial block which runs once at the start of simulation
        $dumpfile("Miniproject2_tb.vcd"); // Store signal transitions for later waveform analysis
        $dumpvars(1, uut); // Records changes in uut's signals
        #1000000000; // Tells the simulator to wait for 1 second
        $finish; // Tells the simulator to finish 
    end
    always begin // Initiate the clock
        #41.6667 clk = ~clk; // ~12 MHz half-period
    end // End
endmodule