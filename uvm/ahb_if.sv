`include "uvm_macros.svh"
import uvm_pkg::*;


interface ahb_if(input logic HCLK);

    logic        HRESETn;
    logic        HSEL;
    logic [31:0] HADDR;
    logic        HWRITE;
    logic [31:0] HWDATA;
    logic [1:0]  HTRANS;
    logic [2:0]  HSIZE;
    logic [2:0]  HBURST;
    logic        HREADY;

    logic [31:0] HRDATA;
    logic        HREADYOUT;

endinterface
