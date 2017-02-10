function [ y ] = TustinZ( u, up, yp, T )
% 
%   Function : TustinZ
%   Desc :     Discrete integrator using Tustin's method
%   Graphic example :
%  
%     1     T     z + 1
%    --- = --- * -------
%     s     2     z - 1
%  
%           _______
%    x(n)  |   1   | y(n)
%   ------>| ----- |------>
%          |   s   |
%          |_______|
%  
%    iLaplace => y(n) = y(n-1) + T/2 * ( x(n-1) + x(n) )
%  
%  

y = yp + T/2 * (u + up);

end

