module tb;
 
  initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end

  
  
    //==================================================
    // Clock
    //==================================================

    logic clk;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    //==================================================
    // Interfaces
    //==================================================

    ahb_if ahb_vif(clk);
    apb_if apb_vif(clk);


    //==================================================
    // DUT
    //==================================================

    bridge_top dut (

        // AHB inputs
        .HCLK      (clk),
        .HRESETn   (ahb_vif.HRESETn),
        .HSEL      (ahb_vif.HSEL),
        .HADDR     (ahb_vif.HADDR),
        .HWRITE    (ahb_vif.HWRITE),
        .HWDATA    (ahb_vif.HWDATA),
        .HTRANS    (ahb_vif.HTRANS),
        .HSIZE     (ahb_vif.HSIZE),
        .HBURST    (ahb_vif.HBURST),
        .HREADY    (ahb_vif.HREADY),

        // APB inputs
        .PREADY    (apb_vif.PREADY),
        .PRDATA    (apb_vif.PRDATA),

        // APB outputs
        .PADDR     (apb_vif.PADDR),
        .PWDATA    (apb_vif.PWDATA),
        .PWRITE    (apb_vif.PWRITE),
        .PSEL      (apb_vif.PSEL),
        .PENABLE   (apb_vif.PENABLE),

        // AHB outputs
        .HRDATA    (ahb_vif.HRDATA),
        .HREADYOUT (ahb_vif.HREADYOUT)

    );
    

    //==================================================
    // Reset and initial values
    //==================================================

    initial begin

        ahb_vif.HRESETn = 1'b0;

        ahb_vif.HSEL    = 1'b0;
        ahb_vif.HADDR   = '0;
        ahb_vif.HWRITE  = 1'b0;
        ahb_vif.HWDATA  = '0;
        ahb_vif.HTRANS  = 2'b00;
        ahb_vif.HSIZE   = 3'b010;
        ahb_vif.HBURST  = 3'b000;
        ahb_vif.HREADY = 1'b1;

        apb_vif.PRESETn = 1'b0;

        #20;

        ahb_vif.HRESETn = 1'b1;
        apb_vif.PRESETn = 1'b1;

    end
     

    //==================================================
    // UVM Configuration
    //==================================================

    initial begin

        // AHB virtual interface
        uvm_config_db #(virtual ahb_if)::set(
            null,
            "*",
            "vif",
            ahb_vif
        );


        // APB virtual interface
        uvm_config_db #(virtual apb_if)::set(
            null,
            "*",
            "apb_vif",
            apb_vif
        );


        // Start UVM
        run_test("bridge_test");

    end

endmodule 
