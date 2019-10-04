function [handles, handlesMean] = plot_chevron (data, varargin)
%% Plots a Chevron (paired comparison) plot from data
% Usage: [handles, handlesMean] = plot_chevron (data, varargin)
% Explanation:
%       TODO
%
% Example(s):
%       randVec1 = randi(10, 10, 1);
%       randVec2 = randi(10, 10, 1) + 10;
%       data = [randVec1, randVec2];
%       plot_chevron(data)
%
% Outputs:
%       handles     - handles to plotted objects for the data
%                   specified as a structure
%       handlesMean - handles to plotted objects for the mean difference
%                   specified as a structure
%
% Arguments:
%       data        - data table or data vectors
%                   must be a table or a numeric array
%                       or a cell array of numeric vectors
%       varargin    - 'PlotMean': whether to plot the mean difference
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'RunTTest': whether to run paired t-test
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'RunRankTest': whether to run paired 
%                                       Wilcoxon signed-rank test
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'PLimits': limits of parameter axis
%                               suppress by setting value to 'suppress'
%                   must be 'suppress' or a 2-element increasing numeric vector
%                   default == set in compute_paxis_limits_chevron()
%                   - 'PTicks': x tick values for the parameter values
%                   must be a numeric vector
%                   default == all parameter values
%                   - 'PTickLabels': x tick labels in place of parameter values
%                   must be a cell array of character vectors/strings
%                   default == table column names or time1, time2, ...
%                   - 'PLabel': label for the parameter, 
%                               suppress by setting value to {'suppress'}
%                   must be a string scalar or a character vector
%                   default == 'suppress'
%                   - 'ColumnLabels': labels for the readout columns, 
%                               suppress by setting value to {'suppress'}
%                   must be a scalartext 
%                       or a cell array of strings or character vectors
%                   default == table row names or data1, data2, ...
%                   - 'ColorMap' - color map used when nColumnsToPlot > 1
%                   must be a 2-D numeric array with 3 columns
%                   default == set in decide_on_colormap.m
%                   - 'LegendLocation': location for legend
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'auto'      - use default
%                       'suppress'  - no legend
%                       anything else recognized by the legend() function
%                   default == 'eastoutside'
%                   - 'FigExpansion': expansion factor for figure position
%                   must be a must be a positive scalar or 2-element vector
%                   default == [1, 0.4]
%                   - Any other parameter-value pair for plot_tuning_curve()
%
% Requires:
%       cd/argfun.m
%       cd/compute_stats.m
%       cd/create_error_for_nargin.m
%       cd/create_labels_from_numbers.m
%       cd/force_matrix.m
%       cd/hold_off.m
%       cd/hold_on.m
%       cd/plot_tuning_curve.m
%
% Used by:
%       cd/plot_relative_events.m

% File History:
% 2019-10-01 Created by Adam Lu
% 2019-10-03 Made many things optional arguments
% TODO: Combine with plot_table.m?

%% Hard-coded parameters
lineWidth = 1;
markerSize = 4;
meanLineWidth = 2;
meanMarkSize = 6;
meanColorMap = 'r';

%% Default values for optional arguments
plotMeanDefault = true;
runTTestDefault = true;
runRankTestDefault = true;
pLimitsDefault = [];                % set later
pTicksDefault = [];                 % set later
pTickLabelsDefault = {};            % set later
pLabelDefault = 'suppress';
columnLabelsDefault = '';           % set later
colorMapDefault = [];               % set later
legendLocationDefault = 'eastoutside';
figExpansionDefault = [1, 0.6];

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
addRequired(iP, 'data', ...
    @(x) validateattributes(x, {'numeric', 'cell', 'table'}, {'2d'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'PlotMean', plotMeanDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'RunTTest', runTTestDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'RunRankTest', runRankTestDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PLimits', pLimitsDefault, ...
    @(x) isempty(x) || ischar(x) && strcmpi(x, 'suppress') || ...
        isnumeric(x) && isvector(x) && length(x) == 2);
addParameter(iP, 'PTicks', pTicksDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'PTickLabels', pTickLabelsDefault, ...
    @(x) isempty(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'PLabel', pLabelDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'ColumnLabels', columnLabelsDefault, ...
    @(x) ischar(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'ColorMap', colorMapDefault);
addParameter(iP, 'LegendLocation', legendLocationDefault, ...
    @(x) all(islegendlocation(x, 'ValidateMode', true)));
addParameter(iP, 'FigExpansion', figExpansionDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'positive'}));

% Read from the Input Parser
parse(iP, data, varargin{:});
plotMean = iP.Results.PlotMean;
runTTest = iP.Results.RunTTest;
runRankTest = iP.Results.RunRankTest;
pLimits = iP.Results.PLimits;
pTicks = iP.Results.PTicks;
pTickLabels = iP.Results.PTickLabels;
pLabel = iP.Results.PLabel;
columnLabels = iP.Results.ColumnLabels;
colorMap = iP.Results.ColorMap;
[~, legendLocation] = islegendlocation(iP.Results.LegendLocation, ...
                                        'ValidateMode', true);
figExpansion = iP.Results.FigExpansion;

% Keep unmatched arguments for the plot_tuning_curve() function
otherArguments = iP.Unmatched;

%% Preparation
% Decide on data values
if istable(data)
    % Extract values
    dataValues = table2array(data);
else
    % Force as a matrix
    dataValues = force_matrix(data, 'AlignMethod', 'leftadjustpad');
end

% Count the number of conditions
nConds = size(dataValues, 2);

% Count the number of samples
nSamples = size(dataValues, 1);

% Decide on a color map
if isempty(colorMap)
    colorMap = decide_on_colormap(colorMap, nSamples);
end

% Compute parameter values for the plot
pValues = transpose(1:nConds);

% Compute parameter axis limits
if isempty(pLimits)
    pLimits = compute_paxis_limits_chevron(pValues);
end

% Decide on parameter tick values
if isempty(pTicks)
    pTicks = pValues;
end

% Decide on parameter tick labels
if isempty(pTickLabels)
    if istable(data)
        % Extract variable names if any
        pTickLabels = data.Properties.VariableNames;
    else
        % Create labels
        pTickLabels = create_labels_from_numbers(pValues, 'Prefix', 'param');
    end
end

% Decide on column labels
if isempty(columnLabels)
    if istable(data) && ~isempty(data.Properties.RowNames)
        % Extract row names if any
        columnLabels = data.Properties.RowNames;
    else
        % Create labels
        columnLabels = create_labels_from_numbers(1:nSamples, 'Prefix', 'data');
    end
end

% Compute means and confidence intervals
if nConds == 2
    % Compute the mean of the baseline values
    baseMean = compute_stats(dataValues(:, 1), 'mean');

    % Compute the differences
    diffValues = dataValues(:, 2) - dataValues(:, 1);

    % Compute the mean and confidence intervals of the differences
    [diffMean, diffLower95, diffUpper95] = ...
        argfun(@(x) compute_stats(diffValues, x), 'mean', 'lower95', 'upper95');

    % Compute the values to plot
    [meanValues, lower95Values, upper95Values] = ...
        argfun(@(x) baseMean + [0; x], diffMean, diffLower95, diffUpper95);
end

%% Do the job
% Plot a tuning curve
handles = plot_tuning_curve(pValues, transpose(dataValues), ...
                    'RunTTest', runTTest, 'RunRankTest', runRankTest, ...
                    'PLimits', pLimits, 'PTicks', pTicks, ...
                    'PTickLabels', pTickLabels, 'PLabel', pLabel, ...
                    'ColumnLabels', columnLabels, ...
                    'ColorMap', colorMap, ...
                    'LegendLocation', legendLocation, ...
                    'FigExpansion', figExpansion, ...
                    'LineWidth', lineWidth, ...
                    'Marker', 'o', 'MarkerSize', markerSize, ...
                    otherArguments);

% Plot the mean and confidence intervals of the differences
%   TODO: Does it ever make sense for more than 2 conditions?
if plotMean && nConds == 2
    % Hold on
    wasHold = hold_on;

    % Plot mean and confidence intervals
    handlesMean = plot_tuning_curve(pValues, meanValues, 'PlotOnly', true, ...
                    'LowerCI', lower95Values, 'UpperCI', upper95Values, ...
                    'LineWidth', meanLineWidth, 'ColorMap', meanColorMap, ...
                    'Marker', 'o', 'MarkerFaceColor', meanColorMap, ...
                    'MarkerSize', meanMarkSize);

    % Hold off
    hold_off(wasHold);
else
    handlesMean = struct;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xLimits = compute_paxis_limits_chevron (tickValues)
%% Computes x axis limits for Chevron plots

% Hard-coded parameters
marginPercentage = 25;          % 25% margins

% Compute the mean difference between ticks
meanTickInt = mean(diff(tickValues));

% Compute x axis limits
xLimits = [tickValues(1), tickValues(end)] + ...
            (marginPercentage / 100) * meanTickInt * [-1, 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

% Compute the mean, lower and upper confidence interval bounds
[means, lower95s, upper95s] = ...
    argfun(@(x) compute_stats(dataValues, x), 'mean', 'lower95', 'upper95');

% Plot the means
plot(pValues, means, 'r-o', ...
    'LineWidth', meanLineWidth, 'MarkerSize', meanMarkSize, ...
    'MarkerFaceColor', meanColorMap);

% Plot error bars
plot_error_bar(pValues, lower95s, upper95s, 'Color', meanColorMap, ...
                'LineWidth', meanLineWidth);

% Plot a star if significant
plotStar = false;
if plotStar
    starXPos = mean(pValues);
    yLimits = get(gca, 'YLim');
    starYPos = yLimits(1) + 0.8 * (yLimits(2) - yLimits(1));
    plot(starXPos, starYPos, 'k*');
end

colorMap = [0, 0, 0];

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%