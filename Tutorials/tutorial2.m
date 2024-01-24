% the first (non-comment) line of a function is called the 
% syntax declaration. it defines the function name and specifies the 
% function's inputs and outputs 
% while it is not required that the filename match the function name, it is
% very strongly recommended that you always do so, to avoid confusion.
function [out1, out2, out3, out4] = tutorial2(in1, in2)

% everything that happens here is separate from what is happening in the
% main workspace, or what is happening inside of other functions.  This
% function does not have access to any data that might be defined in the
% main scope except for what is passed into it via the input arguments.

out1 = in1 + in2;
out2 = in1 - in2;

out3 = tutorial2_subfunction1(in1);


    % this is a nested subfunction.  it has access to all of the data
    % available to its parent function, but the parent function can only
    % access variables defined in the subfunction if they are returned
    function out = tutorial2_subfunction1(in)
        internal_variable = in.*in1;
        out = 2*internal_variable;
    end


out4 = tutorial2_subfunction1(in2);
% note that we can use our subfunction before or after it is defined.

end 
% even though MATLAB does not strictly require that functions have an end 
% statement, you should always put one in anyway.  With nested functions,
% an end is always required. 

% Question: can the outer function access internal_variable from the inner
% function?