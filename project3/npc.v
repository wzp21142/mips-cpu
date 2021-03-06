module npc_module(PC_change_flag,npc_sel,zero,pc,imout,regadd,npc,bgezal_flag,opcode,epc);
  input zero,PC_change_flag,bgezal_flag;
  input [2:0]npc_sel;//00:+4,01:beq,10:j/jal,11:jr
  input [31:0]imout,regadd;
  input [31:0]pc;
  input [31:0]epc;
  input [5:0]opcode;
  output [31:0]npc;
  reg [31:0]npc;
  wire [31:0]t4,t3,t2,t1,t0,extout,temp;
  wire [15:0]imm;
  assign imm=imout[15:0];
  assign temp={{16{imm[15]}},imm};
  assign t0=pc+4;
  assign extout=temp<<2;
  assign t1=t0+extout;
  assign t2={t0[31:28],imout[25:0],1'b0,1'b0};
  assign t3=regadd;
  assign t4=epc;
  always@(npc_sel or PC_change_flag)
    begin
      if(PC_change_flag||npc_sel==2'b11)
     case(npc_sel)
        3'b00:npc=t0;
        3'b001:begin if(opcode==6'b000001) begin 
          npc=bgezal_flag?t1:t0; 
          if(bgezal_flag) $display($time,,"BGEZAL happening: PC <= %h", npc);
        end
        else if(opcode==6'b000100) begin 
          npc=zero?t1:t0; 
          if(zero) $display($time,,"BEQ happening: PC <= %h", npc);
        end
            end
        3'b010:begin npc=t2;$display($time,,"J/JAL happening: PC <= %h", npc); end
        3'b011:begin npc=t3;$display($time,,"JR happening: PC <= %h", npc);end
        3'b100:begin npc=t4;$display($time,,"ERET happening: PC <= %h", npc);end
        3'b101:begin npc=32'h0000_4180;$display($time,,"exception happening: PC <= %h", npc);end  
      endcase
    end
endmodule