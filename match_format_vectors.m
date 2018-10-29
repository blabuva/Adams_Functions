function [vecs1, vecs2] = match_format_vectors (vecs1, vecs2, varargin)
%% Matches a set of vectors to another set of vectors so that they are both cell arrays of the same number of column vectors
% Usage: [vecs1, vecs2] = match_format_vectors (vecs1, vecs2, varargin)
% Explanation:
%       TODO
%       cf. match_vector_counts.m
% Example(s):
%       [a, b] = match_format_vectors({1:5, 2:6}, 1:5)
%       [a, b] = match_format_vectors({1:5, [2:6]'}, 1:5)
%       [a, b] = match_format_vectors([[1:5]', [2:6]'], [1:5]')
% Outputs:
%       vecs1       - new first set of vectors
%                   specified as a numeric vector 
%                       or a cell array of numeric vectors
%       vecs2       - new second set of vectors
%                   specified as a numeric vector 
%                       or a cell array of numeric vectors
% Arguments:
%       vecs1       - first set of vectors
%                   must be a numeric array or a cell array of numeric arrays
%       vecs2       - second set of vectors
%                   must be a numeric array or a cell array of numeric arrays
%       varargin    - 'ForceCellOutputs': whether to force outputs as 
%                                           cell arrays
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%
% Requires:
%       cd/argfun.m
%       cd/force_column_cell.m
%       cd/force_column_numeric.m
%       cd/iscellnumeric.m
%       cd/match_dimensions.m
%
% Used by:    
%       cd/compute_residuals.m
%       cd/compute_rms_error.m
%       cd/extract_subvectors.m
%       cd/find_pulse_response_endpoints.m
%       cd/find_window_endpoints.m

% File History:
% 2018-10-28 Adapted from code in find_window_endpoints.m 
%               and match_vector_counts.m
% 

%% Hard-coded parameters

%% Default values for optional arguments
forceCellOutputsDefault = false;    % don't force as cell array by default

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 2
    error(['Not enough input arguments, ', ...
            'type ''help %s'' for usage'], mfilename);
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add required inputs to the Input Parser
addRequired(iP, 'vecs1', ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vecs1 must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));
addRequired(iP, 'vecs2', ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vecs2 must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'ForceCellOutputs', forceCellOutputsDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));

% Read from the Input Parser
parse(iP, vecs1, vecs2, varargin{:});
forceCellOutputs = iP.Results.ForceCellOutputs;

%% Preparation
% TODO

%% Do the job
% If the vecs1 or vecs2 is a numeric vector, make sure it is a column vector
[vecs1, vecs2] = ...
    argfun(@(x) force_column_numeric(x, 'IgnoreNonVectors', true), ...
            vecs1, vecs2);

% If there are more than one vectors in either vecs1 or vecs2, 
%   put things in a format so cellfun can be used
if ~(isnumeric(vecs1) && isvector(vecs1) && ...
        isnumeric(vecs2) && isvector(vecs2))
    % Force vecs1/vecs2 to become 
    %   column cell arrays of column numeric vectors
    [vecs1, vecs2] = argfun(@force_column_cell, vecs1, vecs2);

    % Find the maximum number of rows
    maxVecs = max(numel(vecs1), numel(vecs2));

    % Match up the vector counts
    % TODO: Incorporate comparison into match_dimensions.m
    [vecs1, vecs2] = ...
        argfun(@(x) match_dimensions(x, [maxVecs, 1]), vecs1, vecs2);
else
    % Force outputs to be cell arrays if requested
    if forceCellOutputs
        vecs1 = {vecs1};
        vecs2 = {vecs2};
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%