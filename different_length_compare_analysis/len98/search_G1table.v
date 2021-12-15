
module search_G1table
#(
    parameter SUBSET_NUM=0,
    parameter TABLE_NUM=0,
    parameter TABLE_ENTRY_SIZE=154,
    parameter INDEX_BIT_LEN=11,
    parameter PACKET_BIT_LEN=104,
    parameter COMMAND_BIT_LEN=2,
    parameter ENTRY_DATA_WIDTH=98
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


//G1's memory table
(* RAM_STYLE="DISTRIBUTED" *) reg [ENTRY_DATA_WIDTH-1:0] G1_table [TABLE_ENTRY_SIZE:0];

// accordding SUBSET_NUM and TABLE_NUM read different file from output
initial begin
    case(SUBSET_NUM)
        0:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset0_G1_table/table0.txt", G1_table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset0_G1_table/table1.txt", G1_table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset0_G1_table/table2.txt", G1_table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset0_G1_table/table3.txt", G1_table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
        1:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset1_G1_table/table0.txt", G1_table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset1_G1_table/table1.txt", G1_table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset1_G1_table/table2.txt", G1_table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset1_G1_table/table3.txt", G1_table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
        2:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset2_G1_table/table0.txt", G1_table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset2_G1_table/table1.txt", G1_table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset2_G1_table/table2.txt", G1_table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset2_G1_table/table3.txt", G1_table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
        3:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset3_G1_table/table0.txt", G1_table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset3_G1_table/table1.txt", G1_table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset3_G1_table/table2.txt", G1_table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset3_G1_table/table3.txt", G1_table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
    endcase
end

always@(posedge clk)
begin
    // assign next search index
    next_index <= G1_table[search_index][ENTRY_DATA_WIDTH-1:ENTRY_DATA_WIDTH-11];

    // compare logic
    if(G1_table[search_index][31:0] == tupleData[31:0])// compare srcIP
    begin
        if(G1_table[search_index][69:38] == tupleData[63:32])//compare dstIP
        begin
            match <= 1'b1;
            ruleID <= G1_table[search_index][ENTRY_DATA_WIDTH-12:ENTRY_DATA_WIDTH-22];
        end
    end
    
    //write to G1 table entry logic
    if(we)
        G1_table[search_index] <= din;
end

endmodule
