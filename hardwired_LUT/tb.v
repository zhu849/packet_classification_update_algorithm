`timescale 1ns / 10ps
`define CYCLE 5.0
`define END_CYCLE 100000
`define FILE_NAME "ipv4_data.txt"
`define FILE_PATH "D:/LUT_test/LUT_test1107/ipv4_data.txt"

module tb;
    reg [35:0] ip_data [7:0];
    reg [35:0] ip_in;
    reg [5:0] counter;
    reg valid;
    wire [5:0] match_out;
    reg [5:0] match_out_r;
    
    reg reset = 0;
    reg clk = 0;
    reg [22:0] cycle = 0;
    
    
// Declared lut instance
mylut mylut_U0(
    .out(match_out),
    
    .clk(clk),
    .valid(valid),
    .in(ip_in)
);

// Set clock
always begin 
    #(`CYCLE/2) clk = ~clk;
end

initial begin
    @(posedge clk); #2 reset = 1'b1;
    #(`CYCLE*2);
    @(posedge clk); #2 reset = 1'b0;
end

// Open ipv4 data file from output
initial begin
    $readmemb(`FILE_PATH, ip_data, 0, 7);
end

// Fail simulation because waitting too long
always @(posedge clk) begin
    cycle=cycle+1;
    if (cycle > `END_CYCLE) begin
        $display("--------------------------------------------------");
        $display("-- Failed waiting valid signal, Simulation STOP --");
        $display("--------------------------------------------------");
        $finish;
    end
end

always @(posedge clk) begin
    if(reset)begin
        valid <= 1;
        counter <= 0;
    end
   
    if(valid)begin
        ip_in <= ip_data[counter];
        counter <= counter + 1;
        match_out_r <= match_out;
    end

end

endmodule
