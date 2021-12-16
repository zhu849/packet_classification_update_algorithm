
module search_G4table
#(
    parameter SUBSET_NUM=0,
    parameter TABLE_NUM=0,
    parameter TABLE_ENTRY_SIZE=29,
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
    input [INDEX_BIT_LEN:0] search_index,
    input [PACKET_BIT_LEN-1:0] tupleData,
    input clk   
);

//G4's memory table
(* RAM_STYLE="DISTRIBUTED" *) reg [ENTRY_DATA_WIDTH-1:0] G4_table [TABLE_ENTRY_SIZE:0];

//accordding SUBSET_NUM and TABLE_NUM read different file from output
initial begin
    case(SUBSET_NUM)
        0:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset0_G4_table/table0.txt", G4_table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset0_G4_table/table1.txt", G4_table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset0_G4_table/table2.txt", G4_table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset0_G4_table/table3.txt", G4_table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
        1:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset1_G4_table/table0.txt", G4_table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset1_G4_table/table1.txt", G4_table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset1_G4_table/table2.txt", G4_table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset1_G4_table/table3.txt", G4_table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
        2:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset2_G4_table/table0.txt", G4_table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset2_G4_table/table1.txt", G4_table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset2_G4_table/table2.txt", G4_table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset2_G4_table/table3.txt", G4_table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
        3:begin
            case(TABLE_NUM)
                0: $readmemb("D:/YuHang_update/subset3_G3_table/table0.txt", G4_table, 0, TABLE_ENTRY_SIZE);
                1: $readmemb("D:/YuHang_update/subset3_G3_table/table1.txt", G4_table, 0, TABLE_ENTRY_SIZE);
                2: $readmemb("D:/YuHang_update/subset3_G3_table/table2.txt", G4_table, 0, TABLE_ENTRY_SIZE);
                3: $readmemb("D:/YuHang_update/subset3_G3_table/table3.txt", G4_table, 0, TABLE_ENTRY_SIZE);
            endcase
        end
    endcase
end


always@(posedge clk)
begin
    // assign next search index
    next_index <= G4_table[search_index][170:160];

    // compare logic
    if(G4_table[search_index][31:0] == tupleData[31:0])// compare srcIP
    begin
        if(G4_table[search_index][69:38] == tupleData[63:32])//compare dstIP
        begin
            if((G4_table[search_index][107:92] < tupleData[79:64]) & (tupleData[79:64] < G4_table[search_index][91:76]))// compare srcPort
            begin
                if((G4_table[search_index][139:124] < tupleData[79:64]) & (tupleData[79:64] < G4_table[search_index][123:108]))// compare dstPort
                begin 
                    if(G4_table[search_index][148] | (G4_table[search_index][139:124] == tupleData[103:96]))// compare protocol
                    begin
                        match <= 1'b1;
                        ruleID <= G4_table[search_index][159:149];
                    end
                end
            end
        end
    end
    
    //write to G4 table entry logic
    if(we)
        G4_table[search_index] <= din;    
end
endmodule


/*
// get result from memory
wire [170:0] mem_data_w;
G4_table_rom
#(
    .SUBSET_NUM(SUBSET_NUM),
    .TABLE_NUM(TABLE_NUM),
    .TABLE_ENTRY_SIZE(TABLE_ENTRY_SIZE)
)
G4_table_rom(
    .dout(mem_data_w),

    //.din(),
    .addr(search_index),
    .we(1'b0),
    .clk(clk)
);
*/