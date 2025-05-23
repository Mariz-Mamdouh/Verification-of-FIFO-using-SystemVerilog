import shared_pkg::*;
import FIFO_sb_pkg::*;
import FIFO_transaction_pkg::*;
module FIFO_tb (FIFO_if.TEST fifo_if);
    FIFO_transaction txn = new();
    initial begin
        assert_reset();
        repeat (1000) begin
            // Fill the FIFO
            repeat(9) begin
                assert (txn.randomize());
                fifo_if.wr_en = 1;
                fifo_if.rd_en = 0;
                fifo_if.data_in = txn.data_in;
                @(negedge fifo_if.clk);
                -> fifo_if.drive_done;
            end
            // Try to write when FIFO full
            assert(txn.randomize());
            fifo_if.data_in = txn.data_in;
            fifo_if.wr_en = 1;
            fifo_if.rd_en = 0;
            @(negedge fifo_if.clk);
            -> fifo_if.drive_done;
            // Read the FIFO
            repeat(9) begin
                fifo_if.wr_en = 0;
                fifo_if.rd_en = 1;
                @(negedge fifo_if.clk);
                -> fifo_if.drive_done;
            end
            // Try to read when empty
            fifo_if.wr_en = 0;
            fifo_if.rd_en = 1;
            @(negedge fifo_if.clk);
            -> fifo_if.drive_done;

            // Fill the FIFO completely 
            repeat (9) begin
                assert(txn.randomize());
                fifo_if.data_in = txn.data_in;
                fifo_if.wr_en = 1;
                fifo_if.rd_en = 0;
                @(negedge fifo_if.clk);
                -> fifo_if.drive_done;
            end
            // Read the FIFO
            repeat(9) begin
                fifo_if.wr_en = 0;
                fifo_if.rd_en = 1;
                @(negedge fifo_if.clk);
                -> fifo_if.drive_done;
            end
            // Both read & write are asserted when FIFO is empty → should write only
            repeat(9) begin
                assert (txn.randomize());
                fifo_if.wr_en = 1;
                fifo_if.rd_en = 1;
                fifo_if.data_in = txn.data_in;
                @(negedge fifo_if.clk);
                -> fifo_if.drive_done;
            end

            // Read the FIFO
            repeat(9) begin
                fifo_if.wr_en = 0;
                fifo_if.rd_en = 1;
                @(negedge fifo_if.clk);
                -> fifo_if.drive_done;
            end
            // Fill the FIFO completely 
            repeat (9) begin
                assert(txn.randomize());
                fifo_if.data_in = txn.data_in;
                fifo_if.wr_en = 1;
                fifo_if.rd_en = 0;
                @(negedge fifo_if.clk);
                -> fifo_if.drive_done;
            end
            // Both read & write are asserted when FIFO is full → should read only
            repeat (9) begin
                assert(txn.randomize());
                fifo_if.data_in = txn.data_in;
                fifo_if.wr_en = 1;
                fifo_if.rd_en = 1;
                @(negedge fifo_if.clk);
                -> fifo_if.drive_done;
            end
            // Pre-fill FIFO with 3 elements
            repeat (3) begin
                assert (txn.randomize());
                fifo_if.wr_en = 1;
                fifo_if.rd_en = 0;
                fifo_if.data_in = txn.data_in;
                @(negedge fifo_if.clk);
                -> fifo_if.drive_done;
            end
            // Now do 3 read-only cycles
            repeat (3) begin
                fifo_if.wr_en = 0;
                fifo_if.rd_en = 1;
                @(negedge fifo_if.clk);
                -> fifo_if.drive_done;
            end
            assert(txn.randomize());
            fifo_if.rst_n = txn.rst_n;
            fifo_if.data_in = txn.data_in;
            fifo_if.wr_en = txn.wr_en;
            fifo_if.rd_en = txn.rd_en;
            @(negedge fifo_if.clk);
            -> fifo_if.drive_done;
        end
        test_finished = 1;
    end

    task assert_reset();
        fifo_if.rst_n = 0;
        fifo_if.wr_en = 0;
        fifo_if.rd_en = 0;
        fifo_if.data_in = 0;
        @(negedge fifo_if.clk);
        fifo_if.rst_n = 1;
        @(negedge fifo_if.clk);
    endtask
endmodule