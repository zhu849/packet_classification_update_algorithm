
module search_G2table
#(
    parameter SUBSET_NUM=0,
    parameter TABLE_NUM=0,
    parameter TABLE_ENTRY_SIZE=18,
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

//G2's memory table
(* RAM_STYLE="DISTRIBUTED" *) reg [ENTRY_DATA_WIDTH-1:0] G2_table [TABLE_ENTRY_SIZE:0];

//accordding SUBSET_NUM and TABLE_NUM read different file from output
initial begin
    case(SUBSET_NUM)
        0:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset0_G2_table/table0.txt", G2_table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset0_G2_table/table1.txt", G2_table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset0_G2_table/table2.txt", G2_table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset0_G2_table/table3.txt", G2_table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
        1:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset1_G2_table/table0.txt", G2_table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset1_G2_table/table1.txt", G2_table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset1_G2_table/table2.txt", G2_table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset1_G2_table/table3.txt", G2_table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
        2:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset2_G2_table/table0.txt", G2_table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset2_G2_table/table1.txt", G2_table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset2_G2_table/table2.txt", G2_table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset2_G2_table/table3.txt", G2_table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
        3:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset3_G2_table/table0.txt", G2_table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset3_G2_table/table1.txt", G2_table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset3_G2_table/table2.txt", G2_table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset3_G2_table/table3.txt", G2_table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
    endcase
end

always@(posedge clk)
begin
    // assign next search index
    next_index <= G2_table[search_index][ENTRY_DATA_WIDTH-1:ENTRY_DATA_WIDTH-11];

    // compare logic
    if(G2_table[search_index][31:0] == tupleData[31:0])// compare srcIP
    begin
        if(G2_table[search_index][69:38] == tupleData[63:32])//compare dstIP
        begin
            match <= 1'b1;
            ruleID <= G2_table[search_index][ENTRY_DATA_WIDTH-12:ENTRY_DATA_WIDTH-22];
        end
    end
    
    //write to G2 table entry logic
    if(we)
        G2_table[search_index] <= din;
end
endmodule

/*
// get result from memory
wire [170:0] mem_data_w;
G2_table_rom
#(
    .SUBSET_NUM(SUBSET_NUM),
    .TABLE_NUM(TABLE_NUM),
    .TABLE_ENTRY_SIZE(TABLE_ENTRY_SIZE)
)
G2_table_rom(
    .dout(mem_data_w),

    //.din(),
    .addr(search_index),
    .we(1'b0),
    .clk(clk)
);
*/
