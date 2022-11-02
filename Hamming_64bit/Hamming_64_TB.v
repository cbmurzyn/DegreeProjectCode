
`timescale 100ms/100ms

module Hamming_64_TB;
    reg [63:0] dataIn;
    reg clk;
    wire [71:0] codeWord;
    //reg [63:0] max = 64'b1111111111111111111111111111111111111111111111111111111111111111;

    HammingEncoding64_Run UUT (
        .dataIn(dataIn),
        .clk(clk),
        .codeWord(codeWord)
    );

    always begin
        clk = 1'b1;
        #0.5; //high for 1 second
        clk = 1'b0;
        #0.5; // low for 1 second
    end

    always @(posedge clk ) begin
        dataIn = 64'b1010101010101010101010101010101010101010101010101010101010101010;      //2^64;
    end
    
endmodule