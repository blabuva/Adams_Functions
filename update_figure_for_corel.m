function figHandle = update_figure_for_corel (figHandle, varargin)
%% Update figure to be journal-friendly (ready for CorelDraw)
% Usage: figHandle = update_figure_for_corel (figHandle, varargin)
% Explanation:
%       TODO
%
% Example(s):
%       fig = update_figure_for_corel(fig);
%
% Outputs:
%       figHandle   - figure handle updated
%                   specified as a Figure object handle
%
% Arguments:
%       figHandle   - figure handle to update
%                   must be a Figure object handle
%       varargin    - 'RemoveTicks': whether to remove all ticks
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'RemoveLegends': whether to remove all legends
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - Any other parameter-value pair for set_figure_properties()
%
% Requires:
%       cd/create_error_for_nargin.m
%       cd/set_figure_properties.m
%
% Used by:
%       cd/plot_calcium_imaging_traces.m
%       cd/plot_traces_spike2_mat.m
%       /home/Matlab/plethR01/plethR01_analyze.m

% File History:
% 2019-09-19 Created by Adam Lu
% 2019-09-20 Added 'RemoveTicks' as an optional argument
% 2019-10-04 Added 'RemoveLegends' as an optional argument
% 2019-10-05 Add textFontSize

%% Hard-coded parameters
% TODO: Make optional parameters
labelsFontSize = 8;
axisFontSize = 6; 
textFontSize = 6;
lineWidth = 1;
tickLengths = [0.01, 0.01];

%% Default values for optional arguments
removeTicksDefault = false;  % set later
removeLegendsDefault = false;  % set later

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
addRequired(iP, 'figHandle');

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'RemoveTicks', removeTicksDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'RemoveLegends', removeLegendsDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));

% Read from the Input Parser
parse(iP, figHandle, varargin{:});
removeTicks = iP.Results.RemoveTicks;
removeLegends = iP.Results.RemoveLegends;

% Keep unmatched arguments for set_figure_properties()
otherArguments = iP.Unmatched;

%% Preparation
% Compute font size multipliers
titleFontSizeMultiplier = labelsFontSize / axisFontSize;
labelFontSizeMultiplier = labelsFontSize / axisFontSize;

% Check if the figure handle is valid
if ~isempty(figHandle) && ~isvalid(figHandle)
    error('figHandle is not valid!');
end


%% Set figure properties
% Might change sizes
figHandle = set_figure_properties('FigHandle', figHandle, otherArguments);

%% Set axes properties
% Find all axes in the figure
ax = findall(figHandle, 'type', 'axes');

% Count the number of axes
nAx = numel(ax);

% Set font
set(ax, 'FontName', 'Arial');
set(ax, 'FontSize', axisFontSize);
set(ax, 'TitleFontSizeMultiplier', titleFontSizeMultiplier);
set(ax, 'TitleFontWeight', 'normal');
set(ax, 'LabelFontSizeMultiplier', labelFontSizeMultiplier);

% Make all rulers the same linewidth
set(ax, 'LineWidth', lineWidth);

% Remove boxes
for iAx = 1:nAx
    box(ax(iAx), 'off');
end

% Make all ticks go outward
set(ax, 'TickDir', 'out');
set(ax, 'TickDirMode', 'manual');
set(ax, 'TickLength', tickLengths);

% Remove x and y axis ticks
if removeTicks
    set(ax, 'XTick', []);
    set(ax, 'YTick', []);
end

% Remove legends if requested
if removeLegends
    lgds = findobj(gcf, 'Type', 'Legend');
    delete(lgds);
end

% Change the fontsize of texts
texts = findobj(gcf, 'Type', 'Text');
if ~isempty(texts)
    set(texts, 'Fontsize', textFontSize);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

for iAx = 1:nAx
    ax(iAx).XAxis.LineWidth = 1;
    ax(iAx).YAxis.LineWidth = 1;
end

% Set other axes properties
if ~isempty(otherArguments)
    set(ax, otherArguments{:});    
end

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%