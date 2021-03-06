function [idxClosest, valClosest] = find_closest (vecs, target, varargin)
%% Finds the element(s) in monotonic numeric vector(s) closest to target(s)
% Usage: [idxClosest, valClosest] = find_closest (vecs, target, varargin)
% Explanation:
%       TODO
%
% Example(s):
%       [i, v] = find_closest(2:9, 5.6)
%       [i, v] = find_closest([1, 2, 3; 4, 5, 6; 7, 8, 9], 5)
%       [i, v] = find_closest(9:-2:1, 4)
%       [i, v] = find_closest({5:-1:1, 8:-2:0}, 4)
%       [i, v] = find_closest(5:-1:1, [3.2, 3.8])
%       [i, v] = find_closest(5:-1:1, [3.2, 3.8], 'Direction', 'none')
%
% Outputs:
%       idxClosest  - index(ices) of the closest value(s)
%                   specified as a positive integer vector
%       valClosest  - the closest value(s)
%                   specified as a numeric vector
%
% Arguments:
%       vecs        - monotonic vector(s)
%                   Note: If a cell array, each element must be a vector
%                         If a non-vector array, each column is a vector
%                   must be a numeric array or a cell array of numeric vectors
%       target      - target value(s)
%                   must be a numeric vector
%       varargin    - 'Direction': rounding direction
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'nearest'   - round to 'nearest'
%                       'down'      - always round down
%                       'up'        - always round up
%                       'none'      - no rounding, use interpolation
%                   default == 'nearest'
%
% Requires:
%       cd/create_error_for_nargin.m
%       cd/extract_elements.m
%       cd/extract_subvectors.m
%       cd/find_window_endpoints.m
%       cd/match_format_vector_sets.m
%
% Used by:
%       cd/parse_phase_info.m
%       cd/parse_stim.m
%       cd/parse_ipsc.m

% File History:
% 2019-11-14 Created by Adam Lu
% 2019-11-25 Added 'none' as a direction
% 

%% Hard-coded parameters
validDirections = {'nearest', 'down', 'up', 'none'};

%% Default values for optional arguments
directionDefault = 'nearest';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 2
    error(create_error_for_nargin(mfilename));
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add required inputs to the Input Parser
addRequired(iP, 'vecs', ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vecs must be either a numeric array ', ...
                    'or a cell array of numeric vectors!']));
addRequired(iP, 'target', ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'Direction', directionDefault, ...
    @(x) any(validatestring(x, validDirections)));

% Read from the Input Parser
parse(iP, vecs, target, varargin{:});
direction = validatestring(iP.Results.Direction, validDirections);

%% Preparation
% Create a cell array
targetCell = num2cell(target);

% Match the number of rows
[vecs, targetCell] = match_format_vector_sets(vecs, targetCell);

%% Do the job
% Create "time windows"
windows = cellfun(@(x) [x; x], targetCell, 'UniformOutput', false);

% Find endpoints that "include" the target value
indClosest = find_window_endpoints(windows, vecs, 'BoundaryMode', 'inclusive');

% Find corresponding values
valsClosest = extract_subvectors(vecs, 'Indices', indClosest);

% Sort the values in descending order
%   Note: Must be descending for 'nearest' to work
[valsClosest, origInd] = ...
    cellfun(@(x) sort(x, 'descend'), valsClosest, 'UniformOutput', false);

% Reorder the indices in the same order
indClosest = cellfun(@(x, y) x(y), indClosest, origInd, 'UniformOutput', false);

% Compute the absolute differences
absDiffValues = cellfun(@(x, y) abs(x - y), targetCell, valsClosest, ...
                        'UniformOutput', false);

% Choose the endpoint that is "closest"
switch direction
    case 'nearest'
        [~, iClosest] = cellfun(@min, absDiffValues, 'UniformOutput', false);
        idxClosest = cellfun(@(x, y) x(y), indClosest, iClosest);
        valClosest = cellfun(@(x, y) x(y), valsClosest, iClosest);
    case 'down'
        idxClosest = extract_elements(indClosest, 'last');
        valClosest = extract_elements(valsClosest, 'last');
    case 'up'
        idxClosest = extract_elements(indClosest, 'first');
        valClosest = extract_elements(valsClosest, 'first');
    case 'none'
        valClosest = target(:);
        idxClosest = cellfun(@(x, y, z) interp1(x, y, z), ...
                            valsClosest, indClosest, targetCell);
    otherwise
        error('direction unrecognized!!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%