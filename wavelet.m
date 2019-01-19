function [C, D] = wavelet(signal, N, wname)
%wavelet - Computes wavelet decomposition of input signal
%
% Syntax:  [C, D] = wavelet(signal, N, wname)
% 
% Inputs: 
%    signal   - The input signal
%    N        - The level of decomposition
%    wname    - The name of the mother wavelet
%
% Outputs: 
%    C - A vector containing the last approximation and all detail
%        coefficients
%    D - A vector containing the detail coefficients
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author: Umaer Hanif
% March 2017; Last revision: 16-June-2017

%------------------------------ BEGIN CODE --------------------------------

% Perform wavelet decomposition
[C, L] = wavedec(signal, N, wname);

% Extract detail coefficients
D = detcoef(C, L, wname, N);

end

%------------------------------ END OF CODE -------------------------------