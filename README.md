# clock_display

The functions in this problem are identical to a previous project in which code to support an LCD clock display was written. These functions are:

`int set_tod_from_secs(int time_of_day_sec, tod_t *tod)`
Given the number of seconds from the start of the day, set the fields of the struct pointed to by tod to have the correct hours, minutes, seconds, and pm indication.
`int set_display_from_tod(tod_t tod, int *display)`
Given a `tod_t` struct, reset and alter the bits pointed to by display to cause a proper clock display.
`int clock_update()`
Update global `CLOCK_DISPLAY_PORT` using the `TIME_OF_DAY_SECS`. Call the previous two functions.
The big change in this iteration will be that the functions must be written in x86-64 assembly code. As C functions each of these is short, up to 85 lines maximum. The assembly versions will be somewhat longer as each C line typically needs 1-4 lines of assembly code to implement fully. Coding these functions in assembly give you real experience writing working assembly code and working with it in combination with C.
