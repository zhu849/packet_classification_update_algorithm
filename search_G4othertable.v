`timescale 1ns / 1ps

module search_G4othertable
#(
    parameter SUBSET_NUM=0,
    parameter TABLE_NUM=0,
    parameter TABLE_ENTRY_SIZE=0
)
(
    output reg match,
    output reg [10:0] ruleID,
    output reg [10:0] next_index,
    
    input we,
    input [170:0] din,
    input [10:0] search_index,
    input [103:0] tupleData,
    input clk   
);

//G4 protocol other's memory table
(* RAM_STYLE="DISTRIBUTED" *) reg [170:0] G4_other_table [TABLE_ENTRY_SIZE:0];

initial begin
    if(SUBSET_NUM == 0)
    begin
        if(TABLE_NUM == 0)
        begin
            $readmemb("D:/YuHang_update/subset0_G4_other_table/table0.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 1)
        begin
            $readmemb("D:/YuHang_update/subset0_G4_other_table/table1.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 2)
        begin
            $readmemb("D:/YuHang_update/subset0_G4_other_table/table2.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 3)
        begin
            $readmemb("D:/YuHang_update/subset0_G4_other_table/table3.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 4)
        begin
            $readmemb("D:/YuHang_update/subset0_G4_other_table/table4.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 5)
        begin
            $readmemb("D:/YuHang_update/subset0_G4_other_table/table5.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 6)
        begin
            $readmemb("D:/YuHang_update/subset0_G4_other_table/table6.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 7)
        begin
            $readmemb("D:/YuHang_update/subset0_G4_other_table/table7.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 8)
        begin
            $readmemb("D:/YuHang_update/subset0_G4_other_table/table8.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else 
        begin
            $readmemb("D:/YuHang_update/subset0_G4_other_table/table9.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
     end
    if(SUBSET_NUM == 1)
    begin
        if(TABLE_NUM == 0)
        begin
            $readmemb("D:/YuHang_update/subset1_G4_other_table/table0.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 1)
        begin
            $readmemb("D:/YuHang_update/subset1_G4_other_table/table1.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 2)
        begin
            $readmemb("D:/YuHang_update/subset1_G4_other_table/table2.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 3)
        begin
            $readmemb("D:/YuHang_update/subset1_G4_other_table/table3.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 4)
        begin
            $readmemb("D:/YuHang_update/subset1_G4_table/table4.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 5)
        begin
            $readmemb("D:/YuHang_update/subset1_G4_other_table/table5.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 6)
        begin
            $readmemb("D:/YuHang_update/subset1_G4_other_table/table6.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 7)
        begin
            $readmemb("D:/YuHang_update/subset1_G4_other_table/table7.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 8)
        begin
            $readmemb("D:/YuHang_update/subset1_G4_other_table/table8.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else 
        begin
            $readmemb("D:/YuHang_update/subset1_G4_other_table/table9.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end       
    end
    if(SUBSET_NUM == 2)
    begin
        if(TABLE_NUM == 0)
        begin
            $readmemb("D:/YuHang_update/subset2_G4_other_table/table0.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 1)
        begin
            $readmemb("D:/YuHang_update/subset2_G4_other_table/table1.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 2)
        begin
            $readmemb("D:/YuHang_update/subset2_G4_other_table/table2.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 3)
        begin
            $readmemb("D:/YuHang_update/subset2_G4_other_table/table3.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 4)
        begin
            $readmemb("D:/YuHang_update/subset2_G4_other_table/table4.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 5)
        begin
            $readmemb("D:/YuHang_update/subset2_G4_other_table/table5.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 6)
        begin
            $readmemb("D:/YuHang_update/subset2_G4_other_table/table6.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 7)
        begin
            $readmemb("D:/YuHang_update/subset2_G4_other_table/table7.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 8)
        begin
            $readmemb("D:/YuHang_update/subset2_G4_other_table/table8.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else 
        begin
            $readmemb("D:/YuHang_update/subset2_G4_other_table/table9.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end       
    end
    if(SUBSET_NUM == 3)
    begin
        if(TABLE_NUM == 0)
        begin
            $readmemb("D:/YuHang_update/subset3_G4_other_table/table0.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 1)
        begin
            $readmemb("D:/YuHang_update/subset3_G4_other_table/table1.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 2)
        begin
            $readmemb("D:/YuHang_update/subset3_G4_other_table/table2.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 3)
        begin
            $readmemb("D:/YuHang_update/subset3_G4_other_table/table3.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 4)
        begin
            $readmemb("D:/YuHang_update/subset3_G4_other_table/table4.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 5)
        begin
            $readmemb("D:/YuHang_update/subset3_G4_other_table/table5.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 6)
        begin
            $readmemb("D:/YuHang_update/subset3_G4_other_table/table6.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 7)
        begin
            $readmemb("D:/YuHang_update/subset3_G4_other_table/table7.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 8)
        begin
            $readmemb("D:/YuHang_update/subset3_G4_other_table/table8.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end
        else 
        begin
            $readmemb("D:/YuHang_update/subset3_G4_other_table/table9.txt", G4_other_table, 0, TABLE_ENTRY_SIZE);
        end       
    end
end

always@(posedge clk)
begin
    // assign next search index
    next_index <= G4_other_table[search_index][170:160];

    // compare logic
    if(G4_other_table[search_index][31:0] == tupleData[31:0])// compare srcIP
    begin
        if(G4_other_table[search_index][69:38] == tupleData[63:32])//compare dstIP
        begin
            if((G4_other_table[search_index][107:92] <= tupleData[79:64]) && (tupleData[79:64] <= G4_other_table[search_index][91:76]))// compare srcPort
            begin
                if((G4_other_table[search_index][139:124] <= tupleData[79:64]) && (tupleData[79:64] <= G4_other_table[search_index][123:108]))// compare dstPort
                begin 
                    if(G4_other_table[search_index][148] || G4_other_table[search_index][139:124] == tupleData[103:96])// compare protocol
                    begin
                        match <= 1'b1;
                        ruleID <= G4_other_table[search_index][159:149];
                    end
                end
            end
        end
    end
    
    //write to G4 table entry logic
    if(we)
        G4_other_table[search_index] <= din;    
end

endmodule
