function [bars, fig] = plot_histogram_with_outliers (X, varargin)
%% Plots a histogram labelling out of range values differently
% Usage: [bars, fig] = plot_histogram_with_outliers (X, varargin)
% Explanation:
%       Automatically combines the counts of X outside of the finite range 
%           of edges on the left or on the right to a bin on the left or 
%           on the right, respectively.
%       Note: The bar() function is used for the main histogram
%               unless 'UseBuiltIn' is set to true
% Example(s):
%       plot_histogram_with_outliers([0, 4, 5, 4, 5, 10])
% Outputs:
%       bars        - handles to Bar objects
%                       bars(1:nGroups) - main histogram
%                       bars(nGroups+1) - left out of range bar if any
%                       bars(nGroups+2) - right out of range bar if any
%                   specified as a Bar object array
%       fig         - figure handle for the created figure
%                   specified as a figure object handle
% Side Effects:
%       Plots a histogram
% Arguments:
%       X           - data to distribute among bins
%                   must be an array of one the following types:
%                       'numeric', 'logical', 'datetime', 'duration'
%       varargin    - 'PlotOutliers': whether to plot outliers separately
%                   must be logical 1 (true) or 0 (false)
%                   default == true
%                   - 'UseBuiltIn': whether to use built in histogram() function
%                                   Note: this will not work if data is grouped
%                   must be logical 1 (true) or 0 (false)
%                   default == false
%                   - 'Counts': bin counts, with each group 
%                                   being a different column
%                   must be an array of one the following types:
%                       'numeric', 'logical', 'datetime', 'duration'
%                   default == returned by compute_grouped_histcounts(stats)
%                   - 'Edges': bin edges
%                   must be a vector of one the following types:
%                       'numeric', 'logical', 'datetime', 'duration'
%                   default == returned by compute_grouped_histcounts(stats)
%                   - 'Grouping': group assignment for each data point
%                   must be an array of one the following types:
%                       'cell', 'string', numeric', 'logical', 
%                           'datetime', 'duration'
%                   default == the column number for a 2D array
%                   - 'SpecialColor': color of expanded bins
%                   must be a 3-element numeric vector:
%                   default == [0 0.8 0.8] (light blue)
%                   - 'XLimits': x-axis limits
%                   must be a two element vector of one the following types:
%                       'numeric', 'logical''datetime', 'duration'
%                   default == minimum and maximum edges of bins
%                   - 'OutlierMethod': method for determining outliers
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'boxplot'   - same as the Matlab function boxplot()
%                       'isoutlier' - Use the built-in isoutlier function
%                       'fiveStds'  - Take out data points 
%                                       more than 5 standard deviations away
%                       'threeStds' - Take out data points 
%                                       more than 3 standard deviations away
%                       'twoStds'   - Take out data points 
%                                       more than 2 standard deviations away
%                   default == 'isoutlier'
%                   - 'FigHandle': figure handle for created figure
%                   must be a empty or a figure object handle
%                   default == []
%                   - Any other parameter-value pair for the bar() function
%
% Requires:
%       cd/compute_grouped_histcounts.m
%       cd/create_error_for_nargin.m
%       cd/plot_grouped_histogram.m
%       cd/remove_outliers.m
%
% Used by:    
%       TODO /home/Matlab/Marks_Functions/paula/Oct2017/zgRasterFigureMaker.m
%       TODO /media/adamX/m3ha/data_dclamp/initial_slopes.m
%
% File History:
% 2017-12-12 Created by Adam Lu
% 2018-06-05 Made edges an optional parameter and make the default dependent
%               on the isoutlier() and histcounts() functions
% 2018-06-11 Now uses the remove_outliers.m function
% 2019-01-15 Now uses plot_grouped_histogram.m by default
%               and added 'UseBuiltIn' as an optional parameter (default false)
% 2019-01-15 Made 'PlotOutliers' an optional parameter with default true
%       and rename as just plot_histogram.m

%% Hard-coded parameters
validOutlierMethods = {'boxplot', 'isoutlier', ...
                        'fiveStds', 'threeStds', 'twoStds'};

%% Default values for optional arguments
plotOutliersDefault = false;            % don't ignore case by default
useBuiltInDefault = false;              % don't ignore case by default
countsDefault = [];                     % set later
edgesDefault = [];                      % set later
groupingDefault = [];                   % set later
xLimitsDefault = [];                    % set later
specialColorDefault = [0, 0.8, 0.8];    % light blue
outlierMethodDefault = 'isoutlier';     % use built-in isoutlier function
figHandleDefault = [];                  % no existing figure by default

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
addRequired(iP, 'X', ...                        % data to distribute among bins
    @(x) validateattributes(x, {'numeric', 'logical', ...
                                'datetime', 'duration'}, {'2d'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'Counts', countsDefault, ...
    @(x) validateattributes(x, {'numeric', 'logical', ...
                                'datetime', 'duration'}, {'2d'}));
addParameter(iP, 'Edges', edgesDefault, ...
    @(x) validateattributes(x, {'numeric', 'logical', ...
                                'datetime', 'duration'}, {'2d'}));
addParameter(iP, 'Grouping', groupingDefault, ...
    @(x) validateattributes(x, {'cell', 'string', 'numeric', 'logical', ...
                                'datetime', 'duration'}, {'2d'}));
addParameter(iP, 'PlotOutliers', plotOutliersDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'UseBuiltIn', useBuiltInDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'SpecialColor', specialColorDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
addParameter(iP, 'XLimits', xLimitsDefault, ...
    @(x) validateattributes(x, {'numeric', 'categorical', ...
        'datetime', 'duration'}, {'vector', 'numel', 2}));
addParameter(iP, 'OutlierMethod', outlierMethodDefault, ...
    @(x) any(validatestring(x, validOutlierMethods)));
addParameter(iP, 'FigHandle', figHandleDefault);

% Read from the Input Parser
parse(iP, X, varargin{:});
plotOutliers = iP.Results.PlotOutliers;
useBuiltIn = iP.Results.UseBuiltIn;
counts = iP.Results.Counts;
edges = iP.Results.Edges;
grouping = iP.Results.Grouping;
xLimits = iP.Results.XLimits;
specialColor = iP.Results.SpecialColor;
outlierMethod = validatestring(iP.Results.OutlierMethod, validOutlierMethods);
figHandle = iP.Results.FigHandle;

% Keep unmatched arguments for the bar() or histogram() function
otherArguments = struct2arglist(iP.Unmatched);

%% Prepare
% Get the current MATLAB release
matlabRelease = version('-release');

% Get the current MATLAB release year
matlabYear = str2num(matlabRelease(1:4));

%% Identify edges if not provided
if isempty(edges)
    % Remove outliers if any
    XTrimmed = remove_outliers(X, 'OutlierMethod', outlierMethod);

    % Use compute_grouped_histcounts to find the proper bin edges
    [~, edges] = compute_grouped_histcounts(XTrimmed);
end

%% Create histogram
% Extract finite part of edges
edgesFinite = edges(isfinite(edges));

% Expand edges
if iscolumn(edgesFinite)
    edgesExpanded = [-Inf; edgesFinite; Inf];
else
    edgesExpanded = [-Inf, edgesFinite, Inf];
end

% Compute histogram bincounts with expanded edges
%   Note: the first bin is always < the first non-Inf number in edges
%   Note: the last bin is always >= the last non-Inf number in edges
counts = compute_grouped_histcounts(X, edgesExpanded);

% Check for out of range data and adjust the bincounts and edges
expandedOnTheLeft = false;  % whether histogram will be expanded on the left
expandedOnTheRight = false; % whether histogram will be expanded on the right
if (counts(1) > 0 || edges(1) == -Inf) && (counts(end) > 0 || edges(end) == Inf)
        % if data out of range or user specifies so on both sides
    % Histogram will be expanded on both sides
    expandedOnTheLeft = true;
    expandedOnTheRight = true;

    % The new edges are simply the expanded edges
    edgesNew = edgesExpanded;
elseif counts(1) > 0 || edges(1) == -Inf
        % if data out of range or user specifies so on the left side only
    % Histogram will be expanded on the left
    expandedOnTheLeft = true;

    % Remove the last bin
    counts(end) = [];

    % The new edges excludes Inf
    edgesNew = edgesExpanded(1:end-1);
elseif counts(end) > 0 || edges(end) == Inf
        % if data out of range or user specifies so on the right side only
    % Histogram will be expanded on the right
    expandedOnTheRight = true;

    % Remove the first bin
    counts(1) = [];

    % The new edges excludes -Inf
    edgesNew = edgesExpanded(2:end);
else    % if no data out of range
    % Remove the first and last bins
    counts(1) = [];
    counts(end) = [];

    % The new edges excludes -Inf and Inf
    edgesNew = edgesExpanded(2:end-1);
end

% The left edges of the histogram exclude the last edge
leftEdges = edgesNew(1:end-1);

% Determine the left edges for plotting 
%   If expanded to the left, replace -Inf with a finite left edge
leftEdgesPlot = leftEdges;          % initialize to be the same as left edges
if edgesNew(1) == -Inf              % data out of range on the left
    % Use the left most finite bin width to set the width for the first bin
    leftMostBinWidth = edgesExpanded(3) - edgesExpanded(2);

    % Update the left edge of the first bin
    leftEdgesPlot(1) = leftEdges(2) - leftMostBinWidth;
end

% Determine the right edge of the histogram
if edgesNew(end) == Inf             % data out of range on the right
    % OBSERVATION: The right most finite bin width is used 
    %   by bar() to set the width for the last bin
    rightMostBinWidth = edgesNew(end-1) - edgesNew(end-2);
    
    % Update the right edge of the last bin
    rightMostEdgePlot = edgesNew(end-1) + rightMostBinWidth;
else                                % nothing out of range on the right
    % The right most edge is the right most finite edge
    rightMostEdgePlot = edgesNew(end);
end

% Update edges for plotting
if iscolumn(edgesNew)
    edgesPlot = [leftEdgesPlot; rightMostEdgePlot];
else
    edgesPlot = [leftEdgesPlot, rightMostEdgePlot];
end

% Set xLimits if not specified
if isempty(xLimits)
    xLimits = [edgesPlot(1), edgesPlot(end)];
end

% Plot histogram
if useBuiltIn
    if matlabYear >= 2017
        % Plot histogram with histogram()
        bars = histogram('BinEdges', edgesPlot, 'BinCounts', counts, ...
                      'DisplayName', 'data', otherArguments{:});
                                        % available for R2017a and beyond
    else
        % Plot histogram by using the bar() function in the 'histc' style
        bars = bar(leftEdgesPlot, counts, 'histc', ...
                'DisplayName', 'data', otherArguments{:});
    end
else
    % Allow the option to plot a grouped histogram
    [bars, fig] = ...
        plot_grouped_histogram('Counts', counts, 'Edges', edgesPlot, ...
                                'FigHandle', figHandle, otherArguments{:});
end

% Count the number of bars plotted
nGroups = numel(bars);

% Initialize XTick locations with current locations
xTicks = get(gca, 'XTick'); 

% Remove XTicks that are beyond finite range of edges
%   and initialize XTickLabels with these numbers
xTicks = xTicks(xTicks >= edgesFinite(1));
xTicks = xTicks(xTicks <= edgesFinite(end));
xTickLabelNums = xTicks;

% Update xTicks to include where -Inf and Inf would be placed
if edgesNew(1) == -Inf              % data out of range on the left
    % Add -Inf as first XTick at edgesPlot(1)
    xTicks = [edgesPlot(1), xTicks];
    xTickLabelNums = [-Inf, xTickLabelNums];
end
if edgesNew(end) == Inf              % data out of range on the right
    % Add Inf as last XTick at edgesPlot(end)
    xTicks = [xTicks, edgesPlot(end)];
    xTickLabelNums = [xTickLabelNums, Inf];
end
set(gca, 'XTick', xTicks);
% xticks(xTicks);               % valid for R2016a and beyond

% Update xTickLabels using xTickLabelNums
if iscolumn(xTickLabelNums)
    xTickLabels = cellfun(@num2str, mat2cell(xTickLabelNums, ...
                    ones(1, length(xTickLabelNums), 1)), ...
                    'UniformOutput', false);
else
    xTickLabels = cellfun(@num2str, mat2cell(xTickLabelNums, ...
                    1, ones(1, length(xTickLabelNums))), ...
                    'UniformOutput', false);
end
set(gca, 'XTickLabel', xTickLabels);
% xticklabels(xTickLabels);     % valid for R2016a and beyond

% Change bar color of expanded bins to special color
if ~ishold
    hold on;
    wasHold = false;
else
    wasHold = true;
end
if xTickLabelNums(1) == -Inf
    if useBuiltIn
        bars(nGroups + 1) = ...
            histogram(edgesPlot(1) * ones(1, counts(1)), ...
                        edgesPlot(1:2), ...
                        'FaceAlpha', 1, 'FaceColor', specialColor, ...
                        'DisplayName', 'data too small', otherArguments{:});
    else
        bars(nGroups + 1) = ...
            bar(mean(edgesPlot(1:2)), counts(1), ...
                        'FaceAlpha', 1, 'FaceColor', specialColor, ...
                        'DisplayName', 'data too small', otherArguments{:});
    end
else
    bars(nGroups + 1) = gobjects(1);
end
if xTickLabelNums(end) == Inf
    if useBuiltIn
        bars(nGroups + 2) = ...
            histogram(edgesPlot(end-1) * ones(1, counts(end)), ...
                        edgesPlot(end-1:end), ...
                        'FaceAlpha', 1, 'FaceColor', specialColor, ...
                        'DisplayName', 'data too large', otherArguments{:});
    else
        bars(nGroups + 2) = ...
            bar(mean(edgesPlot(end-1:end)), counts(end), ...
                        'FaceAlpha', 1, 'FaceColor', specialColor, ...
                        'DisplayName', 'data too large', otherArguments{:});
    end
else
    bars(nGroups + 2) = gobjects(1);
end
if ~wasHold
    hold off;
end

% Update x axis limits
xlim(xLimits);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

if isempty(xTicks)
    xTicks = edgesPlot;
end

% Expand edges
edgesExpanded = edges;
if edgesExpanded(1) ~= -Inf
    if iscolumn(edgesExpanded)
        edgesExpanded = [-Inf; edgesExpanded];
    else
        edgesExpanded = [-Inf, edgesExpanded];
    end
end
if edgesExpanded(end) ~= Inf
    if iscolumn(edgesExpanded)
        edgesExpanded = [edgesExpanded; Inf];
    else
        edgesExpanded = [edgesExpanded, Inf];
    end
end

% Initialize flags

if edgesNew(1) == -Inf              % data out of range on the left
    if ismember(edgesPlot(1), xTicks)   % xTicks already include the left end
        % First XTickLabel should be -Inf
        xTickLabelNums(1) = -Inf;
    else
        % Need to add -Inf as first XTick at edgesPlot(1)
        xTicks = [edgesPlot(1), xTicks];
        xTickLabelNums = [-Inf, xTickLabelNums];
    end
end
if edgesNew(end) == Inf              % data out of range on the right
    if ismember(edgesPlot(end), xTicks) % xTicks already include the right end
        % Last XTickLabel should be Inf
        xTickLabelNums(end) = Inf;
    else
        % Need to add Inf as last XTick at edgesPlot(end)
        xTicks = [xTicks, edgesPlot(end)];
        xTickLabelNums = [xTickLabelNums, Inf];
    end
end

if matlabYear >= 2017
    b.CData(1, :) = specialColor;      % valid for at least R2017a
end
if matlabYear >= 2017
    b.CData(1, :) = specialColor;      % valid for at least R2017a
end

nStds = str2double(outlierMethod(1));

%       bars           - the histogram returned as a Bar object
%                   specified as a Patch (R2015a) or Bar (R2017a) object
%       h1          - the histogram for the isolated expanded left bar if exists
%                   specified as a Histogram object
%       h2          - the histogram for the isolated expanded right bar if exists
%                   specified as a Histogram object

% Use the built-in histcounts function to find the proper bin edges
[~, edges] = histcounts(XTrimmed);
counts = histcounts(X, edgesExpanded);

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
