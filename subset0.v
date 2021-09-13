`timescale 1ns / 1ps

module subset0(
    output reg match_reg,
    output reg [10:0] match_ruleID_reg,
    
    input [103:0] tupleData,
    input [1:0] command,
    input clk
);

integer i; // variable
(* KEEP = "TRUE" *)reg [103:0] tupleData_reg [9:0];//every stage should have one packet, and it should record with ten pipeline stage

// get from small segment table's information
wire smallorbig_segment;
wire [10:0] segment_index; // used to record index in small segment if segment table say it is small segment, else than segment_index[7:0] is big segment index

// get from big segment table's index
wire [10:0] group0_index;
wire [10:0] group1_index;
wire [10:0] group2_index;
wire [10:0] group3_index;
wire [10:0] group4_index;

// go to search next stage's memory
// group table max size is 10, and search  index max lens is 11 to indicate that max small segment size is 1738
wire [10:0] searchG0_index_w [9:0];
wire [10:0] searchG1_index_w [9:0];
wire [10:0] searchG2_index_w [9:0];
wire [10:0] searchG3_index_w [9:0];
wire [10:0] searchG4_index_w [9:0];
(* KEEP = "TRUE" *)reg [10:0] searchG0_index_reg [9:0];
(* KEEP = "TRUE" *)reg [10:0] searchG1_index_reg [9:0];
(* KEEP = "TRUE" *)reg [10:0] searchG2_index_reg [9:0];
(* KEEP = "TRUE" *)reg [10:0] searchG3_index_reg [9:0];
(* KEEP = "TRUE" *)reg [10:0] searchG4_index_reg [9:0];

// use to record match status with each stage
// have 10 stages
wire [9:0] G0_match_w [9:0];
wire [9:0] G1_match_w [9:0];
wire [9:0] G2_match_w [9:0];
wire [9:0] G3_match_w [9:0];
wire [9:0] G4_match_w [9:0];
(* KEEP = "TRUE" *)reg [9:0] G0_match_reg [9:0];
(* KEEP = "TRUE" *)reg [9:0] G1_match_reg [9:0];
(* KEEP = "TRUE" *)reg [9:0] G2_match_reg [9:0];
(* KEEP = "TRUE" *)reg [9:0] G3_match_reg [9:0];
(* KEEP = "TRUE" *)reg [9:0] G4_match_reg [9:0];

// use to record match_ruleID with each stage
// have 10 stages, every stage record 11 lens index
wire [10:0] G0_match_ruleID_w [9:0];
wire [10:0] G1_match_ruleID_w [9:0];
wire [10:0] G2_match_ruleID_w [9:0];
wire [10:0] G3_match_ruleID_w [9:0];
wire [10:0] G4_match_ruleID_w [9:0];
(* KEEP = "TRUE" *)reg [10:0] G0_match_ruleID_reg [9:0];
(* KEEP = "TRUE" *)reg [10:0] G1_match_ruleID_reg [9:0];
(* KEEP = "TRUE" *)reg [10:0] G2_match_ruleID_reg [9:0];
(* KEEP = "TRUE" *)reg [10:0] G3_match_ruleID_reg [9:0];
(* KEEP = "TRUE" *)reg [10:0] G4_match_ruleID_reg [9:0];

hashtable0_index_check hashtable0_index_check(
    .smallorbig_segment(smallorbig_segment),
    .seg_index(segment_index),
    
    .we(1'b0),
    .tupleData(tupleData),
    .clk(clk)
);

bigsegtable0_index_check bigsegtable0_index_check(
    .group0_index(group0_index),
    .group1_index(group1_index),
    .group2_index(group2_index),
    .group3_index(group3_index),
    .group4_index(group4_index),
    
    .tupleData(tupleData),
    .smallorbig_segment(smallorbig_segment),
    .segment_index(segment_index),
    .clk(clk)
);

search_stage #(
  .SUBSET_NUM(0),
  .TABLE_NUM(0),
  .G0_TABLE_ENTRY_SIZE(1738),
  .G1_TABLE_ENTRY_SIZE(154),
  .G2_TABLE_ENTRY_SIZE(18),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(29)
) stage1(
    .G0_match(G0_match_w[0]),
    .G0_match_ruleID(G0_match_ruleID_w[0]),
    .G0_next_index(searchG0_index_w[1]),
    .G1_match(G1_match_w[0]),
    .G1_match_ruleID(G1_match_ruleID_w[0]),
    .G1_next_index(searchG1_index_w[1]),
    .G2_match(G2_match_w[0]),
    .G2_match_ruleID(G2_match_ruleID_w[0]),
    .G2_next_index(searchG2_index_w[1]),    
    .G3_match(G3_match_w[0]),
    .G3_match_ruleID(G3_match_ruleID_w[0]),
    .G3_next_index(searchG3_index_w[1]),
    .G4_match(G4_match_w[0]),
    .G4_match_ruleID(G4_match_ruleID_w[0]),
    .G4_next_index(searchG4_index_w[1]),   
    
    .last_G0_match(1'b0),
    .last_G1_match(1'b0),
    .last_G2_match(1'b0),
    .last_G3_match(1'b0),
    .last_G4_match(1'b0),
    .last_G0_match_ruleID(11'b00000000000),
    .last_G1_match_ruleID(11'b00000000000),
    .last_G2_match_ruleID(11'b00000000000),
    .last_G3_match_ruleID(11'b00000000000),
    .last_G4_match_ruleID(11'b00000000000),
    .search0_index(searchG0_index_reg[0]),
    .search1_index(searchG1_index_reg[0]),
    .search2_index(searchG2_index_reg[0]),
    .search3_index(searchG3_index_reg[0]),
    .search4_index(searchG4_index_reg[0]),
    .tupleData(tupleData),
    .clk(clk)
);

always@(posedge clk)
begin
    // set input packet into tupleData reg
    // first stage0 will get from source
    tupleData_reg[0] <= tupleData;
    for(i=0;i<9;i=i+1)
        tupleData_reg[i+1] <= tupleData_reg[i];
     
    // stage 0 
    // small segment
    if(smallorbig_segment == 0)
        searchG0_index_reg[0] <= segment_index;
    // big segment
    else begin
        searchG0_index_reg[0] <= group0_index;
        searchG1_index_reg[0] <= group1_index;
        searchG2_index_reg[0] <= group2_index;
        searchG3_index_reg[0] <= group3_index;
        searchG4_index_reg[0] <= group4_index;
    end
    
    //assign last stage's index to next level reg
    for(i=0;i<9;i=i+1)
    begin
        searchG0_index_reg[i+1] <= searchG0_index_reg[i]; 
        searchG1_index_reg[i+1] <= searchG1_index_reg[i]; 
        searchG2_index_reg[i+1] <= searchG2_index_reg[i];
        searchG3_index_reg[i+1] <= searchG3_index_reg[i];
        searchG4_index_reg[i+1] <= searchG4_index_reg[i];
    end
    
    // assign every stage search result
    for(i=0;i<10;i=i+1)
    begin
        G0_match_reg[i] <= G0_match_w[i];
        G1_match_reg[i] <= G1_match_w[i];
        G2_match_reg[i] <= G2_match_w[i];
        G3_match_reg[i] <= G3_match_w[i];
        G4_match_reg[i] <= G4_match_w[i];
        G0_match_ruleID_reg[i] <= G0_match_ruleID_w[i];
        G1_match_ruleID_reg[i] <= G1_match_ruleID_w[i];
        G2_match_ruleID_reg[i] <= G2_match_ruleID_w[i];
        G3_match_ruleID_reg[i] <= G3_match_ruleID_w[i];
        G4_match_ruleID_reg[i] <= G4_match_ruleID_w[i];
    end 
end

endmodule
