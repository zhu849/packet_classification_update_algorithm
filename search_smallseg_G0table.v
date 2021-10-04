`timescale 1ns / 1ps

module search_smallseg_G0table
#(
    parameter SUBSET_NUM=0,
    parameter TABLE_NUM=0,
    parameter TABLE_ENTRY_SIZE=1738
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

//small segment and G0's memory table
(* ram_style = "distributed" *) reg [170:0] smallseg_G0table [TABLE_ENTRY_SIZE:0];

// get from distributed RAM
wire [10:0] ruleID_w;
wire [10:0] next_index_w;


/*
// get result from memory
wire [170:0] mem_data_w;
smallseg_G0table_rom
#(
    .SUBSET_NUM(SUBSET_NUM),
    .TABLE_NUM(TABLE_NUM),
    .TABLE_ENTRY_SIZE(TABLE_ENTRY_SIZE)
)
smallseg_G0table_rom
(
    .dout(mem_data_w),

    //.din(),
    .addr(search_index),
    .we(we),
    .clk(clk)
);
*/

initial begin
    if(SUBSET_NUM == 0)
    begin
        if(TABLE_NUM == 0)
        begin
            $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table0.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 1)
        begin
            $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table1.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 2)
        begin
            $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table2.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 3)
        begin
            $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table3.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 4)
        begin
            $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table4.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 5)
        begin
            $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table5.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 6)
        begin
            $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table6.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 7)
        begin
            $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table7.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 8)
        begin
            $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table8.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else 
        begin
            $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table9.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
     end
    if(SUBSET_NUM == 1)
    begin
        if(TABLE_NUM == 0)
        begin
            $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table0.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 1)
        begin
            $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table1.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 2)
        begin
            $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table2.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 3)
        begin
            $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table3.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 4)
        begin
            $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table4.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 5)
        begin
            $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table5.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 6)
        begin
            $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table6.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 7)
        begin
            $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table7.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 8)
        begin
            $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table8.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else 
        begin
            $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table9.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end       
    end
    if(SUBSET_NUM == 2)
    begin
        if(TABLE_NUM == 0)
        begin
            $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table0.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 1)
        begin
            $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table1.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 2)
        begin
            $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table2.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 3)
        begin
            $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table3.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 4)
        begin
            $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table4.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 5)
        begin
            $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table5.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 6)
        begin
            $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table6.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 7)
        begin
            $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table7.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 8)
        begin
            $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table8.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else 
        begin
            $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table9.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end       
    end
    if(SUBSET_NUM == 3)
    begin
        if(TABLE_NUM == 0)
        begin
            $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table0.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 1)
        begin
            $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table1.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 2)
        begin
            $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table2.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 3)
        begin
            $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table3.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 4)
        begin
            $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table4.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 5)
        begin
            $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table5.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 6)
        begin
            $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table6.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 7)
        begin
            $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table7.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else if(TABLE_NUM == 8)
        begin
            $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table8.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end
        else 
        begin
            $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table9.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
        end       
    end
end



always@(posedge clk)
begin
    // assign next search index
    next_index <= smallseg_G0table[search_index][170:160];
    
    // compare logic
    if(smallseg_G0table[search_index][31:0] == tupleData[31:0])// compare srcIP
    begin
        if(smallseg_G0table[search_index][69:38] == tupleData[63:32])//compare dstIP
        begin
            if((smallseg_G0table[search_index][107:92] <= tupleData[79:64]) && (tupleData[79:64] <= smallseg_G0table[search_index][91:76]))// compare srcPort
            begin
                if((smallseg_G0table[search_index][139:124] <= tupleData[79:64]) && (tupleData[79:64] <= smallseg_G0table[search_index][123:108]))// compare dstPort
                begin 
                    if(smallseg_G0table[search_index][148] || smallseg_G0table[search_index][139:124] == tupleData[103:96])// compare protocol
                    begin
                        match <= 1'b1;
                        ruleID <= smallseg_G0table[search_index][159:149];
                    end
                end
            end
        end
    end
    
    //write to G0 table entry logic
    if(we)
        smallseg_G0table[search_index] <= din;// not use real din
end

endmodule
