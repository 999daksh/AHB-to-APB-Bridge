class apb_monitor extends uvm_monitor;

    `uvm_component_utils(apb_monitor)

    virtual apb_if vif;

    uvm_analysis_port #(apb_transaction) ap;

    bit in_transfer;


    function new(string name = "apb_monitor",
                 uvm_component parent);

        super.new(name, parent);

        ap = new("ap", this);

        in_transfer = 1'b0;

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db #(virtual apb_if)::get(
                this,
                "",
                "apb_vif",
                vif))

            `uvm_fatal(
                "NOVIF",
                "APB virtual interface not found"
            );

    endfunction


    task run_phase(uvm_phase phase);

        apb_transaction tr;

        forever begin

            @(posedge vif.PCLK);

            // Capture exactly once when APB enters ENABLE
            if (vif.PSEL &&
                vif.PENABLE &&
                !in_transfer) begin

                in_transfer = 1'b1;

                tr = apb_transaction::type_id::create("tr");

                tr.PADDR   = vif.PADDR;
                tr.PWRITE  = vif.PWRITE;
                tr.PWDATA  = vif.PWDATA;
                tr.PSEL    = vif.PSEL;
                tr.PENABLE = vif.PENABLE;
                tr.PRDATA  = vif.PRDATA;

                ap.write(tr);

            end

            // APB transfer ended
            if (!vif.PSEL || !vif.PENABLE) begin

                in_transfer = 1'b0;

            end

        end

    endtask

endclass
