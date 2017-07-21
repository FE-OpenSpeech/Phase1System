-- -------------------------------------------------------------
--
-- Module: HA_Bandpass32
-- Generated by MATLAB(R) 9.1 and the Filter Design HDL Coder 3.1.
-- Generated on: 2017-06-13 12:52:31
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- HDL Code Generation Options:
--
-- TargetLanguage: VHDL
-- Name: HA_Bandpass32
-- SerialPartition: [8  5]
-- InputDataType: numerictype(1,32,28)
-- TestBenchName: firfilt_copy_tb
-- TestBenchStimulus: impulse step ramp chirp noise 

-- -------------------------------------------------------------
-- HDL Implementation    : Partly Serial
-- Folding Factor        : 8
-- -------------------------------------------------------------
-- Filter Settings:
--
-- Discrete-Time FIR Filter (real)
-- -------------------------------
-- Filter Structure  : Direct-Form FIR
-- Filter Length     : 33
-- Stable            : Yes
-- Linear Phase      : Yes (Type 1)
-- Arithmetic        : fixed
-- Numerator         : s32,32 -> [-5.000000e-01 5.000000e-01)
-- -------------------------------------------------------------



LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY HA_Bandpass32 IS
   PORT( clk                             :   IN    std_logic; 
         clk_enable                      :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         filter_in                       :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En28
         filter_out                      :   OUT   std_logic_vector(69 DOWNTO 0)  -- sfix70_En60
         );

END HA_Bandpass32;


----------------------------------------------------------------
--Module Architecture: HA_Bandpass32
----------------------------------------------------------------
ARCHITECTURE rtl OF HA_Bandpass32 IS
  -- Local Functions
  -- Type Definitions
  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF signed(31 DOWNTO 0); -- sfix32_En28
  -- Constants
  CONSTANT coeff1                         : signed(31 DOWNTO 0) := to_signed(11793810, 32); -- sfix32_En32
  CONSTANT coeff2                         : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff3                         : signed(31 DOWNTO 0) := to_signed(-19378142, 32); -- sfix32_En32
  CONSTANT coeff4                         : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff5                         : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff6                         : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff7                         : signed(31 DOWNTO 0) := to_signed(85850827, 32); -- sfix32_En32
  CONSTANT coeff8                         : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff9                         : signed(31 DOWNTO 0) := to_signed(-159216434, 32); -- sfix32_En32
  CONSTANT coeff10                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff11                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff12                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff13                        : signed(31 DOWNTO 0) := to_signed(510240978, 32); -- sfix32_En32
  CONSTANT coeff14                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff15                        : signed(31 DOWNTO 0) := to_signed(-1138084480, 32); -- sfix32_En32
  CONSTANT coeff16                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff17                        : signed(31 DOWNTO 0) := to_signed(1426107000, 32); -- sfix32_En32
  CONSTANT coeff18                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff19                        : signed(31 DOWNTO 0) := to_signed(-1138084480, 32); -- sfix32_En32
  CONSTANT coeff20                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff21                        : signed(31 DOWNTO 0) := to_signed(510240978, 32); -- sfix32_En32
  CONSTANT coeff22                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff23                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff24                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff25                        : signed(31 DOWNTO 0) := to_signed(-159216434, 32); -- sfix32_En32
  CONSTANT coeff26                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff27                        : signed(31 DOWNTO 0) := to_signed(85850827, 32); -- sfix32_En32
  CONSTANT coeff28                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff29                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff30                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff31                        : signed(31 DOWNTO 0) := to_signed(-19378142, 32); -- sfix32_En32
  CONSTANT coeff32                        : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En32
  CONSTANT coeff33                        : signed(31 DOWNTO 0) := to_signed(11793810, 32); -- sfix32_En32

  -- Signals
  SIGNAL cur_count                        : unsigned(2 DOWNTO 0); -- ufix3
  SIGNAL phase_7                          : std_logic; -- boolean
  SIGNAL phase_0                          : std_logic; -- boolean
  SIGNAL phase_1                          : std_logic; -- boolean
  SIGNAL delay_pipeline                   : delay_pipeline_type(0 TO 32); -- sfix32_En28
  SIGNAL inputmux_1                       : signed(31 DOWNTO 0); -- sfix32_En28
  SIGNAL inputmux_2                       : signed(31 DOWNTO 0); -- sfix32_En28
  SIGNAL acc_final                        : signed(69 DOWNTO 0); -- sfix70_En60
  SIGNAL acc_out_1                        : signed(69 DOWNTO 0); -- sfix70_En60
  SIGNAL product_1                        : signed(63 DOWNTO 0); -- sfix64_En60
  SIGNAL product_1_mux                    : signed(31 DOWNTO 0); -- sfix32_En32
  SIGNAL prod_typeconvert_1               : signed(69 DOWNTO 0); -- sfix70_En60
  SIGNAL acc_sum_1                        : signed(69 DOWNTO 0); -- sfix70_En60
  SIGNAL acc_in_1                         : signed(69 DOWNTO 0); -- sfix70_En60
  SIGNAL add_temp                         : signed(70 DOWNTO 0); -- sfix71_En60
  SIGNAL acc_out_2                        : signed(69 DOWNTO 0); -- sfix70_En60
  SIGNAL product_2                        : signed(63 DOWNTO 0); -- sfix64_En60
  SIGNAL product_2_mux                    : signed(31 DOWNTO 0); -- sfix32_En32
  SIGNAL prod_typeconvert_2               : signed(69 DOWNTO 0); -- sfix70_En60
  SIGNAL acc_sum_2                        : signed(69 DOWNTO 0); -- sfix70_En60
  SIGNAL acc_in_2                         : signed(69 DOWNTO 0); -- sfix70_En60
  SIGNAL add_temp_1                       : signed(70 DOWNTO 0); -- sfix71_En60
  SIGNAL sum1                             : signed(69 DOWNTO 0); -- sfix70_En60
  SIGNAL add_temp_2                       : signed(70 DOWNTO 0); -- sfix71_En60
  SIGNAL output_typeconvert               : signed(69 DOWNTO 0); -- sfix70_En60
  SIGNAL output_register                  : signed(69 DOWNTO 0); -- sfix70_En60


BEGIN

  -- Block Statements
  Counter_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      cur_count <= to_unsigned(7, 3);
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        IF cur_count = to_unsigned(7, 3) THEN
          cur_count <= to_unsigned(0, 3);
        ELSE
          cur_count <= cur_count + 1;
        END IF;
      END IF;
    END IF; 
  END PROCESS Counter_process;

  phase_7 <= '1' WHEN cur_count = to_unsigned(7, 3) AND clk_enable = '1' ELSE '0';

  phase_0 <= '1' WHEN cur_count = to_unsigned(0, 3) AND clk_enable = '1' ELSE '0';

  phase_1 <= '1' WHEN  (((cur_count = to_unsigned(0, 3))  OR
                         (cur_count = to_unsigned(1, 3))  OR
                         (cur_count = to_unsigned(2, 3))  OR
                         (cur_count = to_unsigned(3, 3))  OR
                         (cur_count = to_unsigned(4, 3)))  AND clk_enable = '1') ELSE '0';

  Delay_Pipeline_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      delay_pipeline(0 TO 32) <= (OTHERS => (OTHERS => '0'));
    ELSIF clk'event AND clk = '1' THEN
      IF phase_7 = '1' THEN
        delay_pipeline(0) <= signed(filter_in);
        delay_pipeline(1 TO 32) <= delay_pipeline(0 TO 31);
      END IF;
    END IF; 
  END PROCESS Delay_Pipeline_process;

  inputmux_1 <= delay_pipeline(0) WHEN ( cur_count = to_unsigned(0, 3) ) ELSE
                     delay_pipeline(2) WHEN ( cur_count = to_unsigned(1, 3) ) ELSE
                     delay_pipeline(6) WHEN ( cur_count = to_unsigned(2, 3) ) ELSE
                     delay_pipeline(8) WHEN ( cur_count = to_unsigned(3, 3) ) ELSE
                     delay_pipeline(12) WHEN ( cur_count = to_unsigned(4, 3) ) ELSE
                     delay_pipeline(14) WHEN ( cur_count = to_unsigned(5, 3) ) ELSE
                     delay_pipeline(16) WHEN ( cur_count = to_unsigned(6, 3) ) ELSE
                     delay_pipeline(18);

  inputmux_2 <= delay_pipeline(20) WHEN ( cur_count = to_unsigned(0, 3) ) ELSE
                     delay_pipeline(24) WHEN ( cur_count = to_unsigned(1, 3) ) ELSE
                     delay_pipeline(26) WHEN ( cur_count = to_unsigned(2, 3) ) ELSE
                     delay_pipeline(30) WHEN ( cur_count = to_unsigned(3, 3) ) ELSE
                     delay_pipeline(32);

  --   ------------------ Serial partition # 1 ------------------

  product_1_mux <= coeff1 WHEN ( cur_count = to_unsigned(0, 3) ) ELSE
                        coeff3 WHEN ( cur_count = to_unsigned(1, 3) ) ELSE
                        coeff7 WHEN ( cur_count = to_unsigned(2, 3) ) ELSE
                        coeff9 WHEN ( cur_count = to_unsigned(3, 3) ) ELSE
                        coeff13 WHEN ( cur_count = to_unsigned(4, 3) ) ELSE
                        coeff15 WHEN ( cur_count = to_unsigned(5, 3) ) ELSE
                        coeff17 WHEN ( cur_count = to_unsigned(6, 3) ) ELSE
                        coeff19;
  product_1 <= inputmux_1 * product_1_mux;

  prod_typeconvert_1 <= resize(product_1, 70);

  add_temp <= resize(prod_typeconvert_1, 71) + resize(acc_out_1, 71);
  acc_sum_1 <= add_temp(69 DOWNTO 0);

  acc_in_1 <= prod_typeconvert_1 WHEN ( phase_0 = '1' ) ELSE
                   acc_sum_1;

  Acc_reg_1_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      acc_out_1 <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        acc_out_1 <= acc_in_1;
      END IF;
    END IF; 
  END PROCESS Acc_reg_1_process;

  --   ------------------ Serial partition # 2 ------------------

  product_2_mux <= coeff21 WHEN ( cur_count = to_unsigned(0, 3) ) ELSE
                        coeff25 WHEN ( cur_count = to_unsigned(1, 3) ) ELSE
                        coeff27 WHEN ( cur_count = to_unsigned(2, 3) ) ELSE
                        coeff31 WHEN ( cur_count = to_unsigned(3, 3) ) ELSE
                        coeff33;
  product_2 <= inputmux_2 * product_2_mux;

  prod_typeconvert_2 <= resize(product_2, 70);

  add_temp_1 <= resize(prod_typeconvert_2, 71) + resize(acc_out_2, 71);
  acc_sum_2 <= add_temp_1(69 DOWNTO 0);

  acc_in_2 <= prod_typeconvert_2 WHEN ( phase_0 = '1' ) ELSE
                   acc_sum_2;

  Acc_reg_2_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      acc_out_2 <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF phase_1 = '1' THEN
        acc_out_2 <= acc_in_2;
      END IF;
    END IF; 
  END PROCESS Acc_reg_2_process;

  add_temp_2 <= resize(acc_out_2, 71) + resize(acc_out_1, 71);
  sum1 <= add_temp_2(69 DOWNTO 0);

  Finalsum_reg_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      acc_final <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF phase_0 = '1' THEN
        acc_final <= sum1;
      END IF;
    END IF; 
  END PROCESS Finalsum_reg_process;

  output_typeconvert <= acc_final;

  Output_Register_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      output_register <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF phase_7 = '1' THEN
        output_register <= output_typeconvert;
      END IF;
    END IF; 
  END PROCESS Output_Register_process;

  -- Assignment Statements
  filter_out <= std_logic_vector(output_register);
END rtl;
