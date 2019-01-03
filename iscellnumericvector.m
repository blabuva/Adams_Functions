function isCellNumericVector = iscellnumericvector (x)
%% Returns whether an input is a cell array of numeric vectors (may be empty)
% Usage: isCellNumericVector = iscellnumericvector (x)
% Explanation:
%       Tests whether the input is a cell array of numeric vectors
% Example(s):
%       iscellnumericvector({1:10, 2:20})
%       iscellnumericvector({magic(3), 2:20})
%       iscellnumericvector({'sets', 'lasts'})
% Outputs:
%       isCellNumericVector   
%                       - whether the input is a cell array of numeric vectors
%                       specified as a logical scalar
% Arguments:    
%       x               - an input to check
%
% Requires:
%       cd/isnumericvector.m
%
% Used by:
%       cd/compute_combined_trace.m
%       cd/compute_rms_error.m
%       cd/compute_single_neuron_errors.m
%       cd/compute_sweep_errors.m
%       cd/count_samples.m
%       cd/count_vectors.m
%       cd/create_average_time_vector.m
%       cd/extract_elements.m
%       cd/extract_subvectors.m

% File History:
% 2018-10-25 Created by Adam Lu
% 2018-10-28 Vectors can now be empty

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(['Not enough input arguments, ', ...
            'type ''help %s'' for usage'], mfilename);
end

%% Do the job
isCellNumericVector = iscell(x) && all(cellfun(@isnumericvector, x));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%