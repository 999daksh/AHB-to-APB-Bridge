class ahb_transaction extends uvm_sequence_item;

    // AHB request
    rand bit [31:0] HADDR;
    rand bit        HWRITE;
    rand bit [31:0] HWDATA;
    rand bit [1:0]  HTRANS;
    rand bit [2:0]  HSIZE;

    // AHB read response
    bit [31:0]      HRDATA;

    constraint valid_transfer {
        HTRANS == 2'b10;
        HSIZE  == 3'b010;
    }

    `uvm_object_utils(ahb_transaction)

    function new(string name = "ahb_transaction");
        super.new(name);
    endfunction

endclass
