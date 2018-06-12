function [results, linestyles] = islinestyle (strings, varargin)
%% Check whether a string or each string in a cell array is a valid line style accepted by plot() or line()
% Usage: [results, linestyles] = islinestyle (strings, varargin)
% Outputs:    
%       results     - indication of whether the specified string is
%                        valid linestyle accepted by plot() or line()
%                   specified as a logical array
%       linestyles  - validated linestyles, if any
%                   specified as a string/char-vec or 
%                       a cell array of strings/char-vecs
%                   returns the shortest match if matchMode == 'substring' 
%                       (sames as validatestring())
% Arguments:
%       strings     - string or strings to check
%                   must be a string/char-vec or 
%                       a cell array of strings/char-vecs
%       varargin    - 'ValidateMode': whether to validate string and 
%                       throw error if string is not a substring of a sheettype
%                   must be logical 1 (true) or 0 (false)
%                   default == false
%                   - 'MatchMode': the matching mode
%                   must be an unambiguous, case-insensitive match 
%                       to one of the following:
%                       'exact'         - string must be exact
%                       'substring'     - string can be a substring
%                   if 'ValidateMode' is 'true', matching mode is 
%                       automatically 'substring'
%                   default == 'substring'
%
% Requires:
%       /home/Matlab/Adams_Functions/istype.m
%
% Used by:
%       /home/Matlab/Adams_Functions/plot_ellipse.m
%       /home/Matlab/Adams_Functions/plot_raster.m
%       /home/Matlab/EEG_gui/combine_EEG_gui_outputs.m
%
% File History:
% 2018-05-16 Modified from issheettype.m
% 

%% Hard-coded parameters
validLineStyles = {'-', '--', ':', '-.', 'none'};
                                        % accepted by line() or plot()
                                        % Note: from Matlab 2018a Documentation

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
iP.KeepUnmatched = true;                        % allow extraneous options

% Add required inputs to an Input Parser
addRequired(iP, 'strings', ...                  % string or strings to check
    @(x) assert(ischar(x) || ...
                iscell(x) && (min(cellfun(@ischar, x)) || ...
                min(cellfun(@isstring, x))) || isstring(x) , ...
                ['strings must be either a string/character array ', ...
                'or a cell array of strings/character arrays!']));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'ValidateMode', false, ...     % whether to validate string
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'MatchMode', 'substring', ...  % the matching mode
    @(x) any(validatestring(x, {'exact', 'substring'})));

% Read from the Input Parser
parse(iP, strings, varargin{:});
validateMode = iP.Results.ValidateMode;
matchMode = iP.Results.MatchMode;

% Display warning message if some inputs are unmatched
if ~isempty(fieldnames(iP.Unmatched))
    fprintf('WARNING: The following name-value pairs could not be parsed: \n');
    disp(iP.Unmatched);
end

%% Check strings and validate with istype.m
[results, linestyles] = istype(strings, validLineStyles, ...
                               'ValidateMode', validateMode, ...
                               'MatchMode', matchMode);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

% Requires:
%       /home/Matlab/Adams_Functions/validate_string.m

%% Check strings and validate
if iscell(strings)
    linestyles = cellfun(@(x) validate_string(x, validLineStyles, ...
                                            'ValidateMode', validateMode, ...
                                            'MatchMode', matchMode), ...
                                            strings, 'UniformOutput', false);
    results = ~cellfun(@isempty, linestyles);
elseif ischar(strings)
    linestyles = validate_string(strings, validLineStyles, ...
                                'ValidateMode', validateMode, ...
                                'MatchMode', matchMode);
    results = ~isempty(linestyles);
else
    error(['input argument is in the wrong format! ', ...
            'Type ''help %s'' for usage'], mfilename);
end

%}