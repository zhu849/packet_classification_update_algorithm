`timescale 1ns / 1ps

module bigsegtable0_index_check(
    output reg [10:0] group0_index,
    output reg [10:0] group1_index,
    output reg [10:0] group2_index,
    output reg [10:0] group3_index,
    output reg [10:0] group4_index,
    
    input [103:0] tupleData,
    input smallorbig_segment,
    input [10:0] segment_index,
    input clk
 );
    
//hash related
localparam magic_num = 32'b10000000000000001000000000000001;//0x80008001

// big segment table
localparam big_segment_num = 184;
localparam big_segment_bitlens = 8; //because 2^8=256 > 184 > 2^7=128
(* KEEP = "TRUE" *)(* RAM_STYLE="distributed" *) reg [59:0] bigseg_table [big_segment_num-1:0]; // lens is 11+1 bit*5 group = 60, 11 bit for index, 1 bit indicate that group is big or small

initial begin
    $readmemb("D:\YuHang_update\bigseg_table\bigseg_table.txt", bigseg_table, 0, big_segment_num-1);
end

wire [big_segment_bitlens-1:0] bigseg_index;
assign bigseg_index = segment_index[big_segment_bitlens-1:0];// get big segment index form segment_index last bit that len is [big_segment_bitlens-1:0]

always@(posedge clk)
begin
    // big segment
    if(smallorbig_segment == 1)
    begin
        //check if it is big group or small group
        // G0 is big group
        if(bigseg_table[48] == 1)
        begin
           group0_index <= (tupleData[31:0] & magic_num) >> 21;// hashkey = tupleData[31:0]
        end
        // G0 is samll group
        else begin
           group0_index <= bigseg_table[bigseg_index][59:49];
        end
        
        //G1 is big group
        if(bigseg_table[36] == 1)
        begin
            group1_index <= (tupleData[63:32] & magic_num) >> 21;// hashkey = tupleData[63:32]
        end
        else begin
            group1_index <= bigseg_table[bigseg_index][47:37];
        end
        
        //G2 is big group
        if(bigseg_table[24] == 1)
        begin
            group2_index <= (tupleData[79:64] & magic_num) >> 21;// hashkey = tupleData[63:32]
        end
        else begin
             group2_index <= bigseg_table[bigseg_index][35:25];
        end
        
        //G3 is big group
        if(bigseg_table[12] == 1)
        begin
            group3_index <= (tupleData[95:80] & magic_num) >> 21;// hashkey = tupleData[63:32]
        end
        else begin
            group3_index <= bigseg_table[bigseg_index][23:13];
        end
        
        // G4 is big group
        if(bigseg_table[0] == 1)
        begin
            group4_index <= (tupleData[103:96] & magic_num) >> 21;// hashkey = tupleData[63:32]
        end
        else begin
            group4_index <= bigseg_table[bigseg_index][12:1];
        end
    end
end
endmodule
