module bridge_top (

    //==========================
    // AHB Interface
    //==========================
    input         HCLK,
    input         HRESETn,
    input         HSEL,
    input  [31:0] HADDR,
    input         HWRITE,
    input  [31:0] HWDATA,
    input  [1:0]  HTRANS,
    input  [2:0]  HSIZE,
    input  [2:0]  HBURST,
    input         HREADY,

    //==========================
    // APB Slave Interface
    //==========================
    input         PREADY,
    input  [31:0] PRDATA,

    //==========================
    // APB Outputs
    //==========================
    output [31:0] PADDR,
    output [31:0] PWDATA,
    output        PWRITE,
    output        PSEL,
    output        PENABLE,

    //==========================
    // AHB Outputs
    //==========================
    output [31:0] HRDATA,
    output        HREADYOUT
);

    //==========================
    // Internal Signals
    //==========================
    wire [31:0] addr_reg;
    wire [31:0] data_reg;
    wire        write_reg;
    wire [2:0]  size_reg;
    wire        trans_valid;

    wire PSEL_internal;
    wire PENABLE_internal;

    //==========================
    // AHB Slave Interface
    //==========================
    ahb_slave_if ahb_inst1 (

        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HSEL(HSEL),
        .HADDR(HADDR),
        .HWRITE(HWRITE),
        .HWDATA(HWDATA),
        .HTRANS(HTRANS),
        .HSIZE(HSIZE),
        .HBURST(HBURST),
        .HREADY(HREADY),

        .addr_reg(addr_reg),
        .data_reg(data_reg),
        .write_reg(write_reg),
        .size_reg(size_reg),
        .trans_valid(trans_valid)

    );

    //==========================
    // Bridge FSM
    //==========================
    bridge_fsm bridge_fsm_inst1 (

        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .trans_valid(trans_valid),
        .PREADY(PREADY),

        .PSEL(PSEL_internal),
        .PENABLE(PENABLE_internal),
        .HREADYOUT(HREADYOUT)

    );

    //==========================
    // APB Master Interface
    //==========================
    apb_master_if apb_inst1 (

        .addr_reg(addr_reg),
        .data_reg(data_reg),
        .write_reg(write_reg),

        .PSEL_in(PSEL_internal),
        .PENABLE_in(PENABLE_internal),

        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE)

    );

    //==========================
    // Read Data Path
    //==========================
    assign HRDATA = PRDATA;

endmodule
