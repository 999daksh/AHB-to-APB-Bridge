class apb_slave_model extends uvm_component;

    `uvm_component_utils(apb_slave_model)

    virtual apb_if vif;


    function new(string name = "apb_slave_model",
                 uvm_component parent);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db #(virtual apb_if)::get(
                this,
                "",
                "apb_vif",
                vif
            ))

            `uvm_fatal(
                "NOVIF",
                "APB virtual interface not found"
            )

    endfunction


    task run_phase(uvm_phase phase);

        forever begin

            @(posedge vif.PCLK);

            if (vif.PSEL && vif.PENABLE) begin

                // APB transfer is ready
                vif.PREADY <= 1'b1;

                // APB READ
                if (!vif.PWRITE) begin

                    vif.PRDATA <= 32'h12345678;

                end

            end
            else begin

                vif.PREADY <= 1'b0;
                vif.PRDATA <= 32'h0;

            end

        end

    endtask

endclass
