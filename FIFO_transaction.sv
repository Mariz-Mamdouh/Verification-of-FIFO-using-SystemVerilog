import shared_pkg::*;
package FIFO_transaction_pkg;
    class FIFO_transaction;
        parameter FIFO_WIDTH = 16;
        parameter FIFO_DEPTH = 8;
        bit clk;
        rand logic [FIFO_WIDTH-1:0] data_in;
        rand logic rst_n, wr_en, rd_en;
        logic [FIFO_WIDTH-1:0] data_out;
        logic wr_ack, overflow;
        logic full, empty, almostfull, almostempty, underflow;
        int RD_EN_ON_DIST;
        int WR_EN_ON_DIST;

        function new(input rd_dist = 30, wr_dist = 70);
            this.RD_EN_ON_DIST = rd_dist;
            this.WR_EN_ON_DIST = wr_dist;
        endfunction //new()

        constraint rst_const {
            rst_n dist {0:=10, 1:=90};
        }
        constraint wr_en_const {
            wr_en dist {1:=WR_EN_ON_DIST, 0:=(100-WR_EN_ON_DIST)};
        }
        constraint rd_en_const {
            rd_en dist {1:=RD_EN_ON_DIST, 0:=(100-RD_EN_ON_DIST)};
        }
    endclass //FIFO_transaction
endpackage