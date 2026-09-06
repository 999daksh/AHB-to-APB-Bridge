class bridge_env extends uvm_env;

    `uvm_component_utils(bridge_env)

    ahb_agent         ahb_ag;
    bridge_scoreboard sb;
    apb_monitor       apb_mon;
    apb_slave_model   apb_slave;

    function new(string name = "bridge_env",
                 uvm_component parent);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        ahb_ag    = ahb_agent::type_id::create("ahb_ag", this);
        sb        = bridge_scoreboard::type_id::create("sb", this);
        apb_mon   = apb_monitor::type_id::create("apb_mon", this);
        apb_slave = apb_slave_model::type_id::create("apb_slave", this);

    endfunction


    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        ahb_ag.monitor.ap.connect(
            sb.ahb_fifo.analysis_export
        );

        apb_mon.ap.connect(
            sb.apb_fifo.analysis_export
        );

    endfunction

endclass

class bridge_test extends uvm_test;

    `uvm_component_utils(bridge_test)

    bridge_env env;

    function new(string name = "bridge_test",
                 uvm_component parent);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        env = bridge_env::type_id::create("env", this);

    endfunction


    task run_phase(uvm_phase phase);

        ahb_sequence seq;

        phase.raise_objection(this);

        seq = ahb_sequence::type_id::create("seq");

        seq.start(env.ahb_ag.sequencer);

        phase.drop_objection(this);

    endtask

endclass
