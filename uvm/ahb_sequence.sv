class ahb_sequence extends uvm_sequence #(ahb_transaction);

    `uvm_object_utils(ahb_sequence)

    function new(string name = "ahb_sequence");
        super.new(name);
    endfunction

    task body();

        ahb_transaction tr;

        repeat(5) begin

            tr = ahb_transaction::type_id::create("tr");

            start_item(tr);

            if (!tr.randomize())
                `uvm_error("SEQ", "Transaction randomization failed")

            finish_item(tr);

        end

    endtask

endclass
