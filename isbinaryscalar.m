function isBinaryScalar = isbinaryscalar (x)
%% Returns whether an input is a binary scalar (may be empty)
% Usage: isBinaryScalar = isbinaryscalar (x)
% Explanation:
%       Tests whether the input is a binary scalar
% Example(s):
%       isbinaryscalar([])
%       isbinaryscalar(false)
%       isbinaryscalar(2)
%       isbinaryscalar(1)
%       isbinaryscalar([0 0 1])
% Outputs:
%       isBinaryScalar  - whether the input is a binary scalar (may be empty)
%                       specified as a logical scalar
% Arguments:    
%       x               - an input to check
%
% Used by:
%       cd/m3ha_plot_individual_traces.m

% File History:
% 2018-10-31 Modified from isnumericvector.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(['Not enough input arguments, ', ...
            'type ''help %s'' for usage'], mfilename);
end

%% Do the job
% TODO: Place in own function
isBinary = @(x) islogical(x) || isnumeric(x) && all(x == 0 || x == 1);

isBinaryScalar = isempty(x) || isscalar(x) && isBinary(x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%