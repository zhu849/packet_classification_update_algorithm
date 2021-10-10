
module hashtable0_index_check
#(
    parameter SUBSET_NUM = 0,
    parameter INDEX_BIT_LEN=11,
    parameter PACKET_BIT_LEN=104,
    parameter COMMAND_BIT_LEN=2
)
(
    output reg smallorbig_segment,
    output reg [INDEX_BIT_LEN-1:0] seg_index,
    
    input we,//control hash memory table signal
    input [PACKET_BIT_LEN-1:0] tupleData,
    input clk
);

//hash related
localparam MAGIC_NUM = 32'b10000000000000001000000000000001;//0x80008001
localparam HASHTABLE_ENTRY_BIT_LEN=12;

(* KEEP = "TRUE" *) reg [15:0] seg_table_index; // store hashed index after hash function
(* KEEP = "TRUE" *) wire [HASHTABLE_ENTRY_BIT_LEN-1:0] hash_data; // get data from hash table

hashtable0_rom #(
    .SUBSET_NUM(SUBSET_NUM),
    .HASHTABLE_ENTRY_BIT_LEN(HASHTABLE_ENTRY_BIT_LEN)
)hashtable0_rom(
    .dout(hash_data),
    
    .din(0),//nothing write now, not have update
    .addr(seg_table_index),
    .we(we),
    .clk(clk)
);

always@(posedge clk)
begin
    // use srcIP first 16 bits prefix and dstIP first 16 bits prefix construct a hashkey
    //hashkey <= {ip[15:0],ip[47:32]};
    seg_table_index <= (({tupleData[15:0],tupleData[47:32]}) * (MAGIC_NUM)) >> 16;
    
    // split data that get from hash table
    smallorbig_segment <= hash_data[INDEX_BIT_LEN];
    seg_index <= hash_data[INDEX_BIT_LEN-1:0];
end
endmodule
