

module subset0#(
    parameter INDEX_BIT_LEN=11,
    parameter PACKET_BIT_LEN=104,
    parameter COMMAND_BIT_LEN=2
)
(
    output reg match_reg,
    output reg [INDEX_BIT_LEN-1:0] match_ruleID_reg,
    
    input [PACKET_BIT_LEN-1:0] tupleData,
    input [COMMAND_BIT_LEN-1:0] command,
    input clk
);

 /******  Localparam Define ******/
 localparam STAGE_NUM=13;
 localparam SEARCH_STAGE_NUM=10;//這裡因為在 Yuhung 原版中 T1 是用 10 當作 theshold 所以整個方法最多不會超過 10次的 memory access，意即最多就是搜尋時次一定可以搜尋完畢(worst case)
 /****************************/

integer i; // 被控制邏輯的 for 迴圈所用
// 每個 pipeline 內的 pipeline reg 都需要一份目前處理的 packet tuple data
(* KEEP = "TRUE" *)reg [PACKET_BIT_LEN-1:0] tupleData_reg [STAGE_NUM-1:0];

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
    .SUBSET_NUM(0),
    .INDEX_BIT_LEN(INDEX_BIT_LEN),
    .PACKET_BIT_LEN(PACKET_BIT_LEN),
    .COMMAND_BIT_LEN(COMMAND_BIT_LEN)
)hashtable0_index_check(
    .smallorbig_segment(smallorbig_segment),
    .seg_index(segment_index),
    
    .we(1'b0),
    .tupleData(tupleData_reg[0]),
    .clk(clk)
);
///////////////////////////////////////////////////////// Search Big Segment Table /////////////////////////////////////////////////////////
bigsegtable0_index_check 
#(
    .SUBSET_NUM(0),
    .INDEX_BIT_LEN(INDEX_BIT_LEN),
    .PACKET_BIT_LEN(PACKET_BIT_LEN),
    .COMMAND_BIT_LEN(COMMAND_BIT_LEN),
    .BIGSEGMENT_NUM(184),
    .BIGSEGMENT_BIT_LEN(8),//2^8=256>184
    .DIN_BIT_LEN(60)
)bigsegtable0_index_check(
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
    .SUBSET_NUM(0),
    .INDEX_BIT_LEN(INDEX_BIT_LEN),
    .PACKET_BIT_LEN(PACKET_BIT_LEN),
    .COMMAND_BIT_LEN(COMMAND_BIT_LEN),
    .PROTOCOL_TABLE_SIZE(0),
    .DIN_BIT_LEN(33)
)prototable0_index_check(
     .searchG0_index(searchG0_index_w[0]),
     .searchG1_index(searchG1_index_w[0]),
     .searchG2_index(searchG2_index_w[0]),
     .searchG3_index(searchG3_index_w[0]),
     .searchG4_index(searchG4_index_w[0]),
     .searchG4_others_index(searchG4_other_index_w[0]),
     
     .we(1'b0),
     .din(0),
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
  .SUBSET_NUM(0),
  .TABLE_NUM(0),
  .INDEX_BIT_LEN(INDEX_BIT_LEN),
  .PACKET_BIT_LEN(PACKET_BIT_LEN),
  .COMMAND_BIT_LEN(COMMAND_BIT_LEN),
  .G0_TABLE_ENTRY_SIZE(1738),
  .G1_TABLE_ENTRY_SIZE(154),
  .G2_TABLE_ENTRY_SIZE(18),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(29),
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
  .SUBSET_NUM(0),
  .TABLE_NUM(1),
  .G0_TABLE_ENTRY_SIZE(258),
  .G1_TABLE_ENTRY_SIZE(91),
  .G2_TABLE_ENTRY_SIZE(0),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(4),
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
  .SUBSET_NUM(0),
  .TABLE_NUM(2),
  .G0_TABLE_ENTRY_SIZE(211),
  .G1_TABLE_ENTRY_SIZE(49),
  .G2_TABLE_ENTRY_SIZE(0),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(1),
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
  .SUBSET_NUM(0),
  .TABLE_NUM(3),
  .G0_TABLE_ENTRY_SIZE(174),
  .G1_TABLE_ENTRY_SIZE(19),
  .G2_TABLE_ENTRY_SIZE(0),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(0),
  .G4_OTHER_TABLE_ENTRY_SIZE(0)
) stage4(
    .G0_match(G0_match_w[3]),
    .G0_match_ruleID(G0_match_ruleID_w[3]),
    .G0_next_index(searchG0_index_w[4]),
    .G1_match(G1_match_w[3]),
    .G1_match_ruleID(G1_match_ruleID_w[3]),
    .G1_next_index(searchG1_index_w[4]),
    .G2_match(G2_match_w[3]),
    .G2_match_ruleID(G2_match_ruleID_w[3]),
    .G2_next_index(searchG2_index_w[4]),    
    .G3_match(G3_match_w[3]),
    .G3_match_ruleID(G3_match_ruleID_w[3]),
    .G3_next_index(searchG3_index_w[4]),
    .G4_match(G4_match_w[3]),
    .G4_match_ruleID(G4_match_ruleID_w[3]),
    .G4_next_index(searchG4_index_w[4]),   
    .G4_other_match(G4_other_match_w[3]),
    .G4_other_match_ruleID(G4_other_match_ruleID_w[3]),
    .G4_other_next_index(searchG4_other_index_w[4]),
    
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
///////////////////////////////////////////////////////// Stage 5 /////////////////////////////////////////////////////////
search_stage #(
  .SUBSET_NUM(0),
  .TABLE_NUM(4),
  .G0_TABLE_ENTRY_SIZE(148),
  .G1_TABLE_ENTRY_SIZE(0),
  .G2_TABLE_ENTRY_SIZE(0),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(0),
  .G4_OTHER_TABLE_ENTRY_SIZE(0)
) stage5(
    .G0_match(G0_match_w[4]),
    .G0_match_ruleID(G0_match_ruleID_w[4]),
    .G0_next_index(searchG0_index_w[5]),
    .G1_match(G1_match_w[4]),
    .G1_match_ruleID(G1_match_ruleID_w[4]),
    .G1_next_index(searchG1_index_w[5]),
    .G2_match(G2_match_w[4]),
    .G2_match_ruleID(G2_match_ruleID_w[4]),
    .G2_next_index(searchG2_index_w[5]),    
    .G3_match(G3_match_w[4]),
    .G3_match_ruleID(G3_match_ruleID_w[4]),
    .G3_next_index(searchG3_index_w[5]),
    .G4_match(G4_match_w[4]),
    .G4_match_ruleID(G4_match_ruleID_w[4]),
    .G4_next_index(searchG4_index_w[5]),   
    .G4_other_match(G4_other_match_w[4]),
    .G4_other_match_ruleID(G4_other_match_ruleID_w[4]),
    .G4_other_next_index(searchG4_other_index_w[5]),
    
    .last_G0_match(G0_match_reg[3]),
    .last_G1_match(G1_match_reg[3]),
    .last_G2_match(G2_match_reg[3]),
    .last_G3_match(G3_match_reg[3]),
    .last_G4_match(G4_match_reg[3]),
    .last_G4_other_match(G4_other_match_reg[3]),
    .last_G0_match_ruleID(G0_match_ruleID_reg[3]),
    .last_G1_match_ruleID(G1_match_ruleID_reg[3]),
    .last_G2_match_ruleID(G2_match_ruleID_reg[3]),
    .last_G3_match_ruleID(G3_match_ruleID_reg[3]),
    .last_G4_match_ruleID(G4_match_ruleID_reg[3]),
    .last_G4_other_match_ruleID(G4_other_match_ruleID_reg[3]),
    .search0_index(searchG0_index_reg[4]),
    .search1_index(searchG1_index_reg[4]),
    .search2_index(searchG2_index_reg[4]),
    .search3_index(searchG3_index_reg[4]),
    .search4_index(searchG4_index_reg[4]),
    .search4_other_index(searchG4_other_index_reg[4]),
    .tupleData(tupleData_reg[7]),
    .clk(clk)
);
///////////////////////////////////////////////////////// Stage 6 /////////////////////////////////////////////////////////
search_stage #(
  .SUBSET_NUM(0),
  .TABLE_NUM(5),
  .G0_TABLE_ENTRY_SIZE(118),
  .G1_TABLE_ENTRY_SIZE(0),
  .G2_TABLE_ENTRY_SIZE(0),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(0),
  .G4_OTHER_TABLE_ENTRY_SIZE(0)
) stage6(
    .G0_match(G0_match_w[5]),
    .G0_match_ruleID(G0_match_ruleID_w[5]),
    .G0_next_index(searchG0_index_w[6]),
    .G1_match(G1_match_w[5]),
    .G1_match_ruleID(G1_match_ruleID_w[5]),
    .G1_next_index(searchG1_index_w[6]),
    .G2_match(G2_match_w[5]),
    .G2_match_ruleID(G2_match_ruleID_w[5]),
    .G2_next_index(searchG2_index_w[6]),    
    .G3_match(G3_match_w[5]),
    .G3_match_ruleID(G3_match_ruleID_w[5]),
    .G3_next_index(searchG3_index_w[6]),
    .G4_match(G4_match_w[5]),
    .G4_match_ruleID(G4_match_ruleID_w[5]),
    .G4_next_index(searchG4_index_w[6]),   
    .G4_other_match(G4_other_match_w[5]),
    .G4_other_match_ruleID(G4_other_match_ruleID_w[5]),
    .G4_other_next_index(searchG4_other_index_w[6]),
    
    .last_G0_match(G0_match_reg[4]),
    .last_G1_match(G1_match_reg[4]),
    .last_G2_match(G2_match_reg[4]),
    .last_G3_match(G3_match_reg[4]),
    .last_G4_match(G4_match_reg[4]),
    .last_G4_other_match(G4_other_match_reg[4]),
    .last_G0_match_ruleID(G0_match_ruleID_reg[4]),
    .last_G1_match_ruleID(G1_match_ruleID_reg[4]),
    .last_G2_match_ruleID(G2_match_ruleID_reg[4]),
    .last_G3_match_ruleID(G3_match_ruleID_reg[4]),
    .last_G4_match_ruleID(G4_match_ruleID_reg[4]),
    .last_G4_other_match_ruleID(G4_other_match_ruleID_reg[4]),
    .search0_index(searchG0_index_reg[5]),
    .search1_index(searchG1_index_reg[5]),
    .search2_index(searchG2_index_reg[5]),
    .search3_index(searchG3_index_reg[5]),
    .search4_index(searchG4_index_reg[5]),
    .search4_other_index(searchG4_other_index_reg[5]),
    .tupleData(tupleData_reg[8]),
    .clk(clk)
);
///////////////////////////////////////////////////////// Stage 7 /////////////////////////////////////////////////////////
search_stage #(
  .SUBSET_NUM(0),
  .TABLE_NUM(6),
  .G0_TABLE_ENTRY_SIZE(94),
  .G1_TABLE_ENTRY_SIZE(0),
  .G2_TABLE_ENTRY_SIZE(0),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(0),
  .G4_OTHER_TABLE_ENTRY_SIZE(0)
) stage7(
    .G0_match(G0_match_w[6]),
    .G0_match_ruleID(G0_match_ruleID_w[6]),
    .G0_next_index(searchG0_index_w[7]),
    .G1_match(G1_match_w[6]),
    .G1_match_ruleID(G1_match_ruleID_w[6]),
    .G1_next_index(searchG1_index_w[7]),
    .G2_match(G2_match_w[6]),
    .G2_match_ruleID(G2_match_ruleID_w[6]),
    .G2_next_index(searchG2_index_w[7]),    
    .G3_match(G3_match_w[6]),
    .G3_match_ruleID(G3_match_ruleID_w[6]),
    .G3_next_index(searchG3_index_w[7]),
    .G4_match(G4_match_w[6]),
    .G4_match_ruleID(G4_match_ruleID_w[6]),
    .G4_next_index(searchG4_index_w[7]),   
    .G4_other_match(G4_other_match_w[6]),
    .G4_other_match_ruleID(G4_other_match_ruleID_w[6]),
    .G4_other_next_index(searchG4_other_index_w[7]),
    
    .last_G0_match(G0_match_reg[5]),
    .last_G1_match(G1_match_reg[5]),
    .last_G2_match(G2_match_reg[5]),
    .last_G3_match(G3_match_reg[5]),
    .last_G4_match(G4_match_reg[5]),
    .last_G4_other_match(G4_other_match_reg[5]),
    .last_G0_match_ruleID(G0_match_ruleID_reg[5]),
    .last_G1_match_ruleID(G1_match_ruleID_reg[5]),
    .last_G2_match_ruleID(G2_match_ruleID_reg[5]),
    .last_G3_match_ruleID(G3_match_ruleID_reg[5]),
    .last_G4_match_ruleID(G4_match_ruleID_reg[5]),
    .last_G4_other_match_ruleID(G4_other_match_ruleID_reg[5]),
    .search0_index(searchG0_index_reg[6]),
    .search1_index(searchG1_index_reg[6]),
    .search2_index(searchG2_index_reg[6]),
    .search3_index(searchG3_index_reg[6]),
    .search4_index(searchG4_index_reg[6]),
    .search4_other_index(searchG4_other_index_reg[6]),
    .tupleData(tupleData_reg[9]),
    .clk(clk)
);
///////////////////////////////////////////////////////// Stage 8 /////////////////////////////////////////////////////////
search_stage #(
  .SUBSET_NUM(0),
  .TABLE_NUM(7),
  .G0_TABLE_ENTRY_SIZE(67),
  .G1_TABLE_ENTRY_SIZE(0),
  .G2_TABLE_ENTRY_SIZE(0),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(0),
  .G4_OTHER_TABLE_ENTRY_SIZE(0)
) stage8(
    .G0_match(G0_match_w[7]),
    .G0_match_ruleID(G0_match_ruleID_w[7]),
    .G0_next_index(searchG0_index_w[8]),
    .G1_match(G1_match_w[7]),
    .G1_match_ruleID(G1_match_ruleID_w[7]),
    .G1_next_index(searchG1_index_w[8]),
    .G2_match(G2_match_w[7]),
    .G2_match_ruleID(G2_match_ruleID_w[7]),
    .G2_next_index(searchG2_index_w[8]),    
    .G3_match(G3_match_w[7]),
    .G3_match_ruleID(G3_match_ruleID_w[7]),
    .G3_next_index(searchG3_index_w[8]),
    .G4_match(G4_match_w[7]),
    .G4_match_ruleID(G4_match_ruleID_w[7]),
    .G4_next_index(searchG4_index_w[8]),   
    .G4_other_match(G4_other_match_w[7]),
    .G4_other_match_ruleID(G4_other_match_ruleID_w[7]),
    .G4_other_next_index(searchG4_other_index_w[8]),
    
    .last_G0_match(G0_match_reg[6]),
    .last_G1_match(G1_match_reg[6]),
    .last_G2_match(G2_match_reg[6]),
    .last_G3_match(G3_match_reg[6]),
    .last_G4_match(G4_match_reg[6]),
    .last_G4_other_match(G4_other_match_reg[6]),
    .last_G0_match_ruleID(G0_match_ruleID_reg[6]),
    .last_G1_match_ruleID(G1_match_ruleID_reg[6]),
    .last_G2_match_ruleID(G2_match_ruleID_reg[6]),
    .last_G3_match_ruleID(G3_match_ruleID_reg[6]),
    .last_G4_match_ruleID(G4_match_ruleID_reg[6]),
    .last_G4_other_match_ruleID(G4_other_match_ruleID_reg[6]),
    .search0_index(searchG0_index_reg[7]),
    .search1_index(searchG1_index_reg[7]),
    .search2_index(searchG2_index_reg[7]),
    .search3_index(searchG3_index_reg[7]),
    .search4_index(searchG4_index_reg[7]),
    .search4_other_index(searchG4_other_index_reg[7]),
    .tupleData(tupleData_reg[10]),
    .clk(clk)
);
///////////////////////////////////////////////////////// Stage 9 /////////////////////////////////////////////////////////
search_stage #(
  .SUBSET_NUM(0),
  .TABLE_NUM(8),
  .G0_TABLE_ENTRY_SIZE(42),
  .G1_TABLE_ENTRY_SIZE(0),
  .G2_TABLE_ENTRY_SIZE(0),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(0),
  .G4_OTHER_TABLE_ENTRY_SIZE(0)
) stage9(
    .G0_match(G0_match_w[8]),
    .G0_match_ruleID(G0_match_ruleID_w[8]),
    .G0_next_index(searchG0_index_w[9]),
    .G1_match(G1_match_w[8]),
    .G1_match_ruleID(G1_match_ruleID_w[8]),
    .G1_next_index(searchG1_index_w[9]),
    .G2_match(G2_match_w[8]),
    .G2_match_ruleID(G2_match_ruleID_w[8]),
    .G2_next_index(searchG2_index_w[9]),    
    .G3_match(G3_match_w[8]),
    .G3_match_ruleID(G3_match_ruleID_w[8]),
    .G3_next_index(searchG3_index_w[9]),
    .G4_match(G4_match_w[8]),
    .G4_match_ruleID(G4_match_ruleID_w[8]),
    .G4_next_index(searchG4_index_w[9]),   
    .G4_other_match(G4_other_match_w[8]),
    .G4_other_match_ruleID(G4_other_match_ruleID_w[8]),
    .G4_other_next_index(searchG4_other_index_w[9]),
    
    .last_G0_match(G0_match_reg[7]),
    .last_G1_match(G1_match_reg[7]),
    .last_G2_match(G2_match_reg[7]),
    .last_G3_match(G3_match_reg[7]),
    .last_G4_match(G4_match_reg[7]),
    .last_G4_other_match(G4_other_match_reg[7]),
    .last_G0_match_ruleID(G0_match_ruleID_reg[7]),
    .last_G1_match_ruleID(G1_match_ruleID_reg[7]),
    .last_G2_match_ruleID(G2_match_ruleID_reg[7]),
    .last_G3_match_ruleID(G3_match_ruleID_reg[7]),
    .last_G4_match_ruleID(G4_match_ruleID_reg[7]),
    .last_G4_other_match_ruleID(G4_other_match_ruleID_reg[7]),
    .search0_index(searchG0_index_reg[8]),
    .search1_index(searchG1_index_reg[8]),
    .search2_index(searchG2_index_reg[8]),
    .search3_index(searchG3_index_reg[8]),
    .search4_index(searchG4_index_reg[8]),
    .search4_other_index(searchG4_other_index_reg[8]),
    .tupleData(tupleData_reg[11]),
    .clk(clk)
);
///////////////////////////////////////////////////////// Stage 10 /////////////////////////////////////////////////////////
search_stage #(
  .SUBSET_NUM(0),
  .TABLE_NUM(9),
  .G0_TABLE_ENTRY_SIZE(19),
  .G1_TABLE_ENTRY_SIZE(0),
  .G2_TABLE_ENTRY_SIZE(0),
  .G3_TABLE_ENTRY_SIZE(0),
  .G4_TABLE_ENTRY_SIZE(0),
  .G4_OTHER_TABLE_ENTRY_SIZE(0)
) stage10(
    .G0_match(G0_match_w[9]),
    .G0_match_ruleID(G0_match_ruleID_w[9]),
    //.G0_next_index(searchG0_index_w[10]),
    .G1_match(G1_match_w[9]),
    .G1_match_ruleID(G1_match_ruleID_w[9]),
    //.G1_next_index(searchG1_index_w[10]),
    .G2_match(G2_match_w[9]),
    .G2_match_ruleID(G2_match_ruleID_w[9]),
    //.G2_next_index(searchG2_index_w[10]),    
    .G3_match(G3_match_w[9]),
    .G3_match_ruleID(G3_match_ruleID_w[9]),
    //.G3_next_index(searchG3_index_w[10]),
    .G4_match(G4_match_w[9]),
    .G4_match_ruleID(G4_match_ruleID_w[9]),
    //.G4_next_index(searchG4_index_w[10]),   
    .G4_other_match(G4_other_match_w[9]),
    .G4_other_match_ruleID(G4_other_match_ruleID_w[9]),
    //.G4_next_other_index(searchG4_other_index_w[10]),
    
    
    .last_G0_match(G0_match_reg[8]),
    .last_G1_match(G1_match_reg[8]),
    .last_G2_match(G2_match_reg[8]),
    .last_G3_match(G3_match_reg[8]),
    .last_G4_match(G4_match_reg[8]),
    .last_G4_other_match(G4_other_match_reg[8]),
    .last_G0_match_ruleID(G0_match_ruleID_reg[8]),
    .last_G1_match_ruleID(G1_match_ruleID_reg[8]),
    .last_G2_match_ruleID(G2_match_ruleID_reg[8]),
    .last_G3_match_ruleID(G3_match_ruleID_reg[8]),
    .last_G4_match_ruleID(G4_match_ruleID_reg[8]),
    .last_G4_other_match_ruleID(G4_other_match_ruleID_reg[8]),
    .search0_index(searchG0_index_reg[9]),
    .search1_index(searchG1_index_reg[9]),
    .search2_index(searchG2_index_reg[9]),
    .search3_index(searchG3_index_reg[9]),
    .search4_index(searchG4_index_reg[9]),
    .search4_other_index(searchG4_other_index_reg[9]),
    .tupleData(tupleData_reg[12]),
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
