
module subset3_group_index_check#(
    parameter INDEX_BIT_LEN=11,
    parameter PACKET_BIT_LEN=104
)(
    output reg [INDEX_BIT_LEN-1:0] group0_index,
    output reg [INDEX_BIT_LEN-1:0] group1_index,
    output reg [INDEX_BIT_LEN-1:0] group2_index,
    output reg [INDEX_BIT_LEN-1:0] group3_index,
    output reg [INDEX_BIT_LEN-1:0] group4_table_index,
    output reg group4_smallorbiggroup,
    
    input [PACKET_BIT_LEN-1:0] tupleData,
    input clk
 );
    
//hash related
localparam magic_num = 32'b10000000000000001000000000000001;//0x80008001

wire [59:0] index_table; 
assign index_table[59:0] = 60'b0;

always@(posedge clk)
begin
    //check if it is big group or small group
    // G0 is big group
    if(index_table[48])
       group0_index <= (tupleData[31:0] & magic_num) >> (32-INDEX_BIT_LEN);// hashkey = tupleData[31:0]
    else // G0 is samll group
       group0_index <= index_table[59:49];
 
    //G1 is big group
    if(index_table[36])
        group1_index <= (tupleData[63:32] & magic_num) >> (32-INDEX_BIT_LEN);// hashkey = tupleData[63:32]
    else
        group1_index <= index_table[47:37];
    
    //G2 is big group
    if(index_table[24])
        group2_index <= (tupleData[79:64] & magic_num) >> (32-INDEX_BIT_LEN);// hashkey = tupleData[63:32]
    else 
        group2_index <= index_table[35:25];
    
    //G3 is big group
    if(index_table[12])
        group3_index <= (tupleData[95:80] & magic_num) >> (32-INDEX_BIT_LEN);// hashkey = tupleData[63:32]
    else
        group3_index <= index_table[23:13];
    
    // G4 just output, let next stage to check protocol entry
    group4_table_index <= index_table[12:1];
    group4_smallorbiggroup <= index_table[0];
end
endmodule
