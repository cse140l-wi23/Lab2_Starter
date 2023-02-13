
// convert seven segment control wires for a
// decimal digit
// to its ordinal value (dec)
//
function bit [4:0] Seven2Bin(logic [6:0] decSeg);
	begin
		logic [4:0] val;
		case (decSeg)
			7'b100_0000: val = 5'b0_0000; // 0
			7'b111_1001: val = 5'b0_0001; // 1
			7'b010_0100: val = 5'b0_0010; // 2        
			7'b011_0000: val = 5'b0_0011; // 3         
			7'b001_1001: val = 5'b0_0100; // 4        
			7'b001_0010: val = 5'b0_0101; // 5         
			7'b000_0010: val = 5'b0_0110; // 6        
			7'b111_1000: val = 5'b0_0111; // 7        
			7'b000_0000: val = 5'b0_1000; // 8        
			7'b001_1000: val = 5'b0_1001; // 9        
			default: val = 5'b1_0000;
		endcase
		return val;
	end
endfunction

function integer getNum(input logic [6:0] D1, D0);
	begin
		integer low;
		low = Seven2Bin(D0);
		return (Seven2Bin(D1)*10 + low);
	end
endfunction

function string getTime(input logic [6:0] HM1disp, HM0disp, MD1disp, MD0disp, S1disp, S0disp, input logic AMorPM);
	begin
		string ampm;
		ampm = AMorPM ? " PM" : " AM";
		return {$sformatf("%0d",Seven2Bin(HM1disp)), $sformatf("%0d",Seven2Bin(HM0disp)), ":", $sformatf("%0d",Seven2Bin(MD1disp)), $sformatf("%0d",Seven2Bin(MD0disp)), ":", $sformatf("%0d",Seven2Bin(S1disp)), $sformatf("%0d",Seven2Bin(S0disp)), ampm};
	end
endfunction
	
task automatic setTime(input integer setHr, setMin, setSec, input logic setAM, 
			input logic [6:0] HM1disp, HM0disp, MD1disp, MD0disp, S1disp, S0disp, input logic AMorPM, ref logic Timeset, Minadv, Hrsadv);
	begin
		integer currHr, currMin, currSec, setHrZ, carryMin;
		currSec = getNum(S1disp, S0disp);
		currMin = getNum(MD1disp, MD0disp);
		currHr = getNum(HM1disp, HM0disp);
		carryMin = 0;
		if(currSec > setSec) begin
			#((60 - (currSec - setSec)) * 1us);
			carryMin = 1;
		end
		else if(currSec < setSec)
			#((setSec - currSec) * 1us);
		Timeset = 1;
		Minadv = 1;
		currMin = (currMin + carryMin) % 60;
		if(currMin > setMin)
			#((60 - (currMin - setMin)) * 1us);
		else if(currMin < setMin)
			#((setMin - currMin) * 1us);
		Minadv = 0;
		Hrsadv = 1;
		currHr = currHr % 12;
		setHrZ = setHr % 12;
		if(currHr >= setHrZ && setAM != AMorPM)
			#((12 - (currHr - setHrZ)) * 1us);
		else if(currHr > setHrZ && setAM == AMorPM)
			#((24 - (currHr - setHrZ)) * 1us);
		else if(currHr <= setHrZ && setAM != AMorPM)
			#((12 + (setHrZ - currHr)) * 1us);
		else if (currHr < setHrZ && setAM == AMorPM)
			#((setHrZ - currHr) * 1us);
		Hrsadv = 0;
		#1us
		Timeset = 0;
	end
endtask

// Note: Alarmset must be set to 1 before calling setAlarm() and set to 0 after
task automatic setAlarm(input integer setHr, setMin, input logic setAM, 
			input logic [6:0] HM1disp, HM0disp, MD1disp, MD0disp, input logic AMorPM, ref logic Minadv, Hrsadv);
	begin
		integer currHr, currMin, setHrZ;
		currMin = getNum(MD1disp, MD0disp);
		currHr = getNum(HM1disp, HM0disp);
		Minadv = 1;
		if(currMin > setMin)
			#((60 - (currMin - setMin)) * 1us);
		else if(currMin < setMin)
			#((setMin - currMin) * 1us);
		Minadv = 0;
		Hrsadv = 1;
		currHr = currHr % 12;
		setHrZ = setHr % 12;
		if(currHr >= setHrZ && setAM != AMorPM)
			#((12 - (currHr - setHrZ)) * 1us);
		else if(currHr > setHrZ && setAM == AMorPM)
			#((24 - (currHr - setHrZ)) * 1us);
		else if(currHr <= setHrZ && setAM != AMorPM)
			#((12 + (setHrZ - currHr)) * 1us);
		else if (currHr < setHrZ && setAM == AMorPM)
			#((setHrZ - currHr) * 1us);
		Hrsadv = 0;
	end
endtask

function string getDay(input logic[6:0] DayLED);
	begin
		string weekday;
		case(DayLED)
			7'b100_0000: weekday = "Sunday";
			7'b010_0000: weekday = "Monday";
			7'b001_0000: weekday = "Tuesday";
			7'b000_1000: weekday = "Wednesday";
			7'b000_0100: weekday = "Thursday";
			7'b000_0010: weekday = "Friday";
			7'b000_0001: weekday = "Saturday";
			default:	 weekday = "Invalid weekday";
		endcase
		return weekday;
	end
endfunction

function integer getDayInt(input logic[6:0] DayLED);
	begin
		integer weekday;
		case(DayLED)
			7'b100_0000: weekday = 0;
			7'b010_0000: weekday = 1;
			7'b001_0000: weekday = 2;
			7'b000_1000: weekday = 3;
			7'b000_0100: weekday = 4;
			7'b000_0010: weekday = 5;
			7'b000_0001: weekday = 6;
			default:	 weekday = 0;
		endcase
		return weekday;
	end
endfunction

function string getDayFromInt(int dayNum);
	begin
		string weekday;
		case(dayNum)
			0: weekday = "Sunday";
			1: weekday = "Monday";
			2: weekday = "Tuesday";
			3: weekday = "Wednesday";
			4: weekday = "Thursday";
			5: weekday = "Friday";
			6: weekday = "Saturday";
			default:	 weekday = "Invalid weekday";
		endcase
		return weekday;
	end
endfunction
   

task automatic setDay(input integer setD, input logic[6:0] DayLED, ref logic Timeset, Dayadv);
	begin
		integer currD;
		currD = getDayInt(DayLED);
		Timeset = 1;
		Dayadv = 1;
		if(currD > setD)
			#((7 - (currD - setD)) * 1us);
		else if(currD < setD)
			#((setD - currD) * 1us);
		Dayadv = 0;
		Timeset = 0;
	end
endtask
