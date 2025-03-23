// Miniproject 3: Sine Wave Generator Using Quarter-Wave ROM and DAC Output
module mp3(
    input logic clk, // iceblinkpico fpga clock input
    output logic _9b, // DAC bit 0 (LSB)
    output logic _6a, // DAC bit 1
    output logic _4a, // DAC bit 2
    output logic _2a, // DAC bit 3
    output logic _0a, // DAC bit 4
    output logic _5a, // DAC bit 5
    output logic _3b, // DAC bit 6
    output logic _49a, // DAC bit 7
    output logic _45a, // DAC bit 8
    output logic _48b  // DAC bit 9 (MSB)
);

// 9-bit counter that goes from 0 to 511 (512 samples per sine wave cycle)
logic [8:0] sample_index = 0;
// ROM-based lookup table (LUT) with 128 precomputed 10-bit values for quarter sine wave
logic [9:0] quarter_sine_waveform_values [0:127];
// Final 10-bit value to be sent to the DAC each clock cycle
logic [9:0] dac_output;

// Load quarter-wave sine values from 'quarter_waveform.txt' into ROM LUT at start
initial begin
    $readmemh("quarter_waveform.txt", quarter_sine_waveform_values);
end 

// Increment a sample counter on rising edge of the clock, reset back to zero when counter reaches 511 (one full sin wave period)
always_ff @(posedge clk) begin
    if (sample_index == 511)
        sample_index <= 0;
    else begin
        sample_index++;
    end
end

// Symmetry logic to reconstruct full sine wave from quarter waveform
always_comb begin
    if (sample_index < 128) begin
        // Q1: use LUT as is (0 to pi/2)
        dac_output = quarter_sine_waveform_values[sample_index];
    end else if (sample_index < 256) begin
        // Q2: Mirror LUT index (pi/2 to pi)
        dac_output = quarter_sine_waveform_values[127 - (sample_index - 128)];
    end else if (sample_index < 384) begin
        // Q3: Invert LUT values (pi to 3pi/2)
        dac_output = 1023 - quarter_sine_waveform_values[sample_index-256];
    end else begin
        // Q4: Mirror then Invert LUT (3pi/2 to 2pi)
        dac_output = 1023 - quarter_sine_waveform_values[127 - (sample_index - 384)];
    end
end

// Assign each bit of the 10-bit DAC output value to its respective FPGA pin
assign {_48b, _45a, _49a, _3b, _5a, _0a, _2a, _4a, _6a, _9b} = dac_output;

endmodule

