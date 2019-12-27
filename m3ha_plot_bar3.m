function [output1] = m3ha_plot_bar3 (statsPath, varargin)
%% Plots 3-dimensional bar plots from a statistics table returned by m3ha_compute_statistics.m
% Usage: [output1] = m3ha_plot_bar3 (statsPath, varargin)
% Explanation:
%       TODO
%
% Example(s):
%       TODO
%
% Outputs:
%       output1     - TODO: Description of output1
%                   specified as a TODO
%
% Arguments:
%       statsPath  - a statistics table returned by m3ha_compute_statistics.m
%                   must be a table
%       varargin    - 'RowsToPlot': rows to extract
%                   must be a numeric array,
%                       a string scalar or a character vector, 
%                       or a cell array of character vectors
%                   default == 'all' (no restrictions)
%                   - 'OutFolder': the directory where plots will be placed
%                   must be a string scalar or a character vector
%                   default == pwd
%                   - Any other parameter-value pair for bar3()
%
% Requires:
%       cd/create_error_for_nargin.m
%       cd/struct2arglist.m
%       TODO:
%       cd/combine_strings.m
%       cd/decide_on_colormap.m
%       cd/extract_fileparts.m
%       cd/ispositiveintegervector.m
%       cd/save_all_figtypes.m
%       cd/set_figure_properties.m
%       cd/update_figure_for_corel.m
%
% Used by:
%       /TODO:dir/TODO:file

% File History:
% 2019-12-27 Moved from m3ha_plot_figure02.m
% 

%% Hard-coded parameters
bar3FigHeight = 6;              % in centimeters
bar3FigWidth = 6;               % in centimeters
figTypes = {'png', 'epsc2'};

%% Default values for optional arguments
rowsToPlotDefault = 'all';
outFolderDefault = '';          % set later

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
addRequired(iP, 'statsPath', ...
    @(x) validateattributes(x, {'table'}, {'2d'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'RowsToPlot', rowsToPlotDefault, ...
    @(x) assert(ispositiveintegervector(x) || iscellstr(x) || isstring(x), ...
                ['RowsToPlot must be either a positive integer vector, ', ...
                    'a string array or a cell array of character arrays!']));
addParameter(iP, 'OutFolder', outFolderDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));

% Read from the Input Parser
parse(iP, statsPath, varargin{:});
rowsToPlot = iP.Results.RowsToPlot;
outFolder = iP.Results.OutFolder;

% Keep unmatched arguments for the bar3() function
otherArguments = struct2arglist(iP.Unmatched);

%% Preparation
% Set default output directory
if isempty(outFolder)
    outFolder = extract_fileparts(statsPath, 'directory');
end

% Load stats table
disp('Loading statistics for 3D bar plots ...');
load(statsPath, 'statsTable', 'pharmLabels', 'gIncrLabels', 'conditionLabel');

% Extract variables
allMeasureTitles = statsTable.measureTitle;
allMeasureStrs = statsTable.measureStr;
allMeanValues = statsTable.meanValue;
allUpper95Values = statsTable.upper95Value;

% Create figure bases
allFigBases3D = combine_strings({allMeasureStrs, conditionLabel});

% Create full path bases
allFigPathBases3D = fullfile(outFolder, allFigBases3D);

%% Do the job
% Plot all 3D bar plots
disp('Plotting 3D bar plots ...');
handles = cellfun(@(a, b, c, d) m3ha_plot_bar3_helper(a, b, c, ...
                                pharmLabels, gIncrLabels, ...
                                d, bar3FigHeight, bar3FigWidth, ...
                                figTypes, otherArguments), ...
                allMeanValues, allUpper95Values, ...
                allMeasureTitles, allFigPathBases3D);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles = m3ha_plot_bar3_helper(meanValue, upper95Value, ...
                        measureTitle, pharmLabels, gIncrLabels, ...
                        figPathBase, figHeight, figWidth, figTypes, ...
                        otherArguments)

% Create figure for conductance traces
fig = set_figure_properties('AlwaysNew', true);

% Flip the g incr axis
[meanValue, upper95Value, gIncrLabels] = ...
    argfun(@fliplr, meanValue, upper95Value, gIncrLabels);

% Set x and y tick labels
xTickLabels = pharmLabels;
yTickLabels = gIncrLabels;

% TODO: Add the following to plot_bar.m?
% Hard-coded parameters
relativeBarWidth = 0.2;
xTickAngle = 320;
barSeparation = 1;

% Decide on the color map
cm = decide_on_colormap([], 4);

% Set the color map
colormap(cm);

% Prepare for bar3
meanValueTransposed = transpose(meanValue);
upper95ValueTransposed = transpose(upper95Value);

% Plot the means as bars
bars = bar3(meanValueTransposed, relativeBarWidth, 'detached', ...
            otherArguments{:});

% Plot error bars
% TODO: Incorporate into plot_error_bar.m?

% Set the relative error bar width to be the same as the bars themselves
%   Note: error bar width must not exceed the bar width, 
%           otherwise the edges would be cut off
relativeErrorBarWidth = relativeBarWidth;

% Compute the actual error bar width
errorBarWidth = relativeErrorBarWidth * barSeparation;

% Compute the x and y values corresponding to each data point
[xValues, yValues] = meshgrid(1:numel(xTickLabels), 1:numel(yTickLabels));

% Compute the left and right positions of the horizontal parts of the error bars
xPosBarLeft = xValues - errorBarWidth / 2;
xPosBarRight = xValues + errorBarWidth / 2;

% Plot the vertical part of the error bars
errorBarVert = ...
    arrayfun(@(a, b, c, d, e, f) line([a, b], [c, d], [e, f], 'Color', 'k'), ...
            xValues, xValues, yValues, yValues, ...
            meanValueTransposed, upper95ValueTransposed);

% Plot the horizontal part of the error bars
errorBarHorz = ...
    arrayfun(@(a, b, c, d, e, f) line([a, b], [c, d], [e, f], 'Color', 'k'), ...
            xPosBarLeft, xPosBarRight, yValues, yValues, ...
            upper95ValueTransposed, upper95ValueTransposed);

% Plot z axis label
zlabel(measureTitle);

% Set x tick labels
set(gca, 'XTickLabel', xTickLabels);

% Set x tick angle
xtickangle(xTickAngle);

% Set y tick labels
set(gca, 'YTickLabel', yTickLabels);

% Update figure for CorelDraw
update_figure_for_corel(fig, 'Units', 'centimeters', ...
                        'Height', figHeight, 'Width', figWidth);

% Save the figure
save_all_figtypes(fig, figPathBase, figTypes);

% Save in handles
handles.fig = fig;
handles.bars = bars;
handles.errorBarVert = errorBarVert;
handles.errorBarHorz = errorBarHorz;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%