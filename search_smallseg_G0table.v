
module search_smallseg_G0table
#(
    parameter SUBSET_NUM=0,
    parameter TABLE_NUM=0,
    parameter TABLE_ENTRY_SIZE=1738,
    parameter INDEX_BIT_LEN=11,
    parameter PACKET_BIT_LEN=104,
    parameter COMMAND_BIT_LEN=2,
    parameter ENTRY_DATA_WIDTH=171
)
(
    output reg match,
    output reg [INDEX_BIT_LEN-1:0] ruleID,
    output reg [INDEX_BIT_LEN-1:0] next_index,
    
    input we,
    input [ENTRY_DATA_WIDTH-1:0] din,
    input [INDEX_BIT_LEN-1:0] search_index,
    input [PACKET_BIT_LEN-1:0] tupleData,
    input clk
);

//small segment and G0's memory table
(* ram_style = "distributed" *) reg [ENTRY_DATA_WIDTH-1:0] smallseg_G0table [TABLE_ENTRY_SIZE:0];

// accordding SUBSET_NUM and TABLE_NUM read different file from output
initial begin
    case(SUBSET_NUM)
        0:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table0.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table1.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table2.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table3.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                4: $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table4.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                5: $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table5.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                6: $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table6.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                7: $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table7.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                8: $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table8.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                9: $readmemb("D:/YuHang_update/subset0_smallsegG0_table/table9.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
        1:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table0.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table1.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table2.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table3.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                4: $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table4.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                5: $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table5.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                6: $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table6.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                7: $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table7.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                8: $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table8.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                9: $readmemb("D:/YuHang_update/subset1_smallsegG0_table/table9.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
        2:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table0.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table1.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table2.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table3.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                4: $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table4.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                5: $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table5.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                6: $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table6.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                7: $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table7.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                8: $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table8.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                9: $readmemb("D:/YuHang_update/subset2_smallsegG0_table/table9.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
        3:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table0.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table1.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table2.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table3.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                4: $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table4.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                5: $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table5.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                6: $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table6.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                7: $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table7.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                8: $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table8.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
                9: $readmemb("D:/YuHang_update/subset3_smallsegG0_table/table9.txt", smallseg_G0table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
    endcase
end

always@(posedge clk)
begin
    // assign next search index     
    next_index <= smallseg_G0table[search_index][170:160];
    
    // compare logic
    if(smallseg_G0table[search_index][31:0] == tupleData[31:0]) // compare srcIP,
    begin
        if(smallseg_G0table[search_index][69:38] == tupleData[63:32]) //compare dstIP,
        begin
            if((smallseg_G0table[search_index][107:92] < tupleData[79:64]) & (tupleData[79:64] < smallseg_G0table[search_index][91:76])) // compare srcPort
            begin
                if((smallseg_G0table[search_index][139:124] < tupleData[79:64]) & (tupleData[79:64] < smallseg_G0table[search_index][123:108])) // compare dstPort
                begin 
                    // smallseg_G0table[search_index][148] is wildcard
                    if(smallseg_G0table[search_index][148] | (smallseg_G0table[search_index][139:124] == tupleData[103:96])) // compare protocol
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
        smallseg_G0table[search_index] <= din;
end
endmodule


/*
// get from distributed RAM
wire [INDEX_BIT_LEN-1:0] ruleID_w;
wire [INDEX_BIT_LEN-1:0] next_index_w;
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