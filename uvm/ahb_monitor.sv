class ahb_monitor extends uvm_monitor;

    `uvm_component_utils(ahb_monitor)

    virtual ahb_if vif;

    uvm_analysis_port #(ahb_transaction) ap;

    bit in_transfer;


    function new(string name = "ahb_monitor",
                 uvm_component parent);

        super.new(name, parent);

        ap = new("ap", this);

        in_transfer = 1'b0;

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db #(virtual ahb_if)::get(
                this, "", "vif", vif))

            `uvm_fatal(
                "NOVIF",
                "AHB virtual interface not found"
            );

    endfunction


    task run_phase(uvm_phase phase);

        ahb_transaction tr;

        forever begin

            @(posedge vif.HCLK);

            // Capture exactly once per AHB request
            if (vif.HSEL &&
                vif.HREADY &&
                vif.HTRANS[1] &&
                !in_transfer) begin

                in_transfer = 1'b1;

                tr = ahb_transaction::type_id::create("tr");

                tr.HADDR  = vif.HADDR;
                tr.HWRITE = vif.HWRITE;
                tr.HWDATA = vif.HWDATA;
                tr.HTRANS = vif.HTRANS;
                tr.HSIZE  = vif.HSIZE;

                ap.write(tr);

            end

            // Request ended
            if (!vif.HSEL || !vif.HTRANS[1]) begin

                in_transfer = 1'b0;

            end

        end

    endtask

endclass
