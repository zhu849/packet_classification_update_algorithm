`timescale 1ns / 1ps

module main(
    output reg match_reg,
    
    input [103:0] tupleData,//srcIP:0-31, dstIP:32-63, srcport:64-79, dstport:80-95, protocol:96-103
    input [1:0] command,// 10:search, 01:update
    input clk
 );
 
 // check whether match in each subset
 wire subset0_match;
 wire subset1_match;
 wire subset2_match;
 wire subset3_match;
 
 // record match rule's ID
 wire [10:0]match_ruleID0; // max element size is 1738(Small segment + G0) 
 wire [10:0]match_ruleID1; // max element size is 1738(Small segment + G0) 
 wire [10:0]match_ruleID2; // max element size is 1738(Small segment + G0) 
 wire [10:0]match_ruleID3; // max element size is 1738(Small segment + G0) 
 //reg subset3_smallorbig; // check subset if small or big segment 
 
 subset0 subset0(
 .match_reg(subset0_match),
 .match_ruleID_reg(match_ruleID0), 
 
 .tupleData(tupleData),
 .command(command), 
 .clk(clk)
 );
 
 always@(posedge clk)
 begin
    //subset3_smallorbig <= 1'b1; // small=0, bit=1
    //compare subset0-3 match reuslt
 end
 
endmodule
