`timescale 1ns / 1ps

module hashtable0_index_check(
    output reg smallorbig_segment,
    output reg [10:0] seg_index,
    
    input we,//control hash memory table signal
    input [103:0] tupleData,
    input clk
);

//hash related
localparam magic_num = 32'b10000000000000001000000000000001;//0x80008001
(* KEEP = "TRUE" *) reg [15:0] seg_table_index; // store hashed index after hash function
(* KEEP = "TRUE" *) wire [11:0] hash_data; // get data from hash table

hashtable0_rom hashtable0_rom(
    .dout(hash_data),
    
    //.din(),
    .addr(seg_table_index),
    .we(we),
    .clk(clk)
);

always@(posedge clk)
begin
    // use srcIP first 16 bits prefix and dstIP first 16 bits prefix construct a hashkey
    //hashkey <= {ip[15:0],ip[47:32]};
    seg_table_index <= (({tupleData[15:0],tupleData[47:32]})&(magic_num)) >> 16;
    
    // split data that get from hash table
    smallorbig_segment <= hash_data[11];
    seg_index <= hash_data[10:0];
   
end
endmodule
