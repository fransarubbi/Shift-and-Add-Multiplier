library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_multiplicador is
end tb_multiplicador;

architecture behavior of tb_multiplicador is
	 signal activate : std_logic;
    signal A, B : std_logic_vector(7 downto 0);
    signal rst, Clk : std_logic;
    signal res_ls : std_logic_vector(7 downto 0);
	 signal res_ms : std_logic_vector(7 downto 0);

    component multiplicador
        port(
			   activate : in std_logic;
            A, B     : in std_logic_vector(7 downto 0);
            rst, Clk: in std_logic;
            res_ls   : out std_logic_vector(7 downto 0);
				res_ms : out std_logic_vector(7 downto 0)
        );
    end component;

begin
    -- Instanciación del módulo multiplicador
    DUT: multiplicador
        port map(
			   activate => activate,
            A => A,
            B => B,
            rst => rst,
            Clk => Clk,
            res_ls => res_ls,
				res_ms => res_ms
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
		  activate <= '1';
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
        A <= "00010101";  -- A = 15
        B <= "00010101";  -- B = 15
		  wait for 100 ns;
        rst <= '1';
        wait for 500 ns;
		  
		  rst <= '0';
        -- Cuarta prueba: 99 * 99 = 9801
        A <= "10011001";  -- A = 99
        B <= "10011001";  -- B = 99
		  wait for 100 ns;
        rst <= '1';
        wait for 500 ns;
		  
        wait;
    end process stimulus;
end behavior;
