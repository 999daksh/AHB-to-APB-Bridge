module ahb_slave_if (
    input         HCLK,
    input         HRESETn,

    //==========================
    // AHB-Lite Interface
    //==========================
    input         HSEL,
    input  [31:0] HADDR,
    input         HWRITE,
    input  [31:0] HWDATA,
    input  [1:0]  HTRANS,
    input  [2:0]  HSIZE,
    input  [2:0]  HBURST,   // Reserved for future burst support
    input         HREADY,

    //==========================
    // Latched Transaction Outputs
    //==========================
    output reg [31:0] addr_reg,
    output reg [31:0] data_reg,
    output reg        write_reg,
    output reg [2:0]  size_reg,
    output reg        trans_valid
);

    // Valid AHB transaction:
    // HSEL      = Slave selected
    // HREADY    = Previous transfer completed
    // HTRANS[1] = NONSEQ or SEQ transfer
    wire ahb_valid;

    assign ahb_valid = HSEL && HREADY && HTRANS[1];

    //--------------------------
    // Capture AHB Transaction
    //--------------------------
    always @(posedge HCLK or negedge HRESETn) begin

        if (!HRESETn) begin
            addr_reg    <= 32'd0;
            data_reg    <= 32'd0;
            write_reg   <= 1'b0;
            size_reg    <= 3'd0;
            trans_valid <= 1'b0;
        end

        else if (ahb_valid) begin
            addr_reg    <= HADDR;
            data_reg    <= HWDATA;
            write_reg   <= HWRITE;
            size_reg    <= HSIZE;
            trans_valid <= 1'b1;
        end

        else begin
            // Keep previously captured transaction
            // Generate a one-cycle trans_valid pulse
            trans_valid <= 1'b0;
        end

    end

endmodule
