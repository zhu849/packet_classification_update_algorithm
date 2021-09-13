`timescale 1ns / 1ps

module search_G4table
#(
    parameter SUBSET_NUM=0,
    parameter TABLE_NUM=0,
    parameter TABLE_ENTRY_SIZE=29
)
(
    output reg match,
    output reg [10:0] ruleID,
    output reg [10:0] next_index,

    input [10:0] search_index,
    input [103:0] tupleData,
    input clk   
);

// get result from memory
wire [170:0] mem_data_w;

G4_table_rom
#(
    .SUBSET_NUM(SUBSET_NUM),
    .TABLE_NUM(TABLE_NUM),
    .TABLE_ENTRY_SIZE(TABLE_ENTRY_SIZE)
)
G4_table_rom(
    .dout(mem_data_w),

    //.din(),
    .addr(search_index),
    .we(1'b0),
    .clk(clk)
);

always@(posedge clk)
begin
    // assign next search index
    next_index <= mem_data_w[170:160];

    // compare logic
    if(mem_data_w[31:0] == tupleData[31:0])// compare srcIP
    begin
        if(mem_data_w[69:38] == tupleData[63:32])//compare dstIP
        begin
            if((mem_data_w[107:92] <= tupleData[79:64]) && (tupleData[79:64] <= mem_data_w[91:76]))// compare srcPort
            begin
                if((mem_data_w[139:124] <= tupleData[79:64]) && (tupleData[79:64] <= mem_data_w[123:108]))// compare dstPort
                begin 
                    if(mem_data_w[148] || mem_data_w[139:124] == tupleData[103:96])// compare protocol
                    begin
                        match <= 1'b1;
                        ruleID <= mem_data_w[159:149];
                    end
                end
            end
        end
    end
end

endmodule
