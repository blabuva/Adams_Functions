function rgbValue = char2rgb (colorStr, varargin)
%% Converts a color string to an rgb value
% Usage: rgbValue = char2rgb (colorStr, varargin)
% Explanation:
%       TODO
%
% Example(s):
%       TODO
%
% Outputs:
%       rgbValue    - [R, G, B] value for the color string
%                   specified as a 1-by-3 numeric vector
%
% Arguments:
%       colorStr    - a color string
%                   must be a character vector or a string scalar
%       varargin    - 'param1': TODO: Description of param1
%                   must be a TODO
%                   default == TODO
%
% Requires:
%       cd/create_error_for_nargin.m
%       cd/find_in_strings.m
%       ~/Downloaded_Functions/rgb.m
%
% Used by:
%       /TODO:dir/TODO:file

% File History:
% 2019-08-22 Adapted from https://stackoverflow.com/questions/4922383/how-can-i-convert-a-color-name-to-a-3-element-rgb-vector
% 

%% Hard-coded parameters
matlabColorStrings = {'k', 'r', 'g', 'y', 'b', 'm', 'c', 'w'};

%% Default values for optional arguments
% param1Default = [];             % default TODO: Description of param1

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
addRequired(iP, 'colorStr');

% Add parameter-value pairs to the Input Parser
% addParameter(iP, 'param1', param1Default);

% Read from the Input Parser
parse(iP, colorStr, varargin{:});
% param1 = iP.Results.param1;

%% Do the job
% First test whether it's a MATLAB color string
idxColor = find_in_strings(colorStr, matlabColorStrings, 'IgnoreCase', true);

% Get the rgb value
if ~isempty(idxColor)
    % Use bitget to get the appropriate rgb value
    rgbValue = bitget(idxColor - 1, 1:3);
else
    % Otherwise, use the rgb.m function
    rgbValue = rgb(colorStr);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%