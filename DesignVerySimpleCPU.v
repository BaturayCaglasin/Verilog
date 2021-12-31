`timescale 1ns / 1ps



module VerySimpleCPU(clk,rst,data_fromRAM,wrEn,addr_toRAM,data_toRAM,interrupt);



    parameter SIZE = 14;

    input clk,rst;

    input wire[31:0] data_fromRAM;

    input interrupt;

   

    output reg wrEn;

    output reg[SIZE-1:0] addr_toRAM;

    output reg[31:0] data_toRAM;



   

    reg[5:0] state_current,state_next;

    reg[SIZE-1:0] pc_current,pc_next;

    reg[31:0] iw_current,iw_next;

    reg[31:0] r1_current,r1_next ;

    reg[31:0] r2_current,r2_next ;
     
    reg interrupt_flag_current,interrupt_flag_next ;



    always@ (posedge clk )begin



        if(rst)begin

            state_current <= 0;

            pc_current <= 14'b0; //PROGRAM COUNTER

            iw_current <= 32'b0; //INSTRUCTION WORD

            r1_current <= 32'b0; //R1 OR A

            r2_current <= 32'b0; //R2 OR B      

                 

            end else begin

            state_current<=state_next;

            pc_current <= pc_next;

            iw_current <= iw_next;

            r1_current<= r1_next;

            r2_current<= r2_next;      

        end end



    always@(*)begin



        state_next = state_current;

        pc_next = pc_current;

        iw_next =iw_current;

        r2_next = r1_current;

        r2_next = r2_current;

        wrEn = 0;

        //interrupt= 0;

        addr_toRAM = 0;

        data_toRAM = 0;

        case(state_current)

            0:begin

                pc_next = 0;

                iw_next = 0;

                r1_next = 0;

                r2_next= 0;

                state_next = 1;

            end

            1:begin

                addr_toRAM = pc_current;

                state_next = 2;

            end



            2:begin

                iw_next = data_fromRAM;

                case(data_fromRAM[31:28])

                    {3'b000,1'b0}:begin //ADD INSTRUCTION

                        addr_toRAM = data_fromRAM[27:14]; //R1

                        state_next= 3;

                    end

                       

                    {3'b001,1'b1}:begin //NANDi INSTRUCTION

                        addr_toRAM = data_fromRAM[27:14]; //R1

                        state_next= 3;

                    end



                    {3'b000,1'b1}:begin //ADDi INSTRUCTION

                        addr_toRAM = data_fromRAM[27:14]; //R1

                        state_next= 3;

                    end

             

                    {3'b001,1'b0}:begin //NAND INSTRUCTION

                        addr_toRAM = data_fromRAM[27:14]; //R1

                        state_next= 3;

                    end



                    {3'b010,1'b0}:begin //SRL INSTRUCTION

                        addr_toRAM = data_fromRAM[27:14]; //R1

                        state_next= 3;

                    end

                   

                     {3'b010,1'b1}:begin //SRLi INSTRUCTION

                        addr_toRAM = data_fromRAM[27:14]; //R1

                        state_next= 3;

                    end

                   

                    {3'b011,1'b0}:begin //LT INSTRUCTION

                        addr_toRAM = data_fromRAM[27:14]; //R1

                        state_next= 3;

                    end

                   

                      {3'b011,1'b1}:begin //LTi INSTRUCTION

                        addr_toRAM = data_fromRAM[27:14]; //R1

                        state_next= 3;

                    end

                   

                    {3'b111,1'b0}:begin //MUL INSTRUCTION

                        addr_toRAM = data_fromRAM[27:14]; //R1

                        state_next= 3;

                    end

                   

                     {3'b111,1'b1}:begin //MULi INSTRUCTION

                        addr_toRAM = data_fromRAM[27:14]; //R1

                        state_next= 3;

                    end

                   

                    {3'b100,1'b0}:begin //CP INSTRUCTION

                        addr_toRAM = data_fromRAM[13:0]; //R2

                        state_next= 3;

                    end

                   

                     {3'b100,1'b1}:begin //CPi INSTRUCTION

                        addr_toRAM = data_fromRAM[13:0]; //R2

                        state_next= 3;

                    end

                   

                    {3'b101,1'b0}:begin //CPI INSTRUCTION

                        addr_toRAM = data_fromRAM[13:0]; //R1

                        state_next= 3;

                    end

                   

                     {3'b101,1'b1}:begin //CPIi INSTRUCTION

                        addr_toRAM = data_fromRAM[27:14]; //R1

                        state_next= 3;

                    end

                   

                   {3'b110,1'b0}:begin //BZJ INSTRUCTION

                        addr_toRAM = data_fromRAM[27:14]; //R1

                        state_next= 3;

                    end              

                               

                    {3'b110,1'b1}:begin //BZJi INSTRUCTION

                        addr_toRAM = data_fromRAM[27:14]; //R1

                        state_next= 3;

                    end          

                                                                                                                                               

                   default:begin

                        pc_next = pc_current ;

                        state_next = 1;

                    end

                endcase

            end

           3:begin

           if(data_fromRAM[31:28]=={3'b101,1'b0}) begin //CPI

               addr_toRAM =data_fromRAM ;
               end
               
               else begin

                r1_next = data_fromRAM;

                addr_toRAM=iw_current[13:0]; //R2

                state_next = 4;

		end

		if(interrupt)begin

			interrupt_flag_next = 1;

		end

            end              

           4:begin

                case(iw_current[31:28])

                    {3'b000,1'b0}:begin //ADD

                        wrEn=1;

                        addr_toRAM = iw_current[27:14];

                        data_toRAM = data_fromRAM + r1_current; //mem[IW[27:14]] R1+R2

                        pc_next =pc_current + 1'b1; //PC+1

                        if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end
                  
                               
                     {3'b001,1'b0}:begin //NANDi

                        wrEn=1;

                        addr_toRAM = iw_current[27:14];

                        data_toRAM = ~(iw_current[13:0]& r1_current); //mem[IW[27:14]] ~(R1 & R2)

                        pc_next =pc_current + 1'b1; //PC+1

                       if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end

                   

                    {3'b001,1'b1}:begin //ADDi

                        wrEn=1;

                        addr_toRAM = iw_current[27:14];

                        data_toRAM = iw_current[13:0] + r1_current; //mem[IW[27:14]] R1+R2

                        pc_next =pc_current + 1'b1; //PC+1

                         if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end
                   

                    {3'b001,1'b0}:begin //NAND

                        wrEn=1;

                        addr_toRAM = iw_current[27:14];

                        data_toRAM = ~(data_fromRAM & r1_current); //mem[IW[27:14]] ~(R1 & R2)

                        pc_next =pc_current + 1'b1; //PC+1

                       if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end

                   

                    {3'b010,1'b0}:begin //SRL

                        wrEn=1;

                        addr_toRAM = iw_current[27:14];

                        data_toRAM = (data_fromRAM < 32) ? (r1_current  >> data_fromRAM) : (r1_current << (data_fromRAM-32)); //mem[IW[27:14]] <- (R2 < 32) ? (R1 >> R2) : (R1 << (R2-32))

                        pc_next =pc_current + 1'b1; //PC+1

                        if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end

                       

                        {3'b010,1'b1}:begin //SRLi

                        wrEn=1;

                        addr_toRAM = iw_current[27:14];

                        data_toRAM = (iw_current[13:0] < 32) ? (r1_current  >> iw_current[13:0]) : (r1_current << (iw_current[13:0]-32)); //mem[IW[27:14]] <- (R2 < 32) ? (R1 >> R2) : (R1 << (R2-32))

                        pc_next =pc_current + 1'b1; //PC+1

                       if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end
                   

                    {3'b010,1'b0}:begin //LT

                        wrEn=1;

                        addr_toRAM = iw_current[27:14];  

                        data_toRAM = (r1_current < data_fromRAM) ? 1 : 0; //mem[IW[27:14]] <- (R1 < R2) ? 1 : 0

                        pc_next =pc_current + 1'b1; //PC+1

                         if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end
                       

                        {3'b010,1'b1}:begin //LTi

                        wrEn=1;

                        addr_toRAM = iw_current[27:14];  

                        data_toRAM = (r1_current < iw_current[13:0]) ? 1 : 0; //mem[IW[27:14]] <- (R1 < R2) ? 1 : 0

                        pc_next =pc_current + 1'b1; //PC+1

                         if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end

                       

                         {3'b111,1'b0}:begin //MUL

                       wrEn=1;

                        addr_toRAM = iw_current[27:14];

                        data_toRAM = (data_fromRAM * r1_current); //mem[IW[27:14]] <- (R1 * R2)

                        pc_next =pc_current + 1'b1; //PC+1

                         if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end

                       

                        {3'b111,1'b1}:begin //MULi

                       wrEn=1;

                        addr_toRAM = iw_current[27:14];

                        data_toRAM = (iw_current[13:0] * r1_current); //mem[IW[27:14]] <- (R1 * R2)

                        pc_next =pc_current + 1'b1; //PC+1

                         if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end

                       

                      {3'b100,1'b0}:begin //CP

                        wrEn=1;

                        addr_toRAM = iw_current[27:14];   //R2<- mem[IW[13:0]]

                        data_toRAM = data_fromRAM; // mem[IW[27:14]] <- R2

                        pc_next =pc_current + 1'b1; //PC+1

                        if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end

                       

                       {3'b100,1'b1}:begin //CPi

                        wrEn=1;

                        addr_toRAM = iw_current[27:14];  //R2<- IW[13:0]

                        data_toRAM = iw_current[13:0]; // mem[IW[27:14]] <- R2

                        pc_next =pc_current + 1'b1; //PC+1

                        if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end
                   

                    {3'b101,1'b0}:begin //CPI

                       wrEn=1;

                        addr_toRAM = iw_current[27:14];

                        data_toRAM = data_fromRAM; //mem[IW[27:14]] <- R2

                        pc_next =pc_current + 1'b1; //PC+1

                         if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end

     

                       {3'b101,1'b1}:begin //CPIi

                        wrEn=1;

                        addr_toRAM = r1_current;

                        data_toRAM = data_fromRAM; //mem[R1]<- R2

                        pc_next =pc_current + 1'b1; //PC+1

                        if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end

                       

                       {3'b110,1'b0}:begin //BZJ                                                

                        pc_next = (data_fromRAM==0) ? r1_current : (pc_current + 1'b1); //  PC<-(R2 == 0) ? R1 : (PC + 1)

                       if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end

                       

                    {3'b110,1'b1}:begin //BZJi

                        pc_next = data_fromRAM + r1_current; //PC<- (R1 + R2)

                        if(interrupt)begin

				state_next = 5;
				end

			else if(interrupt_flag_current)begin

				interrupt_flag_next = 0;

				state_next = 5;
				end

			else begin

				state_next = 1;

                    end
                    end                                                                     

                endcase

            end

           5:begin //interrupt stage 0

             if(interrupt)begin

             addr_toRAM = 5;

            end          

            end

            6:begin //interrupt stage 1

               addr_toRAM = 6;

               wrEn =1;            

               data_toRAM=pc_current;

               pc_next=data_fromRAM;

            end          

        endcase

    end

endmodule
