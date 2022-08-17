function [x_incpt,y_incpt] = get_intersect_line2d(a1,c1,a2,c2)
% [x_incpt,y_incpt] = get_intersect_line2d(a1,c1,a2,c2)
%   return the intersection of the two lines:
%       a1' [x y]' = c1
%       and a2' [x y]' = c2
%   from two points that pass it.
%  INPUTS
%    a1: [1 x 2], normal vector for the first line.
%    c1: scalar, line constant
%    a2: [1 x 2], normal vector for the other line.
%    c2: scalar, line constant
%  OUTPUTS
%    x_incpt, y_incpt: coordinate of the intersection
%  
%  Detail:
%   Solving following matrix inversion.
%     A = [a1;a2] c = [c1;c2];
%    _       _
%   | x_incpt | = inv(A) * c
%   | y_incpt |
%    -       -

xy_incpt = 1/(a1(1)*a2(2)-a1(2)*a2(1)) * [a2(2) -a1(2); -a2(1) a1(1)] * [c1;c2];

x_incpt = xy_incpt(1); y_incpt = xy_incpt(2);

end