
module bigsegtable0_index_check#(
    parameter SUBSET_NUM=0,
    parameter INDEX_BIT_LEN=11,
    parameter PACKET_BIT_LEN=104,
    parameter COMMAND_BIT_LEN=2,
    parameter BIGSEGMENT_NUM=184,
    parameter BIGSEGMENT_BIT_LEN=8,
    parameter DIN_BIT_LEN=60
)(
    output reg [INDEX_BIT_LEN-1:0] group0_index,
    output reg [INDEX_BIT_LEN-1:0] group1_index,
    output reg [INDEX_BIT_LEN-1:0] group2_index,
    output reg [INDEX_BIT_LEN-1:0] group3_index,
    output reg [INDEX_BIT_LEN-1:0] group4_table_index,
    output reg group4_smallorbiggroup,
    
    input we,
    input [DIN_BIT_LEN-1:0] din,//length is (INDEX_BIT_LEN+1)*5
    input [PACKET_BIT_LEN-1:0] tupleData,
    input smallorbig_segment,
    input [INDEX_BIT_LEN-1:0] segment_index,
    input clk
 );
    
//hash related
localparam magic_num = 32'b10000000000000001000000000000001;//0x80008001

// big segment table
(* RAM_STYLE="DISTRIBUTED" *) reg [DIN_BIT_LEN-1:0] bigseg_table [BIGSEGMENT_NUM-1:0]; // lens is 11+1 bit*5 group = 60, 11 bit for index, 1 bit indicate that group is big or small

initial begin
    if(SUBSET_NUM == 0)
        $readmemb("D:/YuHang_update/bigseg_table/subset0_bigseg_table.txt", bigseg_table, 0, BIGSEGMENT_NUM-1);
    else if(SUBSET_NUM == 1)
        $readmemb("D:/YuHang_update/bigseg_table/subset1_bigseg_table.txt", bigseg_table, 0, BIGSEGMENT_NUM-1);
    else if (SUBSET_NUM == 2)
        $readmemb("D:/YuHang_update/bigseg_table/subset2_bigseg_table.txt", bigseg_table, 0, BIGSEGMENT_NUM-1);
end

wire [BIGSEGMENT_BIT_LEN-1:0] bigseg_index;
assign bigseg_index = segment_index[BIGSEGMENT_BIT_LEN-1:0];// get big segment index form segment_index last bit that len is [big_segment_bitlens-1:0]

always@(posedge clk)
begin
    // big segment
    if(smallorbig_segment)
    begin
        //check if it is big group or small group
        // G0 is big group
        if(bigseg_table[bigseg_index][48])
           group0_index <= (tupleData[31:0] * magic_num) >> (32-INDEX_BIT_LEN);// hashkey = tupleData[31:0]
        // G0 is samll group
        else 
           group0_index <= bigseg_table[bigseg_index][59:49];
        
        //G1 is big group
        if(bigseg_table[bigseg_index][36])
            group1_index <= (tupleData[63:32] * magic_num) >> (32-INDEX_BIT_LEN);// hashkey = tupleData[63:32]
        else 
            group1_index <= bigseg_table[bigseg_index][47:37];
        
        //G2 is big group
        if(bigseg_table[bigseg_index][24])
            group2_index <= (tupleData[79:64] * magic_num) >> (32-INDEX_BIT_LEN);// hashkey = tupleData[63:32]
        else 
            group2_index <= bigseg_table[bigseg_index][35:25];
        
        //G3 is big group
        if(bigseg_table[bigseg_index][12])
            group3_index <= (tupleData[95:80] * magic_num) >> (32-INDEX_BIT_LEN);// hashkey = tupleData[63:32]
        else 
            group3_index <= bigseg_table[bigseg_index][23:13];
        
        // G4 just output, let next stage to check protocol entry
        group4_table_index <= bigseg_table[bigseg_index][12:1];
        group4_smallorbiggroup <= bigseg_table[bigseg_index][0];
    end
    
    if(we)
        bigseg_table[bigseg_index] <= din;
end
endmodule
