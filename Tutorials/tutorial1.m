% MATLAB Tutorial 1

% The percent sign is a comment symbol - anything after the percent sign
% will be ignored.  You can place it at the start of a line for long
% comments, or in the middle of a line for short comments following code. 

%% Variables
% A variable is a piece of information.  Variables have 'types' (what kind
% of information is being stored).  MATLAB is weakly typed - you don't have
% to tell MATLAB what kind of data you want to store, it'll figure it out
% automatically. 

% Here are some ways of defining variables:
x = 1
y = 2;
z = x + y;
% Notice that a semi-colon at the end of a line suppresses output of that
% line's results.  You will almost always want to end lines with semicolons
% in your code.

% All of the values above are scalars. MATLAB also allows you to create 
% array (matrix) variables. 
arr1 = [1,2,3];
arr2 = [4;5;6];
% commas separate elements of an array in a column, semicolons start a new
% row. You can use both to define matrices:
M = [-1, 0, -2; 1, 2, 0];
% Question: what will be the dimensionality of this matrix?

% MATLAB can tell us: 
size(M)

% We can find more information on any MATLAB command or variable by asking 
% for help:
help size
help length

% You can actually skip the commas and just use spaces:
arr3 = [7 8 9];
% However, you may want to include the commas for clarity

% You can also use colons to create an ordered list of numbers
% The syntax is start:increment:stop. Skipping the increment defaults it to
% 1:
t = 0:10;
t2 = 0:0.25:1;

t3 = 0:0.3:1;
% Question: How many elements will be in t3?

% Another very useful command is linspace, which produces a linearly spaced
% list of numbers, similar to the colon operator:
t3 = linspace(0, 1, 10);

%% Array indexing

% You can always extract elements from an array (or matrix).  This is known
% as array indexing.  MATLAB uses 1-based indexing, meaning that the first
% index is 1 (other languages, including Pythong, start with 0).  Be
% careful, this is a frequent source of errors.

% to index a 1-D array (regardless of whether it is a column or row), you
% just use the number of the element you wish to extract:

arr1 = 0:10;
arr1(1)
arr1(10)

% we expect this one to throw an error, as our array only has 11 elements:
arr1(12) 

arr2 = [0;5;10;15;20];
arr2(1)
arr2(5)

% for multi-dimensional arrays, you can index with a single value, or with
% the number of values equivalent to the dimensionality of the array:
M = [1 2 3; 4 5 6; 7 8 9];
M(2,2)
M(2) %what happened??? When we use 1-D indexing, we go down columns first

% Question: What 1-D index will extract the 8 from M?

% You can also index ranges:
arr3 = 0:10;
arr3(1:5)

% Question: what will this command do?
arr3(1:2:length(arr3))


% Assigning values to indexes beyond the current size of an array
% will automatically grow it:

B(1,1) = 1
B(2, 3) = 2
B(4, 1:3) = 3

% The .' operator is the transpose (' by itself is conjugate trasnpose):
arr2.'

%% Math
% MATLAB does all the basic math
x = 1;
y = 2;
z1 = x+y
z2 = x - y
z3 = x*y
z4 = x/y
z5 = x^y %exponent
z6 = sqrt(y)

% and trigonometry:
% the default trigonometric operators assume radian inputs:
cos(pi/3)
sin(pi/4)

% Question: what will this return?
tan(pi/6) - sin(pi/6)/cos(pi/6)

%there are also equivalent methods that assume degree inputs:
cosd(60)
sind(45)
tand(30)

% what if we want more sig figs?
format long
ans 
% the output of any previous command not assigned to a variable is 
% automatically assigne dto ans

% inverse trigonometric functions are asin, acos, atan, asind, acosd, atand

% For arrays, addition and subtraction operate element by element:
arr1 = [1;2;3];
arr2 = [4;5;6];
arr1 + arr2
arr2 - arr1

% However, for multiplication and division, the default operators are
% interpreted as matrix multiplication and division (more on this later)
% To get element-by-element multiplication/division, we use the .* and ./
% operators
arr1.*arr2
arr1./arr2

% similarly, .^ does element by element exponentiation 
arr1.^arr2

% mixing up the * and .* (and / vs ./) operators is one of the largest
% sources of errors in MATLAB programs

% a few more useful math commands:
exp(1) %natural exponent
log(10) % natural logarithm
log10(10) %base-10 logarithm

% and finally, vector algebra:
x = [1;2;3];
y = [4;5;6];

dot(x,y)
cross(x,y)

%% Boolean Operators


%% Flow Control

%% Functions and scripts
