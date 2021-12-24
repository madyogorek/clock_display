#include "batt.h"

//Madelyn Ogorek ogore017

//int set_batt_from_ports(batt_t *batt)
// Uses the two global variables (ports) BATT_VOLTAGE_PORT and
// BATT_STATUS_PORT to set the fields of the parameter 'batt'.  If
// BATT_VOLTAGE_PORT is negative, then battery has been wired wrong;
// no fields of 'batt' are changed and 1 is returned to indicate an
// error.  Otherwise, sets fields of batt based on reading the voltage
// value and converting to precent using the provided formula. Returns
// 0 on a successful execution with no errors. This function DOES NOT
// modify any global variables but may access global variables.
//
// CONSTRAINT: Uses only integer operations. No floating point
// operations are used as the target machine does not have a FPU.
// 
// CONSTRAINT: Limit the complexity of code as much as possible. Do
// not use deeply nested conditional structures. Seek to make the code
// as short, and simple as possible. Code longer than 40 lines may be
// penalized for complexity.
//{
	////indicates an error
	//if(BATT_VOLTAGE_PORT < 0)
	//{
		//return 1;
	//}
	//batt->volts = BATT_VOLTAGE_PORT;
	////using given equation
	//batt->percent = (BATT_VOLTAGE_PORT - 3000) / 8;
	////preventing percents above 100%
	//if(BATT_VOLTAGE_PORT > 3800)
	//{
		//batt->percent = 100;
	//}
	////preventing negative percents
	//else if(BATT_VOLTAGE_PORT <= 3000)
	//{
		//batt->percent = 0;
	//}
	////if last bit is 1 it will put mode in 1 meaning percent
	//int mask = 0x1;
	//if(mask & BATT_STATUS_PORT)
	//{
		//batt->mode = 1;
	//}
	//else
		//batt->mode = 0;
	//return 0;
//}

//int set_display_from_batt(batt_t batt, int *display)
// Alters the bits of integer pointed to by display to reflect the
// data in struct param 'batt'.  Selects either to show Volts (mode=0)
// or Percent (mode=1). If Volts are displayed, only displays 3 digits
// rounding the lowest digit up or down appropriate to the last digit.
// Calculates each digit to display changes bits at 'display' to show
// the volts/percent according to the pattern for each digit. Modifies
// additional bits to show a decimal place for volts and a 'V' or '%'
// indicator appropriate to the mode. In both modes, places bars in
// the level display as indicated by percentage cutoffs in provided
// diagrams. This function DOES NOT modify any global variables but
// may access global variables. Always returns 0.
// 
// CONSTRAINT: Limit the complexity of code as much as possible. Do
// not use deeply nested conditional structures. Seek to make the code
// as short, and simple as possible. Code longer than 85 lines may be
// penalized for complexity.
//{
	//filling table with bits representing each digit's representation
	//char table[10];
	//table[0] = 0b0111111;
	//table[1] = 0b0000011;
	//table[2] = 0b1101101;
	//table[3] = 0b1100111;
	//table[4] = 0b1010011;
	//table[5] = 0b1110110;
	//table[6] = 0b1111110;
	//table[7] = 0b0100011;
	//table[8] = 0b1111111;
	//table[9] = 0b1110111;
	//vars will hold the representations of each digit
	//int left_digit, middle_digit, right_digit;
	//volt stuff
	//if(batt.mode == 0)
	//{
		//holds the least significant digit
		//int rounding_digit = batt.volts % 10;
		//right_digit = (batt.volts / 10) % 10;
		//rounding up the last digit
		//if(rounding_digit >= 5)
			//right_digit++;
		//middle_digit = (batt.volts / 100) % 10;
		//left_digit = (batt.volts / 1000) % 10;
	//}
	//percent mode
	//else 
	//{
		//right_digit = batt.percent % 10;
		//middle_digit = (batt.percent / 10) % 10;
		//this digit wont be used if not 100%
		//left_digit = 1;
	//}
	//var will hold all the bits needed for the correct display
	//int digit_holder = 0;
	//only set left digit if its in volts or @ 100%
	//if(batt.mode == 0 || batt.percent == 100)
	//{
		//digit_holder = table[left_digit] << 14;
	//}
	//only set middle digit if in volts or percent is >= 10
	//if(batt.mode == 0 || batt.percent >= 10)
	//{
		//int x = table[middle_digit] << 7;
		//digit_holder = digit_holder | x;
	//}
	//sets right digit no matter what
	//digit_holder = digit_holder | table[right_digit];
	//displays v and decimal point
	//if(batt.mode == 0)
	//{
		//int n = 0b11 << 21;
		//digit_holder = digit_holder | n;
	//}
	//displays %
	//else
	//{
		//int n = 0b1 << 23;
		//digit_holder = digit_holder | n;
	//}
	//remaining if statements determine what the battery meter shows
	//if(batt.percent >= 90)
	//{
		//int n = 0b11111 << 24;
		//digit_holder = digit_holder | n;
	//}
	//else if(batt.percent >= 70)
	//{
		//int n = 0b1111 << 25;
		//digit_holder = digit_holder | n;
	//}
	//else if(batt.percent >= 50)
	//{
		//int n = 0b111 << 26;
		//digit_holder = digit_holder | n;
	//}
	//else if(batt.percent >= 30)
	//{
		//int n = 0b11 << 27;
		//digit_holder = digit_holder | n;
	//}
	//else if(batt.percent >= 5)
	//{
		//int n = 0b1 << 28;
		//digit_holder = digit_holder | n;
	//}
	//pointer now points to digit_holder
	//*display = digit_holder;
	//return 0;
//}

//int batt_update()
// Called to update the battery meter display.  Makes use of
// set_batt_from_ports() and set_display_from_batt() to access battery
// voltage sensor then set the display. Checks these functions and if
// they indicate an error, does NOT change the display.  If functions
// succeed, modifies BATT_DISPLAY_PORT to show current battery level.
// 
// CONSTRAINT: Does not allocate any heap memory as malloc() is NOT
// available on the target microcontroller.  Uses stack and global
// memory only.
//{
	//creating batt_t struct so we can call functions
	//batt_t mybatt = {.volts=-100, .percent=-1, .mode=-1};
	//initially calling functions to check for errors
	//int result_of_ports = set_batt_from_ports(&mybatt);
	//int mydisplay = 0;
	//int result_of_display = set_display_from_batt(mybatt, &mydisplay);
	//if(result_of_ports || result_of_display)
	//{
		//error occurred
		//return 1;
	//}
	//no errors so we update the display
	//set_display_from_batt(mybatt, &BATT_DISPLAY_PORT);
	//return 0;
//}





























