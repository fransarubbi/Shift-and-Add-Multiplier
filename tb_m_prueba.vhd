library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_multiplicador is
end tb_multiplicador;

architecture behavior of tb_multiplicador is
    signal A, B : std_logic_vector(7 downto 0);
    signal rst, Clk : std_logic;
    signal Result : std_logic_vector(15 downto 0);

    component multiplicador
        port(
            A, B     : in std_logic_vector(7 downto 0);
            rst, Clk: in std_logic;
            Result   : out std_logic_vector(15 downto 0)
        );
    end component;

begin
    -- Instanciación del módulo multiplicador
    DUT: multiplicador
        port map(
            A => A,
            B => B,
            rst => rst,
            Clk => Clk,
            Result => Result
        );

    clk_process : process
    begin
        Clk <= '0';
        wait for 10 ns;  
        Clk <= '1';
        wait for 10 ns;
    end process clk_process;

    -- Proceso de estímulos
    stimulus : process
    begin 
		  wait for 100 ns;
		  rst<= '0';
        -- Primera prueba: 3 * 2 = 6
        A <= "00000011";  -- A = 3
        B <= "00000010";  -- B = 2
		  wait for 10 ns;
        rst<= '1';
        wait for 500 ns;
        
		  rst <= '0';
        -- Segunda prueba: 7 * 5 = 35
        A <= "00000111";  -- A = 7
        B <= "00000101";  -- B = 5
		  wait for 10 ns;
        rst <= '1';
        wait for 500 ns;

		  rst <= '0';
        -- Tercera prueba: 15 * 15 = 225
        A <= "00001111";  -- A = 15
        B <= "00001111";  -- B = 15
		  wait for 10 ns;
        rst <= '1';
        wait for 500 ns;
		  
        wait;
    end process stimulus;
end behavior;
