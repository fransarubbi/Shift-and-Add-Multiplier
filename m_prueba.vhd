library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.conversor.all;

entity multiplicador is
    generic(N : integer := 8);
    port(
		  activate : in std_logic;
        A, B     : in std_logic_vector(N-1 downto 0);
        rst, clk : in std_logic;
        res_ls   : out std_logic_vector(N-1 downto 0);
		  res_ms   : out std_logic_vector(N-1 downto 0)
    );
end multiplicador;

architecture Behavioral of multiplicador is
	 -- Estados
	 type state is(init,calculate,ok);
	 signal state_present,state_future: state;
	 
	 -- Entradas modificadas
	 signal a_mod : STD_LOGIC_VECTOR(7 downto 0);
	 signal b_mod : STD_LOGIC_VECTOR(7 downto 0);

	 -- Registros y señales de calculo
    signal P_reg : STD_LOGIC_VECTOR(N-1 downto 0) := "00000000";
	 signal P_input : STD_LOGIC_VECTOR(N-1 downto 0) := "00000000";
	 signal Q_reg : STD_LOGIC_VECTOR(N-1 downto 0);
	 signal Q_input : STD_LOGIC_VECTOR(N-1 downto 0):= "00000000";
	 signal add : STD_LOGIC_VECTOR(N downto 0):= "000000000";
	 signal multiplicando : STD_LOGIC_VECTOR(N-1 downto 0):= "00000000";
	 signal RES_reg : STD_LOGIC_VECTOR(2*N-1 downto 0);
	 signal RES_input : STD_LOGIC_VECTOR(2*N-1 downto 0);
	 
	 -- Contador
	 signal C_input : std_logic_vector(3 downto 0);
	 signal C_reg : std_logic_vector(3 downto 0) := "0000";
	 signal C_zero : STD_LOGIC;
	 
	 -- Señales de control
	 signal C_load_mdor : STD_LOGIC; --Cargar el multiplicador
	 signal C_shift_mdor : STD_LOGIC; --Hacer el shifteo en Q
	 signal C_load_sum : STD_LOGIC; --Cargar la suma en P
	 signal C_load_cont : STD_LOGIC; --Cargar 8 en contador
	 signal C_dec_cont : STD_LOGIC; --Habilita decrementar el contador
	 signal C_ready : STD_LOGIC; --Aviso de fin de calculo
begin
	 -- Convertir entradas al binario correspondiente
	 hexa_to_bin(A, a_mod);
	 hexa_to_bin(B, b_mod);

	 -- Contador
	 C_zero <= '1' when C_reg = "0000" else '0';
	 C_input <= "1000" when C_load_cont = '1' else 
					C_reg - '1' when C_dec_cont = '1' else "0000";
					
	 --Multiplicacion
	 Q_input <= (a_mod and (N-1 downto 0 =>C_load_mdor)) or ((add(0) & Q_reg(N-1 downto 1)) and (N-1 downto 0 => C_shift_mdor));
	 P_input <= (N-1 downto 0 => C_load_sum) and add(N downto 1);
	 multiplicando <= (b_mod and (N-1 downto 0 => Q_reg(0)));
	 add <= std_logic_vector(unsigned('0' & multiplicando) + unsigned('0' & P_reg));
	 RES_input <= P_reg & Q_reg;
	 
	 combinacional:process(state_present,C_zero, activate)
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
				res_ls <= (others => '0');
				res_ms <= (others => '0');
				if activate = '1' then
					state_future <= calculate;
				end if;
				
			when calculate =>
				C_load_mdor <= '0';
				res_ls <= (others => '0');
				res_ms <= (others => '0');
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
				bin_to_dec(RES_reg, res_ls, res_ms);
		end case;
	end process combinacional;

    -- Proceso secuencial activado por el reloj
    secuencial: process(clk)
    begin
		if rst = '0' then
			RES_reg <= (others => '0');
			hexa_to_bin(A, Q_reg);
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