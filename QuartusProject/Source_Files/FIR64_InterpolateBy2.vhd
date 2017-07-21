-- -------------------------------------------------------------
--
-- Module: FIR64_InterpolateBy2
-- Generated by MATLAB(R) 9.1 and the Filter Design HDL Coder 3.1.
-- Generated on: 2017-06-13 12:04:22
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- HDL Code Generation Options:
--
-- TargetLanguage: VHDL
-- Name: FIR64_InterpolateBy2
-- SerialPartition: [16   1]
-- InputDataType: numerictype(1,32,28)
-- TestBenchName: firinterp_copy_tb
-- TestBenchStimulus: step ramp chirp noise 

-- -------------------------------------------------------------
-- HDL Implementation    : Partly Serial
-- Folding Factor        : 16
-- -------------------------------------------------------------
-- Filter Settings:
--
-- Discrete-Time FIR Multirate Filter (real)
-- -----------------------------------------
-- Filter Structure      : Direct-Form FIR Polyphase Interpolator
-- Interpolation Factor  : 2
-- Polyphase Length      : 33
-- Filter Length         : 65
-- Stable                : Yes
-- Linear Phase          : Yes (Type 1)
--
-- Arithmetic            : fixed
-- Numerator             : s32,32 -> [-5.000000e-01 5.000000e-01)
-- -------------------------------------------------------------



LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY FIR64_InterpolateBy2 IS
   PORT( clk                             :   IN    std_logic; 
         clk_enable                      :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         filter_in                       :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En28
         filter_out                      :   OUT   std_logic_vector(69 DOWNTO 0); -- sfix70_En60
         ce_out                          :   OUT   std_logic  
         );

END FIR64_InterpolateBy2;


----------------------------------------------------------------
--Module Architecture: FIR64_InterpolateBy2
----------------------------------------------------------------
ARCHITECTURE rtl OF FIR64_InterpolateBy2 IS
  -- Local Functions
  -- Type Definitions
  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF signed(31 DOWNTO 0); -- sfix32_En28
  -- Constants
  CONSTANT coeffphase1_1                  : signed(31 DOWNTO 0) := to_signed(-3093618, 32); -- sfix32_En32
  CONSTANT coeffphase1_2                  : signed(31 DOWNTO 0) := to_signed(3851666, 32); -- sfix32_En32
  CONSTANT coeffphase1_3                  : signed(31 DOWNTO 0) := to_signed(-5518202, 32); -- sfix32_En32
  CONSTANT coeffphase1_4                  : signed(31 DOWNTO 0) := to_signed(8269448, 32); -- sfix32_En32
  CONSTANT coeffphase1_5                  : signed(31 DOWNTO 0) := to_signed(-12211991, 32); -- sfix32_En32
  CONSTANT coeffphase1_6                  : signed(31 DOWNTO 0) := to_signed(17368568, 32); -- sfix32_En32
  CONSTANT coeffphase1_7                  : signed(31 DOWNTO 0) := to_signed(-23669972, 32); -- sfix32_En32
  CONSTANT coeffphase1_8                  : signed(31 DOWNTO 0) := to_signed(30953944, 32); -- sfix32_En32
  CONSTANT coeffphase1_9                  : signed(31 DOWNTO 0) := to_signed(-38971397, 32); -- sfix32_En32
  CONSTANT coeffphase1_10                 : signed(31 DOWNTO 0) := to_signed(47399686, 32); -- sfix32_En32
  CONSTANT coeffphase1_11                 : signed(31 DOWNTO 0) := to_signed(-55862069, 32); -- sfix32_En32
  CONSTANT coeffphase1_12                 : signed(31 DOWNTO 0) := to_signed(63951971, 32); -- sfix32_En32
  CONSTANT coeffphase1_13                 : signed(31 DOWNTO 0) := to_signed(-71260243, 32); -- sfix32_En32
  CONSTANT coeffphase1_14                 : signed(31 DOWNTO 0) := to_signed(77403334, 32); -- sfix32_En32
  CONSTANT coeffphase1_15                 : signed(31 DOWNTO 0) := to_signed(-82050183, 32); -- sfix32_En32
  CONSTANT coeffphase1_16                 : signed(31 DOWNTO 0) := to_signed(84945739, 32); -- sfix32_En32
  CONSTANT coeffphase1_17                 : signed(31 DOWNTO 0) := to_signed(2062301496, 32); -- sfix32_En32
  CONSTANT coeffphase1_18                 : signed(31 DOWNTO 0) := to_signed(84945739, 32); -- sfix32_En32
  CONSTANT coeffphase1_19                 : signed(31 DOWNTO 0) := to_signed(-82050183, 32); -- sfix32_En32
  CONSTANT coeffphase1_20                 : signed(31 DOWNTO 0) := to_signed(77403334, 32); -- sfix32_En32
  CONSTANT coeffphase1_21                 : signed(31 DOWNTO 0) := to_signed(-71260243, 32); -- sfix32_En32
  CONSTANT coeffphase1_22                 : signed(31 DOWNTO 0) := to_signed(63951971, 32); -- sfix32_En32
  CONSTANT coeffphase1_23                 : signed(31 DOWNTO 0) := to_signed(-55862069, 32); -- sfix32_En32
  CONSTANT coeffphase1_24                 : signed(31 DOWNTO 0) := to_signed(47399686, 32); -- sfix32_En32
  CONSTANT coeffphase1_25                 : signed(31 DOWNTO 0) := to_signed(-38971397, 32); -- sfix32_En32
  CONSTANT coeffphase1_26                 : signed(31 DOWNTO 0) := to_signed(30953944, 32); -- sfix32_En32
  CONSTANT coeffphase1_27                 : signed(31 DOWNTO 0) := to_signed(-23669972, 32); -- sfix32_En32
  CONSTANT coeffphase1_28                 : signed(31 DOWNTO 0) := to_signed(17368568, 32); -- sfix32_En32
  CONSTANT coeffphase1_29                 : signed(31 DOWNTO 0) := to_signed(-12211991, 32); -- sfix32_En32
  CONSTANT coeffphase1_30                 : signed(31 DOWNTO 0) := to_signed(8269448, 32); -- sfix32_En32
  CONSTANT coeffphase1_31                 : signed(31 DOWNTO 0) := to_signed(-5518202, 32); -- sfix32_En32
  CONSTANT coeffphase1_32                 : signed(31 DOWNTO 0) := to_signed(3851666, 32); -- sfix32_En32
  CONSTANT coeffphase1_33                 : signed(31 DOWNTO 0) := to_signed(-3093618, 32); -- sfix32_En32
  CONSTANT coeffphase2_1                  : signed(31 DOWNTO 0) := to_signed(1335197, 32); -- sfix32_En32
  CONSTANT coeffphase2_2                  : signed(31 DOWNTO 0) := to_signed(-1170534, 32); -- sfix32_En32
  CONSTANT coeffphase2_3                  : signed(31 DOWNTO 0) := to_signed(852692, 32); -- sfix32_En32
  CONSTANT coeffphase2_4                  : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeffphase2_5                  : signed(31 DOWNTO 0) := to_signed(-1849544, 32); -- sfix32_En32
  CONSTANT coeffphase2_6                  : signed(31 DOWNTO 0) := to_signed(5233764, 32); -- sfix32_En32
  CONSTANT coeffphase2_7                  : signed(31 DOWNTO 0) := to_signed(-10770347, 32); -- sfix32_En32
  CONSTANT coeffphase2_8                  : signed(31 DOWNTO 0) := to_signed(19180735, 32); -- sfix32_En32
  CONSTANT coeffphase2_9                  : signed(31 DOWNTO 0) := to_signed(-31355200, 32); -- sfix32_En32
  CONSTANT coeffphase2_10                 : signed(31 DOWNTO 0) := to_signed(48504116, 32); -- sfix32_En32
  CONSTANT coeffphase2_11                 : signed(31 DOWNTO 0) := to_signed(-72502667, 32); -- sfix32_En32
  CONSTANT coeffphase2_12                 : signed(31 DOWNTO 0) := to_signed(106723369, 32); -- sfix32_En32
  CONSTANT coeffphase2_13                 : signed(31 DOWNTO 0) := to_signed(-158319825, 32); -- sfix32_En32
  CONSTANT coeffphase2_14                 : signed(31 DOWNTO 0) := to_signed(246004646, 32); -- sfix32_En32
  CONSTANT coeffphase2_15                 : signed(31 DOWNTO 0) := to_signed(-438924374, 32); -- sfix32_En32
  CONSTANT coeffphase2_16                 : signed(31 DOWNTO 0) := to_signed(1361884192, 32); -- sfix32_En32
  CONSTANT coeffphase2_17                 : signed(31 DOWNTO 0) := to_signed(1361884192, 32); -- sfix32_En32
  CONSTANT coeffphase2_18                 : signed(31 DOWNTO 0) := to_signed(-438924374, 32); -- sfix32_En32
  CONSTANT coeffphase2_19                 : signed(31 DOWNTO 0) := to_signed(246004646, 32); -- sfix32_En32
  CONSTANT coeffphase2_20                 : signed(31 DOWNTO 0) := to_signed(-158319825, 32); -- sfix32_En32
  CONSTANT coeffphase2_21                 : signed(31 DOWNTO 0) := to_signed(106723369, 32); -- sfix32_En32
  CONSTANT coeffphase2_22                 : signed(31 DOWNTO 0) := to_signed(-72502667, 32); -- sfix32_En32
  CONSTANT coeffphase2_23                 : signed(31 DOWNTO 0) := to_signed(48504116, 32); -- sfix32_En32
  CONSTANT coeffphase2_24                 : signed(31 DOWNTO 0) := to_signed(-31355200, 32); -- sfix32_En32
  CONSTANT coeffphase2_25                 : signed(31 DOWNTO 0) := to_signed(19180735, 32); -- sfix32_En32
  CONSTANT coeffphase2_26                 : signed(31 DOWNTO 0) := to_signed(-10770347, 32); -- sfix32_En32
  CONSTANT coeffphase2_27                 : signed(31 DOWNTO 0) := to_signed(5233764, 32); -- sfix32_En32
  CONSTANT coeffphase2_28                 : signed(31 DOWNTO 0) := to_signed(-1849544, 32); -- sfix32_En32
  CONSTANT coeffphase2_29                 : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeffphase2_30                 : signed(31 DOWNTO 0) := to_signed(852692, 32); -- sfix32_En32
  CONSTANT coeffphase2_31                 : signed(31 DOWNTO 0) := to_signed(-1170534, 32); -- sfix32_En32
  CONSTANT coeffphase2_32                 : signed(31 DOWNTO 0) := to_signed(1335197, 32); -- sfix32_En32
  CONSTANT coeffphase2_33                 : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32

  CONSTANT const_zero                     : signed(64 DOWNTO 0) := to_signed(0, 65); -- sfix65_En60
  -- Signals
  SIGNAL cur_count                        : unsigned(4 DOWNTO 0); -- ufix5
  SIGNAL phase_0                          : std_logic; -- boolean
  SIGNAL phase_1                          : std_logic; -- boolean
  SIGNAL phase_16                         : std_logic; -- boolean
  SIGNAL phase_16_1                       : std_logic; -- boolean
  SIGNAL phase_16_2                       : std_logic; -- boolean
  SIGNAL delay_pipeline                   : delay_pipeline_type(0 TO 32); -- sfix32_En28
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
  SIGNAL tapsum_and_13                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_14                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_15                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_16                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_17                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_18                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_19                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_20                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_21                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_22                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_23                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_24                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_25                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_26                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_27                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_28                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_29                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL tapsum_and_30                    : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL delay_pipeline16_cast            : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL inputmux                         : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL inputmux_1                       : signed(32 DOWNTO 0); -- sfix33_En28
  SIGNAL product1                         : signed(64 DOWNTO 0); -- sfix65_En60
  SIGNAL product1_mux                     : signed(31 DOWNTO 0); -- sfix32_En32
  SIGNAL product2                         : signed(64 DOWNTO 0); -- sfix65_En60
  SIGNAL product2_mux                     : signed(31 DOWNTO 0); -- sfix32_En32
  SIGNAL phasemux                         : signed(64 DOWNTO 0); -- sfix65_En60
  SIGNAL phasemux_1                       : signed(64 DOWNTO 0); -- sfix65_En60
  SIGNAL sumofproducts                    : signed(65 DOWNTO 0); -- sfix66_En60
  SIGNAL sumofproducts_cast               : signed(80 DOWNTO 0); -- sfix81_En60
  SIGNAL acc_sum                          : signed(80 DOWNTO 0); -- sfix81_En60
  SIGNAL accreg_in                        : signed(80 DOWNTO 0); -- sfix81_En60
  SIGNAL accreg_out                       : signed(80 DOWNTO 0); -- sfix81_En60
  SIGNAL add_temp                         : signed(81 DOWNTO 0); -- sfix82_En60
  SIGNAL accreg_final                     : signed(80 DOWNTO 0); -- sfix81_En60
  SIGNAL output_typeconvert               : signed(69 DOWNTO 0); -- sfix70_En60
  SIGNAL output_register                  : signed(69 DOWNTO 0); -- sfix70_En60


BEGIN

  -- Block Statements
  Counter : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      cur_count <= to_unsigned(31, 5);
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        IF cur_count = to_unsigned(31, 5) THEN
          cur_count <= to_unsigned(0, 5);
        ELSE
          cur_count <= cur_count + 1;
        END IF;
      END IF;
    END IF; 
  END PROCESS Counter;

  phase_0 <= '1' WHEN cur_count = to_unsigned(0, 5) AND clk_enable = '1' ELSE '0';

  phase_1 <= '1' WHEN  (((cur_count = to_unsigned(1, 5))  OR
                         (cur_count = to_unsigned(2, 5))  OR
                         (cur_count = to_unsigned(3, 5))  OR
                         (cur_count = to_unsigned(4, 5))  OR
                         (cur_count = to_unsigned(5, 5))  OR
                         (cur_count = to_unsigned(6, 5))  OR
                         (cur_count = to_unsigned(7, 5))  OR
                         (cur_count = to_unsigned(8, 5))  OR
                         (cur_count = to_unsigned(9, 5))  OR
                         (cur_count = to_unsigned(10, 5))  OR
                         (cur_count = to_unsigned(11, 5))  OR
                         (cur_count = to_unsigned(12, 5))  OR
                         (cur_count = to_unsigned(13, 5))  OR
                         (cur_count = to_unsigned(14, 5))  OR
                         (cur_count = to_unsigned(15, 5))  OR
                         (cur_count = to_unsigned(16, 5))  OR
                         (cur_count = to_unsigned(17, 5))  OR
                         (cur_count = to_unsigned(18, 5))  OR
                         (cur_count = to_unsigned(19, 5))  OR
                         (cur_count = to_unsigned(20, 5))  OR
                         (cur_count = to_unsigned(21, 5))  OR
                         (cur_count = to_unsigned(22, 5))  OR
                         (cur_count = to_unsigned(23, 5))  OR
                         (cur_count = to_unsigned(24, 5))  OR
                         (cur_count = to_unsigned(25, 5))  OR
                         (cur_count = to_unsigned(26, 5))  OR
                         (cur_count = to_unsigned(27, 5))  OR
                         (cur_count = to_unsigned(28, 5))  OR
                         (cur_count = to_unsigned(29, 5))  OR
                         (cur_count = to_unsigned(30, 5)))  AND clk_enable = '1') ELSE '0';

  phase_16 <= '1' WHEN  (((cur_count = to_unsigned(1, 5))  OR
                          (cur_count = to_unsigned(17, 5)))  AND clk_enable = '1') ELSE '0';

  phase_16_1 <= '1' WHEN  (((cur_count = to_unsigned(17, 5))  OR
                            (cur_count = to_unsigned(1, 5)))  AND clk_enable = '1') ELSE '0';

  phase_16_2 <= '1' WHEN  (((cur_count = to_unsigned(18, 5))  OR
                            (cur_count = to_unsigned(2, 5)))  AND clk_enable = '1') ELSE '0';

  --   ---------------- Delay Registers ----------------

  Delay_Pipeline_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      delay_pipeline(0 TO 32) <= (OTHERS => (OTHERS => '0'));
    ELSIF clk'event AND clk = '1' THEN
      IF phase_0 = '1' THEN
        delay_pipeline(0) <= signed(filter_in);
        delay_pipeline(1 TO 32) <= delay_pipeline(0 TO 31);
      END IF;
    END IF; 
  END PROCESS Delay_Pipeline_process;

  -- Adding (or subtracting) the taps based on the symmetry (or asymmetry)

  tapsum_and <= resize(delay_pipeline(0), 33) + resize(delay_pipeline(32), 33);

  tapsum_and_1 <= resize(delay_pipeline(1), 33) + resize(delay_pipeline(31), 33);

  tapsum_and_2 <= resize(delay_pipeline(2), 33) + resize(delay_pipeline(30), 33);

  tapsum_and_3 <= resize(delay_pipeline(3), 33) + resize(delay_pipeline(29), 33);

  tapsum_and_4 <= resize(delay_pipeline(4), 33) + resize(delay_pipeline(28), 33);

  tapsum_and_5 <= resize(delay_pipeline(5), 33) + resize(delay_pipeline(27), 33);

  tapsum_and_6 <= resize(delay_pipeline(6), 33) + resize(delay_pipeline(26), 33);

  tapsum_and_7 <= resize(delay_pipeline(7), 33) + resize(delay_pipeline(25), 33);

  tapsum_and_8 <= resize(delay_pipeline(8), 33) + resize(delay_pipeline(24), 33);

  tapsum_and_9 <= resize(delay_pipeline(9), 33) + resize(delay_pipeline(23), 33);

  tapsum_and_10 <= resize(delay_pipeline(10), 33) + resize(delay_pipeline(22), 33);

  tapsum_and_11 <= resize(delay_pipeline(11), 33) + resize(delay_pipeline(21), 33);

  tapsum_and_12 <= resize(delay_pipeline(12), 33) + resize(delay_pipeline(20), 33);

  tapsum_and_13 <= resize(delay_pipeline(13), 33) + resize(delay_pipeline(19), 33);

  tapsum_and_14 <= resize(delay_pipeline(14), 33) + resize(delay_pipeline(18), 33);

  tapsum_and_15 <= resize(delay_pipeline(15), 33) + resize(delay_pipeline(17), 33);

  tapsum_and_16 <= resize(delay_pipeline(2), 33) + resize(delay_pipeline(29), 33);

  tapsum_and_17 <= resize(delay_pipeline(1), 33) + resize(delay_pipeline(30), 33);

  tapsum_and_18 <= resize(delay_pipeline(0), 33) + resize(delay_pipeline(31), 33);

  tapsum_and_19 <= resize(delay_pipeline(4), 33) + resize(delay_pipeline(27), 33);

  tapsum_and_20 <= resize(delay_pipeline(5), 33) + resize(delay_pipeline(26), 33);

  tapsum_and_21 <= resize(delay_pipeline(6), 33) + resize(delay_pipeline(25), 33);

  tapsum_and_22 <= resize(delay_pipeline(7), 33) + resize(delay_pipeline(24), 33);

  tapsum_and_23 <= resize(delay_pipeline(8), 33) + resize(delay_pipeline(23), 33);

  tapsum_and_24 <= resize(delay_pipeline(9), 33) + resize(delay_pipeline(22), 33);

  tapsum_and_25 <= resize(delay_pipeline(10), 33) + resize(delay_pipeline(21), 33);

  tapsum_and_26 <= resize(delay_pipeline(11), 33) + resize(delay_pipeline(20), 33);

  tapsum_and_27 <= resize(delay_pipeline(12), 33) + resize(delay_pipeline(19), 33);

  tapsum_and_28 <= resize(delay_pipeline(13), 33) + resize(delay_pipeline(18), 33);

  tapsum_and_29 <= resize(delay_pipeline(14), 33) + resize(delay_pipeline(17), 33);

  tapsum_and_30 <= resize(delay_pipeline(15), 33) + resize(delay_pipeline(16), 33);

  -- Mux(es) to select the input taps for multipliers 

  delay_pipeline16_cast <= resize(delay_pipeline(16), 33);

  inputmux <= tapsum_and WHEN ( cur_count = to_unsigned(1, 5) ) ELSE
                   tapsum_and_2 WHEN ( cur_count = to_unsigned(2, 5) ) ELSE
                   tapsum_and_3 WHEN ( cur_count = to_unsigned(3, 5) ) ELSE
                   tapsum_and_4 WHEN ( cur_count = to_unsigned(4, 5) ) ELSE
                   tapsum_and_5 WHEN ( cur_count = to_unsigned(5, 5) ) ELSE
                   tapsum_and_6 WHEN ( cur_count = to_unsigned(6, 5) ) ELSE
                   tapsum_and_7 WHEN ( cur_count = to_unsigned(7, 5) ) ELSE
                   tapsum_and_8 WHEN ( cur_count = to_unsigned(8, 5) ) ELSE
                   tapsum_and_9 WHEN ( cur_count = to_unsigned(9, 5) ) ELSE
                   tapsum_and_10 WHEN ( cur_count = to_unsigned(10, 5) ) ELSE
                   tapsum_and_11 WHEN ( cur_count = to_unsigned(11, 5) ) ELSE
                   tapsum_and_12 WHEN ( cur_count = to_unsigned(12, 5) ) ELSE
                   tapsum_and_13 WHEN ( cur_count = to_unsigned(13, 5) ) ELSE
                   tapsum_and_14 WHEN ( cur_count = to_unsigned(14, 5) ) ELSE
                   tapsum_and_15 WHEN ( cur_count = to_unsigned(15, 5) ) ELSE
                   delay_pipeline16_cast WHEN ( cur_count = to_unsigned(16, 5) ) ELSE
                   tapsum_and_18 WHEN ( cur_count = to_unsigned(17, 5) ) ELSE
                   tapsum_and_16 WHEN ( cur_count = to_unsigned(18, 5) ) ELSE
                   tapsum_and_19 WHEN ( cur_count = to_unsigned(19, 5) ) ELSE
                   tapsum_and_20 WHEN ( cur_count = to_unsigned(20, 5) ) ELSE
                   tapsum_and_21 WHEN ( cur_count = to_unsigned(21, 5) ) ELSE
                   tapsum_and_22 WHEN ( cur_count = to_unsigned(22, 5) ) ELSE
                   tapsum_and_23 WHEN ( cur_count = to_unsigned(23, 5) ) ELSE
                   tapsum_and_24 WHEN ( cur_count = to_unsigned(24, 5) ) ELSE
                   tapsum_and_25 WHEN ( cur_count = to_unsigned(25, 5) ) ELSE
                   tapsum_and_26 WHEN ( cur_count = to_unsigned(26, 5) ) ELSE
                   tapsum_and_27 WHEN ( cur_count = to_unsigned(27, 5) ) ELSE
                   tapsum_and_28 WHEN ( cur_count = to_unsigned(28, 5) ) ELSE
                   tapsum_and_29 WHEN ( cur_count = to_unsigned(29, 5) ) ELSE
                   tapsum_and_30;

  inputmux_1 <= tapsum_and_1 WHEN ( cur_count = to_unsigned(1, 5) ) ELSE
                     tapsum_and_17;

  product1_mux <= coeffphase1_1 WHEN ( cur_count = to_unsigned(1, 5) ) ELSE
                       coeffphase1_3 WHEN ( cur_count = to_unsigned(2, 5) ) ELSE
                       coeffphase1_4 WHEN ( cur_count = to_unsigned(3, 5) ) ELSE
                       coeffphase1_5 WHEN ( cur_count = to_unsigned(4, 5) ) ELSE
                       coeffphase1_6 WHEN ( cur_count = to_unsigned(5, 5) ) ELSE
                       coeffphase1_7 WHEN ( cur_count = to_unsigned(6, 5) ) ELSE
                       coeffphase1_8 WHEN ( cur_count = to_unsigned(7, 5) ) ELSE
                       coeffphase1_9 WHEN ( cur_count = to_unsigned(8, 5) ) ELSE
                       coeffphase1_10 WHEN ( cur_count = to_unsigned(9, 5) ) ELSE
                       coeffphase1_11 WHEN ( cur_count = to_unsigned(10, 5) ) ELSE
                       coeffphase1_12 WHEN ( cur_count = to_unsigned(11, 5) ) ELSE
                       coeffphase1_13 WHEN ( cur_count = to_unsigned(12, 5) ) ELSE
                       coeffphase1_14 WHEN ( cur_count = to_unsigned(13, 5) ) ELSE
                       coeffphase1_15 WHEN ( cur_count = to_unsigned(14, 5) ) ELSE
                       coeffphase1_16 WHEN ( cur_count = to_unsigned(15, 5) ) ELSE
                       coeffphase1_17 WHEN ( cur_count = to_unsigned(16, 5) ) ELSE
                       coeffphase2_1 WHEN ( cur_count = to_unsigned(17, 5) ) ELSE
                       coeffphase2_3 WHEN ( cur_count = to_unsigned(18, 5) ) ELSE
                       coeffphase2_5 WHEN ( cur_count = to_unsigned(19, 5) ) ELSE
                       coeffphase2_6 WHEN ( cur_count = to_unsigned(20, 5) ) ELSE
                       coeffphase2_7 WHEN ( cur_count = to_unsigned(21, 5) ) ELSE
                       coeffphase2_8 WHEN ( cur_count = to_unsigned(22, 5) ) ELSE
                       coeffphase2_9 WHEN ( cur_count = to_unsigned(23, 5) ) ELSE
                       coeffphase2_10 WHEN ( cur_count = to_unsigned(24, 5) ) ELSE
                       coeffphase2_11 WHEN ( cur_count = to_unsigned(25, 5) ) ELSE
                       coeffphase2_12 WHEN ( cur_count = to_unsigned(26, 5) ) ELSE
                       coeffphase2_13 WHEN ( cur_count = to_unsigned(27, 5) ) ELSE
                       coeffphase2_14 WHEN ( cur_count = to_unsigned(28, 5) ) ELSE
                       coeffphase2_15 WHEN ( cur_count = to_unsigned(29, 5) ) ELSE
                       coeffphase2_16;
  product1 <= inputmux * product1_mux;

  product2_mux <= coeffphase1_2 WHEN ( cur_count = to_unsigned(1, 5) ) ELSE
                       coeffphase2_2;
  product2 <= inputmux_1 * product2_mux;

  phasemux <= product1 WHEN ( phase_1 = '1' ) ELSE
                   const_zero;
  phasemux_1 <= product2 WHEN ( phase_16 = '1' ) ELSE
                     const_zero;


  -- Add the products in linear fashion

  sumofproducts <= resize(phasemux, 66) + resize(phasemux_1, 66);

  -- Resize the sum of products to the accumulator type for full precision addition

  sumofproducts_cast <= resize(sumofproducts, 81);

  -- Accumulator register with a mux to reset it with the first addend

  add_temp <= resize(sumofproducts_cast, 82) + resize(accreg_out, 82);
  acc_sum <= add_temp(80 DOWNTO 0);

  accreg_in <= sumofproducts_cast WHEN ( phase_16_1 = '1' ) ELSE
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
      IF phase_16_1 = '1' THEN
        accreg_final <= accreg_out;
      END IF;
    END IF; 
  END PROCESS Acc_finalreg_process;

  output_typeconvert <= accreg_final(69 DOWNTO 0);

  Output_Register_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      output_register <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF phase_16_2 = '1' THEN
        output_register <= output_typeconvert;
      END IF;
    END IF; 
  END PROCESS Output_Register_process;

  -- Assignment Statements
  ce_out <= phase_0;
  filter_out <= std_logic_vector(output_register);
END rtl;
