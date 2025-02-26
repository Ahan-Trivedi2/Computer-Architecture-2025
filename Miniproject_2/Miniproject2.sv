module miniproject_2 #( // Create parameterized miniproject_2 module
    parameter CLK_FREQUENCY = 12000000, // Clock Signal Frequency (12MHz) of our FPGA Board
    parameter STEP_INTERVAL = CLK_FREQUENCY / 360 // Every 1/360th of a second, we change the hue by 1 degree (33,333 cycles)
)(
    input logic clk, // Clock input 
    output logic RGB_R, // Red LED Output
    output logic RGB_B, // Blue LED Output
    output logic RGB_G // Green LED Output
);
    // Register Initialization
    logic [15:0] clock_counter; // Counter for hue transition (every 33,333 clock cycles), 16 bits
    logic [8:0] hue_angle; // 9 bits of storage for 0-359 degrees of possible hue colors
    logic [7:0] duty_R; // 8 bits to store PWM duty cycle for the Red LED (0-255)
    logic [7:0] duty_B; // 8 bits to store PWM duty cycle for the Blue LED (0-255)
    logic [7:0] duty_G; // 8 bits to store PWM duty cycle for the Green LED (0-255)
    logic [7:0] pwm_counter; // 8 bit counter to allow color changes to occur smoothly and not rapidly.
    // Initialize values to the variables stored in register
    initial begin
        pwm_counter = 0; // pwm_counter set to 0
        hue_angle = 0; // Make hue_angle start at begining of hsv color wheel
        clock_counter = 0; // Clock_counter should start at 0
    end
    // Logic to handle transitions around hue color wheel
    always_ff @(posedge clk) begin // We use always_ff since we are updating values stored in registers (made of flip flops)
        if (clock_counter >= STEP_INTERVAL) begin // If are ready to change our hsv color by 1 degree
            clock_counter <= 0; // Set our clock_counter back to 0 using non-blocking assignment
            hue_angle <= (hue_angle == 359) ? 0 : hue_angle + 1; // If hue_angle is 359 set it back to 0, else set it to the next degree
        end else begin // If we are not ready to change our hsv color by 1 degree
            clock_counter <= clock_counter + 1; // Increase the clock counter by 1
        end // End of else statement
    end // End of always_ff block
    // Compute RGB intensity values based on hue color wheel
    always_comb begin // Combinatorial logic block since clock is not important
        case (hue_angle / 60) // Divides the hsv color wheel into 6 segments
            0: begin duty_R = 255; duty_G = (hue_angle % 60) * 255 / 60; duty_B = 0; end // Goes through the first sixth of the hsv color wheel 
            1: begin duty_R = (60 - (hue_angle % 60)) * 255 / 60; duty_G = 255; duty_B = 0; end // Goes through the second sixth of the hsv color wheel
            2: begin duty_R = 0; duty_G = 255; duty_B = (hue_angle % 60) * 255 / 60; end // Goes through the third sixth of the hsv color wheel 
            3: begin duty_R = 0; duty_G = (60 - (hue_angle % 60)) * 255 / 60; duty_B = 255; end // Goes through the fourth sixth of the hsv color wheel
            4: begin duty_R = (hue_angle % 60) * 255 / 60; duty_G = 0; duty_B = 255; end // Goes through the fifth sixth of the hsv color wheel
            5: begin duty_R = 255; duty_G = 0; duty_B = (60 - (hue_angle % 60)) * 255 / 60; end // Goes through the sixth sixth of the hsv color wheel
            default: begin duty_R = 0; duty_G = 0; duty_B = 0; end // Safety mechanism to prevent undefined behavior
        endcase
    end
    // Logic to increment PWM counter
    always_ff @(posedge clk) begin // Use always_ff since updating a value stored in a register.
        pwm_counter <= pwm_counter + 1; // Increment pwm counter using non-blocking assignment
    end
    // FPGA PWM Outputs
    assign RGB_R = (pwm_counter < duty_R); // PWM Red
    assign RGB_G = (pwm_counter < duty_G); // PWM Green
    assign RGB_B = (pwm_counter < duty_B); // PWM Blue
endmodule