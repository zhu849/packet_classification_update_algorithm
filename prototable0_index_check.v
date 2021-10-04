`timescale 1ns / 1ps

module prototable0_index_check(
    output reg [10:0] searchG0_index,
    output reg [10:0] searchG1_index,
    output reg [10:0] searchG2_index,
    output reg [10:0] searchG3_index,
    output reg [10:0] searchG4_index,
    output reg [10:0] searchG4_others_index,// use to search other table's index
    
    input we,
    input [32:0] din,
    input [103:0] tupleData,
    input [10:0] group0_index,
    input [10:0] group1_index,
    input [10:0] group2_index,
    input [10:0] group3_index,
    input [10:0] group4_table_index,// use to search protocol table's index
    input group4_smallorbiggroup,
    input clk
);

// Protocol (udp, tcp, others) index table
localparam protocol_table_size = 0;
(* RAM_STYLE="DISTRIBUTED" *) reg [32:0] protocol_table [protocol_table_size-1:0]; // protocol entry is 11 + 11 + 11 bits, for tcp, udp, others field
initial begin
    $readmemb("D:/YuHang_update/protocol_table/subset0_protocol_table.txt", protocol_table, 0, protocol_table_size-1);
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
        begin
            searchG4_index <= protocol_table[searchG4_index][32:22];
        end
        else if (tupleData[103:96]==8'd17) // protocol type is UDP
        begin
            searchG4_index <= protocol_table[searchG4_index][21:11];
        end
    end
    else
    begin
        searchG4_index <= group4_table_index;
    end
    
    searchG4_others_index <= protocol_table[searchG4_index][10:0];
    
    if(we)
    begin
        protocol_table[searchG4_index] <= din;
    end
    
end
endmodule
