function iterStrs = m3ha_extract_iteration_string (strs, varargin)
%% Extracts the iteration string from strings
% Usage: iterStrs = m3ha_extract_iteration_string (strs, varargin)
% Explanation:
%       TODO
%
% Example(s):
%       m3ha_extract_iteration_string({'singleneuronfitting15_12', 'singleneuronfitting15_13'})
%
% Outputs:
%       iterStrs    - iteration strings
%                   specified as a character vector
%
% Arguments:
%       strs        - strings
%                   must be a character vector or a string vector
%                       or a cell array of character vectors
%       varargin    - Any other parameter-value pair for extract_substrings()
%
% Requires:
%       cd/create_error_for_nargin.m
%       cd/extract_substrings.m
%
% Used by:
%       cd/m3ha_neuron_choose_best_params.m
%       cd/m3ha_simulate_population.m

% File History:
% 2019-12-21 Created by Adam Lu
% 

%% Hard-coded parameters
iterStrPattern = 'singleneuronfitting[\d]*';

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
addRequired(iP, 'strs', ...
    @(x) assert(ischar(x) || iscellstr(x) || isstring(x), ...
        ['strs5 must be a character array or a string array ', ...
            'or cell array of character arrays!']));

% Read from the Input Parser
parse(iP, strs, varargin{:});

% Keep unmatched arguments for the extract_substrings() function
otherArguments = iP.Unmatched;

%% Do the job
% Extract the iteration strings
iterStrs = extract_substrings(strs, 'FromBaseName', true, ...
                                'RegExp', iterStrPattern, otherArguments);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
