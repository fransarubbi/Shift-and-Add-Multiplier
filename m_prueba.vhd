library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity multiplicador is
    generic(N : integer := 8);
    port(
        A, B     : in std_logic_vector(N-1 downto 0);
        rst, clk : in std_logic;
        result   : out std_logic_vector(2*N-1 downto 0)
    );
end multiplicador;

architecture Behavioral of multiplicador is
	 --Estados
	 type state is(init,calculate,ok);
	 signal state_present,state_future: state;

	 --Registros y señales de calculo
    	 signal P_reg : STD_LOGIC_VECTOR(N-1 downto 0) := "00000000";
	 signal P_input : STD_LOGIC_VECTOR(N-1 downto 0) := "00000000";
	 signal Q_reg : STD_LOGIC_VECTOR(N-1 downto 0) := A;
	 signal Q_input : STD_LOGIC_VECTOR(N-1 downto 0):= "00000000";
	 signal add : STD_LOGIC_VECTOR(N downto 0):= "000000000";
	 signal multiplicando : STD_LOGIC_VECTOR(N-1 downto 0):= "00000000";
	 signal RES_reg : STD_LOGIC_VECTOR(2*N-1 downto 0);
	 signal RES_input : STD_LOGIC_VECTOR(2*N-1 downto 0);
	 
	 --Contador
	 signal C_input : std_logic_vector(3 downto 0);
	 signal C_reg : std_logic_vector(3 downto 0) := "0000";
	 signal C_zero : STD_LOGIC;
	 
	 --Señales de control
	 signal C_load_mdor : STD_LOGIC; --Cargar el multiplicador
	 signal C_shift_mdor : STD_LOGIC; --Hacer el shifteo en Q
	 signal C_load_sum : STD_LOGIC; --Cargar la suma en P
	 signal C_load_cont : STD_LOGIC; --Cargar 8 en contador
	 signal C_dec_cont : STD_LOGIC; --Habilita decrementar el contador
	 signal C_ready : STD_LOGIC; --Aviso de fin de calculo
begin
	 --Contador
	 C_zero <= '1' when C_reg = "0000" else '0';
	 C_input <= "1000" when C_load_cont = '1' else 
					C_reg - '1' when C_dec_cont = '1' else "0000";
					
	 --Multiplicacion
	 Q_input <= (A and (N-1 downto 0 =>C_load_mdor)) or ((add(0) & Q_reg(N-1 downto 1)) and (N-1 downto 0 => C_shift_mdor));
	 P_input <= (N-1 downto 0 => C_load_sum) and add(N downto 1);
	 multiplicando <= (B and (N-1 downto 0 => Q_reg(0)));
	 add <= std_logic_vector(unsigned('0' & multiplicando) + unsigned('0' & P_reg));
	 RES_input <= P_reg & Q_reg;
	 
	 combinacional:process(state_present,C_zero)
	 begin
		C_load_mdor <= '0';
		C_shift_mdor <= '0';
		C_load_sum <= '0';
		C_load_cont <= '0';
		C_dec_cont <= '0';
		C_ready <= '0';
		state_future <= state_present;
		
		case state_present is
			when init =>
				C_shift_mdor <= '0';
				C_load_sum <= '0';
				C_dec_cont <= '0';
				C_ready <= '0';
				C_load_cont <= '1';
				C_load_mdor <= '1';
				result <= (others => '0');
				state_future <= calculate;
			when calculate =>
				C_load_mdor <= '0';
				result <= (others => '0');
				if C_zero = '0' then
					C_dec_cont <= '1';
					C_load_sum <= '1';
					C_shift_mdor <= '1';
				else
					state_future <= ok;
				end if;
			when ok =>
				C_ready <= '1';
				state_future <= ok;
				result <= RES_reg;
		end case;
	end process combinacional;

    -- Proceso secuencial activado por el reloj
    secuencial: process(clk)
    begin
	if rst = '0' then
		state_present <= init;
        elsif clk'event and clk = '1' then
		if C_ready = '1' then
			state_present <= state_future;
		else
			C_reg <= C_input;
			P_reg <= P_input;
			Q_reg <= Q_input;
			RES_reg <= RES_input;
			state_present <= state_future;
		end if;
        end if;
    end process secuencial;
end Behavioral;
