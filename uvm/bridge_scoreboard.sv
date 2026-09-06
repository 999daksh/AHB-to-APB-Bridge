class bridge_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(bridge_scoreboard)

    uvm_tlm_analysis_fifo #(ahb_transaction) ahb_fifo;
    uvm_tlm_analysis_fifo #(apb_transaction) apb_fifo;

    int total_transactions;
    int failed_transactions;


    function new(string name = "bridge_scoreboard",
                 uvm_component parent);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        ahb_fifo = new("ahb_fifo", this);
        apb_fifo = new("apb_fifo", this);

        total_transactions = 0;
        failed_transactions = 0;

    endfunction


    task run_phase(uvm_phase phase);

        ahb_transaction ahb_tr;
        apb_transaction apb_tr;

        forever begin

            ahb_fifo.get(ahb_tr);
            apb_fifo.get(apb_tr);

            total_transactions++;

            `uvm_info(
                "DEBUG",
                $sformatf(
                    "AHB: ADDR=%h WRITE=%b WDATA=%h HRDATA=%h",
                    ahb_tr.HADDR,
                    ahb_tr.HWRITE,
                    ahb_tr.HWDATA,
                    ahb_tr.HRDATA
                ),
                UVM_NONE
            )

            `uvm_info(
                "DEBUG",
                $sformatf(
                    "APB: ADDR=%h WRITE=%b WDATA=%h PRDATA=%h",
                    apb_tr.PADDR,
                    apb_tr.PWRITE,
                    apb_tr.PWDATA,
                    apb_tr.PRDATA
                ),
                UVM_NONE
            )


            //========================================
            // Address check
            //========================================

            



            //========================================
            // Read / Write check
            //========================================

            if (ahb_tr.HWRITE != apb_tr.PWRITE) begin

                failed_transactions++;

                `uvm_error(
                    "SCOREBOARD",
                    "Read/Write mismatch: AHB HWRITE != APB PWRITE"
                )

            end


            //========================================
            // WRITE
            //========================================

            if (ahb_tr.HWRITE) begin

                if (ahb_tr.HWDATA != apb_tr.PWDATA) begin

                    failed_transactions++;

                    `uvm_error(
                        "SCOREBOARD",
                        "Write data mismatch: AHB HWDATA != APB PWDATA"
                    )

                end
                else begin

                    `uvm_info(
                        "SCOREBOARD",
                        "AHB WRITE -> APB WRITE matched",
                        UVM_MEDIUM
                    )

                end

            end


            //========================================
            // READ
            //========================================

            else begin

                if (apb_tr.PRDATA != ahb_tr.HRDATA) begin

                    failed_transactions++;

                    `uvm_error(
                        "SCOREBOARD",
                        "Read data mismatch: APB PRDATA != AHB HRDATA"
                    )

                end
                else begin

                    `uvm_info(
                        "SCOREBOARD",
                        "AHB READ -> APB READ matched",
                        UVM_MEDIUM
                    )

                end

            end

        end

    endtask


    //========================================
    // Final PASS / FAIL report
    //========================================

    function void report_phase(uvm_phase phase);

        if (total_transactions == 5 &&
            failed_transactions == 0) begin

            `uvm_info(
                "FINAL_RESULT",
                $sformatf(
                    "PASS: All %0d AHB-to-APB transactions verified successfully.",
                    total_transactions
                ),
                UVM_NONE
            )

        end
        else begin

            `uvm_error(
                "FINAL_RESULT",
                $sformatf(
                    "FAIL: Transactions checked=%0d, failures=%0d",
                    total_transactions,
                    failed_transactions
                )
            )

        end

    endfunction

endclass
