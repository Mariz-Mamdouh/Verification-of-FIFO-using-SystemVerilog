module FIFO(FIFO_if.DUT fifo_if);
localparam max_fifo_addr = $clog2(fifo_if.FIFO_DEPTH);
reg [fifo_if.FIFO_WIDTH-1:0] mem [fifo_if.FIFO_DEPTH-1:0];
reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
	if (!fifo_if.rst_n) begin
		wr_ptr <= 0;
		fifo_if.overflow <= 0;
		fifo_if.wr_ack <= 0;
	end
	else if (fifo_if.wr_en && count < fifo_if.FIFO_DEPTH) begin
		mem[wr_ptr] <= fifo_if.data_in;
		fifo_if.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
		fifo_if.overflow <= 0;
	end
	else begin 
		fifo_if.wr_ack <= 0; 
		if (fifo_if.full && fifo_if.wr_en)
			fifo_if.overflow <= 1;
		else
			fifo_if.overflow <= 0;
	end
end

always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
	if (!fifo_if.rst_n) begin
		rd_ptr <= 0;
		fifo_if.underflow <= 0;
	end
	else if (fifo_if.rd_en && count != 0) begin
		fifo_if.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		fifo_if.underflow <= 0;
	end else begin
		if (fifo_if.empty && fifo_if.rd_en) begin
			fifo_if.underflow <= 1;
		end else begin
			fifo_if.underflow <= 0;
		end
	end
end

always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
	if (!fifo_if.rst_n) begin
		count <= 0;
	end
	else begin
		if (({fifo_if.wr_en, fifo_if.rd_en} == 2'b11)) begin
			if (fifo_if.full) begin
				count <= count - 1;
			end
			if (fifo_if.empty) begin
				count <= count + 1;
			end
		end 
		else if	( ({fifo_if.wr_en, fifo_if.rd_en} == 2'b10) && !fifo_if.full) 
			count <= count + 1;
		else if ( ({fifo_if.wr_en, fifo_if.rd_en} == 2'b01) && !fifo_if.empty)
			count <= count - 1;
	end
end

assign fifo_if.full = (count == fifo_if.FIFO_DEPTH)? 1 : 0;
assign fifo_if.empty = (count == 0)? 1 : 0;
assign fifo_if.almostfull = (count == fifo_if.FIFO_DEPTH-1)? 1 : 0; 
assign fifo_if.almostempty = (count == 1)? 1 : 0;


`ifdef SIM
	// Reset Behavior
	always_comb begin
		if (!fifo_if.rst_n) begin
			a_reset: assert final ((count == {(max_fifo_addr+1){1'b0}}) && (wr_ptr == {max_fifo_addr{1'b0}}) 
																		&& (rd_ptr == {max_fifo_addr{1'b0}}));
		end
	end

	// Write Acknowledge (wr_ack)
	property p_wr_ack;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n)
		(fifo_if.wr_en) && !(fifo_if.full) |=> (fifo_if.wr_ack==1'b1);
	endproperty
	wr_ack_assertion: assert property(p_wr_ack);
	wr_ack_coverage: cover property(p_wr_ack);

	// Overflow Detection
	property p_overflow;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n)
		(fifo_if.wr_en) && (fifo_if.full) |=> (fifo_if.overflow==1'b1);
	endproperty
	overflow_assertion: assert property(p_overflow);
	overflow_coverage: cover property(p_overflow);

	// Underflow Detection
	property p_underflow;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n)
		(fifo_if.rd_en) && (fifo_if.empty) |=> (fifo_if.underflow==1'b1);
	endproperty
	underflow_assertion: assert property(p_underflow);
	underflow_coverage: cover property(p_underflow);

	// Empty Flag Assertion
	property p_empty;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n)
		(count == {(max_fifo_addr+1){1'b0}}) |-> (fifo_if.empty==1'b1);
	endproperty
	empty_assertion: assert property(p_empty);
	empty_coverage: cover property(p_empty);

	// Full Flag Assertion
	property p_full;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n)
		(count == fifo_if.FIFO_DEPTH) |-> (fifo_if.full==1'b1);
	endproperty
	full_assertion: assert property(p_full);
	full_coverage: cover property(p_full);

	// Almost Full Condition
	property p_almostfull;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n)
		(count == ((fifo_if.FIFO_DEPTH)-1'b1)) |-> (fifo_if.almostfull==1'b1);
	endproperty
	almostfull_assertion: assert property(p_almostfull);
	almostfull_coverage: cover property(p_almostfull);

	// Almost Empty Condition
	property p_almostempty;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n)
		(count == 1'b1) |-> (fifo_if.almostempty==1'b1);
	endproperty
	almostempty_assertion: assert property(p_almostempty);
	almostempty_coverage: cover property(p_almostempty);

	// Pointer Wraparound & threshold
	property p_wr_ptr;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n)
		(fifo_if.wr_en) && (count < fifo_if.FIFO_DEPTH) |=> (wr_ptr == $past(wr_ptr) + 1'b1);
	endproperty
	wr_ptr_assertion: assert property(p_wr_ptr);
	wr_ptr_coverage: cover property(p_wr_ptr);

	property p_rd_ptr;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n)
		(fifo_if.rd_en) && (count != 1'b0) |=> (rd_ptr == $past(rd_ptr) + 1'b1);
	endproperty
	rd_ptr_assertion: assert property(p_rd_ptr);
	rd_ptr_coverage: cover property(p_rd_ptr);


	// Counter Wraparound & threshold
	property p_counter_up;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n)
		(fifo_if.wr_en) && !(fifo_if.full) && !(fifo_if.rd_en) |=> (count == $past(count) + 1'b1);
	endproperty
	counter_up_assertion: assert property(p_counter_up);
	counter_up_coverage: cover property(p_counter_up);

	property p_counter_down;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n)
		!(fifo_if.wr_en) && !(fifo_if.empty) && (fifo_if.rd_en) |=> (count == $past(count) - 1'b1);
	endproperty
	counter_down_assertion: assert property(p_counter_down);
	counter_down_coverage: cover property(p_counter_down);
`endif
endmodule