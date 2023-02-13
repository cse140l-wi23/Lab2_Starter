// new lab 2 testbench
`include "lab2_display_tb.sv"
`include "new_lab2_part1_tb_support.sv"
module new_lab2_part1_tb();
  logic Reset = 1,
        Clk = 0,
        Timeset = 0,
        Alarmset = 0,
		Minadv = 0,
		Hrsadv = 0,
		Alarmon = 0,
		Pulse = 0;
		
  logic[6:0] H1disp, H0disp,
            M1disp, M0disp,
	    S1disp, S0disp;
  wire Buzz;
  wire AMorPM;
  string mystring;
  

  top_level_lab2_part1 top(.*); // (.Reset(Reset),....)
  initial begin
    # 1us Reset = 0;

    // ResetTime
    // Check that time is 12:00:00 AM after reset
    mystring = getTime(H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM);
    assert(mystring == "12:00:00 AM")
      $display("Pass ResetTime: %s", mystring);
    else
      $display("Fail ResetTime: Expected %s, got %s", "12:00:00 AM", mystring);

    // SecRollover
    // Set time to 12:00:58, wait 2 seconds, time should be 12:01:00
    setTime(12, 00, 58, 0, H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM, Timeset, Minadv, Hrsadv);
    #2us;
    mystring = getTime(H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM);
    assert(mystring == "12:01:00 AM")
      $display("Pass SecRollover: %s", mystring);
    else
      $display("Fail SecRollover: Expected %s, got %s", "12:01:00 AM", mystring);

    // TimeSet1
    // Set time to 12:03:00 AM and check
    // Check Minadv
    setTime(12, 03, 00, 0, H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM, Timeset, Minadv, Hrsadv);
    mystring = getTime(H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM);
    assert(mystring == "12:03:00 AM")
      $display("Pass TimeSet1: %s", mystring);
    else
      $display("Fail TimeSet1: Expected %s, got %s", "12:03:00 AM", mystring);
    
    // TimeSet2
    // Set time to 1:03:00 AM and check
    // Check Hrsadv
    setTime(1, 03, 00, 0, H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM, Timeset, Minadv, Hrsadv);
    mystring = getTime(H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM);
    assert(mystring == "01:03:00 AM")
      $display("Pass TimeSet2: %s", mystring);
    else
      $display("Fail TimeSet2: Expected %s, got %s", "01:03:00 AM", mystring);
    
    // TimeSet3
    // Set time to 1:03:00 PM and check
    // Check AM to PM
    setTime(01, 03, 00, 1, H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM, Timeset, Minadv, Hrsadv);
    mystring = getTime(H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM);
    assert(mystring == "01:03:00 PM")
      $display("Pass TimeSet3: %s", mystring);
    else
      $display("Fail TimeSet3: Expected %s, got %s", "01:03:00 PM", mystring);
    
    // TimeSet4
    // Set time to 01:01:00 PM and check
    setTime(01, 01, 00, 1, H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM, Timeset, Minadv, Hrsadv);
    mystring = getTime(H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM);
    assert(mystring == "01:01:00 PM")
      $display("Pass TimeSet4: %s", mystring);
    else
      $display("Fail TimeSet4: Expected %s, got %s", "01:01:00 PM", mystring);

    // MintoHrRoll1
    setTime(01, 58, 00, 0, H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM, Timeset, Minadv, Hrsadv);
    #120us;
    mystring = getTime(H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM);
    assert(mystring == "02:00:00 AM")
      $display("Pass MinToHrRoll1: %s", mystring);
    else
      $display("Fail MinToHrRoll1: Expected %s, got %s", "02:00:00 AM", mystring);

    // AlarmSet1
    // Set alarm to 05:00 AM and check
    Alarmset = 1;
    #1us
    setAlarm(05, 00, 0, H1disp, H0disp, M1disp, M0disp, AMorPM, Minadv, Hrsadv);
    mystring = getTime(H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM);
    assert(mystring.substr(0,4) == "05:00" && mystring.substr(9,10) == "AM")
      $display("Pass AlarmSet1: %s", mystring);
    else
      $display("Fail AlarmSet1: Expected %s, got %s", "05:00:-- AM", mystring);
    Alarmset = 0;
    //    Alarmon = 1;  // IF WE SET ALARM ON HERE, then while setting the time we might trigger the alarm
    #1us
     
    // FalseAlarm1
    // Set time to 05:00 PM and check that alarm buzz does not turn on
    setTime(05, 00, 00, 1, H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM, Timeset, Minadv, Hrsadv);
    Alarmon = 1;
    #1us
    mystring = getTime(H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM);
    assert(Buzz == 0)
      $display("Pass FalseAlarm1");
    else
      $display("Fail FalseAlarm1: 5am alarm went off at or before 5pm");

    // AlarmBuzz1
    // Set time to 05:00 AM and check that alarm buzz turns on
    Alarmon = 0;
    setTime(05, 00, 00, 0, H1disp, H0disp, M1disp, M0disp, S1disp, S0disp, AMorPM, Timeset, Minadv, Hrsadv);
    Alarmon = 1;
    #1us
    assert(Buzz == 1)
      $display("Pass AlarmBuzz1");
    else
      $display("Fail AlarmBuzz1: 5am alarm failed to go off at 5am");
    
    // AlarmBuzzCont
    // Wait 2 minutes and check that alarm buzz stays on
    #120us
    assert(Buzz == 1)
      $display("Pass AlarmBuzzCont");
    else
      $display("Fail AlarmBuzzCont: 5am alarm turns off after 5:00am");

    // AlarmBuzzOff
    // Turn off alarm and check that alarm buzz turns off
    Alarmon = 0;
    #1us
    assert(Buzz == 0)
      $display("Pass AlarmBuzzOff");
    else
      $display("Fail AlarmBuzzOff: Alarm buzz does not turn off when alarm is turned off");


    #100ns  $stop;
  end

  always begin  // period is 2 ns
    #500ns Pulse = 1;
	  #500ns Pulse = 0;
  end



endmodule
