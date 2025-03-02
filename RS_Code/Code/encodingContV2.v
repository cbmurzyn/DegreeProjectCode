/*
TODO: Make code more efficent
  ?Can shift registers be executed to at the same time (may need multiple multiply functions)?
  ?Can multiply[0,1,2,3] be executed to at the same time

*/

module encodingContV2(
input [35:0] message,
input encodeMessage,
output reg [59:0] encodedMessage,
output reg encoderBusy
); 
//==============================================================================================
    reg [3:0] galoisField [15:0]; // n = 15 GF elements of length m = 4
    reg [3:0] parityInfo [5:0] ; //CK(X)
    reg [3:0] messageIn [8:0]; //M(X)
    reg [3:0] codeWord [14:0]; //C(X) = [X^(n-k)]M(X) + CK(X)
    reg [3:0] shiftRegister [5:0]; 
    reg [3:0] shiftRegisterOld [5:0];     
    integer i,j,k;

//==============================================================================================    
  initial begin
    encoderBusy = 0;
    //Initialization
      for (i = 0; i < 15; i = i + 1) begin
        parityInfo[i] = 4'b0;
      end

      for (i = 0; i < 15; i = i + 1) begin
        codeWord[i] = 4'b0;
      end
  end

//==============================================================================================  
  always @(encodeMessage)begin  
    encoderBusy = 1;
    //Unpack message
    for (i = 0; i <= 8; i = i + 1) begin
      messageIn[i] = message[4*i +: 4]; //[<start_bit> +: <width>] indexed part select
    end
  
    //==========================================================================================
    // Following Appendix A from Tutorial on Reed-Solomon Error Correction Coding
    //Case 0
    for (i = 0; i < 6; i = i + 1) begin
      shiftRegister[i] = 4'b0000;
    end
    //Case 1 through k=9
    for (i = 8; i > -1; i = i - 1) begin
      for (j = 0; j < 15; j = j + 1) begin
        shiftRegisterOld[j] = shiftRegister[j];
      end

      //X^0 = (X^5_old + M_i(X))alpha^6
      shiftRegister[0] = multiply(shiftRegisterOld[5] ^ messageIn[i], 4'b1100); 

      //X^1 = X^0_old + (X^5_old + M_i(X))alpha^9
      shiftRegister[1] = shiftRegisterOld[0] ^ (multiply((shiftRegisterOld[5] ^ messageIn[i]), 4'b1010));

      //X^2 = X^1_old + (X^5_old + M_i(X))alpha^6
      shiftRegister[2] = shiftRegisterOld[1] ^ (multiply((shiftRegisterOld[5] ^ messageIn[i]), 4'b1100));

      //X^3 = X^2_old + (X^5_old + M_i(X))alpha^4
      shiftRegister[3] = shiftRegisterOld[2] ^ (multiply((shiftRegisterOld[5] ^ messageIn[i]), 4'b0011));

      //X^4 = X^3_old + (X^5_old + M_i(X))alpha^14
      shiftRegister[4] = shiftRegisterOld[3] ^ (multiply((shiftRegisterOld[5] ^ messageIn[i]), 4'b1001));

      //X^5 = X^4_old + (X^5_old + M_i(X))alpha^10
      shiftRegister[5] = shiftRegisterOld[4] ^ (multiply((shiftRegisterOld[5] ^ messageIn[i]), 4'b0111));  

      //!-----------------------------------------REMOVE-----------------------------------------------------
      //! Packing shiftRegister values just for monitoring wave.
      ////for (k = 0; k <= 5; k = k + 1) begin
      ////  shiftRegisterPacked[4*k +: 4] = shiftRegister[k]; //[<start_bit> +: <width>] indexed part select
      ////end    
      //!-----------------------------------------REMOVE------------------------------------------------------
    end
    //C(X) = X^{n-k}*M(X) + CK(X)
    for (i = 0; i < 15; i = i + 1) begin
      if (i < 6) codeWord[i] = shiftRegister[i];        
      else codeWord[i] = messageIn[i - 6];
    end
    
    //Pack codeWord
    for (i = 0; i <= 14; i = i + 1) begin
      encodedMessage[4*i +: 4] = codeWord[i]; //[<start_bit> +: <width>] indexed part select
    end
    encoderBusy = 0;
  end

  function [3:0] multiply; //GF multiplication
  input [3:0] a, b;
    begin
        multiply[3] = (a[0]&b[3]) ^ (a[1]&b[2]) ^ (a[2]&b[1]) ^ (a[3]&b[0]) ^ (a[3]&b[3]);
        multiply[2] = (a[0]&b[2]) ^ (a[1]&b[1]) ^ (a[2]&b[0]) ^ (a[3]&b[3]) ^ (a[3]&b[2]) ^ (a[2]&b[3]);
        multiply[1] = (a[0]&b[1]) ^ (a[1]&b[0]) ^ (a[3]&b[2]) ^ (a[2]&b[3]) ^ (a[1]&b[3]) ^ (a[2]&b[2]) ^ (a[3]&b[1]);
        multiply[0] = (a[0]&b[0]) ^ (a[1]&b[3]) ^ (a[2]&b[2]) ^ (a[3]&b[1]);
    end
  endfunction
endmodule

