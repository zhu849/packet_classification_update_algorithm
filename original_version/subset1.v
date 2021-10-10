
module subset1#(
    parameter INDEX_BIT_LEN=11,
    parameter PACKET_BIT_LEN=104,
    parameter COMMAND_BIT_LEN=2
)(
    output reg match_reg,
    output reg [INDEX_BIT_LEN-1:0] match_ruleID_reg,
    
    input [PACKET_BIT_LEN-1:0] tupleData,
    input [COMMAND_BIT_LEN-1:0] command,
    input clk
);

 /******  Localparam Define ******/
 localparam STAGE_NUM=7;
 localparam SEARCH_STAGE_NUM=4;
 /****************************/


integer i; // variable
(* KEEP = "TRUE" *)reg [PACKET_BIT_LEN-1:0] tupleData_reg [STAGE_NUM-1:0];//every stage should have one packet, and it should record with ten pipeline stage

// get from small segment table's information
// 從 segmentation table 中得到的
wire smallorbig_segment;//代表從 segmentation table 中拿到的這個 cell 是 big segment 還是 small segment
// used to record index in small segment if segment table say it is small segment, else than segment_index[7:0] is big segment index
// 用來當作 small segment+G0 table 中的 search index，如果這個 cell 是 big segment ，則會利用 segment_index [7:0] 去做 hash 計算得到要 search 的 table index
wire [INDEX_BIT_LEN-1:0] segment_index; 

// get from big segment table's index
// 這個是從 big segment table 中 entry 得到的資訊，共有 group 0-3 在 stage1 要搜尋所需要的 search index，以及在下一個 stage 中才會針對 group4 再去做 protocol table 的 search
// 這裡的 group0-3 相當於 search_index in stage1
wire [INDEX_BIT_LEN-1:0] group0_index_w;
wire [INDEX_BIT_LEN-1:0] group1_index_w;
wire [INDEX_BIT_LEN-1:0] group2_index_w;
wire [INDEX_BIT_LEN-1:0] group3_index_w;
wire [INDEX_BIT_LEN-1:0] group4_table_index_w;//use to protocol stage check protocol type and group size
wire group4_smallorbiggroup_w; // get from big segment table, let us know this table entry is big group or small group
//因為這些資訊需要被存放在 pipeline register 內，所以需要宣告 reg 形式存放，傳入下一個 stage 做 search
reg [INDEX_BIT_LEN-1:0] group0_index_reg;
reg [INDEX_BIT_LEN-1:0] group1_index_reg;
reg [INDEX_BIT_LEN-1:0] group2_index_reg;
reg [INDEX_BIT_LEN-1:0] group3_index_reg;
reg [INDEX_BIT_LEN-1:0] group4_table_index_reg;
reg group4_smallorbiggroup_reg;

// go to search next stage's memory
// 用於搜尋第幾個 pipeline stage 之 index
// searchG0_index_w[0] 被用於搜尋 stage1 之 G0 的 memory 之第一條之 index
// 需要存放在 pipeline register 中
wire [INDEX_BIT_LEN-1:0] searchG0_index_w [SEARCH_STAGE_NUM-1:0];
wire [INDEX_BIT_LEN-1:0] searchG1_index_w [SEARCH_STAGE_NUM-1:0];
wire [INDEX_BIT_LEN-1:0] searchG2_index_w [SEARCH_STAGE_NUM-1:0];
wire [INDEX_BIT_LEN-1:0] searchG3_index_w [SEARCH_STAGE_NUM-1:0];
wire [INDEX_BIT_LEN-1:0] searchG4_index_w [SEARCH_STAGE_NUM-1:0];
wire [INDEX_BIT_LEN-1:0] searchG4_other_index_w [SEARCH_STAGE_NUM-1:0];
(* KEEP = "TRUE" *)reg [INDEX_BIT_LEN-1:0] searchG0_index_reg [SEARCH_STAGE_NUM-1:0];
(* KEEP = "TRUE" *)reg [INDEX_BIT_LEN-1:0] searchG1_index_reg [SEARCH_STAGE_NUM-1:0];
(* KEEP = "TRUE" *)reg [INDEX_BIT_LEN-1:0] searchG2_index_reg [SEARCH_STAGE_NUM-1:0];
(* KEEP = "TRUE" *)reg [INDEX_BIT_LEN-1:0] searchG3_index_reg [SEARCH_STAGE_NUM-1:0];
(* KEEP = "TRUE" *)reg [INDEX_BIT_LEN-1:0] searchG4_index_reg [SEARCH_STAGE_NUM-1:0];
(* KEEP = "TRUE" *)reg [INDEX_BIT_LEN-1:0] searchG4_other_index_reg [SEARCH_STAGE_NUM-1:0];

// 用來針對 G0-G4 和 G4 other 是否 match 的紀錄以及其 ruleID
// 需要存放在 pipeline register 中
// use to record match status with each stage
wire [SEARCH_STAGE_NUM-1:0] G0_match_w;
wire [SEARCH_STAGE_NUM-1:0] G1_match_w;
wire [SEARCH_STAGE_NUM-1:0] G2_match_w;
wire [SEARCH_STAGE_NUM-1:0] G3_match_w;
wire [SEARCH_STAGE_NUM-1:0] G4_match_w;
wire [SEARCH_STAGE_NUM-1:0] G4_other_match_w;
(* KEEP = "TRUE" *)reg [SEARCH_STAGE_NUM-1:0] G0_match_reg;
(* KEEP = "TRUE" *)reg [SEARCH_STAGE_NUM-1:0] G1_match_reg;
(* KEEP = "TRUE" *)reg [SEARCH_STAGE_NUM-1:0] G2_match_reg;
(* KEEP = "TRUE" *)reg [SEARCH_STAGE_NUM-1:0] G3_match_reg;
(* KEEP = "TRUE" *)reg [SEARCH_STAGE_NUM-1:0] G4_match_reg;
(* KEEP = "TRUE" *)reg [SEARCH_STAGE_NUM-1:0] G4_other_match_reg;
// use to record match_ruleID with each stage
wire [INDEX_BIT_LEN-1:0] G0_match_ruleID_w [SEARCH_STAGE_NUM-1:0];
wire [INDEX_BIT_LEN-1:0] G1_match_ruleID_w [SEARCH_STAGE_NUM-1:0];
wire [INDEX_BIT_LEN-1:0] G2_match_ruleID_w [SEARCH_STAGE_NUM-1:0];
wire [INDEX_BIT_LEN-1:0] G3_match_ruleID_w [SEARCH_STAGE_NUM-1:0];
wire [INDEX_BIT_LEN-1:0] G4_match_ruleID_w [SEARCH_STAGE_NUM-1:0];
wire [INDEX_BIT_LEN-1:0] G4_other_match_ruleID_w [SEARCH_STAGE_NUM-1:0];
(* KEEP = "TRUE" *)reg [INDEX_BIT_LEN-1:0] G0_match_ruleID_reg [SEARCH_STAGE_NUM-1:0];
(* KEEP = "TRUE" *)reg [INDEX_BIT_LEN-1:0] G1_match_ruleID_reg [SEARCH_STAGE_NUM-1:0];
(* KEEP = "TRUE" *)reg [INDEX_BIT_LEN-1:0] G2_match_ruleID_reg [SEARCH_STAGE_NUM-1:0];
(* KEEP = "TRUE" *)reg [INDEX_BIT_LEN-1:0] G3_match_ruleID_reg [SEARCH_STAGE_NUM-1:0];
(* KEEP = "TRUE" *)reg [INDEX_BIT_LEN-1:0] G4_match_ruleID_reg [SEARCH_STAGE_NUM-1:0];
(* KEEP = "TRUE" *)reg [INDEX_BIT_LEN-1:0] G4_other_match_ruleID_reg [SEARCH_STAGE_NUM-1:0];

///////////////////////////////////////////////////////// Search Hash Table /////////////////////////////////////////////////////////
hashtable0_index_check #(
    .SUBSET_NUM(1),
    .INDEX_BIT_LEN(INDEX_BIT_LEN),
    .PACKET_BIT_LEN(PACKET_BIT_LEN),
    .COMMAND_BIT_LEN(COMMAND_BIT_LEN)
)hashtable1_index_check(
    .smallorbig_segment(smallorbig_segment),
    .seg_index(segment_index),
    
    .we(1'b0),
    .tupleData(tupleData_reg[0]),
    .clk(clk)
);
///////////////////////////////////////////////////////// Search Big Segment Table /////////////////////////////////////////////////////////
bigsegtable0_index_check 
#(
    .SUBSET_NUM(1),
    .INDEX_BIT_LEN(INDEX_BIT_LEN),
    .PACKET_BIT_LEN(PACKET_BIT_LEN),
    .COMMAND_BIT_LEN(COMMAND_BIT_LEN),
    .BIGSEGMENT_NUM(1),
    .BIGSEGMENT_BIT_LEN(1),
    .DIN_BIT_LEN(60)
)bigsegtable1_index_check(
    .group0_index(group0_index_w),
    .group1_index(group1_index_w),
    .group2_index(group2_index_w),
    .group3_index(group3_index_w),
    .group4_table_index(group4_table_index_w),
    .group4_smallorbiggroup(group4_smallorbiggroup_w),
    
    .we(1'b0),
    .din(0),
    .tupleData(tupleData_reg[1]),
    .smallorbig_segment(smallorbig_segment),
    .segment_index(segment_index),
    .clk(clk)
);
///////////////////////////////////////////////////////// Protocol Table /////////////////////////////////////////////////////////
prototable0_index_check #(
    .SUBSET_NUM(1),
    .INDEX_BIT_LEN(INDEX_BIT_LEN),
    .PACKET_BIT_LEN(PACKET_BIT_LEN),
    .COMMAND_BIT_LEN(COMMAND_BIT_LEN),
    .PROTOCOL_TABLE_SIZE(0),
    .DIN_BIT_LEN(33)
)prototable1_index_check(
     .searchG0_index(searchG0_index_w[0]),
     .searchG1_index(searchG1_index_w[0]),
     .searchG2_index(searchG2_index_w[0]),
     .searchG3_index(searchG3_index_w[0]),
     .searchG4_index(searchG4_index_w[0]),
     .searchG4_others_index(searchG4_other_index_w[0]),
     
     .we(1'b0),
     .din(),
     .tupleData(tupleData_reg[2]),
     .group0_index(group0_index_reg),
     .group1_index(group1_index_reg),
     .group2_index(group2_index_reg),
     .group3_index(group3_index_reg),
     .group4_table_index(group4_table_index_reg),
     .group4_smallorbiggroup(group4_smallorbiggroup_reg),
     .clk(clk)
);
///////////////////////////////////////////////////////// Stage 1 /////////////////////////////////////////////////////////
search_stage #(
  .SUBSET_NUM(1),
  .TABLE_NUM(0),
  .G0_TABLE_ENTRY_SIZE(81),
  .G1_TABLE_ENTRY_SIZE(0),
  .G2_TABLE_ENTRY_SIZE(0),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(0),
  .G4_OTHER_TABLE_ENTRY_SIZE(0)
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
    .G4_other_match(G4_other_match_w[0]),
    .G4_other_match_ruleID(G4_other_match_ruleID_w[0]),
    .G4_other_next_index(searchG4_other_index_w[1]),
    
    .last_G0_match(1'b0),
    .last_G1_match(1'b0),
    .last_G2_match(1'b0),
    .last_G3_match(1'b0),
    .last_G4_match(1'b0),
    .last_G4_other_match(1'b0),
    .last_G0_match_ruleID(11'b00000000000),
    .last_G1_match_ruleID(11'b00000000000),
    .last_G2_match_ruleID(11'b00000000000),
    .last_G3_match_ruleID(11'b00000000000),
    .last_G4_match_ruleID(11'b00000000000),
    .last_G4_other_match_ruleID(11'b00000000000),
    .search0_index(searchG0_index_reg[0]),
    .search1_index(searchG1_index_reg[0]),
    .search2_index(searchG2_index_reg[0]),
    .search3_index(searchG3_index_reg[0]),
    .search4_index(searchG4_index_reg[0]),
    .search4_other_index(searchG4_other_index_reg[0]),
    .tupleData(tupleData_reg[3]),
    .clk(clk)
);
///////////////////////////////////////////////////////// Stage 2 /////////////////////////////////////////////////////////
search_stage #(
  .SUBSET_NUM(1),
  .TABLE_NUM(1),
  .G0_TABLE_ENTRY_SIZE(33),
  .G1_TABLE_ENTRY_SIZE(0),
  .G2_TABLE_ENTRY_SIZE(0),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(0),
  .G4_OTHER_TABLE_ENTRY_SIZE(0)
) stage2(
    .G0_match(G0_match_w[1]),
    .G0_match_ruleID(G0_match_ruleID_w[1]),
    .G0_next_index(searchG0_index_w[2]),
    .G1_match(G1_match_w[1]),
    .G1_match_ruleID(G1_match_ruleID_w[1]),
    .G1_next_index(searchG1_index_w[2]),
    .G2_match(G2_match_w[1]),
    .G2_match_ruleID(G2_match_ruleID_w[1]),
    .G2_next_index(searchG2_index_w[2]),    
    .G3_match(G3_match_w[1]),
    .G3_match_ruleID(G3_match_ruleID_w[1]),
    .G3_next_index(searchG3_index_w[2]),
    .G4_match(G4_match_w[1]),
    .G4_match_ruleID(G4_match_ruleID_w[1]),
    .G4_next_index(searchG4_index_w[2]),   
    .G4_other_match(G4_other_match_w[1]),
    .G4_other_match_ruleID(G4_other_match_ruleID_w[1]),
    .G4_other_next_index(searchG4_other_index_w[2]),
    
    .last_G0_match(G0_match_reg[0]),
    .last_G1_match(G1_match_reg[0]),
    .last_G2_match(G2_match_reg[0]),
    .last_G3_match(G3_match_reg[0]),
    .last_G4_match(G4_match_reg[0]),
    .last_G4_other_match(G4_other_match_reg[0]),
    .last_G0_match_ruleID(G0_match_ruleID_reg[0]),
    .last_G1_match_ruleID(G1_match_ruleID_reg[0]),
    .last_G2_match_ruleID(G2_match_ruleID_reg[0]),
    .last_G3_match_ruleID(G3_match_ruleID_reg[0]),
    .last_G4_match_ruleID(G4_match_ruleID_reg[0]),
    .last_G4_other_match_ruleID(G4_other_match_ruleID_reg[0]),
    .search0_index(searchG0_index_reg[1]),
    .search1_index(searchG1_index_reg[1]),
    .search2_index(searchG2_index_reg[1]),
    .search3_index(searchG3_index_reg[1]),
    .search4_index(searchG4_index_reg[1]),
    .search4_other_index(searchG4_other_index_reg[1]),
    .tupleData(tupleData_reg[4]),
    .clk(clk)
);
///////////////////////////////////////////////////////// Stage 3 /////////////////////////////////////////////////////////
search_stage #(
  .SUBSET_NUM(1),
  .TABLE_NUM(2),
  .G0_TABLE_ENTRY_SIZE(10),
  .G1_TABLE_ENTRY_SIZE(0),
  .G2_TABLE_ENTRY_SIZE(0),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(0),
  .G4_OTHER_TABLE_ENTRY_SIZE(0)
) stage3(
    .G0_match(G0_match_w[2]),
    .G0_match_ruleID(G0_match_ruleID_w[2]),
    .G0_next_index(searchG0_index_w[3]),
    .G1_match(G1_match_w[2]),
    .G1_match_ruleID(G1_match_ruleID_w[2]),
    .G1_next_index(searchG1_index_w[3]),
    .G2_match(G2_match_w[2]),
    .G2_match_ruleID(G2_match_ruleID_w[2]),
    .G2_next_index(searchG2_index_w[3]),    
    .G3_match(G3_match_w[2]),
    .G3_match_ruleID(G3_match_ruleID_w[2]),
    .G3_next_index(searchG3_index_w[3]),
    .G4_match(G4_match_w[2]),
    .G4_match_ruleID(G4_match_ruleID_w[2]),
    .G4_next_index(searchG4_index_w[3]),   
    .G4_other_match(G4_other_match_w[2]),
    .G4_other_match_ruleID(G4_other_match_ruleID_w[2]),
    .G4_other_next_index(searchG4_other_index_w[3]),
    
    .last_G0_match(G0_match_reg[1]),
    .last_G1_match(G1_match_reg[1]),
    .last_G2_match(G2_match_reg[1]),
    .last_G3_match(G3_match_reg[1]),
    .last_G4_match(G4_match_reg[1]),
    .last_G4_other_match(G4_other_match_reg[1]),
    .last_G0_match_ruleID(G0_match_ruleID_reg[1]),
    .last_G1_match_ruleID(G1_match_ruleID_reg[1]),
    .last_G2_match_ruleID(G2_match_ruleID_reg[1]),
    .last_G3_match_ruleID(G3_match_ruleID_reg[1]),
    .last_G4_match_ruleID(G4_match_ruleID_reg[1]),
    .last_G4_other_match_ruleID(G4_other_match_ruleID_reg[1]),
    .search0_index(searchG0_index_reg[2]),
    .search1_index(searchG1_index_reg[2]),
    .search2_index(searchG2_index_reg[2]),
    .search3_index(searchG3_index_reg[2]),
    .search4_index(searchG4_index_reg[2]),
    .search4_other_index(searchG4_other_index_reg[2]),
    .tupleData(tupleData_reg[5]),
    .clk(clk)
);
///////////////////////////////////////////////////////// Stage 4 /////////////////////////////////////////////////////////
search_stage #(
  .SUBSET_NUM(1),
  .TABLE_NUM(3),
  .G0_TABLE_ENTRY_SIZE(4),
  .G1_TABLE_ENTRY_SIZE(0),
  .G2_TABLE_ENTRY_SIZE(0),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(0),
  .G4_OTHER_TABLE_ENTRY_SIZE(0)
) stage4(
    .G0_match(G0_match_w[3]),
    .G0_match_ruleID(G0_match_ruleID_w[3]),
    //.G0_next_index(searchG0_index_w[4]),
    .G1_match(G1_match_w[3]),
    .G1_match_ruleID(G1_match_ruleID_w[3]),
    //.G1_next_index(searchG1_index_w[4]),
    .G2_match(G2_match_w[3]),
    .G2_match_ruleID(G2_match_ruleID_w[3]),
    //.G2_next_index(searchG2_index_w[4]),    
    .G3_match(G3_match_w[3]),
    .G3_match_ruleID(G3_match_ruleID_w[3]),
    //.G3_next_index(searchG3_index_w[4]),
    .G4_match(G4_match_w[3]),
    .G4_match_ruleID(G4_match_ruleID_w[3]),
    //.G4_next_index(searchG4_index_w[4]),   
    .G4_other_match(G4_other_match_w[3]),
    .G4_other_match_ruleID(G4_other_match_ruleID_w[3]),
    //.G4_other_next_index(searchG4_other_index_w[4]),
    
    .last_G0_match(G0_match_reg[2]),
    .last_G1_match(G1_match_reg[2]),
    .last_G2_match(G2_match_reg[2]),
    .last_G3_match(G3_match_reg[2]),
    .last_G4_match(G4_match_reg[2]),
    .last_G4_other_match(G4_other_match_reg[2]),
    .last_G0_match_ruleID(G0_match_ruleID_reg[2]),
    .last_G1_match_ruleID(G1_match_ruleID_reg[2]),
    .last_G2_match_ruleID(G2_match_ruleID_reg[2]),
    .last_G3_match_ruleID(G3_match_ruleID_reg[2]),
    .last_G4_match_ruleID(G4_match_ruleID_reg[2]),
    .last_G4_other_match_ruleID(G4_other_match_ruleID_reg[2]),
    .search0_index(searchG0_index_reg[3]),
    .search1_index(searchG1_index_reg[3]),
    .search2_index(searchG2_index_reg[3]),
    .search3_index(searchG3_index_reg[3]),
    .search4_index(searchG4_index_reg[3]),
    .search4_other_index(searchG4_other_index_reg[3]),
    .tupleData(tupleData_reg[6]),
    .clk(clk)
);
///////////////////////////////////////////////////////// Search End /////////////////////////////////////////////////////////

always@(posedge clk)
begin
    //因為每個 clk 傳入不同的封包，又因為每個 stage 所會去比對的 packet tuple data 不同，所以需要共 search stage + 3 個 stage 才能做完
    // 13 個 stage = hash table search -> big segment table search -> protocol table search -> memory table search*10
    // set input packet into tupleData reg
    // first stage0 will get from source(main.v)
    tupleData_reg[0] <= tupleData;
    //將上一個 Stage 內的 tuple data 傳到下一個 pipeline stage 去做
    for(i=0;i<SEARCH_STAGE_NUM+3-1;i=i+1)
        tupleData_reg[i+1] <= tupleData_reg[i];
     
     //transfor group index to big segment search first stage search index
     group0_index_reg <= group0_index_w;
     group1_index_reg <= group1_index_w;
     group2_index_reg <= group2_index_w;
     group3_index_reg <= group3_index_w;
     group4_table_index_reg <= group4_table_index_w;
     group4_smallorbiggroup_reg <= group4_smallorbiggroup_w;
     
    //index assign to next level reg that get from last stage's 
    for(i=0;i<SEARCH_STAGE_NUM;i=i+1)
    begin
        searchG0_index_reg[i] <= searchG0_index_w[i]; 
        searchG1_index_reg[i] <= searchG1_index_w[i]; 
        searchG2_index_reg[i] <= searchG2_index_w[i];
        searchG3_index_reg[i] <= searchG3_index_w[i];
        searchG4_index_reg[i] <= searchG4_index_w[i];
        searchG4_other_index_reg[i] <= searchG4_other_index_w[i];
    end
    
    // assign every stage search result
    for(i=0;i<SEARCH_STAGE_NUM;i=i+1)
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
    
    //check final match result
    if(G0_match_w[SEARCH_STAGE_NUM-1] | G1_match_w[SEARCH_STAGE_NUM-1] | G2_match_w[SEARCH_STAGE_NUM-1] | G3_match_w[SEARCH_STAGE_NUM-1] | G4_match_w[SEARCH_STAGE_NUM-1])
    begin
        match_reg <= 1'b1;
        
        //check max priority ruleID
        if( (G0_match_ruleID_w[SEARCH_STAGE_NUM-1]>G1_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G0_match_ruleID_w[SEARCH_STAGE_NUM-1]>G2_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G0_match_ruleID_w[SEARCH_STAGE_NUM-1]>G3_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G0_match_ruleID_w[SEARCH_STAGE_NUM-1]>G4_match_ruleID_w[SEARCH_STAGE_NUM-1]))
            match_ruleID_reg <= G0_match_ruleID_w[SEARCH_STAGE_NUM-1];
        else if( (G1_match_ruleID_w[SEARCH_STAGE_NUM-1]>G0_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G1_match_ruleID_w[SEARCH_STAGE_NUM-1]>G2_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G1_match_ruleID_w[SEARCH_STAGE_NUM-1]>G3_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G1_match_ruleID_w[SEARCH_STAGE_NUM-1]>G4_match_ruleID_w[SEARCH_STAGE_NUM-1]))
            match_ruleID_reg <= G1_match_ruleID_w[SEARCH_STAGE_NUM-1];
        else if( (G2_match_ruleID_w[SEARCH_STAGE_NUM-1]>G0_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G2_match_ruleID_w[SEARCH_STAGE_NUM-1]>G1_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G2_match_ruleID_w[SEARCH_STAGE_NUM-1]>G3_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G2_match_ruleID_w[SEARCH_STAGE_NUM-1]>G4_match_ruleID_w[SEARCH_STAGE_NUM-1]))
            match_ruleID_reg <= G2_match_ruleID_w[SEARCH_STAGE_NUM-1];
        else if( (G3_match_ruleID_w[SEARCH_STAGE_NUM-1]>G0_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G3_match_ruleID_w[SEARCH_STAGE_NUM-1]>G1_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G3_match_ruleID_w[SEARCH_STAGE_NUM-1]>G2_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G3_match_ruleID_w[SEARCH_STAGE_NUM-1]>G4_match_ruleID_w[SEARCH_STAGE_NUM-1]))
            match_ruleID_reg <= G3_match_ruleID_w[SEARCH_STAGE_NUM-1];
        else if( (G4_match_ruleID_w[SEARCH_STAGE_NUM-1]>G0_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G4_match_ruleID_w[SEARCH_STAGE_NUM-1]>G1_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G4_match_ruleID_w[SEARCH_STAGE_NUM-1]>G2_match_ruleID_w[SEARCH_STAGE_NUM-1]) & (G4_match_ruleID_w[SEARCH_STAGE_NUM-1]>G3_match_ruleID_w[SEARCH_STAGE_NUM-1]))
            match_ruleID_reg <= G4_match_ruleID_w[SEARCH_STAGE_NUM-1]; 
    end
    else
        match_reg <= 1'b0;
end

endmodule
