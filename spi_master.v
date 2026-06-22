
module spi_master(
 input clk,
 input rst,
 input tx_enb,
 input MISO,
 output wire SCLK,
 output reg MOSI,
 output reg slave_select,
 
 output reg [7:0] rx_data,
 output reg rx_done 
 );
 
parameter IDLE=2'B00;
parameter start_tx=2'b01;
parameter tx_data=2'b10;
parameter end_tx=2'b11;

reg[7:0] rx_shift;
reg[1:0] current_state ,next_state;
reg [7:0] din= 8'b10101011; 

    reg spi_sclk = 0;
    reg [2:0] ccount = 0;
    reg [2:0] count = 0; 
    integer bit_count = 0;


// generateting the sclk;
always@(posedge clk)
begin
    case(current_state)
        IDLE:
        begin
            spi_sclk <=0;
        end
        
        start_tx:
        begin
            if(count <3'b011)
            begin
            spi_sclk <=1'b1;
            end
            
            else
            begin
            spi_sclk <=1'b0;
            end
        end
        
        tx_data:
        begin
            if(count < 3'b011)
            begin
            spi_sclk <=1'b1;
            end
            
            else
            begin
            spi_sclk <=1'b0;
            end
        end
        
        end_tx:
        begin
            if(count < 3'b011)
            begin
            spi_sclk <=1'b1;
            end
            
            else
            begin
            spi_sclk <=1'b0;
            end
        end
        
      default:
      begin
          spi_sclk <= 0;
      end
    endcase
end


always@(posedge clk)
begin
    if(rst == 1'b1)
    begin
        current_state <=IDLE;
        rx_shift <= 8'b0;
        rx_data  <= 8'b0;
        rx_done  <= 1'b0;
    end
    
    else
    begin
    current_state <= next_state;
    end    
end 


always@(*)
begin
    slave_select = 1'b0;
    MOSI = 1'b0;
    next_state = current_state;
    case(current_state)
    
    IDLE:
        begin
        MOSI = 1'b0;
        slave_select = 1'b1;
        
        if(tx_enb==1'b1)
            begin
            next_state =start_tx;
            end
        
        else
            begin
            next_state = IDLE;
            end
        end
        
        
    start_tx:
    begin
        MOSI=din[7];
        slave_select =1'b0;
         
        if(count== 3'b111)
        begin
        next_state = tx_data;
        end
        
        else
        begin
        next_state =start_tx;
        end
    end
    
    tx_data:
    begin
        slave_select=1'b0;
       
        if(bit_count <8)
        begin
        MOSI=din[7-bit_count];
        next_state =tx_data;
        end
        
        else
        begin
        next_state =end_tx;
        MOSI=1'b0;
        end
    end
     
    end_tx:
    begin
    slave_select=1'b1;
    MOSI=1'b0;
        if(count ==3'b111)
        begin
        next_state =IDLE;
        end
        
        else
        begin
        next_state =end_tx;
        end
    end
    
    default:
    begin
    next_state =IDLE;
    end
     
    
   endcase
end

// counter

always@(posedge clk)
begin
 case(current_state)
 
 IDLE:
 begin
 count<=0;

 bit_count <=0;
 rx_done <= 1'b0;

 end
 
 start_tx:
 begin
  rx_done <= 1'b0;
   if(count < 3'b111)
       begin
            count <= count + 1;
       end
    else
        count <= 0;
 end
 
 tx_data:
 begin
     if(bit_count !=8)
      begin
          if(count < 3'b111)
          begin
          count <=count+1;
          end
          
          else
          begin
          count <=0;
          bit_count <=bit_count+1;
          rx_shift <= {rx_shift[6:0], MISO};
     
      
           if(bit_count == 7)
            begin
                rx_data <= {rx_shift[6:0], MISO};
                rx_done <= 1'b1;
            end
            
          end
      end
  end
  
  end_tx:
  begin
      count <=count+1;
      bit_count <=0;
  end
      
  default:
  begin
   bit_count <= 0;

    if(count < 3'b111)
        count <= count + 1;
    else
        count <= 0;
  end
 
  endcase
end
assign SCLK = spi_sclk;
endmodule
