function empty = create_empty_match (array, varargin)
%% Creates an empty array that matches a given array
% Usage: empty = create_empty_match (array, varargin)
% Explanation:
%       TODO
% Example(s):
%       TODO
% Outputs:
%       empty       - empty array matched to input
% Arguments:
%       array       - input array to match
%       varargin    - 'NRows': number of rows
%                   must be a positive integer scalar
%                   default == size(array, 1)
%                   - 'NColumns': number of columns
%                   must be a positive integer scalar
%                   default == size(array, 2)
%
% Requires:
%       cd/create_error_for_nargin.m
%
% Used by:
%       cd/extract_subvectors.m

% File History:
% 2019-01-03 Moved from extract_subvectors.m
% 

%% Hard-coded parameters

%% Default values for optional arguments
nRowsDefault = [];          % set later
nColumnsDefault = [];       % set later

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(create_error_for_nargin(mfilename));
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add required inputs to the Input Parser
addRequired(iP, 'array');

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'NRows', nRowsDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive', 'integer'}));
addParameter(iP, 'NColumns', nColumnsDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive', 'integer'}));

% Read from the Input Parser
parse(iP, array, varargin{:});
nRows = iP.Results.NRows;
nColumns = iP.Results.NColumns;

%% Preparation
% If not provided, get dimensions
if isempty(nRows)
    nRows = size(array, 1);
end
if isempty(nColumns)
    nColumns = size(array, 2);
end

%% Do the job
% Construct the empty array according to type
if isnumeric(array)
    empty = NaN(nRows, nColumns);
elseif iscell(array)
    empty = cell(nRows, nColumns);
elseif isstruct(array)
    empty = struct(nRows, nColumns);
elseif isdatetime(array)
    empty = NaT(nRows, nColumns);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%