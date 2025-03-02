library verilog;
use verilog.vl_types.all;
entity encodingCont is
    port(
        message         : in     vl_logic_vector(35 downto 0);
        clk             : in     vl_logic;
        encodeMessage   : in     vl_logic;
        codeWordVector  : out    vl_logic_vector(59 downto 0);
        encoderBusy     : out    vl_logic
    );
end encodingCont;
