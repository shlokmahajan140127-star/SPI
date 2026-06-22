
module spi_slave (
    input SCLK,
    input MOSI,
    input slave_select,
    output reg MISO,
    output [7:0] dout,
    output reg done
);
reg [7:0] tx_shift ;
reg [7:0] tx_data  = 8'b10101011;// sends data at MOSI 
reg [7:0] rx_shift; // receive data at MISO
reg state;
integer count;


// State definitions
parameter IDLE  = 1'b0;
parameter sample = 1'b1;


initial begin
    state = IDLE;
    count = 0;
    tx_shift =8'b0;
    done = 0;
    
    tx_data =8'b10101011;
    rx_shift = 8'b0;
    MISO = 1'b0;
end

always@(negedge slave_select)
begin

  tx_shift <= tx_data;

end


always@(negedge SCLK)
begin
    if(slave_select ==1'b0)
    begin
    MISO <= tx_shift[7];
    tx_shift <= {tx_shift[6:0],1'b0};
    end
end

always @(negedge SCLK)
begin
    case(state)

        IDLE:
        begin
            done <= 1'b0;

            if(slave_select == 1'b0)
            begin
               state <= sample;
               count <= 0;
               rx_shift <= 8'b0;
               
            end
            
            else
            begin
                state <= IDLE;
                count <= 0;
            end
        end

        sample:
        begin
            if(count < 7)
            begin
                count <= count + 1;
                rx_shift <= {rx_shift[6:0], MOSI};
                state <= sample;
            end
            else
            begin
                rx_shift <= {rx_shift[6:0], MOSI};
                count <= 0;
                state <= IDLE;
                done <= 1'b1;
            end
        end

        default:
            state <= IDLE;

    endcase
end
assign dout = rx_shift;

endmodule
