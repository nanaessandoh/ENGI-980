LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY Bit_Flipping IS
GENERIC(
	-- Define Generics
	 N :natural := 10 -- Length of Codeword Bits
);

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;


	-- Input Interface I/O
	isop : IN std_logic;
	input_data : IN std_logic_vector(N-1 downto 0);

	-- Output Interface I/O
	msg_decode_done : OUT std_logic;
	odata : OUT std_logic_vector (N-1 downto N-5)
);

END Bit_Flipping;



ARCHITECTURE behav OF Bit_Flipping IS

-- Define State of the State Machine
TYPE state_type IS (ONRESET, IDLE, PARITY_CHECK, BIT_ADD1, BIT_ADD2, BIT_ADD3, BIT_ADD4, BIT_ADD5, HOLD_1, HOLD_2, BIT_FLIP, BIT_DECODE);

-- Define States
SIGNAL current_state, next_state : state_type;

-- Define Signals
SIGNAL Bit1 : integer; --Represent Each Bit Protection Equation
SIGNAL Bit2 : integer; -- Eqn 2
SIGNAL Bit3 : integer; -- Eqn 3
SIGNAL Bit4 : integer; -- Eqn 4
SIGNAL Bit5 : integer; -- Eqn 5
SIGNAL Bit6 : integer; -- Eqn 6
SIGNAL Bit7 : integer; -- Eqn 7
SIGNAL Bit8 : integer; -- Eqn 8
SIGNAL Bit9 : integer; -- Eqn 9
SIGNAL Bit10 : integer; -- Eqn 10


SIGNAL Parity1,Parity2,Parity3,Parity4,Parity5 : std_logic;
SIGNAL idata : std_logic_vector (N-1 downto 0);


BEGIN


	clock_state_machine:
	PROCESS(clk,rstb)
	BEGIN
	IF (rstb /= '1') THEN
	current_state <= ONRESET;
	ELSIF (clk'EVENT and clk = '1') THEN
	current_state <= next_state;
	END IF;
	END PROCESS clock_state_machine;



	sequential:
	PROCESS(clk, rstb)
	BEGIN

	CASE current_state IS
	
	WHEN ONRESET =>
	next_state <= IDLE;

	WHEN IDLE =>
	IF( isop = '1') THEN
	next_state <= PARITY_CHECK;
	ELSE
	next_state <= IDLE;
	END IF;

	WHEN PARITY_CHECK =>
	next_state <= HOLD_1;


	WHEN HOLD_1 =>
	IF (Parity1 = '0') and (Parity2 = '0') and (Parity3 = '0') and (Parity4 = '0') and (Parity5 = '0') THEN 	
	next_state <= BIT_DECODE;
        ELSIF (Parity1 = '1') THEN
	next_state <= BIT_ADD1;
        ELSIF (Parity2 = '1') THEN
	next_state <= BIT_ADD2;
        ELSIF (Parity3 = '1') THEN
	next_state <= BIT_ADD3;
        ELSIF (Parity4 = '1') THEN
	next_state <= BIT_ADD4;
        ELSIF (Parity5 = '1') THEN
	next_state <= BIT_ADD5;
	END IF;



	WHEN BIT_ADD1 =>
        IF (Parity2 = '1') THEN
	next_state <= BIT_ADD2;
        ELSIF (Parity3 = '1') THEN
	next_state <= BIT_ADD3;
        ELSIF (Parity4 = '1') THEN
	next_state <= BIT_ADD4;
        ELSIF (Parity5 = '1') THEN
	next_state <= BIT_ADD5;
	ELSE
	next_state<= HOLD_2;
	END IF;

	
	WHEN BIT_ADD2 =>
        IF (Parity3 = '1') THEN
	next_state <= BIT_ADD3;
        ELSIF (Parity4 = '1') THEN
	next_state <= BIT_ADD4;
        ELSIF (Parity5 = '1') THEN
	next_state <= BIT_ADD5;
	ELSE
	next_state<= HOLD_2;
	END IF;

	WHEN BIT_ADD3 =>
	IF (Parity4 = '1') THEN
	next_state <= BIT_ADD4;
        ELSIF (Parity5 = '1') THEN
	next_state <= BIT_ADD5;
	ELSE
	next_state<= HOLD_2;
	END IF;

	WHEN BIT_ADD4 =>
	IF (Parity5 = '1') THEN
	next_state <= BIT_ADD5;
	ELSE
	next_state<= HOLD_2;
	END IF;

	WHEN BIT_ADD5 =>
	next_state<= HOLD_2;

	WHEN HOLD_2 =>
	next_state <= BIT_FLIP;
----------------------------------------------------------

	WHEN BIT_FLIP =>
	next_state <= PARITY_CHECK;

---------------------------------------------------
	WHEN BIT_DECODE =>
	next_state <= ONRESET;


	WHEN OTHERS =>
	next_state <= ONRESET;


	END CASE;

	END PROCESS sequential;

------------------------------------------------------------

	combinational:
	PROCESS(clk, rstb)	
	BEGIN
	
	IF ( clk'EVENT and clk = '1') THEN

	IF ( current_state = ONRESET) THEN
 		odata <= (OTHERS => 'U') ;
		msg_decode_done <= 'U';
		Parity1 <= 'U';
		Parity2 <= 'U';
		Parity3 <= 'U';
		Parity4 <= 'U';
		Parity5 <= 'U';
	END IF;

	IF (current_state = IDLE) THEN
		idata <= input_data;
				
	END IF;

-------------------------------------------------------------
	IF (current_state = PARITY_CHECK) THEN
	
	Parity1 <= idata(N-2) xor idata(N-3) xor idata(N-4) xor idata(N-6);
	Parity2 <= idata(N-1) xor idata(N-3) xor idata(N-7);
	Parity3 <= idata(N-1) xor idata(N-3) xor idata(N-5) xor idata(N-8);
	Parity4 <= idata(N-3) xor idata(N-4) xor idata(N-5) xor idata(N-9);
	Parity5 <= idata(N-1) xor idata(N-2) xor idata(N-5) xor idata(N-10);

	Bit1 <= 0;
	Bit2 <= 0;
	Bit3 <= 0;
	Bit4 <= 0;
	Bit5 <= 0;
	Bit6 <= 0;
	Bit7 <= 0;
	Bit8 <= 0;
	Bit9 <= 0;
	Bit10 <= 0;

	END IF;
-----------------------------------------------------------------------------


	IF (current_state = BIT_ADD1) THEN	

	Bit2 <= Bit2 + 1;
	Bit3 <= Bit3 + 1;
	Bit4 <= Bit4 + 1;
	Bit6 <= Bit6 + 1;

	END IF;

	IF (current_state = BIT_ADD2) THEN	

	Bit1 <= Bit1 + 1;
	Bit3 <= Bit3 + 1;
	Bit7 <= Bit7 + 1;

	END IF;

	IF (current_state = BIT_ADD3) THEN	

	Bit1 <= Bit1 + 1;
	Bit3 <= Bit3 + 1;
	Bit5 <= Bit5 + 1;
	Bit8 <= Bit8 + 1;

	END IF;


	IF (current_state = BIT_ADD4) THEN	

	Bit3 <= Bit3 + 1;
	Bit4 <= Bit4 + 1;
	Bit5 <= Bit5 + 1;
	Bit9 <= Bit9 + 1;

	END IF;


	IF (current_state = BIT_ADD5) THEN	

	Bit1 <= Bit1 + 1;
	Bit2 <= Bit2 + 1;
	Bit5 <= Bit5 + 1;
	Bit10 <= Bit10 + 1;

	END IF;




	IF ( current_state = BIT_FLIP) THEN

	
	--9
	IF ((Bit1>Bit2)and(Bit1>Bit3)and(Bit1>Bit4)and(Bit1>Bit5)and(Bit1>Bit6)and(Bit1>Bit7)and(Bit1>Bit8)and(Bit1>Bit9)and(Bit1>Bit10)) THEN 
	IF(idata(N-1) = '0') THEN
	idata(N-1) <= '1';
	ELSIF (idata(N-1) = '1') THEN
	idata(N-1) <= '0';
	END IF;
	
	--8
	ELSIF ((Bit2>Bit1)and(Bit2>Bit3)and(Bit2>Bit4)and(Bit2>Bit5)and(Bit2>Bit6)and(Bit2>Bit7)and(Bit2>Bit8)and(Bit2>Bit9)and(Bit2>Bit10)) THEN 
	IF(idata(N-2) = '0') THEN
	idata(N-2) <= '1';
	ELSIF (idata(N-2) = '1') THEN
	idata(N-2) <= '0';
	END IF;
	
	--7
	ELSIF ((Bit3>Bit1)and(Bit3>Bit2)and(Bit3>Bit4)and(Bit3>Bit5)and(Bit3>Bit6)and(Bit3>Bit7)and(Bit3>Bit8)and(Bit3>Bit9)and(Bit3>Bit10)) THEN 
	IF(idata(N-3) = '0') THEN
	idata(N-3) <= '1';
	ELSIF (idata(N-3) = '1') THEN
	idata(N-3) <= '0';
	END IF;

	--6
	ELSIF ((Bit4>Bit1)and(Bit4>Bit2)and(Bit4>Bit3)and(Bit4>Bit5)and(Bit4>Bit6)and(Bit4>Bit7)and(Bit4>Bit8)and(Bit4>Bit9)and(Bit4>Bit10)) THEN 
	IF(idata(N-4) = '0') THEN
	idata(N-4) <= '1';
	ELSIF (idata(N-4) = '1') THEN
	idata(N-4) <= '0';
	END IF;

	--5
	ELSIF ((Bit5>Bit1)and(Bit5>Bit2)and(Bit5>Bit3)and(Bit5>Bit4)and(Bit5>Bit6)and(Bit5>Bit7)and(Bit5>Bit8)and(Bit5>Bit9)and(Bit5>Bit10)) THEN 
	IF(idata(N-5) = '0') THEN
	idata(N-5) <= '1';
	ELSIF (idata(N-5) = '1') THEN
	idata(N-5) <= '0';
	END IF;

	--4
	ELSIF ((Bit6>Bit1)and(Bit6>Bit2)and(Bit6>Bit3)and(Bit6>Bit4)and(Bit6>Bit5)and(Bit6>Bit7)and(Bit6>Bit8)and(Bit6>Bit9)and(Bit6>Bit10)) THEN 
	IF(idata(N-6) = '0') THEN
	idata(N-6) <= '1';
	ELSIF (idata(N-6) = '1') THEN
	idata(N-6) <= '0';
	END IF;

	--3
	ELSIF ((Bit7>Bit1)and(Bit7>Bit2)and(Bit7>Bit3)and(Bit7>Bit4)and(Bit7>Bit5)and(Bit7>Bit6)and(Bit7>Bit8)and(Bit7>Bit9)and(Bit7>Bit10)) THEN 
	IF(idata(N-7) = '0') THEN
	idata(N-7) <= '1';
	ELSIF (idata(N-7) = '1') THEN
	idata(N-7) <= '0';
	END IF;

	--2
	ELSIF ((Bit8>Bit1)and(Bit8>Bit2)and(Bit8>Bit3)and(Bit8>Bit4)and(Bit8>Bit5)and(Bit8>Bit6)and(Bit8>Bit7)and(Bit8>Bit9)and(Bit8>Bit10)) THEN 
	IF(idata(N-8) = '0') THEN
	idata(N-8) <= '1';
	ELSIF (idata(N-8) = '1') THEN
	idata(N-8) <= '0';
	END IF;

	--1
	ELSIF ((Bit9>Bit1)and(Bit9>Bit2)and(Bit9>Bit3)and(Bit9>Bit4)and(Bit9>Bit5)and(Bit9>Bit6)and(Bit9>Bit7)and(Bit9>Bit8)and(Bit9>Bit10)) THEN 
	IF(idata(N-9) = '0') THEN
	idata(N-9) <= '1';
	ELSIF (idata(N-9) = '1') THEN
	idata(N-9) <= '0';
	END IF;

	--0
	ELSIF ((Bit10>Bit1)and(Bit10>Bit2)and(Bit10>Bit3)and(Bit10>Bit4)and(Bit10>Bit5)and(Bit10>Bit6)and(Bit10>Bit7)and(Bit10>Bit8)and(Bit10>Bit9)) THEN 
	IF(idata(N-10) = '0') THEN
	idata(N-10) <= '1';
	ELSIF (idata(N-10) = '1') THEN
	idata(N-10) <= '0';
	END IF;

	
	END IF;
	END IF;


	IF ( current_state = BIT_DECODE) THEN
		msg_decode_done <= '1';
		odata <= idata(N-1 downto N-5) ;
	ELSE 
		msg_decode_done <= '0';
		odata <= (OTHERS => 'U');
	END IF;
	END IF;

	END PROCESS combinational;


END behav;