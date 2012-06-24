-- Copyright (C) 2012 
-- Author(s): Marcela Simkova <isimkova@fit.vutbr.cz>

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.math_pack.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity testbench is
end entity testbench;

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of testbench is

   -- constants declarations
   ----------------------------------------------------------------------------
   constant DATA_WIDTH          : integer := 64;
   constant PART_NUM_CNT_WIDTH  : integer := 3;
   constant PART_SIZE_CNT_WIDTH : integer := 32;
   constant ENDPOINT_ID         : integer := 0;
   
   constant clkper            : time := 10 ns; 
   constant reset_time        : time := 100 ns;
   
   constant RUN_REG_ADDR      : std_logic_vector(31 downto 0) := X"00000000";
   constant TRANS_REG_ADDR    : std_logic_vector(31 downto 0) := X"00000004";
   constant PART_NUM_REG_ADDR : std_logic_vector(31 downto 0) := X"00000010";
   constant PART_SIZE_REG_ADDR: std_logic_vector(31 downto 0) := X"00000080";
   constant PART_REG_OFFSET   : integer := 16;
   constant PART_MASK_OFFSET  : integer := 0;
   constant PART_BASE_OFFSET  : integer := 4;
   constant PART_MAX_OFFSET   : integer := 8;

   constant TRANSACTION_COUNT : integer := 16;

   -- signals declarations
   ----------------------------------------------------------------------------
   signal clk                 : std_logic;
   signal reset               : std_logic;
   
   -- UUT signals
   signal adapter_mi_dwr   : std_logic_vector(31 downto 0);
   signal adapter_mi_addr  : std_logic_vector(31 downto 0);
   signal adapter_mi_rd    : std_logic;
   signal adapter_mi_wr    : std_logic;
   signal adapter_mi_be    : std_logic_vector(3 downto 0);
   signal adapter_mi_drd   : std_logic_vector(31 downto 0);
   signal adapter_mi_ardy  : std_logic;
   signal adapter_mi_drdy  : std_logic;
   
   signal adapter_gen_flow : std_logic_vector(DATA_WIDTH-1 downto 0);
   
   signal adapter_fl_data      : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal adapter_fl_rem       : std_logic_vector(log2(DATA_WIDTH/8)-1 downto 0);
   signal adapter_fl_src_rdy_n : std_logic;
   signal adapter_fl_dst_rdy_n : std_logic;
   signal adapter_fl_sop_n     : std_logic;
   signal adapter_fl_eop_n     : std_logic;
   signal adapter_fl_sof_n     : std_logic;
   signal adapter_fl_eof_n     : std_logic;
   
   signal reg_rand_bit         : std_logic;
   
-- ----------------------------------------------------------------------------
--                      Architecture body
-- ----------------------------------------------------------------------------
begin
   -- -------------------------------------------------------------------------
   --                   REG_PROC_UNIT
   -- -------------------------------------------------------------------------
   uut: entity work.FL_ADAPTER_UNIT
   generic map (
      DATA_WIDTH           => DATA_WIDTH,
      ENDPOINT_ID          => ENDPOINT_ID
   )
   port map (
      CLK               => CLK,
      RESET             => RESET,
      
      -- MI32 interface
      MI_DWR            => adapter_mi_dwr, 
      MI_ADDR           => adapter_mi_addr,
      MI_RD             => adapter_mi_rd,
      MI_WR             => adapter_mi_wr,
      MI_BE             => adapter_mi_be,
      MI_DRD            => adapter_mi_drd,
      MI_ARDY           => adapter_mi_ardy,
      MI_DRDY           => adapter_mi_drdy,
    
      -- Generator interface
      GEN_FLOW          => adapter_gen_flow,
   
      -- Output FrameLink Interface
      TX_DATA              => adapter_fl_data,
      TX_REM               => adapter_fl_rem,
      TX_SRC_RDY_N         => adapter_fl_src_rdy_n,
      TX_DST_RDY_N         => adapter_fl_dst_rdy_n,
      TX_SOP_N             => adapter_fl_sop_n,
      TX_EOP_N             => adapter_fl_eop_n,
      TX_SOF_N             => adapter_fl_sof_n,
      TX_EOF_N             => adapter_fl_eof_n
   );

   -- ----------------------------------------------------

   -- CLK generator
   clkgen: process
   begin
      clk <= '1';
      wait for clkper/2;
      clk <= '0';
      wait for clkper/2;
   end process;
   
   -- reset generator
   resetgen: process
   begin
      reset <= '1';
      wait for reset_time;
      reset <= '0';
      wait;
   end process;
   
   -- random data generator
   adapter_gen_flow_p: process(clk)
      variable seed1, seed2: positive;
      variable rand: real;
      variable int_rand: integer;
      variable stim: std_logic_vector(15 downto 0);
   begin
      if (rising_edge(clk)) then
         for i in 0 to 3 loop
            UNIFORM(seed1, seed2, rand);               -- generate random number
            int_rand := INTEGER(TRUNC(rand*real(2**16)));  -- rescale 
            stim := std_logic_vector(to_unsigned(int_rand, stim'LENGTH));  

            adapter_gen_flow((i+1)*16-1 downto i*16) <= stim;
         end loop;
      end if;
   end process;

   -- random bit register for the take signal
   reg_rand_bit_p: process(clk)
      variable seed1, seed2: positive;     -- Seed values for random generator
      variable rand: real;                 -- Random real-number value in range 0 to 1.0
   begin
      if (rising_edge(clk)) then
         UNIFORM(seed1, seed2, rand);
         if (rand > 0.5) then
            reg_rand_bit <= '0';
         else
            reg_rand_bit <= '1';
         end if;
      end if;
   end process;

   adapter_fl_dst_rdy_n   <= reg_rand_bit;

   -- the testbench process
   tb: process
   begin

      -- initialisation of signals
      adapter_mi_rd    <= '0';
      adapter_mi_wr    <= '0';
      adapter_mi_be    <= "1111";
      adapter_mi_dwr   <= (others => '0');
      adapter_mi_addr  <= X"DEADBEEF";

      wait for reset_time; 
      wait until rising_edge(clk);

      -- initialization of registers

      adapter_mi_wr    <= '1';

      -- ----------- PARTS NUM --------------
      -- PARTS_NUM_MASK
      adapter_mi_addr  <= PART_NUM_REG_ADDR + PART_MASK_OFFSET;
      adapter_mi_dwr   <= X"00000007";
      wait until rising_edge(clk);

      -- PARTS_NUM_BASE
      adapter_mi_addr  <= PART_NUM_REG_ADDR + PART_BASE_OFFSET;
      adapter_mi_dwr   <= X"00000001";
      wait until rising_edge(clk);

      -- PARTS_NUM_MAX
      adapter_mi_addr  <= PART_NUM_REG_ADDR + PART_MAX_OFFSET;
      adapter_mi_dwr   <= X"00000005";
      wait until rising_edge(clk);

      -- ----------- PART 0 -----------------
      -- PART0_MASK
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 0*PART_REG_OFFSET + PART_MASK_OFFSET;
      adapter_mi_dwr   <= X"0000000F";
      wait until rising_edge(clk);

      -- PART0_BASE
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 0*PART_REG_OFFSET + PART_BASE_OFFSET;
      adapter_mi_dwr   <= X"00000001";
      wait until rising_edge(clk);

      -- PART0_MAX
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 0*PART_REG_OFFSET + PART_MAX_OFFSET;
      adapter_mi_dwr   <= X"0000000A";
      wait until rising_edge(clk);

      -- ----------- PART 1 -----------------
      -- PART1_MASK
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 1*PART_REG_OFFSET + PART_MASK_OFFSET;
      adapter_mi_dwr   <= X"000000FF";
      wait until rising_edge(clk);

      -- PART1_BASE
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 1*PART_REG_OFFSET + PART_BASE_OFFSET;
      adapter_mi_dwr   <= X"00000010";
      wait until rising_edge(clk);

      -- PART1_MAX
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 1*PART_REG_OFFSET + PART_MAX_OFFSET;
      adapter_mi_dwr   <= X"000000A0";
      wait until rising_edge(clk);

      -- ----------- PART 2 -----------------
      -- PART2_MASK
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 2*PART_REG_OFFSET + PART_MASK_OFFSET;
      adapter_mi_dwr   <= X"00000FFF";
      wait until rising_edge(clk);

      -- PART2_BASE
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 2*PART_REG_OFFSET + PART_BASE_OFFSET;
      adapter_mi_dwr   <= X"00000100";
      wait until rising_edge(clk);

      -- PART2_MAX
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 2*PART_REG_OFFSET + PART_MAX_OFFSET;
      adapter_mi_dwr   <= X"00000A00";
      wait until rising_edge(clk);

      -- ----------- PART 3 -----------------
      -- PART3_MASK
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 3*PART_REG_OFFSET + PART_MASK_OFFSET;
      adapter_mi_dwr   <= X"0000FFFF";
      wait until rising_edge(clk);

      -- PART3_BASE
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 3*PART_REG_OFFSET + PART_BASE_OFFSET;
      adapter_mi_dwr   <= X"00001000";
      wait until rising_edge(clk);

      -- PART3_MAX
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 3*PART_REG_OFFSET + PART_MAX_OFFSET;
      adapter_mi_dwr   <= X"0000A000";
      wait until rising_edge(clk);

      -- ----------- PART 4 -----------------
      -- PART4_MASK
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 4*PART_REG_OFFSET + PART_MASK_OFFSET;
      adapter_mi_dwr   <= X"000FFFFF";
      wait until rising_edge(clk);

      -- PART4_BASE
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 4*PART_REG_OFFSET + PART_BASE_OFFSET;
      adapter_mi_dwr   <= X"00010000";
      wait until rising_edge(clk);

      -- PART4_MAX
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 4*PART_REG_OFFSET + PART_MAX_OFFSET;
      adapter_mi_dwr   <= X"000A0000";
      wait until rising_edge(clk);

      -- ----------- PART 5 -----------------
      -- PART5_MASK
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 5*PART_REG_OFFSET + PART_MASK_OFFSET;
      adapter_mi_dwr   <= X"00FFFFFF";
      wait until rising_edge(clk);

      -- PART5_BASE
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 5*PART_REG_OFFSET + PART_BASE_OFFSET;
      adapter_mi_dwr   <= X"00100000";
      wait until rising_edge(clk);

      -- PART5_MAX
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 5*PART_REG_OFFSET + PART_MAX_OFFSET;
      adapter_mi_dwr   <= X"00A00000";
      wait until rising_edge(clk);

      -- ----------- PART 6 -----------------
      -- PART6_MASK
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 6*PART_REG_OFFSET + PART_MASK_OFFSET;
      adapter_mi_dwr   <= X"0FFFFFFF";
      wait until rising_edge(clk);

      -- PART6_BASE
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 6*PART_REG_OFFSET + PART_BASE_OFFSET;
      adapter_mi_dwr   <= X"01000000";
      wait until rising_edge(clk);

      -- PART6_MAX
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 6*PART_REG_OFFSET + PART_MAX_OFFSET;
      adapter_mi_dwr   <= X"0A000000";
      wait until rising_edge(clk);

      -- ----------- PART 7 -----------------
      -- PART7_MASK
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 7*PART_REG_OFFSET + PART_MASK_OFFSET;
      adapter_mi_dwr   <= X"FFFFFFFF";
      wait until rising_edge(clk);

      -- PART7_BASE
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 7*PART_REG_OFFSET + PART_BASE_OFFSET;
      adapter_mi_dwr   <= X"10000000";
      wait until rising_edge(clk);

      -- PART7_MAX
      adapter_mi_addr  <= PART_SIZE_REG_ADDR + 7*PART_REG_OFFSET + PART_MAX_OFFSET;
      adapter_mi_dwr   <= X"A0000000";
      wait until rising_edge(clk);

      -- ------- TRANSACTION COUNT -----------
      adapter_mi_addr  <= TRANS_REG_ADDR;
      adapter_mi_dwr   <= conv_std_logic_vector(TRANSACTION_COUNT, 32);
      wait until rising_edge(clk);

      -- -------------- RUN ------------------
      adapter_mi_addr  <= RUN_REG_ADDR;
      adapter_mi_dwr   <= X"00000001";
      wait until rising_edge(clk);

      adapter_mi_wr    <= '0';

      wait;
   end process;
end architecture behavioral;
