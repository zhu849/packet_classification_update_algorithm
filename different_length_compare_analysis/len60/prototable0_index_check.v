
module prototable0_index_check#(
    parameter SUBSET_NUM = 0,
    parameter INDEX_BIT_LEN = 11,
    parameter PACKET_BIT_LEN = 104,
    parameter COMMAND_BIT_LEN = 2,
    parameter PROTOCOL_TABLE_SIZE=0,
    parameter DIN_BIT_LEN=33 // it will be INDEX_BIT_LEN*3
)
(
    output reg [INDEX_BIT_LEN-1:0] searchG0_index,
    output reg [INDEX_BIT_LEN-1:0] searchG1_index,
    output reg [INDEX_BIT_LEN-1:0] searchG2_index,
    output reg [INDEX_BIT_LEN-1:0] searchG3_index,
    output reg [INDEX_BIT_LEN-1:0] searchG4_index,
    output reg [INDEX_BIT_LEN-1:0] searchG4_others_index,// use to search other table's index
    
    input we,
    input [DIN_BIT_LEN:0] din,
    input [PACKET_BIT_LEN-1:0] tupleData,
    input [INDEX_BIT_LEN-1:0] group0_index,
    input [INDEX_BIT_LEN-1:0] group1_index,
    input [INDEX_BIT_LEN-1:0] group2_index,
    input [INDEX_BIT_LEN-1:0] group3_index,
    input [INDEX_BIT_LEN-1:0] group4_table_index,// use to search protocol table's index
    input group4_smallorbiggroup,
    input clk
);


(* RAM_STYLE="DISTRIBUTED" *) reg [DIN_BIT_LEN-1:0] protocol_table [PROTOCOL_TABLE_SIZE-1:0]; // protocol entry is 11 + 11 + 11 bits, for tcp, udp, others field
initial begin
    if(SUBSET_NUM == 0)
        $readmemb("D:/YuHang_update/protocol_table/subset0_protocol_table.txt", protocol_table, 0, PROTOCOL_TABLE_SIZE-1);
    else if(SUBSET_NUM == 1)
        $readmemb("D:/YuHang_update/protocol_table/subset1_protocol_table.txt", protocol_table, 0, PROTOCOL_TABLE_SIZE-1);
    else if(SUBSET_NUM == 2)
        $readmemb("D:/YuHang_update/protocol_table/subset2_protocol_table.txt", protocol_table, 0, PROTOCOL_TABLE_SIZE-1);
    else
        $readmemb("D:/YuHang_update/protocol_table/subset3_protocol_table.txt", protocol_table, 0, PROTOCOL_TABLE_SIZE-1);
end

always@(posedge clk)
begin
    searchG0_index <= group0_index;
    searchG1_index <= group1_index;
    searchG2_index <= group2_index;
    searchG3_index <= group3_index;
    
    // check whether group4 is big group or small group
    // use to search big segment big group
    // group4 is big group
    if(group4_smallorbiggroup)
    begin
        if(tupleData[103:96]==8'd6) // protocol type is TCP
            searchG4_index <= protocol_table[searchG4_index][32:22];
        else if (tupleData[103:96]==8'd17) // protocol type is UDP
            searchG4_index <= protocol_table[searchG4_index][21:11];
    end
    else // group4 is small group
        searchG4_index <= group4_table_index;
        
    //assign other table index
    searchG4_others_index <= protocol_table[searchG4_index][10:0];
    
    if(we)
        protocol_table[searchG4_index] <= din;
end
endmodule
