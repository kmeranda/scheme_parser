To build the code:
	Run make.
	The Makefile will create the executable scheme_parser, as well as other output files that the user can ignore.

To run the code:
	Run the executable scheme_parser created by the Makefile.
	If the executable does not exist, see instructions for building the code, above.

To use the code:
	Enter a string in the terminal for the scheme parser to recognize.
	The functions implemented thus far are addition, subtraction, multiplication, division, and car.
	If the code is valid, the program will return the value to which the function evaluates.
	If the code is invalid, it will return a syntax error.
	For example,
		(+ (car (1 2 3)) (- 5 2)) will return the value 4
		(car 2 3) will return a syntax error, because the function car is expecting a list as input 
