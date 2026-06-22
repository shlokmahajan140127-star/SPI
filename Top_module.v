
module TOP_module(
input clk,
input rst,
input tx_enb,
output[7:0]dout,
output done
);
wire MOSI;
wire MISO;         
wire slave_select;
wire SCLK;

spi_master spi_m(
    .clk(clk),
    .rst(rst),
    .tx_enb(tx_enb),
    .MISO(MISO),          
    .MOSI(MOSI),
    .slave_select(slave_select),
    .SCLK(SCLK)
 );
 
 spi_slave spi_slv(
 .SCLK(SCLK),
 .MOSI(MOSI),
 .MISO(MISO),        
 .slave_select(slave_select),
 .dout(dout),
 .done(done)
 );
endmodule
