// THIS SCRIPTS CREATES AN FSM THAT CYCLES THROUGH HSV COLORS AT 60-DEGREE INCREMENTS ONCE PER SECOND.
// THE FSM AUTOMATICALLY STARTS WHEN LOADED ONTO THE FPGA, AND PRESSING THE SWITCH (`SW`) RESETS IT TO RED.
// THIS RESET THROUGH THE SWITCH IS NOT A CHIP RESET, BUT RATHER A SOFTWARE RESET. A CHIP RESET CAN BE 
// INITIALIZED THROUGH CLICKING THE SWITCH BUTTON ON THE FPGA.

module rgb_fsm #(
    parameter BLINK_INTERVAL = 2000000 // 2,000,000 cycles = 1/6 sec transition time
)(
    input logic clk,  // Fast FPGA Clock (12 MHz)
    input logic SW,   // Switch input to restart FSM
    output logic RGB_R, // Red LED control (mapped to PCF pin RGB_R)
    output logic RGB_G, // Green LED control (mapped to PCF pin RGB_G)
    output logic RGB_B  // Blue LED control (mapped to PCF pin RGB_B)
);

// Define the six HSV colors
typedef enum logic [2:0] { 
    RED     = 3'b100,  // R = 1, G = 0, B = 0
    YELLOW  = 3'b110,  // R = 1, G = 1, B = 0
    GREEN   = 3'b010,  // R = 0, G = 1, B = 0
    CYAN    = 3'b011,  // R = 0, G = 1, B = 1
    BLUE    = 3'b001,  // R = 0, G = 0, B = 1
    MAGENTA = 3'b101   // R = 1, G = 0, B = 1
} color_t;

color_t state; // FSM state
logic [31:0] counter; // Counter for timing FSM transitions

// Explicitly initialize the FSM state at power-up
initial begin
    state = RED;
    counter = 0;
end

// FSM State Transition Logic (Runs every BLINK_INTERVAL cycles)
always_ff @(posedge clk) begin
    if (!SW) begin  // Check `!SW` (active-low behavior)
        state <= RED; // Reset FSM to RED when switch is pressed
        counter <= 0; // Reset counter as well
    end else if (counter >= BLINK_INTERVAL) begin
        counter <= 0; // Reset counter after interval
        case (state) // Cycle through the colors
            RED:     state <= YELLOW;
            YELLOW:  state <= GREEN;
            GREEN:   state <= CYAN;
            CYAN:    state <= BLUE;
            BLUE:    state <= MAGENTA;
            MAGENTA: state <= RED;
            default: state <= RED; // Default case for safety
        endcase
    end else begin
        counter <= counter + 1; // Increment counter
    end
end

// Assign RGB output signals based on FSM state
always_comb begin
    {RGB_R, RGB_G, RGB_B} = state; // Map state directly to RGB signals
end

endmodule  // Ends rgb_fsm module
