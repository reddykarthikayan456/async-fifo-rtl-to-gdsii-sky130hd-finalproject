
module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  wire                  wr_clk,
    input  wire                  rd_clk,
    input  wire                  rst_n,
    input  wire                  wr_en,
    input  wire                  rd_en,
    input  wire [DATA_WIDTH-1:0] din,
    output reg  [DATA_WIDTH-1:0] dout,
    output reg                   full,
    output reg                   empty
);

    localparam DEPTH     = (1 << ADDR_WIDTH);
    localparam PTR_WIDTH = ADDR_WIDTH + 1;

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    reg [PTR_WIDTH-1:0] wbin, wgray;
    reg [PTR_WIDTH-1:0] rbin, rgray;

    reg [PTR_WIDTH-1:0] rgray_w1, rgray_w2;
    reg [PTR_WIDTH-1:0] wgray_r1, wgray_r2;

    wire winc = wr_en && !full;
    wire rinc = rd_en && !empty;

    wire [PTR_WIDTH-1:0] wbin_next =
        wbin + winc;
    wire [PTR_WIDTH-1:0] rbin_next =
        rbin + rinc;

    wire [PTR_WIDTH-1:0] wgray_next =
        (wbin_next >> 1) ^ wbin_next;
    wire [PTR_WIDTH-1:0] rgray_next =
        (rbin_next >> 1) ^ rbin_next;

    wire full_next =
        (wgray_next ==
        {~rgray_w2[PTR_WIDTH-1:PTR_WIDTH-2],
          rgray_w2[PTR_WIDTH-3:0]});

    wire empty_next = (rgray_next == wgray_r2);

    // Synchronize read pointer into write-clock domain
    always @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            rgray_w1 <= 0;
            rgray_w2 <= 0;
        end else begin
            rgray_w1 <= rgray;
            rgray_w2 <= rgray_w1;
        end
    end

    // Synchronize write pointer into read-clock domain
    always @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n) begin
            wgray_r1 <= 0;
            wgray_r2 <= 0;
        end else begin
            wgray_r1 <= wgray;
            wgray_r2 <= wgray_r1;
        end
    end

    // Write pointer and registered full flag
    always @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            wbin <= 0;
            wgray <= 0;
            full <= 0;
        end else begin
            wbin <= wbin_next;
            wgray <= wgray_next;
            full <= full_next;

            if (winc)
                mem[wbin[ADDR_WIDTH-1:0]] <= din;
        end
    end

    // Read pointer and registered empty flag
    always @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n) begin
            rbin <= 0;
            rgray <= 0;
            empty <= 1;
            dout <= 0;
        end else begin
            rbin <= rbin_next;
            rgray <= rgray_next;
            empty <= empty_next;

            if (rinc)
                dout <= mem[rbin[ADDR_WIDTH-1:0]];
        end
    end

endmodule

