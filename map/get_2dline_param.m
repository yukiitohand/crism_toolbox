function [a,c] = get_2dline_param(x1,y1,x2,y2)
% [a,c] = get_2dline_param(x1,y1,x2,y2)
%   return a line parameter expressed as a'[x y]' = c
%   from two points that pass it.
%  INPUTS
%    x1, y1 : the first point
%    x2, y2 : the other point
%  OUTPUTS
%    a: [1 x 2], 

a = [y2-y1 x1-x2]; c = x1*y2-x2*y1;

end