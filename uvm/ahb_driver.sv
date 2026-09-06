class ahb_driver extends uvm_driver #(ahb_transaction);

    `uvm_component_utils(ahb_driver)

    virtual ahb_if vif;

    function new(string name = "ahb_driver",
                 uvm_component parent);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db #(virtual ahb_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("NOVIF", "AHB virtual interface not found")

    endfunction
   task run_phase(uvm_phase phase);

    ahb_transaction tr;

    forever begin

        seq_item_port.get_next_item(tr);

        // Drive transaction before the active clock edge
        @(negedge vif.HCLK);

        vif.HSEL   <= 1'b1;
        vif.HADDR  <= tr.HADDR;
        vif.HWRITE <= tr.HWRITE;
        vif.HWDATA <= tr.HWDATA;
        vif.HTRANS <= tr.HTRANS;
        vif.HSIZE  <= tr.HSIZE;

        // Wait until the bridge accepts the transaction
        // and enters its busy state.
        @(posedge vif.HCLK);

        wait (vif.HREADYOUT === 1'b0);

        // Wait until the APB transaction has completed.
        wait (vif.HREADYOUT === 1'b1);

        // Remove AHB request
        @(negedge vif.HCLK);

        vif.HSEL   <= 1'b0;
        vif.HTRANS <= 2'b00;

        seq_item_port.item_done();

    end

endtask
endclass        
