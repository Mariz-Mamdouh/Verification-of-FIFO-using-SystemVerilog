package FIFO_sb_pkg;
    import FIFO_transaction_pkg::*;
    import shared_pkg::*;
    class FIFO_scoreboard;
        parameter FIFO_WIDTH = 16;
        logic [FIFO_WIDTH-1:0] data_out_ref;
        logic [FIFO_WIDTH-1:0] mem [$];

        task check_data(FIFO_transaction fifo_chk);
            reference_model(fifo_chk);
            if (!fifo_chk.rst_n) begin
                if ((fifo_chk.data_out != data_out_ref)) begin
                    error_count++;
                    $display("ERROR in Reset values at time %0t",$time);
                    $display("Expected data_out=%0h", data_out_ref);
                    $display("Received data_out=%0h", fifo_chk.data_out);
                end else begin
                    correct_count++;
                end
            end else begin
                if ((fifo_chk.data_out != data_out_ref)) begin
                    error_count++;
                    $display("ERROR at time %0t and size = %0d",$time,mem.size());
                    $display("Expected data_out=%0h",data_out_ref);
                    $display("Received data_out=%0h",fifo_chk.data_out);
                end else begin
                    correct_count++;
                end
            end
        endtask //check_data

        task reference_model(FIFO_transaction fifo_ref);
            if (!fifo_ref.rst_n) begin
                mem.delete();
            end else begin
                case ({fifo_ref.wr_en, fifo_ref.rd_en})
                    2'b00: begin
                        // No operation
                    end
                    2'b10: begin // Write only
                        if (mem.size() < fifo_ref.FIFO_DEPTH)
                            mem.push_back(fifo_ref.data_in);
                    end
                    2'b01: begin // Read only
                        if (mem.size() > 0)
                            data_out_ref = mem.pop_front();
                    end
                    2'b11: begin // Both read and write
                        if (mem.size() == 0) begin
                            // Empty FIFO → only write
                            mem.push_back(fifo_ref.data_in);
                        end
                        else if (mem.size() == fifo_ref.FIFO_DEPTH) begin
                            // Full FIFO → only read
                            data_out_ref = mem.pop_front();
                        end
                        else begin
                            // Both read and write can happen
                            data_out_ref = mem.pop_front();
                            mem.push_back(fifo_ref.data_in);
                        end
                    end
                endcase
            end
        endtask //reference_model
    endclass //FIFO_scoreboard
endpackage