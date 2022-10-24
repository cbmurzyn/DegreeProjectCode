

module HammingDecoding (
    //input reg[15:0] channelWord, //codeWord with possible error
    //input clk
);
    reg [3:0] channelOnes [14:0]; //
    reg [3:0] onesCount;
    reg [3:0] errorLoc;
    reg [15:0] channelWord;
    integer i,a;
    
    //always @(posedge) begin
    initial begin
        errorLoc = 4'b0000;
        channelWord = 16'b1111110011110010;
        onesCount = 0;

        for (i = 1; i < 16; i = i + 1) begin //skipping the zeroth bit
            if (channelWord[i] == 1) begin
                channelOnes[i] = i; 
                onesCount = onesCount + 1;
            end
            else begin
                channelOnes[i] = 0;
            end
        end    

        //Taking the XOR of channelOnes
        if (onesCount == 1) begin
            for (i = 0; i < 16 ; i = i + 1) begin //Find the one location where the error is
                if (channelOnes[i] != 0) begin
                    errorLoc = channelOnes[i];
                end
            end
        end
        else if (onesCount > 1)begin
            for (i = 1; i < 16; i = i + 1) begin
                errorLoc = errorLoc ^ channelOnes[i];
            end      
        end
        else begin
            $display("No errors were found.");
        end
        //errorLoc reg is getting erased
    end


endmodule
