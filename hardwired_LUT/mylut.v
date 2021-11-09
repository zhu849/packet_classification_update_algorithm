module mylut(
    output reg [5:0] out, // LUT #0-#5
    
    input        clk,
    input  [35:0] in,
    input valid
);                  

reg [35:0]  in_reg;
wire [5:0]  out_wire;

always @(posedge clk) begin
    if(valid)begin
        in_reg <= in;
        out[0] <= out_wire[0];
        out[1] <= out_wire[1];
        out[2] <= out_wire[2];
        out[3] <= out_wire[3];
        out[4] <= out_wire[4];
        out[5] <= out_wire[5];
    end
end
    
(*LOC = "SLICE_X26Y499", BEL = "A6LUT"*)
LUT6 #(
    .INIT (64'h0000_0008_0000_0000)
) LUT6_U0 (
    .O (out_wire[0]),

    .I5 (in[35]), 
    .I4 (in[34]), 
    .I3 (in[33]), 
    .I2 (in[32]), 
    .I1 (in[31]), 
    .I0 (in[30])  
);

(*LOC = "SLICE_X26Y499", BEL = "B6LUT"*)
LUT6 #(
    .INIT (64'h0000_0000_0000_0080)
) LUT6_U1 (
    .O (out_wire[1]),

    .I5 (in[29]), 
    .I4 (in[28]), 
    .I3 (in[27]), 
    .I2 (in[26]), 
    .I1 (in[25]), 
    .I0 (in[24]) 
);

(*LOC = "SLICE_X26Y499", BEL = "C6LUT"*)
LUT6 #(
    .INIT (64'h0000_0000_0002_0000)
) LUT6_U2 (
    .O (out_wire[2]),

    .I5 (in[23]), 
    .I4 (in[22]), 
    .I3 (in[21]), 
    .I2 (in[20]), 
    .I1 (in[19]), 
    .I0 (in[18]) 
);

(*LOC = "SLICE_X26Y499", BEL = "D6LUT"*)
LUT6 #(
    .INIT (64'h0000_0000_000F_0000)
) LUT6_U3 (
    .O (out_wire[3]),

    .I5 (in[17]), 
    .I4 (in[16]), 
    .I3 (in[15]), 
    .I2 (in[14]), 
    .I1 (in[13]), 
    .I0 (in[12]) 
);

(*LOC = "SLICE_X26Y498"*)
LUT6 #(
    .INIT (64'hFFFF_FFFF_FFFF_FFFF)
) LUT6_U4 (
    .O (out_wire[4]),

    .I5 (in[11]), 
    .I4 (in[10]), 
    .I3 (in[9]), 
    .I2 (in[8]), 
    .I1 (in[7]), 
    .I0 (in[6]) 
);

(*LOC = "SLICE_X26Y497"*)
LUT6 #(
    .INIT (64'hFFFF_FFFF_FFFF_FFFF)
) LUT6_U5 (
    .O (out_wire[5]),

    .I5 (in[5]), 
    .I4 (in[4]), 
    .I3 (in[3]), 
    .I2 (in[2]), 
    .I1 (in[1]), 
    .I0 (in[0]) 
);

endmodule 
    
