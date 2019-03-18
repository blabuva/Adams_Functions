function h = plot_horizontal_line (yValue, varargin)
%% Plots a horizontal line
% Usage: h = plot_horizontal_line (yValue, varargin)
% Explanation:
%       TODO
% Example(s):
%       h = plot_horizontal_line(yValue)
%       h = plot_horizontal_line(yValue, 'XLimits', xLimits)
% Outputs:
%       h           - handle to the line object created
%                   specified as a primitive line object handle
% Arguments:
%       yValue      - the y value for the horizontal line
%                   must be a numeric, datetime or duration array
%       varargin    - 'XLimits': x value limits for the line
%                   must be empty or a numeric vector of 2 elements
%                       or an array of 2 rows
%                   default == get(gca, 'XLim')
%                   - Any other parameter-value pair for the line() function
%
% Requires:
%       cd/create_error_for_nargin.m
%       cd/force_column_cell.m
%       cd/isnum.m
%       cd/match_format_vector_sets.m
%
% Used by:
%       cd/parse_multiunit.m
%       cd/plot_pulse_response_with_stimulus.m

% File History:
% 2018-12-19 Created by Adam Lu
% 2018-12-27 Now allows yValue to be an array
% 2018-12-27 Now accepts datetime and duration arrays
% 2019-01-24 Now accepts multiple x limits
% 2019-03-17 Allow each x limits to be of length > 2 and break them up
%               into pairs
% 

%% Hard-coded parameters

%% Default values for optional arguments
xLimitsDefault = [];

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
addRequired(iP, 'yValue', ...
    @(x) validateattributes(x, {'numeric', 'datetime', 'duration'}, {'3d'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'XLimits', xLimitsDefault);

% Read from the Input Parser
parse(iP, yValue, varargin{:});
xLimits = iP.Results.XLimits;

% Keep unmatched arguments for the line() function
otherArguments = iP.Unmatched;

%% Preparation
% Set default x value limits
if isempty(xLimits)
    xLimits = get(gca, 'XLim');
end

% Force as a cell array of column vectors and match vectors
[yValue, xLimits] = match_format_vector_sets(num2cell(yValue), xLimits);

% Place in column cell arrays and 
%   expand x limits if there are more than 2 values
[xLimitsCell, yValueCell] = cellfun(@(x, y) expand_limits(x, y), xLimits, yValue, ...
                                    'UniformOutput', false);

% Vertically concatenate all column cell arrays
yValueAll = apply_over_cell(@vertcat, yValueCell);
xLimitsAll = apply_over_cell(@vertcat, xLimitsCell);

%% Do the job
h = cellfun(@(y, x) line(x, repmat(y, size(x)), otherArguments), ...
            yValueAll, xLimitsAll);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xLimitsCell, yValueCell] = expand_limits(xLimits, yValue)

nXEndpoints = numel(xLimits);

if mod(nXEndpoints, 2) ~= 0
    error('Number of x endpoints must be even!');
end

% Actual number of lines to plot
nLines = nXEndpoints / 2;

% Reshape as two rows
xLimits = reshape(xLimits, 2, nLines);

% Force as column cell array of column vectors
xLimitsCell = force_column_cell(xLimits);

% Expand y value accordingly
yValueCell = repmat({yValue}, nLines, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

@(x) isempty(x) || isnumeric(x) && isvector(x) && length(x) == 2);

h = arrayfun(@(y) line(xLimits, repmat(y, size(xLimits)), otherArguments), ...
            yValue);

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%