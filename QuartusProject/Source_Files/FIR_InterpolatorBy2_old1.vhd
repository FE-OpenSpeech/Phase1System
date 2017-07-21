-- -------------------------------------------------------------
--
-- Module: FIR_InterpolatorBy2
-- Generated by MATLAB(R) 9.1 and the Filter Design HDL Coder 3.1.
-- Generated on: 2017-06-01 11:59:44
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- HDL Code Generation Options:
--
-- TargetLanguage: VHDL
-- OptimizeForHDL: on
-- Name: FIR_InterpolatorBy2
-- SerialPartition: 8
-- InputDataType: numerictype(1,32,28)
-- TestBenchName: firinterp_copy_tb
-- TestBenchStimulus: step ramp chirp noise 
-- GenerateHDLTestBench: off

-- -------------------------------------------------------------
-- HDL Implementation    : Fully Serial
-- Folding Factor        : 8
-- -------------------------------------------------------------
-- Filter Settings:
--
-- Discrete-Time FIR Multirate Filter (real)
-- -----------------------------------------
-- Filter Structure      : Direct-Form FIR Polyphase Interpolator
-- Interpolation Factor  : 2
-- Polyphase Length      : 17
-- Filter Length         : 33
-- Stable                : Yes
-- Linear Phase          : Yes (Type 1)
--
-- Arithmetic            : fixed
-- Numerator             : s32,32 -> [-5.000000e-01 5.000000e-01)
-- -------------------------------------------------------------



LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY FIR_InterpolatorBy2 IS
   PORT( clk                             :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         clk_enable                      :   IN    std_logic; 
         filter_in                       :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En28
         filter_out                      :   OUT   std_logic_vector(68 DOWNTO 0); -- sfix69_En60
         ce_out                          :   OUT   std_logic  
         );
END FIR_InterpolatorBy2;

-- ### Starting VHDL code generation process for filter: FIR_InterpolatorBy2
-- ### Clock rate is 16 times the input and 8 times the output sample rate for this architecture.                NOTE this is what is said
-- ### REALITY: Clock rate is 32 times the input and 16 times the output sample rate for this architecture.      **However** this is what you really need since the clock is says is a factor of 2 off
-- ### HDL latency is 1 samples
-- NOTE:  The amplitude also comes out ~1/2 for a cosine signal, so the gain needs to be doubled.

----------------------------------------------------------------
--Module Architecture: FIR_InterpolatorBy2
----------------------------------------------------------------
ARCHITECTURE rtl OF FIR_InterpolatorBy2 IS
  -- Local Functions
  -- Type Definitions
  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF signed(31 DOWNTO 0); -- sfix32_En28
  -- Constants
  CONSTANT coeffphase1_1                  : signed(31 DOWNTO 0) := to_signed(6495482, 32); -- sfix32_En32
  CONSTANT coeffphase1_2                  : signed(31 DOWNTO 0) := to_signed(-10672579, 32); -- sfix32_En32
  CONSTANT coeffphase1_3                  : signed(31 DOWNTO 0) := to_signed(14367030, 32); -- sfix32_En32
  CONSTANT coeffphase1_4                  : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeffphase1_5                  : signed(31 DOWNTO 0) := to_signed(-54194786, 32); -- sfix32_En32
  CONSTANT coeffphase1_6                  : signed(31 DOWNTO 0) := to_signed(155032944, 32); -- sfix32_En32
  CONSTANT coeffphase1_7                  : signed(31 DOWNTO 0) := to_signed(-281016993, 32); -- sfix32_En32
  CONSTANT coeffphase1_8                  : signed(31 DOWNTO 0) := to_signed(387386168, 32); -- sfix32_En32
  CONSTANT coeffphase1_9                  : signed(31 DOWNTO 0) := to_signed(1716504348, 32); -- sfix32_En32
  CONSTANT coeffphase1_10                 : signed(31 DOWNTO 0) := to_signed(387386168, 32); -- sfix32_En32
  CONSTANT coeffphase1_11                 : signed(31 DOWNTO 0) := to_signed(-281016993, 32); -- sfix32_En32
  CONSTANT coeffphase1_12                 : signed(31 DOWNTO 0) := to_signed(155032944, 32); -- sfix32_En32
  CONSTANT coeffphase1_13                 : signed(31 DOWNTO 0) := to_signed(-54194786, 32); -- sfix32_En32
  CONSTANT coeffphase1_14                 : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeffphase1_15                 : signed(31 DOWNTO 0) := to_signed(14367030, 32); -- sfix32_En32
  CONSTANT coeffphase1_16                 : signed(31 DOWNTO 0) := to_signed(-10672579, 32); -- sfix32_En32
  CONSTANT coeffphase1_17                 : signed(31 DOWNTO 0) := to_signed(6495482, 32); -- sfix32_En32
  CONSTANT coeffphase2_1                  : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeffphase2_2                  : signed(31 DOWNTO 0) := to_signed(-9728750, 32); -- sfix32_En32
  CONSTANT coeffphase2_3                  : signed(31 DOWNTO 0) := to_signed(33591998, 32); -- sfix32_En32
  CONSTANT coeffphase2_4                  : signed(31 DOWNTO 0) := to_signed(-64992124, 32); -- sfix32_En32
  CONSTANT coeffphase2_5                  : signed(31 DOWNTO 0) := to_signed(72230070, 32); -- sfix32_En32
  CONSTANT coeffphase2_6                  : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeffphase2_7                  : signed(31 DOWNTO 0) := to_signed(-246880939, 32); -- sfix32_En32
  CONSTANT coeffphase2_8                  : signed(31 DOWNTO 0) := to_signed(1287613955, 32); -- sfix32_En32
  CONSTANT coeffphase2_9                  : signed(31 DOWNTO 0) := to_signed(1287613955, 32); -- sfix32_En32
  CONSTANT coeffphase2_10                 : signed(31 DOWNTO 0) := to_signed(-246880939, 32); -- sfix32_En32
  CONSTANT coeffphase2_11                 : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeffphase2_12                 : signed(31 DOWNTO 0) := to_signed(72230070, 32); -- sfix32_En32
  CONSTANT coeffphase2_13                 : signed(31 DOWNTO 0) := to_signed(-64992124, 32); -- sfix32_En32
  CONSTANT coeffphase2_14                 : signed(31 DOWNTO 0) := to_signed(33591998, 32); -- sfix32_En32
  CONSTANT coeffphase2_15                 : signed(31 DOWNTO 0) := to_signed(-9728750, 32); -- sfix32_En32
  CONSTANT coeffphase2_16                 : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeffphase2_17                 : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32

  CONSTANT const_zero                     : signed(64 DOWNTO 0) := to_signed(0, 65); -- sfix65_En60
  -- Signals
  SIGNAL cur_count                        : unsigned(3 DOWNTO 0); -- ufix4
  SIGNAL phase_0                          : std_logic; -- boolean
  SIGNAL phase_1                          : std_logic; -- boolean
  SIGNAL phase_8                          : std_logic; -- boolean
  SIGNAL phase_8_1                        : std_logic; -- boolean
  SIGNAL delay_pipeline                   : delay_pipeline_type(0 TO 16); -- sfix32_En28
  SIGNAL tapsum_and                       : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_1                     : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_2                     : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_3                     : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_4                     : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_5                     : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_6                     : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_7                     : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_8                     : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_9                     : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_10                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_11                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_12                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL delay_pipeline8_cast             : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL inputmux                         : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL product1                         : signed(64 DOWNTO 0); -- sfix65_En60
  SIGNAL product1_mux                     : signed(31 DOWNTO 0); -- sfix32_En32
  SIGNAL phasemux                         : signed(64 DOWNTO 0); -- sfix65_En60
  SIGNAL sumofproducts                    : signed(64 DOWNTO 0); -- sfix65_En60
  SIGNAL sumofproducts_cast               : signed(71 DOWNTO 0); -- sfix72_En60
  SIGNAL acc_sum                          : signed(71 DOWNTO 0); -- sfix72_En60
  SIGNAL accreg_in                        : signed(71 DOWNTO 0); -- sfix72_En60
  SIGNAL accreg_out                       : signed(71 DOWNTO 0); -- sfix72_En60
  SIGNAL add_temp                         : signed(72 DOWNTO 0); -- sfix73_En60
  SIGNAL accreg_final                     : signed(71 DOWNTO 0); -- sfix72_En60
  SIGNAL output_typeconvert               : signed(68 DOWNTO 0); -- sfix69_En60
  SIGNAL output_register                  : signed(68 DOWNTO 0); -- sfix69_En60


BEGIN

  -- Block Statements
  Counter : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      cur_count <= to_unsigned(15, 4);
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        IF cur_count = to_unsigned(15, 4) THEN
          cur_count <= to_unsigned(0, 4);
        ELSE
          cur_count <= cur_count + 1;
        END IF;
      END IF;
    END IF; 
  END PROCESS Counter;

  phase_0 <= '1' WHEN cur_count = to_unsigned(0, 4) AND clk_enable = '1' ELSE '0';

  phase_1 <= '1' WHEN  (((cur_count = to_unsigned(1, 4))  OR
                         (cur_count = to_unsigned(2, 4))  OR
                         (cur_count = to_unsigned(3, 4))  OR
                         (cur_count = to_unsigned(4, 4))  OR
                         (cur_count = to_unsigned(5, 4))  OR
                         (cur_count = to_unsigned(6, 4))  OR
                         (cur_count = to_unsigned(7, 4))  OR
                         (cur_count = to_unsigned(8, 4))  OR
                         (cur_count = to_unsigned(9, 4))  OR
                         (cur_count = to_unsigned(10, 4))  OR
                         (cur_count = to_unsigned(11, 4))  OR
                         (cur_count = to_unsigned(12, 4))  OR
                         (cur_count = to_unsigned(13, 4))  OR
                         (cur_count = to_unsigned(14, 4)))  AND clk_enable = '1') ELSE '0';

  phase_8 <= '1' WHEN  (((cur_count = to_unsigned(10, 4))  OR
                         (cur_count = to_unsigned(2, 4)))  AND clk_enable = '1') ELSE '0';

  phase_8_1 <= '1' WHEN  (((cur_count = to_unsigned(9, 4))  OR
                           (cur_count = to_unsigned(1, 4)))  AND clk_enable = '1') ELSE '0';

  --   ---------------- Delay Registers ----------------

  Delay_Pipeline_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      delay_pipeline(0 TO 16) <= (OTHERS => (OTHERS => '0'));
    ELSIF clk'event AND clk = '1' THEN
      IF phase_0 = '1' THEN
        delay_pipeline(0) <= signed(filter_in);
        delay_pipeline(1 TO 16) <= delay_pipeline(0 TO 15);
      END IF;
    END IF; 
  END PROCESS Delay_Pipeline_process;

  -- Adding (or subtracting) the taps based on the symmetry (or asymmetry)

  tapsum_and <= resize(delay_pipeline(0), 33) + resize(delay_pipeline(16), 33);

  tapsum_and_1 <= resize(delay_pipeline(1), 33) + resize(delay_pipeline(15), 33);

  tapsum_and_2 <= resize(delay_pipeline(2), 33) + resize(delay_pipeline(14), 33);

  tapsum_and_3 <= resize(delay_pipeline(4), 33) + resize(delay_pipeline(12), 33);

  tapsum_and_4 <= resize(delay_pipeline(5), 33) + resize(delay_pipeline(11), 33);

  tapsum_and_5 <= resize(delay_pipeline(6), 33) + resize(delay_pipeline(10), 33);

  tapsum_and_6 <= resize(delay_pipeline(7), 33) + resize(delay_pipeline(9), 33);

  tapsum_and_7 <= resize(delay_pipeline(1), 33) + resize(delay_pipeline(14), 33);

  tapsum_and_8 <= resize(delay_pipeline(2), 33) + resize(delay_pipeline(13), 33);

  tapsum_and_9 <= resize(delay_pipeline(3), 33) + resize(delay_pipeline(12), 33);

  tapsum_and_10 <= resize(delay_pipeline(4), 33) + resize(delay_pipeline(11), 33);

  tapsum_and_11 <= resize(delay_pipeline(6), 33) + resize(delay_pipeline(9), 33);

  tapsum_and_12 <= resize(delay_pipeline(7), 33) + resize(delay_pipeline(8), 33);

  -- Mux(es) to select the input taps for multipliers 

  delay_pipeline8_cast <= resize(delay_pipeline(8), 33);

  inputmux <= tapsum_and WHEN ( cur_count = to_unsigned(1, 4) ) ELSE
                   tapsum_and_1 WHEN ( cur_count = to_unsigned(2, 4) ) ELSE
                   tapsum_and_2 WHEN ( cur_count = to_unsigned(3, 4) ) ELSE
                   tapsum_and_3 WHEN ( cur_count = to_unsigned(4, 4) ) ELSE
                   tapsum_and_4 WHEN ( cur_count = to_unsigned(5, 4) ) ELSE
                   tapsum_and_5 WHEN ( cur_count = to_unsigned(6, 4) ) ELSE
                   tapsum_and_6 WHEN ( cur_count = to_unsigned(7, 4) ) ELSE
                   delay_pipeline8_cast WHEN ( cur_count = to_unsigned(8, 4) ) ELSE
                   tapsum_and_7 WHEN ( cur_count = to_unsigned(9, 4) ) ELSE
                   tapsum_and_8 WHEN ( cur_count = to_unsigned(10, 4) ) ELSE
                   tapsum_and_9 WHEN ( cur_count = to_unsigned(11, 4) ) ELSE
                   tapsum_and_10 WHEN ( cur_count = to_unsigned(12, 4) ) ELSE
                   tapsum_and_11 WHEN ( cur_count = to_unsigned(13, 4) ) ELSE
                   tapsum_and_12;

  product1_mux <= coeffphase1_1 WHEN ( cur_count = to_unsigned(1, 4) ) ELSE
                       coeffphase1_2 WHEN ( cur_count = to_unsigned(2, 4) ) ELSE
                       coeffphase1_3 WHEN ( cur_count = to_unsigned(3, 4) ) ELSE
                       coeffphase1_5 WHEN ( cur_count = to_unsigned(4, 4) ) ELSE
                       coeffphase1_6 WHEN ( cur_count = to_unsigned(5, 4) ) ELSE
                       coeffphase1_7 WHEN ( cur_count = to_unsigned(6, 4) ) ELSE
                       coeffphase1_8 WHEN ( cur_count = to_unsigned(7, 4) ) ELSE
                       coeffphase1_9 WHEN ( cur_count = to_unsigned(8, 4) ) ELSE
                       coeffphase2_2 WHEN ( cur_count = to_unsigned(9, 4) ) ELSE
                       coeffphase2_3 WHEN ( cur_count = to_unsigned(10, 4) ) ELSE
                       coeffphase2_4 WHEN ( cur_count = to_unsigned(11, 4) ) ELSE
                       coeffphase2_5 WHEN ( cur_count = to_unsigned(12, 4) ) ELSE
                       coeffphase2_7 WHEN ( cur_count = to_unsigned(13, 4) ) ELSE
                       coeffphase2_8;
  product1 <= inputmux * product1_mux;

  phasemux <= product1 WHEN ( phase_1 = '1' ) ELSE
                   const_zero;


  -- Add the products in linear fashion

  sumofproducts <= phasemux;

  -- Resize the sum of products to the accumulator type for full precision addition

  sumofproducts_cast <= resize(sumofproducts, 72);

  -- Accumulator register with a mux to reset it with the first addend

  add_temp <= resize(sumofproducts_cast, 73) + resize(accreg_out, 73);
  acc_sum <= add_temp(71 DOWNTO 0);

  accreg_in <= sumofproducts_cast WHEN ( phase_8_1 = '1' ) ELSE
                    acc_sum;

  Acc_reg_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      accreg_out <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        accreg_out <= accreg_in;
      END IF;
    END IF; 
  END PROCESS Acc_reg_process;

  -- Register to hold the final value of the accumulated sum

  Acc_finalreg_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      accreg_final <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF phase_8_1 = '1' THEN
        accreg_final <= accreg_out;
      END IF;
    END IF; 
  END PROCESS Acc_finalreg_process;

  output_typeconvert <= accreg_final(68 DOWNTO 0);

  Output_Register_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      output_register <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF phase_8 = '1' THEN
        output_register <= output_typeconvert;
      END IF;
    END IF; 
  END PROCESS Output_Register_process;

  -- Assignment Statements
  ce_out <= phase_0;
  filter_out <= std_logic_vector(output_register);
END rtl;
