function subVecs = extract_subvectors (vecs, varargin)
%% Extracts subvectors from vectors, given either endpoints or value windows
% Usage: subVecs = extract_subvectors (vecs, varargin)
% Explanation:
%       TODO
% Example(s):
%       subVecs1 = extract_subvectors({1:5, 2:6}, 'Endpoints', [1, 3])
%       subVecs2 = extract_subvectors({1:5, 2:6}, 'Endpoints', {[1, 3], [2, 4]})
%       subVecs3 = extract_subvectors(1:5, 'Endpoints', {[1, 3], [2, 4]})
%       subVecs4 = extract_subvectors({1:5, 2:6}, 'Windows', [2.5, 6.5])
% Outputs:
%       subVecs     - subvectors extracted
%                   specified as a numeric vector 
%                       or a cell array of numeric vectors
% Arguments:
%       vecs        - vectors to extract
%                   must be a numeric vector or a cell array of numeric vectors
%       varargin    - 'Endpoints': endpoints for the subvectors to extract 
%                   must be a numeric vector with 2 elements
%                       or a cell array of numeric vectors with 2 elements
%                   default == find_window_endpoints([], vecs)
%                   - 'Windows': value windows to extract 
%                       Note: this assumes that the values are nondecreasing
%                   must be empty or a numeric vector with 2 elements,
%                       or a numeric array with 2 rows
%                       or a cell array of numeric arrays
%                   default == []
%
% Requires:
%       cd/isnumericvector.m
%       cd/iscellnumericvector.m
%       cd/find_window_endpoints.m
%
% Used by:
%       cd/compute_rms_error.m
%       cd/compute_single_neuron_errors.m
%       cd/compute_sweep_errors.m

% File History:
% 2018-10-28 Created by Adam Lu
% 

%% Hard-coded parameters

%% Default values for optional arguments
endPointsDefault = [];          % set later
windowsDefault = [];            % extract entire trace(s) by default

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(['Not enough input arguments, ', ...
            'type ''help %s'' for usage'], mfilename);
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add required inputs to the Input Parser
addRequired(iP, 'vecs', ...                  % vectors to extract
    @(x) assert(isnumericvector(x) || iscellnumericvector(x), ...
                ['vecs must be either a numeric vector ', ...
                    'or a cell array of numeric vectors!']));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'EndPoints', endPointsDefault, ...
    @(x) assert(isnumericvector(x) || iscellnumericvector(x), ...
                ['EndPoints must be either a numeric vector ', ...
                    'or a cell array of numeric vectors!']));
addParameter(iP, 'Windows', windowsDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['Windows must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));

% Read from the Input Parser
parse(iP, vecs, varargin{:});
endPoints = iP.Results.EndPoints;
windows = iP.Results.Windows;

% If endPoints provided and windows also provided, display warning
if ~isempty(endPoints) && ~isempty(windows)
    fprintf('Windows will be ignored because end points are provided!\n');
end

% TODO: check if all endpoints have 2 elements

%% Preparation
% Find default end points if not provided
% TODO: check if vecs are nondecreasing
if isempty(endPoints)
    % Extract the start and end indices of the vectors for fitting
    %   Note: If first argument is empty, 
    %           the first and last indices will be returned
    endPoints = find_window_endpoints(windows, vecs);
end

% Match the formats of endPoints and timeVecs so that cellfun can be used
[endPoints, vecs] = ...
    match_format_vectors(endPoints, vecs, 'ForceCellOutputs', false);

%% Do the job
if iscell(vecs)
    subVecs = cellfun(@(x, y) extract_subvectors_helper(x, y), ...
                        vecs, endPoints, 'UniformOutput', false);
else
    subVecs = extract_subvectors_helper(vecs, endPoints);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function subVec = extract_subvectors_helper (vec, endPoints)
%% Extract a subvector from a vector if not empty

if isempty(vec)
    subVec = vec;
else
    subVec = vec(endPoints(1):endPoints(2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%