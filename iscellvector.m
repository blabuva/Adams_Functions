function isCellVector = iscellvector (x)
%% Returns whether an input is a cell array of vectors (may be empty)
% Usage: isCellVector = iscellvector (x)
% Explanation:
%       Tests whether the input is a cell array of vectors
% Example(s):
%       iscellvector({1:10, 2:20})
%       iscellvector({magic(3), 2:20})
%       iscellvector({'sets', 'lasts'})
%       iscellvector({{1:10, 2:20}, {1:10, 2:20}})
% Outputs:
%       isCellVector    - whether the input is a cell array of vectors
%                       specified as a logical scalar
% Arguments:    
%       x               - an input to check
%
% Requires:
%
% Used by:
%       cd/compute_combined_data.m
%       cd/count_samples.m
%       cd/count_vectors.m
%       cd/extract_columns.m

% File History:
% 2019-01-18 Adapted from iscellnonvector.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(['Not enough input arguments, ', ...
            'type ''help %s'' for usage'], mfilename);
end

%% Do the job
isCellVector = iscell(x) && all(all(all(cellfun(@isvector, x))));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
