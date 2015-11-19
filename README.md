# Empirical Study on Sass

Collect information from Sass/SCSS style sheets and write them into pipe-separated files for statistical analysis,
mostly for research purposes.
This information include: 

1. **variable declarations** (Output file: {extension}-variableDeclarationsInfo.txt)
	* Variable name and location name
	* The scope of the variable (global or local)
	* The type of the value stored in the variable.
	This type can take one of these possible values: color, number, identifier, string, function call, and "other" for all other types of values
2. **Mixin calls** ({extension}-mixinCallsInfo.txt)
	* Name and location
	* Total number of arguments passed to the mixin
	* Name and location of the corresponding Mixin declaration
3. **Mixin Declarations** (Output file: {extension}-mixinDeclarationInfo.txt)
	* Name and location
	* Number of times the mixin is called
	* Number of parameters
	* Number of declarations which directly or indirectly (i.e., using nesting) exist inside the body of the mixin
	* Number of declarations in the body of the mixin which use at least one of the parameters of the mixin
	* Number of declarations styling vendor-specific properties (e.g., -webkit-column-gap vs -moz-column-gap)
	* Number of distinct parameters which are used for two or more different property types (e.g., a parameter used for styling the top and margin properties)
	* Number of declarations using only hard-coded (i.e., literal) values
	* Number of vendor-specific property declarations which share at least one of the mixin’s parameters
4. **Selectors** and **Nesting** (Output file: {extension}-selectorsInfo.txt)
	* Name and location
	* Number of base selectors it consists of (e.g., the grouped selector H1, A > B consists of two base selectors, namely H1 and A > B)
	* Number of combinator selectors in the list of its base selectors (the presence of a combinator selector indicates a missed nesting opportunity)
	* Name of its parent selector
5. **@extend** construct (Output file: {extension}-extendInfo.txt)
	* The target selector which is extended

({extension} = "sass" or "scss", depending on the main input file)

# Usage
1. Clone this repo.
2. Clone [Sass](https://github.com/sass/sass) in the directory named "sass", besides the directory of the cloned repo in 1.
3. Create a file named "mainfiles.txt" in the folder that you have all the Sass/SCSS files to be examined.
In this file, enter the name of the *main* Sass/SCSS files (i.e., the ones that you would pass to Sass compiler to get the corresponding CSS file).
You can enter multiple files, each in a separate line.
4. Run this code with two args: 1) Path to the folder where output files have to be written, 2) Path to the folder having the the file "mainfiles.txt" 

# Licence
The MIT License
