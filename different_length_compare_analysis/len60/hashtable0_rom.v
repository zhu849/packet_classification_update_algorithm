
module hashtable0_rom
#(
    parameter SUBSET_NUM = 0,
    parameter HASHTABLE_ENTRY_BIT_LEN=12
)
(
    output reg [HASHTABLE_ENTRY_BIT_LEN-1:0]dout, // index bit:0-10, indicate bit:11
    
    input [HASHTABLE_ENTRY_BIT_LEN-1:0] din,
    input [15:0] addr,//range in 0-65535, so use 15 bits store data
    input we, //write or read, 0 = read, 1 = wirte
    input clk
);
    
//segment table memory
(* RAM_STYLE="BLOCK" *) reg [HASHTABLE_ENTRY_BIT_LEN-1:0] seg_table [65535:0]; // index bits:0-10, small or big segment bit:11

//read hash table from file
// size is 65535*12 bit
// this index will be small segment index, so it should used 11 bit to store
initial begin
    if(SUBSET_NUM == 0)
        $readmemb("D:/YuHang_update/hashtable/subset0_hashtable.txt", seg_table, 0, 65535);
    else if (SUBSET_NUM == 1)
        $readmemb("D:/YuHang_update/hashtable/subset1_hashtable.txt", seg_table, 0, 65535);
    else if (SUBSET_NUM == 2)
        $readmemb("D:/YuHang_update/hashtable/subset2_hashtable.txt", seg_table, 0, 65535);
end   
    
always@(posedge clk)
begin
    if(we)
        seg_table[addr] <= din;
    else
        dout <= seg_table[addr];
end
    
endmodule
