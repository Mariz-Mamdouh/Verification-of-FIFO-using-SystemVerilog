module FIFO_top;
    bit clk;
    initial begin
        clk = 0;
        forever begin
            #1 clk = ~clk;
        end
    end
    FIFO_if fifo_if(clk);
    FIFO_tb tb(fifo_if);
    FIFO DUT(fifo_if);
    FIFO_monitor mon(fifo_if);
endmodule
