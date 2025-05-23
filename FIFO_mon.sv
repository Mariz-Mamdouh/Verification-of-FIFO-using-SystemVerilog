import FIFO_transaction_pkg::*;
import FIFO_sb_pkg::*;
import FIFO_cvg_pkg::*;
import shared_pkg::*;
module FIFO_monitor (FIFO_if.MONITOR fifo_if);
    FIFO_transaction txn = new();
    FIFO_coverage cov = new();
    FIFO_scoreboard sb = new();

    initial begin
        forever begin
            @(fifo_if.drive_done);
            @(negedge fifo_if.clk);
            txn.rst_n = fifo_if.rst_n;
            txn.data_in = fifo_if.data_in;
            txn.wr_en = fifo_if.wr_en;
            txn.rd_en = fifo_if.rd_en;
            txn.data_out = fifo_if.data_out;
            txn.wr_ack = fifo_if.wr_ack;
            txn.overflow = fifo_if.overflow;
            txn.full = fifo_if.full;
            txn.empty = fifo_if.empty;
            txn.almostfull = fifo_if.almostfull;
            txn.almostempty = fifo_if.almostempty;
            txn.underflow = fifo_if.underflow;
            fork
                begin
                    cov.sample_data(txn);
                end
                begin
                    sb.check_data(txn);
                end
            join
            if (test_finished) begin
                $display(" TEST FINISHED: Correct = %0d, Errors = %0d", correct_count, error_count);
                $stop;
            end
        end
    end
endmodule