
`timescale 1ns/1ps

module tb_async_fifo;

    parameter DATA_WIDTH = 8;

    reg wr_clk = 0;
    reg rd_clk = 0;
    reg rst_n = 0;
    reg wr_en = 0;
    reg rd_en = 0;
    reg [DATA_WIDTH-1:0] din = 0;

    wire [DATA_WIDTH-1:0] dout;
    wire full;
    wire empty;

    integer i;

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(2)
    ) dut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    always #5 wr_clk = ~wr_clk;
    always #7 rd_clk = ~rd_clk;

    initial begin
        $dumpfile("async_fifo.vcd");
        $dumpvars(0, tb_async_fifo);

        $display("Starting asynchronous FIFO test");

        #20;
        rst_n = 1;

        // Wait for reset to settle
        repeat (3) @(negedge wr_clk);

        // Write 4 values
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge wr_clk);
            wr_en = 1;
            din = i + 8'h10;
        end

        @(negedge wr_clk);
        wr_en = 0;

        // Allow the full flag to update
        repeat (3) @(negedge wr_clk);

        $display("After writes: full=%b", full);

        // Allow the read domain to synchronize the write pointer
        repeat (5) @(negedge rd_clk);

        // Read 4 values
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge rd_clk);
            rd_en = 1;
            @(posedge rd_clk);
            #1;
            $display("Read data = %h, expected = %h",
                     dout, i + 8'h10);
        end

        @(negedge rd_clk);
        rd_en = 0;

        repeat (3) @(negedge rd_clk);
        $display("After reads: empty=%b", empty);

        $display("FIFO test completed");
        $finish;
    end

    initial begin
        #2000;
        $display("ERROR: Simulation timeout");
        $finish;
    end

endmodule
