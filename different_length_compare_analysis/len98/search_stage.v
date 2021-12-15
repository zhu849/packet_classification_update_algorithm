
module search_stage
#(
    parameter SUBSET_NUM=0,
    parameter TABLE_NUM=0,
    parameter INDEX_BIT_LEN=11,
    parameter PACKET_BIT_LEN=104,
    parameter COMMAND_BIT_LEN=2,
    parameter G0_TABLE_ENTRY_SIZE=1738,
    parameter G1_TABLE_ENTRY_SIZE=154,
    parameter G2_TABLE_ENTRY_SIZE=18,
    parameter G3_TABLE_ENTRY_SIZE=0,
    parameter G4_TABLE_ENTRY_SIZE=29,
    parameter G4_OTHER_TABLE_ENTRY_SIZE=0
)
(    
    output reg G0_match,
    output reg [INDEX_BIT_LEN-1:0] G0_match_ruleID,
    output reg [INDEX_BIT_LEN-1:0] G0_next_index,
    output reg G1_match,
    output reg [INDEX_BIT_LEN-1:0] G1_match_ruleID,
    output reg [INDEX_BIT_LEN-1:0] G1_next_index,
    output reg G2_match,
    output reg [INDEX_BIT_LEN-1:0] G2_match_ruleID,
    output reg [INDEX_BIT_LEN-1:0] G2_next_index,
    output reg G3_match,
    output reg [INDEX_BIT_LEN-1:0] G3_match_ruleID,
    output reg [INDEX_BIT_LEN-1:0] G3_next_index,
    output reg G4_match,
    output reg [INDEX_BIT_LEN-1:0] G4_match_ruleID,
    output reg [INDEX_BIT_LEN-1:0] G4_next_index,
    output reg G4_other_match,
    output reg [INDEX_BIT_LEN-1:0] G4_other_match_ruleID,
    output reg [INDEX_BIT_LEN-1:0] G4_other_next_index,
    
    // record previous stage match or not
    input last_G0_match,
    input last_G1_match,
    input last_G2_match,
    input last_G3_match,
    input last_G4_match,
    input last_G4_other_match,
    // record previous stage match's ruleID
    input [INDEX_BIT_LEN-1:0] last_G0_match_ruleID,
    input [INDEX_BIT_LEN-1:0] last_G1_match_ruleID,
    input [INDEX_BIT_LEN-1:0] last_G2_match_ruleID,
    input [INDEX_BIT_LEN-1:0] last_G3_match_ruleID,
    input [INDEX_BIT_LEN-1:0] last_G4_match_ruleID,
    input [INDEX_BIT_LEN-1:0] last_G4_other_match_ruleID,
    // expect to search's index
    input [INDEX_BIT_LEN-1:0] search0_index,
    input [INDEX_BIT_LEN-1:0] search1_index,
    input [INDEX_BIT_LEN-1:0] search2_index,
    input [INDEX_BIT_LEN-1:0] search3_index,
    input [INDEX_BIT_LEN-1:0] search4_index,
    input [INDEX_BIT_LEN-1:0] search4_other_index,
    input [PACKET_BIT_LEN-1:0] tupleData,
    input clk
);


//use to propagate in search stage
wire G0_match_w;
wire G1_match_w;
wire G2_match_w;
wire G3_match_w;
wire G4_match_w;
wire G4_other_match_w;
wire [INDEX_BIT_LEN-1:0] G0_ruleID_w;
wire [INDEX_BIT_LEN-1:0] G1_ruleID_w;
wire [INDEX_BIT_LEN-1:0] G2_ruleID_w;
wire [INDEX_BIT_LEN-1:0] G3_ruleID_w;
wire [INDEX_BIT_LEN-1:0] G4_ruleID_w;
wire [INDEX_BIT_LEN-1:0] G4_other_ruleID_w;
wire [INDEX_BIT_LEN-1:0] G0_next_index_w;
wire [INDEX_BIT_LEN-1:0] G1_next_index_w;
wire [INDEX_BIT_LEN-1:0] G2_next_index_w;
wire [INDEX_BIT_LEN-1:0] G3_next_index_w;
wire [INDEX_BIT_LEN-1:0] G4_next_index_w;
wire [INDEX_BIT_LEN-1:0] G4_other_next_index_w;

search_smallseg_G0table #(
    .SUBSET_NUM(SUBSET_NUM),
    .TABLE_NUM(TABLE_NUM),
    .TABLE_ENTRY_SIZE(G0_TABLE_ENTRY_SIZE)
)
search_smallseg_G0table(
    .match(G0_match_w),
    .ruleID(G0_ruleID_w),
    .next_index(G0_next_index_w),
    
    .din(98'b0),
    .we(1'b0),
    .search_index(search0_index),
    .tupleData(tupleData),
    .clk(clk)
);

search_G1table #(
    .SUBSET_NUM(SUBSET_NUM),
    .TABLE_NUM(TABLE_NUM),
    .TABLE_ENTRY_SIZE(G1_TABLE_ENTRY_SIZE)
)
search_G1table(
    .match(G1_match_w),
    .ruleID(G1_ruleID_w),
    .next_index(G1_next_index_w),
    
    .din(98'b0),
    .we(1'b0),
    .search_index(search1_index),
    .tupleData(tupleData),
    .clk(clk)
);

search_G2table #(
    .SUBSET_NUM(SUBSET_NUM),
    .TABLE_NUM(TABLE_NUM),
    .TABLE_ENTRY_SIZE(G2_TABLE_ENTRY_SIZE)
)
search_G2table(
    .match(G2_match_w),
    .ruleID(G2_ruleID_w),
    .next_index(G2_next_index_w),
    
    .din(98'b0),
    .we(1'b0),
    .search_index(search2_index),
    .tupleData(tupleData),
    .clk(clk)
);

search_G3table #(
    .SUBSET_NUM(SUBSET_NUM),
    .TABLE_NUM(TABLE_NUM),
    .TABLE_ENTRY_SIZE(G3_TABLE_ENTRY_SIZE)
)
search_G3table(
    .match(G3_match_w),
    .ruleID(G3_ruleID_w),
    .next_index(G3_next_index_w),
    
    .din(98'b0),
    .we(1'b0),
    .search_index(search3_index),
    .tupleData(tupleData),
    .clk(clk)
);

search_G4table #(
    .SUBSET_NUM(SUBSET_NUM),
    .TABLE_NUM(TABLE_NUM),
    .TABLE_ENTRY_SIZE(G4_TABLE_ENTRY_SIZE)
)
search_G4table(
    .match(G4_match_w),
    .ruleID(G4_ruleID_w),
    .next_index(G4_next_index_w),
    
    .din(98'b0),
    .we(1'b0),
    .search_index(search4_index),
    .tupleData(tupleData),
    .clk(clk)
);

search_G4othertable #(
    .SUBSET_NUM(SUBSET_NUM),
    .TABLE_NUM(TABLE_NUM),
    .TABLE_ENTRY_SIZE(G4_OTHER_TABLE_ENTRY_SIZE)
)
search_G4othertable(
    .match(G4_other_match_w),
    .ruleID(G4_other_ruleID_w),
    .next_index(G4_other_next_index_w),
    
    .din(98'b0),
    .we(1'b0),
    .search_index(search4_other_index),
    .tupleData(tupleData),
    .clk(clk)
);


always@(posedge clk)
begin
    // G0 process
    if(last_G0_match)
    begin
        G0_match <= last_G0_match;
        G0_match_ruleID <= last_G0_match_ruleID;
    end
    else
    begin
        G0_match <= G0_match_w;
        G0_match_ruleID <= G0_ruleID_w;
    end
    // G1 process
    if(last_G1_match)
    begin
        G1_match <= last_G1_match;
        G1_match_ruleID <= last_G1_match_ruleID;
    end
    else
    begin
        G1_match <= G1_match_w;
        G1_match_ruleID <= G1_ruleID_w;
    end   
    // G2 process
    if(last_G2_match)
    begin
        G2_match <= last_G2_match;
        G2_match_ruleID <= last_G2_match_ruleID;
    end
    else
    begin
        G2_match <= G2_match_w;
        G2_match_ruleID <= G2_ruleID_w;
    end
    // G3 process
    if(last_G3_match)
    begin
        G3_match <= last_G3_match;
        G3_match_ruleID <= last_G3_match_ruleID;
    end
    else
    begin
        G3_match <= G3_match_w;
        G3_match_ruleID <= G3_ruleID_w;
    end          
    // G4 process
    if(last_G4_match)
    begin
        G4_match <= last_G4_match;
        G4_match_ruleID <= last_G4_match_ruleID;
    end
    else
    begin
        G4_match <= G4_match_w;
        G4_match_ruleID <= G4_ruleID_w;
    end    
    // G4 other process
    if(last_G4_other_match)
    begin
        G4_other_match <= last_G4_other_match;
        G4_other_match_ruleID <= last_G4_other_match_ruleID;
    end
    else
    begin
        G4_other_match <= G4_other_match_w;
        G4_other_match_ruleID <= G4_other_ruleID_w;
    end       
    
    // assign next search index
    G0_next_index <= G0_next_index_w;
    G1_next_index <= G1_next_index_w;
    G2_next_index <= G2_next_index_w;
    G3_next_index <= G3_next_index_w;
    G4_next_index <= G4_next_index_w;
    G4_other_next_index <= G4_other_next_index_w;
    
end
endmodule
