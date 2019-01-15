function varargout = compute_grouped_histcounts (stats, varargin)
%% Computes bin counts and edges from grouped data
% Usage: varargout = compute_grouped_histcounts (stats, grouping (opt), varargin)
% Explanation:
%       This is similar to histcounts() but returns a 2-D array
%           if a grouping vector is provided
% Example(s):
%       randVec = randn(100, 1);
%       stats1 = [randVec, randVec + 1, randVec - 1];
%       compute_grouped_histcounts(stats1)
%       stats2 = [randVec; randVec + 1; randVec - 1];
%       grouping2 = [repmat({'Mark'}, 100, 1); repmat({'Peter'}, 100, 1); repmat({'Katie'}, 100, 1)];
%       compute_grouped_histcounts(stats2, grouping2)
% Outputs:
%       counts      - bin counts, with each group being a different column
%                   specified as a an array of one the following types:
%                       'numeric', 'logical', 'datetime', 'duration'
%       edges       - bin edges used
%                   specified as a vector of one the following types:
%                       'numeric', 'logical', 'datetime', 'duration'
%       binCenters  - bin centers
%                   specified as a vector of one the following types:
%                       'numeric', 'logical', 'datetime', 'duration'
% Arguments:
%       stats       - data to distribute among bins
%                   must be an array of one the following types:
%                       'numeric', 'logical', 'datetime', 'duration'
%       grouping    - (opt) group assignment for each data point
%                   must be an array of one the following types:
%                       'cell', 'string', numeric', 'logical', 
%                           'datetime', 'duration'
%                   default == the column number for a 2D array
%       varargin    - 'Edges': bin edges
%                   must be a vector of one the following types:
%                       'numeric', 'logical', 'datetime', 'duration'
%                   default == automatic detection of 
%                   - Any other parameter-value pair for histcounts()
%
% Requires:
%       cd/compute_bins.m
%       cd/create_default_grouping.m
%       cd/create_error_for_nargin.m
%       cd/struct2arglist.m
%
% Used by:
%       cd/plot_grouped_histogram.m

% File History:
% 2019-01-15 Moved from plot_grouped_histogram.m
% 

%% Hard-coded parameters

%% Default values for optional arguments
groupingDefault = [];           % set later
edgesDefault = [];              % set later

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(create_error_for_nargin(mfilename));
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;
iP.KeepUnmatched = true;                        % allow extraneous options

% Add required inputs to the Input Parser
addRequired(iP, 'stats', ...
    @(x) validateattributes(x, {'numeric', 'logical', ...
                                'datetime', 'duration'}, {'2d'}));

% Add optional inputs to the Input Parser
addOptional(iP, 'grouping', groupingDefault, ...
    @(x) validateattributes(x, {'cell', 'string', 'numeric', 'logical', ...
                                'datetime', 'duration'}, {'2d'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'Edges', edgesDefault, ...
    @(x) validateattributes(x, {'numeric', 'logical', ...
                                'datetime', 'duration'}, {'2d'}));

% Read from the Input Parser
parse(iP, stats, varargin{:});
grouping = iP.Results.grouping;
edges = iP.Results.Edges;

% Keep unmatched arguments for the histcounts() function
otherArguments = struct2arglist(iP.Unmatched);

%% Preparation
% Decide on the grouping vector
grouping = create_default_grouping(stats, grouping);

% Get all unique group values
groupValues = unique(grouping);

% Count the number of groups
nGroups = numel(groupValues);

%% Break up stats into a cell array of vectors
statsCell = arrayfun(@(x) stats(grouping == groupValues(x)), ...
                    transpose(1:nGroups), 'UniformOutput', false);

%% Compute default bin edges for all data if not provided
if isempty(edges)
    % Compute bin edges for each group
    [~, edgesAll] = ...
        cellfun(@(x) compute_bins(x, 'Edges', edges, otherArguments{:}), ...
                                    statsCell, 'UniformOutput', false);

    % Compute the minimum bin width across groups
    minBinWidth = min(extract_elements(edgesAll, 'firstdiff'));

    % Compute the minimum and maximum edges across groups
    minEdges = min(extract_elements(edgesAll, 'first'));
    maxEdges = max(extract_elements(edgesAll, 'last'));

    % Compute the range of edges
    rangeEdges = maxEdges - minEdges;

    % Compute the number of bins
    nBins = ceil(rangeEdges / minBinWidth);

    % Create bin edges that works for all data
    edges = transpose(linspace(minEdges, maxEdges, nBins));
end

%% Compute the bin counts for each group based on these edges
counts = cellfun(@(x) compute_bins(x, 'Edges', edges, otherArguments{:}), ...
                    statsCell, 'UniformOutput', false);
counts = horzcat(counts{:});

%% Compute the bin centers
if nargout >= 3
    binCenters = mean([edges(1:end-1), edges(2:end)], 2);
end

%% Outputs
varargout{1} = counts;
varargout{2} = edges;
if nargout >= 3
    varargout{3} = binCenters;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%