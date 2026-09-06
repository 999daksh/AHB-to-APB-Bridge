module apb_master_if(

    input  [31:0] addr_reg,
    input  [31:0] data_reg,
    input         write_reg,

    input         PSEL_in,
    input         PENABLE_in,

    output [31:0] PADDR,
    output [31:0] PWDATA,
    output        PWRITE,

    output        PSEL,
    output        PENABLE

);

assign PADDR   = addr_reg;
assign PWDATA  = data_reg;
assign PWRITE  = write_reg;
assign PSEL    = PSEL_in;
assign PENABLE = PENABLE_in;

endmodule
