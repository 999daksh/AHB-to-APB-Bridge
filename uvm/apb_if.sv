interface apb_if(input logic PCLK);

    logic        PRESETn;
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PSEL;
    logic        PENABLE;

    logic        PREADY;
    logic [31:0] PRDATA;

endinterface
