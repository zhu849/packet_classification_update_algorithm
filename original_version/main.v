

module main(
    output reg match_reg,
    output reg [INDEX_BIT_LEN-1:0] matchID_reg,
    
    input [PACKET_BIT_LEN-1:0] tupleData, //srcIP:0-31, dstIP:32-63, srcport:64-79, dstport:80-95, protocol:96-103
    input [COMMAND_BIT_LEN-1:0] command,
    input clk
 );
 
  /******  Localparam Define ******/
localparam INDEX_BIT_LEN = 11; //�Ω���� matchID �� bit ���סA�]���Ҧs�� small segment + G0 table �� entry �ӼƳ̦h�i��|�� 1738�A�ҥH�ثe�ȩw  index ���׬� 11(�e�Ǩ�2048)
localparam PACKET_BIT_LEN = 104; //�Ω�����ʥ]��ƪ� bit ����
localparam COMMAND_BIT_LEN = 2; //�Ω���� command �� bit ���סAcommand �ثe�ȮɬO�� 01 ��@ search�A�� 10 ��@ update
 /****************************/
 
 // check whether match in each subset
 // �ˬd�b�C�� subset ���O�_�� match ��
 wire subset0_match_w;
 wire subset1_match_w;
 wire subset2_match_w;
 wire subset3_match_w;
 /*
 reg subset0_match_reg;
 reg subset1_match_reg;
 reg subset2_match_reg;
 reg subset3_match_reg;
 */
 
 // record match rule's ID
 // �����C�� subset ���ҹ����쪺 match �� match ID ����
 wire [INDEX_BIT_LEN-1:0] match_ruleID0_w;
 wire [INDEX_BIT_LEN-1:0] match_ruleID1_w; 
 wire [INDEX_BIT_LEN-1:0] match_ruleID2_w; 
 wire [INDEX_BIT_LEN-1:0] match_ruleID3_w; 
 reg [INDEX_BIT_LEN-1:0] match_ruleID0_reg;
 reg [INDEX_BIT_LEN-1:0] match_ruleID1_reg;
 reg [INDEX_BIT_LEN-1:0] match_ruleID2_reg;
 reg [INDEX_BIT_LEN-1:0] match_ruleID3_reg;
 
 subset0 #(
    .INDEX_BIT_LEN(INDEX_BIT_LEN),
    .PACKET_BIT_LEN(PACKET_BIT_LEN),
    .COMMAND_BIT_LEN(COMMAND_BIT_LEN)
 )subset0(
 .match_reg(subset0_match_w),
 .match_ruleID_reg(match_ruleID0_w), 
 
 .tupleData(tupleData),
 .command(command), 
 .clk(clk)
 );
 
 subset1 subset1(
 .match_reg(subset1_match_w),
 .match_ruleID_reg(match_ruleID1_w), 
 
 .tupleData(tupleData),
 .command(command), 
 .clk(clk)
 );
 
 subset2 subset2(
 .match_reg(subset2_match_w),
 .match_ruleID_reg(match_ruleID2_w), 
 
 .tupleData(tupleData),
 .command(command), 
 .clk(clk)
 );
 
 subset3 subset3(
 .match_reg(subset3_match_w),
 .match_ruleID_reg(match_ruleID3_w), 
 
 .tupleData(tupleData),
 .command(command), 
 .clk(clk)
 );
 
 always@(posedge clk)
 begin
    /*
        // assign subset 0-3 match result
        // ��±N subset �� match �����G�M match �쪺 ruleID �q wire �g�� reg ��
        subset0_match_reg <= subset0_match_w;
        subset1_match_reg <= subset1_match_w;
        subset2_match_reg <= subset2_match_w;
        subset3_match_reg <= subset3_match_w;
        match_ruleID0_reg <= match_ruleID0_w;
        match_ruleID1_reg <= match_ruleID1_w;
        match_ruleID2_reg <= match_ruleID2_w;
        match_ruleID3_reg <= match_ruleID3_w;
        */
        
    //compare subset0-3 match reuslt
    // Priority encoder with subset 0-3
    // �q subset 0-3 ��ܳ̾A�X�� match rule
    if(subset0_match_w | subset1_match_w | subset2_match_w | subset3_match_w)
    begin
        match_reg <= 1'b1;
        
        if((match_ruleID0_w > match_ruleID1_w) & (match_ruleID0_w > match_ruleID2_w) & (match_ruleID0_w > match_ruleID3_w))
            matchID_reg <= match_ruleID0_w;
        else if((match_ruleID1_w > match_ruleID0_w) & (match_ruleID1_w > match_ruleID2_w) & (match_ruleID1_w > match_ruleID3_w))
            matchID_reg <= match_ruleID1_w;
        else if((match_ruleID2_w >= match_ruleID0_w) & (match_ruleID2_w >= match_ruleID1_w) & (match_ruleID2_w >= match_ruleID3_w))
            matchID_reg <= match_ruleID2_w;
        else 
            matchID_reg <= match_ruleID3_w;
    end
    else
        match_reg <= 1'b0;
 end
 
endmodule
