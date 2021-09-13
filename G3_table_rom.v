`timescale 1ns / 1ps

module G3_table_rom
#(
    parameter SUBSET_NUM=0,
    parameter TABLE_NUM=0,
    parameter TABLE_ENTRY_SIZE=0
)
(
    output reg [170:0]dout, // srcIP: 32bits, srcIP len: 6bits, DstIP: 32bits, DstIP len: 6bits, src prot upper: 16bits, src port lower: 16bits, dst port upper: 16bits, dst port lower: 16bits, protocol: 8 bits, wildcard: 1bit, ruleID: 11 bits, index: 11 bits
    
    input [170:0] din,
    input [10:0] addr, // index bits is 11(it should cover 1738 entrys)
    input we, //write or read, 0 = read, 1 = wirte
    input clk
);

//G3's memory table
(* RAM_STYLE="DISTRIBUTED" *) reg [170:0] G3_table [TABLE_ENTRY_SIZE:0];

initial begin
    if(SUBSET_NUM == 0)
    begin
        if(TABLE_NUM == 0)
            $readmemb("D:\YuHang_update\subset0_G3_table\table0.txt", G3_table, 0, TABLE_ENTRY_SIZE);
        else if(TABLE_NUM == 1)
            $readmemb("D:\YuHang_update\subset0_G3_table\table1.txt", G3_table, 0, TABLE_ENTRY_SIZE);
        else if(TABLE_NUM == 2)
            $readmemb("D:\YuHang_update\subset0_G3_table\table2.txt", G3_table, 0, TABLE_ENTRY_SIZE);
        else if(TABLE_NUM == 3)
            $readmemb("D:\YuHang_update\subset0_G3_table\table3.txt", G3_table, 0, TABLE_ENTRY_SIZE);
    end
    else if(SUBSET_NUM == 1)
    begin
        if(TABLE_NUM == 0)
            $readmemb("D:\YuHang_update\subset1_G3_table\table0.txt", G3_table, 0, TABLE_ENTRY_SIZE);
        else if(TABLE_NUM == 1)
            $readmemb("D:\YuHang_update\subset1_G3_table\table1.txt", G3_table, 0, TABLE_ENTRY_SIZE);
        else if(TABLE_NUM == 2)
            $readmemb("D:\YuHang_update\subset1_G3_table\table2.txt", G3_table, 0, TABLE_ENTRY_SIZE);
        else if(TABLE_NUM == 3)
            $readmemb("D:\YuHang_update\subset1_G3_table\table3.txt", G3_table, 0, TABLE_ENTRY_SIZE);    
    end
    else if(SUBSET_NUM == 2)
    begin
        if(TABLE_NUM == 0)
            $readmemb("D:\YuHang_update\subset2_G3_table\table0.txt", G3_table, 0, TABLE_ENTRY_SIZE);
        else if(TABLE_NUM == 1)
            $readmemb("D:\YuHang_update\subset2_G3_table\table1.txt", G3_table, 0, TABLE_ENTRY_SIZE);
        else if(TABLE_NUM == 2)
            $readmemb("D:\YuHang_update\subset2_G3_table\table2.txt", G3_table, 0, TABLE_ENTRY_SIZE);
        else if(TABLE_NUM == 3)
            $readmemb("D:\YuHang_update\subset2_G3_table\table3.txt", G3_table, 0, TABLE_ENTRY_SIZE);
    end
    else if(SUBSET_NUM == 3)
    begin
        if(TABLE_NUM == 0)
            $readmemb("D:\YuHang_update\subset3_G3_table\table0.txt", G3_table, 0, TABLE_ENTRY_SIZE);
        else if(TABLE_NUM == 1)
            $readmemb("D:\YuHang_update\subset3_G3_table\table1.txt", G3_table, 0, TABLE_ENTRY_SIZE);
        else if(TABLE_NUM == 2)
            $readmemb("D:\YuHang_update\subset3_G3_table\table2.txt", G3_table, 0, TABLE_ENTRY_SIZE);
        else if(TABLE_NUM == 3)
            $readmemb("D:\YuHang_update\subset3_G3_table\table3.txt", G3_table, 0, TABLE_ENTRY_SIZE);
    end    
end

always@(posedge clk)
begin
    if(we)
        G3_table[addr] <= din;
    else
        dout <= G3_table[addr];
end

endmodule
