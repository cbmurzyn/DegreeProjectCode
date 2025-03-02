module encodingDecodingTB;
    reg [35:0] messageOut = 0;
    reg [3:0] message [8:0];
    reg clk;
    reg encodeMessage = 0;
    reg decodeMessage = 0;
    reg [3:0] galoisField [14:0];
    reg [59:0] recievedWordIn;
    reg [3:0] error [14:0];
    reg [59:0] errorPacked;
    wire [59:0] encodedMessage;
    wire encoderBusy;
    wire [35:0] messageRecieved;

    integer i;

    encodingContV2 encodingContV2Inst (
        .message(messageOut),
        .encodedMessage(encodedMessage),
        .encodeMessage(encodeMessage),
        .encoderBusy(encoderBusy)
    );
    
    decodingCont decodingInst(
      .recievedWordIn(recievedWordIn),
      .decodeMessage(decodeMessage),
      .decoderBusy(decoderBusy),
      .messageRecieved(messageRecieved)
    );

    task outputMessage1; //alpha^11*X
      begin
        message[0] = 0;
        message[1] = galoisField[11];
        message[2] = 0;
        message[3] = 0;
        message[4] = 0;
        message[5] = 0;
        message[6] = 0;
        message[7] = 0;
        message[8] = 0;

      //Pack message
      for (i = 0; i <= 14; i = i + 1) begin
        messageOut[4*i +: 4] = message[i];
      end
      end
    endtask


    task addError;
      begin
        error[0] = 0;
        error[1] = 0;
        error[2] = 4'b0001;
        error[3] = 0;
        error[4] = 0;
        error[5] = 0;
        error[6] = 0;
        error[7] = 0;
        error[8] = 4'b0000;
        error[9] = 4'b1111;
        error[10] = 4'b0000;
        error[11] = 4'b0000;
        error[12] = 0;
        error[13] = 0;
        error[14] = 0;
        
      //Pack error
      for (i = 0; i <= 14; i = i + 1) begin
        errorPacked[4*i +: 4] = error[i];
      end

        recievedWordIn = encodedMessage ^ errorPacked;
      end
    endtask


    initial begin
        //Establishing GF elements (alpha_i values)
        galoisField[0] = 4'b0001; //alpha^0
        galoisField[1] = 4'b0010; //alpha^1
        galoisField[2] = 4'b0100; //alpha^2
        galoisField[3] = 4'b1000; //alpha^3
        galoisField[4] = 4'b0011; //alpha^4
        galoisField[5] = 4'b0110; //alpha^5
        galoisField[6] = 4'b1100; //alpha^6
        galoisField[7] = 4'b1011; //alpha^7
        galoisField[8] = 4'b0101; //alpha^8
        galoisField[9] = 4'b1010; //alpha^9
        galoisField[10] = 4'b0111; //alpha^10
        galoisField[11] = 4'b1110; //alpha^11
        galoisField[12] = 4'b1111; //alpha^12
        galoisField[13] = 4'b1101; //alpha^13
        galoisField[14] = 4'b1001; //alpha^14



      #1;
      if (!encoderBusy) begin
        outputMessage1;
        encodeMessage = ~encodeMessage;
        #1;

        //$stop;
      end  
      if (!decoderBusy) begin
        addError;
        decodeMessage = ~decodeMessage;
        #1;
        $stop;
      end  
    end
endmodule

