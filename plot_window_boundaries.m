function h = plot_window_boundaries (win, varargin)
%% Plots window boundaries as vertical lines
% Usage: h = plot_window_boundaries (win, varargin)
% Explanation:
%       TODO
%
% Example(s):
%       figure(2); clf; load_examples; plot(myTimeVec, myRandomSignals1)
%       plot_window_boundaries([5 10 20 25])
%       plot_window_boundaries([1 2 3], 'BoundaryType', 'horizontalLines')
%       plot_window_boundaries([1.5 2 3 3.5], 'BoundaryType', 'verticalBars') TODO
%       plot_window_boundaries([5 10 20 25], 'BoundaryType', 'horizontalBars')
%       plot_window_boundaries([5 10 20 25], 'BoundaryType', 'verticalShades') TODO
%       plot_window_boundaries([2 3], 'BoundaryType', 'horizontalShades')
%
% Outputs:
%       h           - handles to each line object (left, right)
%                   specified as a 2-element column array 
%                       of primitive line object handles
% Arguments:
%       win         - window(s) to plot boundaries for
%                   must be a numeric vector
%       varargin    - 'BoundaryType': type of boundaries
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'verticalLines'     - vertical dotted lines
%                       'horizontalLines'   - horizontal dotted lines
%                       'verticalBars'      - vertical bars
%                       'horizontalBars'    - horizontal bars
%                       'verticalShades'    - vertical shades
%                       'horizontalShades'  - horizontal shades
%                   default == 'verticalLines'
%                   - 'LineStyle': line style of boundaries
%                   must be an unambiguous, case-insensitive match to one of: 
%                       '-'     - solid line
%                       '--'    - dashed line
%                       ':'     - dotted line
%                       '-.'    - dash-dotted line
%                       'none'  - no line
%                   default == '-'
%                   - 'LineWidth': color of boundaries
%                   must be empty or a positive scalar
%                   default == 3 for bars and 2 for lines
%                   - 'BarRelValue': value for bars relative to current axis
%                   must be empty or a positive scalar
%                   default == barRelValue relative to current axis
%                   - 'BarValue': value for bars
%                   must be empty or a numeric scalar
%                   default == barRelValue relative to current axis
%                   - Any other parameter-value pair for the line() function
% 
% Requires:
%       cd/create_error_for_nargin.m
%       cd/force_column_vector.m
%       cd/islinestyle.m
%       cd/plot_vertical_line.m
%
% Used by:    
%       cd/m3ha_plot_individual_traces.m

% File History:
% 2018-10-29 Created by Adam Lu
% 2018-12-19 Now passes extra arguments
% 2018-12-19 Now returns object handles
% 2019-08-27 Added 'BoundaryType' as an optional argument with values:
%               'verticalLines' (default), 'shades', 'horizontalBars'
% 

%% Hard-coded parameters
validBoundaryTypes = {'verticalLines','horizontalLines', ...
                        'horizontalBars', 'verticalBars', ...
                        'verticalShades', 'horizontalShades'};
lineLineStyle = '--';
lineLineWidth = 2;
barLineStyle = '-';
barLineWidth = 3;
shadeLineStyle = 'none';
shadeLineWidth = 0.5;

%% Default values for optional arguments
boundaryTypeDefault = 'verticalLines';
lineStyleDefault = '';      % set later
lineWidthDefault = '';      % set later
barRelValueDefault = 0.1;   % set later
barValueDefault = [];       % set later

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
addRequired(iP, 'win', ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'BoundaryType', boundaryTypeDefault, ...
    @(x) any(validatestring(x, validBoundaryTypes)));
addParameter(iP, 'LineStyle', lineStyleDefault, ...
    @(x) all(islinestyle(x, 'ValidateMode', true)));
addParameter(iP, 'LineWidth', lineWidthDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
addParameter(iP, 'BarRelValue', barRelValueDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
addParameter(iP, 'BarValue', barValueDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));

% Read from the Input Parser
parse(iP, win, varargin{:});
boundaryType = validatestring(iP.Results.BoundaryType, validBoundaryTypes);
[~, lineStyle] = islinestyle(iP.Results.LineStyle, 'ValidateMode', true);
lineWidth = iP.Results.LineWidth;
barRelValue = iP.Results.BarRelValue;
barValue = iP.Results.BarValue;

% Keep unmatched arguments for the line() function
otherArguments = iP.Unmatched;

%% Preparation
% Set default line style
if isempty(lineStyle)
    switch boundaryType
        case {'verticalLines', 'horizontalLines'}
            lineStyle = lineLineStyle;
        case {'verticalBars', 'horizontalBars'}
            lineStyle = barLineStyle;
        case {'verticalShades', 'horizontalShades'}
            lineStyle = shadeLineStyle;
        otherwise
            error('boundaryType unrecognized!');
    end
end

% Set default line width
if isempty(lineWidth)
    switch boundaryType
        case {'verticalLines', 'horizontalLines'}
            lineWidth = lineLineWidth;
        case {'verticalBars', 'horizontalBars'}
            lineWidth = barLineWidth;
        case {'verticalShades', 'horizontalShades'}
            lineWidth = shadeLineWidth;
        otherwise
            error('boundaryType unrecognized!');
    end
end

% Set default bar value
if isempty(barValue)
    switch boundaryType
        case 'verticalBars'
            % Get the current x axis limits
            xLimitsNow = get(gca, 'XLim');

            % Compute a default y value for the bar
            barValue = xLimitsNow(1) + barRelValue * range(xLimitsNow);
        case 'horizontalBars'
            % Get the current y axis limits
            yLimitsNow = get(gca, 'YLim');

            % Compute a default y value for the bar
            barValue = yLimitsNow(1) + barRelValue * range(yLimitsNow);
        case {'verticalLines', 'horizontalLines', ...
                'verticalShades', 'horizontalShades'}
            % Keep empty
        otherwise
            error('boundaryType unrecognized!');
    end    
end

% Force as a column
win = force_column_vector(win);

%% Do the job
% Plot lines
switch boundaryType
    case 'verticalLines' 
        h = plot_vertical_line(win, ...
                            'LineStyle', lineStyle, 'LineWidth', lineWidth, ...
                            otherArguments);
    case 'horizontalLines' 
        h = plot_horizontal_line(win, ...
                            'LineStyle', lineStyle, 'LineWidth', lineWidth, ...
                            otherArguments);
    case 'verticalBars'
        h = plot_vertical_line(barValue, 'YLimits', win, ...
                            'LineStyle', lineStyle, 'LineWidth', lineWidth, ...
                            otherArguments);
    case 'horizontalBars'
        h = plot_horizontal_line(barValue, 'XLimits', win, ...
                            'LineStyle', lineStyle, 'LineWidth', lineWidth, ...
                            otherArguments);
    case 'verticalShades'
        h = plot_vertical_shade(win, ...
                            'LineStyle', lineStyle, 'LineWidth', lineWidth, ...
                            otherArguments);
    case 'horizontalShades'
        h = plot_vertical_shade(win, 'HorizontalInstead', true, ...
                            'LineStyle', lineStyle, 'LineWidth', lineWidth, ...
                            otherArguments);
    otherwise
        error('boundaryType unrecognized!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

yLimits
yLimitsDefault = [];
% Set default y value limits
if isempty(yLimits)
    yLimits = get(gca, 'YLim');
end
addParameter(iP, 'YLimits', yLimitsDefault, ...
    @(x) isempty(x) || isnumeric(x) && isvector(x) && length(x) == 2);
yLimits = iP.Results.YLimits;

line(win(1) * ones(1, 2), yLimits, ...
    'Color', lineColor, 'LineStyle', lineStyle);
line(win(2) * ones(1, 2), yLimits, ...
    'Color', lineColor, 'LineStyle', lineStyle);

% Initialize a graphics object handle array
h = gobjects(2, 1);

h(1) = plot_vertical_line(win(1), 'YLimits', yLimits, ...
                'Color', lineColor, 'LineStyle', lineStyle, otherArguments);
h(2) = plot_vertical_line(win(2), 'YLimits', yLimits, ...
                'Color', lineColor, 'LineStyle', lineStyle, otherArguments);

h = arrayfun(@(x) plot_vertical_line(x, 'YLimits', yLimits, ...
                'Color', lineColor, 'LineStyle', lineStyle, otherArguments), ...
            win);
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
