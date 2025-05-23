package FIFO_cvg_pkg;
    import FIFO_transaction_pkg::*;
    class FIFO_coverage;
        FIFO_transaction F_cvg_txn;

        covergroup cov;
            wr_en_cp:       coverpoint F_cvg_txn.wr_en iff(F_cvg_txn.rst_n);
            rd_en_cp:       coverpoint F_cvg_txn.rd_en iff(F_cvg_txn.rst_n);
            full_cp:        coverpoint F_cvg_txn.full iff(F_cvg_txn.rst_n);
            empty_cp:       coverpoint F_cvg_txn.empty iff(F_cvg_txn.rst_n);
            almostfull_cp:  coverpoint F_cvg_txn.almostfull iff(F_cvg_txn.rst_n);
            almostempty_cp: coverpoint F_cvg_txn.almostempty iff(F_cvg_txn.rst_n);
            underflow_cp:   coverpoint F_cvg_txn.underflow iff(F_cvg_txn.rst_n);
            overflow_cp:    coverpoint F_cvg_txn.overflow iff(F_cvg_txn.rst_n);
            wr_ack_cp:      coverpoint F_cvg_txn.wr_ack iff(F_cvg_txn.rst_n);

            wr_full_cross: cross wr_en_cp,full_cp {
                option.cross_auto_bin_max = 0;
                bins wr_on_full_on = binsof(wr_en_cp) intersect {1} && binsof(full_cp) intersect {1};
                bins wr_on_full_off = binsof(wr_en_cp) intersect {1} && binsof(full_cp) intersect {0};
                bins wr_off_full_off = binsof(wr_en_cp) intersect {0} && binsof(full_cp) intersect {0};
            }
            wr_almosfull_cross: cross wr_en_cp,almostfull_cp;
            wr_overflow_cross: cross wr_en_cp,overflow_cp {
                option.cross_auto_bin_max = 0;
                bins wr_on_overflow_on = binsof(wr_en_cp) intersect {1} && binsof(overflow_cp) intersect {1};
                bins wr_on_overflow_off = binsof(wr_en_cp) intersect {1} && binsof(overflow_cp) intersect {0};
                bins wr_off_overflow_off = binsof(wr_en_cp) intersect {0} && binsof(overflow_cp) intersect {0};
            }
            wr_with_wr_ack_cross: cross wr_en_cp,wr_ack_cp {
                option.cross_auto_bin_max = 0;
                bins wr_on_wr_ack_on = binsof(wr_en_cp) intersect {1} && binsof(wr_ack_cp) intersect {1};
                bins wr_on_wr_ack_off = binsof(wr_en_cp) intersect {1} && binsof(wr_ack_cp) intersect {0};
                bins wr_off_wr_ack_off = binsof(wr_en_cp) intersect {0} && binsof(wr_ack_cp) intersect {0};
            }
            rd_empty_cross: cross rd_en_cp,empty_cp;
            rd_almostempty_cross: cross rd_en_cp,almostempty_cp {
                option.cross_auto_bin_max = 0;
                bins rd_on_almostempty_on = binsof(rd_en_cp) intersect {1} && binsof(almostempty_cp) intersect {1};
                bins rd_on_almostempty_off = binsof(rd_en_cp) intersect {1} && binsof(almostempty_cp) intersect {0};
                bins rd_off_almostempty_off = binsof(rd_en_cp) intersect {0} && binsof(almostempty_cp) intersect {0};
            }
            rd_underflow_cross: cross rd_en_cp,underflow_cp {
                option.cross_auto_bin_max = 0;
                bins rd_on_underflow_on = binsof(rd_en_cp) intersect {1} && binsof(underflow_cp) intersect {1};
                bins rd_on_underflow_off = binsof(rd_en_cp) intersect {1} && binsof(underflow_cp) intersect {0};
                bins rd_off_underflow_off = binsof(rd_en_cp) intersect {0} && binsof(underflow_cp) intersect {0};
            }
        endgroup

        function new();
            cov = new();
        endfunction //new()

        function void sample_data (FIFO_transaction F_txn);
            F_cvg_txn = F_txn;
            cov.sample();
        endfunction
    endclass //FIFO_coverage
endpackage