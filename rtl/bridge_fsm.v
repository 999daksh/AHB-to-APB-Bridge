module bridge_fsm (
    input  HCLK,
    input  HRESETn,

    // Control Inputs
    input  trans_valid,
    input  PREADY,

    // Control Outputs
    output reg PSEL,
    output reg PENABLE,
    output reg HREADYOUT
);

    //--------------------------
    // State Encoding
    //--------------------------
    localparam IDLE   = 2'b00;
    localparam SETUP  = 2'b01;
    localparam ENABLE = 2'b10;

    reg [1:0] current_state;
    reg [1:0] next_state;

    //--------------------------
    // State Register
    //--------------------------
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    //--------------------------
    // Next-State Logic
    //--------------------------
    always @(*) begin

        next_state = current_state;

        case (current_state)

            IDLE: begin
                if (trans_valid)
                    next_state = SETUP;
            end

            SETUP: begin
                next_state = ENABLE;
            end

            ENABLE: begin
                if (PREADY)
                    next_state = IDLE;
                else
                    next_state = ENABLE;
            end

            default:
                next_state = IDLE;

        endcase

    end

    //--------------------------
    // Output Logic
    //--------------------------
    always @(*) begin

        // Default Outputs
        PSEL      = 1'b0;
        PENABLE   = 1'b0;
        HREADYOUT = 1'b1;

        case (current_state)

            IDLE: begin
                PSEL      = 1'b0;
                PENABLE   = 1'b0;
                HREADYOUT = 1'b1;
            end

            SETUP: begin
                PSEL      = 1'b1;
                PENABLE   = 1'b0;
                HREADYOUT = 1'b1;
            end

            ENABLE: begin
                PSEL    = 1'b1;
                PENABLE = 1'b1;

                if (PREADY)
                    HREADYOUT = 1'b1;
                else
                    HREADYOUT = 1'b0;
            end

            default: begin
                PSEL      = 1'b0;
                PENABLE   = 1'b0;
                HREADYOUT = 1'b1;
            end

        endcase

    end

endmodule

