

module Transmitter (
                        clk,                  //input clk signal
                        rst,                  //reset signal for transmitter
                        SIE,	              //SIE  = 1 , for transmitter to perform bit_stuffing , parallel-to-serial implementation
                        STUFF_OPER_tx,         
                        sync_data,            //sync_data needs to be transmitted to initiate transmitter
                        
                        data_in,              //input data to be transmitted
                        SYNC_pattern,         
                        encoded_dataout,
						opcode
                        );
                        
 //port declartions                       
                        
 input clk;
 input rst;
 input SIE;
 input STUFF_OPER_tx;
 input [7:0]sync_data;
 
 input [15:0]data_in;
 output encoded_dataout;
 output  SYNC_pattern;
 output [3:0]opcode;
 
 
 reg encoded_dataout;
 wire SYNC_pattern;
 
 
 //temporary registers
 
 reg[15:0]hold_data;     //hold_data is used to store the input data
 reg temp_out;
 reg [2:0]PS,NS; 		 //PS,NS are present states and next state variables in bit stuff logic state machine
 reg [3:0]opcode;
 reg [2:0]count;
 


 wire Bit_stuff;
 wire data;
 
 
 //parameter definations which are required in bit_stuff logic implementation
 parameter IDLE=3'b000;
 parameter START=3'b001;
 parameter TWO=3'b010;
 parameter THIRD=3'b011;
 parameter FOUR=3'b100;
 parameter FIVE=3'b101;
 parameter BITSTUFF=3'b110;


                       
//data_in is the input data coming in parallel format which the user will enter in this case    

always@(posedge clk)
begin
    if(rst)
    begin
        hold_data<=16'b0000_0000_0000_0000;
        opcode<=4'b0000;
    end
    else if(SIE&&~Bit_stuff&&SYNC_pattern)
       begin
       hold_data<=data_in;
       opcode<=opcode+1'b1;
       end
    else
    opcode<=opcode;
end


//Parallel to serial Converstion
always@( posedge clk)
begin
    case(opcode)
       4'b0000:temp_out=hold_data[15];
       4'b0001:temp_out=hold_data[0];
       4'b0010:temp_out=hold_data[1];
       4'b0011:temp_out=hold_data[2];
       4'b0100:temp_out=hold_data[3];
       4'b0101:temp_out=hold_data[4];
       4'b0110:temp_out=hold_data[5];
       4'b0111:temp_out=hold_data[6];
       4'b1000:temp_out=hold_data[7];
       4'b1001:temp_out=hold_data[8];
       4'b1010:temp_out=hold_data[9];
       4'b1011:temp_out=hold_data[10];
       4'b1100:temp_out=hold_data[11];
       4'b1101:temp_out=hold_data[12];
       4'b1110:temp_out=hold_data[13];
       4'b1111:temp_out=hold_data[14];
    endcase

 end
 
//Bit stuffing implementation
 always@(posedge clk)
 begin
     if(rst)
     begin
          PS<=IDLE;
          count=3'b000;
      end
     else
          PS<=NS;
end

always@(PS or temp_out)
begin
    case(PS)
        IDLE:if(temp_out&&STUFF_OPER_tx)
                begin
                    count=3'b001;//count+1'b1;
                    NS=START;
                end
                else
                begin
                NS=IDLE;
                count=3'b000;
            end
                
        START:if(temp_out)
        begin
             count=3'b010;
             NS=TWO;
         end
         else
            begin
               NS=IDLE;
           end
           
        TWO:if(temp_out)
        begin
             count=3'b011;
             NS=THIRD;
        end   
         else
            begin
               NS=IDLE;
           end
           
        THIRD:if(temp_out)
        begin
             count=3'b100;
             NS=FOUR;
        end   
         else
            begin
               NS=IDLE;
           end
           
        FOUR:if(temp_out)
        begin
             count=3'b101;
             NS=FIVE;
        end   
         else
            begin
               NS=IDLE;
           end
        
        FIVE:if(temp_out)
        begin
             count=3'b110;
             NS=BITSTUFF;
        end   
         else
            begin
               count=3'b000;
               NS=IDLE;
           end
       BITSTUFF:
               begin
                   count=3'b111;
                   NS=IDLE;
               end
               
                 
   endcase
   
   end
  
   
   assign Bit_stuff=(count==3'b111)?1'b1:1'b0;             //if count==7 , It means 6 consecutive 1's have been transmitted thus bit stuffing needs to be done.
   
   assign data=Bit_stuff?0:temp_out;                       //if bit_stuff ==1 , data transmitted is 0 else data transmitted is the hold_data
   
   assign SYNC_pattern=(sync_data==8'b0111_1110)?1'b1:1'b0;//SYNC PATTERN CHECKING where sync data needs to be transmitted.
      
 

 
 
endmodule

              
                                      
