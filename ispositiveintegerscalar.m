function isPositiveIntegerScalar = ispositiveintegerscalar (x)
%% Returns whether an input is a positive integer scalar
% Usage: isPositiveIntegerScalar = ispositiveintegerscalar (x)
% Explanation:
%       Tests whether the input is a positive integer scalar
% Example(s):
%       ispositiveintegerscalar(10)
%       ispositiveintegerscalar(10.5)
%       ispositiveintegerscalar(-1:3)
% Outputs:
%       isPositiveIntegerScalar
%                       - whether the input is a positive integer scalar
%                       specified as a logical scalar
% Arguments:    
%       x               - an input to check
%
% Requires: 
%       cd/isaninteger.m
%
% Used by:
%       cd/compute_weighted_average.m

% File History:
% 2018-10-26 Adapted from ispositiveintegervector.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(['Not enough input arguments, ', ...
            'type ''help %s'' for usage'], mfilename);
end

%% Do the job
isPositiveIntegerScalar = isnumeric(x) && isscalar(x) && ...
                            isaninteger(x) && x > 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%