`timescale 1ns / 1ps

module smallseg_G0table_rom
#(
    parameter SUBSET_NUM=0,
    parameter TABLE_NUM=0,
    parameter TABLE_ENTRY_SIZE=1738
)
(
    output reg [170:0]dout, // srcIP: 32bits, srcIP len: 6bits, DstIP: 32bits, DstIP len: 6bits, src prot upper: 16bits, src port lower: 16bits, dst port upper: 16bits, dst port lower: 16bits, protocol: 8 bits, wildcard: 1bit, ruleID: 11 bits, index: 11 bits
    
    input [170:0] din,
    input [10:0] addr, // index bits is 11(it should cover 1738 entrys)
    input we, //write or read, 0 = read, 1 = wirte
    input clk
 );
    
//small segment and G0's memory table
(* RAM_STYLE="BLOCK" *) reg [171:0] smallseg_G0table [TABLE_ENTRY_SIZE:0];

initial begin
    if(SUBSET_NUM == 0)
    begin
        if(TABLE_NUM == 0)
        begin
            $readmemb("D:\YuHang_update\subset0_smallsegG0_table\table0.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 1)
        begin
            $readmemb("D:\YuHang_update\subset0_smallsegG0_table\table1.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 2)
        begin
            $readmemb("D:\YuHang_update\subset0_smallsegG0_table\table2.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 3)
        begin
            $readmemb("D:\YuHang_update\subset0_smallsegG0_table\table3.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 4)
        begin
            $readmemb("D:\YuHang_update\subset0_smallsegG0_table\table4.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 5)
        begin
            $readmemb("D:\YuHang_update\subset0_smallsegG0_table\table5.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 6)
        begin
            $readmemb("D:\YuHang_update\subset0_smallsegG0_table\table6.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 7)
        begin
            $readmemb("D:\YuHang_update\subset0_smallsegG0_table\table7.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 8)
        begin
            $readmemb("D:\YuHang_update\subset0_smallsegG0_table\table8.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else 
        begin
            $readmemb("D:\YuHang_update\subset0_smallsegG0_table\table9.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
     end
    if(SUBSET_NUM == 1)
    begin
        if(TABLE_NUM == 0)
        begin
            $readmemb("D:\YuHang_update\subset1_smallsegG0_table\table0.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 1)
        begin
            $readmemb("D:\YuHang_update\subset1_smallsegG0_table\table1.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 2)
        begin
            $readmemb("D:\YuHang_update\subset1_smallsegG0_table\table2.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 3)
        begin
            $readmemb("D:\YuHang_update\subset1_smallsegG0_table\table3.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 4)
        begin
            $readmemb("D:\YuHang_update\subset1_smallsegG0_table\table4.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 5)
        begin
            $readmemb("D:\YuHang_update\subset1_smallsegG0_table\table5.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 6)
        begin
            $readmemb("D:\YuHang_update\subset1_smallsegG0_table\table6.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 7)
        begin
            $readmemb("D:\YuHang_update\subset1_smallsegG0_table\table7.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 8)
        begin
            $readmemb("D:\YuHang_update\subset1_smallsegG0_table\table8.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else 
        begin
            $readmemb("D:\YuHang_update\subset1_smallsegG0_table\table9.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end       
    end
    if(SUBSET_NUM == 2)
    begin
        if(TABLE_NUM == 0)
        begin
            $readmemb("D:\YuHang_update\subset2_smallsegG0_table\table0.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 1)
        begin
            $readmemb("D:\YuHang_update\subset2_smallsegG0_table\table1.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 2)
        begin
            $readmemb("D:\YuHang_update\subset2_smallsegG0_table\table2.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 3)
        begin
            $readmemb("D:\YuHang_update\subset2_smallsegG0_table\table3.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 4)
        begin
            $readmemb("D:\YuHang_update\subset2_smallsegG0_table\table4.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 5)
        begin
            $readmemb("D:\YuHang_update\subset2_smallsegG0_table\table5.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 6)
        begin
            $readmemb("D:\YuHang_update\subset2_smallsegG0_table\table6.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 7)
        begin
            $readmemb("D:\YuHang_update\subset2_smallsegG0_table\table7.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 8)
        begin
            $readmemb("D:\YuHang_update\subset2_smallsegG0_table\table8.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else 
        begin
            $readmemb("D:\YuHang_update\subset2_smallsegG0_table\table9.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end       
    end
    if(SUBSET_NUM == 3)
    begin
        if(TABLE_NUM == 0)
        begin
            $readmemb("D:\YuHang_update\subset3_smallsegG0_table\table0.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 1)
        begin
            $readmemb("D:\YuHang_update\subset3_smallsegG0_table\table1.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 2)
        begin
            $readmemb("D:\YuHang_update\subset3_smallsegG0_table\table2.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 3)
        begin
            $readmemb("D:\YuHang_update\subset3_smallsegG0_table\table3.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 4)
        begin
            $readmemb("D:\YuHang_update\subset3_smallsegG0_table\table4.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 5)
        begin
            $readmemb("D:\YuHang_update\subset3_smallsegG0_table\table5.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 6)
        begin
            $readmemb("D:\YuHang_update\subset3_smallsegG0_table\table6.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 7)
        begin
            $readmemb("D:\YuHang_update\subset3_smallsegG0_table\table7.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 8)
        begin
            $readmemb("D:\YuHang_update\subset3_smallsegG0_table\table8.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else 
        begin
            $readmemb("D:\YuHang_update\subset3_smallsegG0_table\table9.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end       
    end
end

always@(posedge clk)
begin
    if(we)
        smallseg_G0table[addr] <= din;
    else
        dout <= smallseg_G0table[addr];
end

endmodule
