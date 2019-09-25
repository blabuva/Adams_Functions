function [isOverlapping, overLapsPrev] = is_overlapping (timeWindows, varargin)
%% Returns whether a set of time windows are overlapping
% Usage: [isOverlapping, overLapsPrev] = is_overlapping (timeWindows, varargin)
% Explanation:
%       TODO
%
% Example(s):
%       [a, b] = is_overlapping({[4, 6], [1, 3]})
%       [a, b] = is_overlapping([3, 4; 1, 2])
%
% Outputs:
%       isOverlapping   - whether the time windows are overlapping
%                       specified as a logical scalar
%       overLapsPrev    - whether each time window overlaps the previous
%                           window
%                       specified as a logical scalar
%
% Arguments:
%       timeWindows - time window(s)
%                   must be empty or a numeric vector with 2 elements,
%                       or a numeric array with 2 rows
%                       or a cell array of numeric vectors with 2 elements
%       varargin    - 'param1': TODO: Description of param1
%                   must be a TODO
%                   default == TODO
%
% Requires:
%       cd/create_error_for_nargin.m
%       cd/count_vectors.m
%       cd/extract_elements.m
%
% Used by:
%       /TODO:dir/TODO:file

% File History:
% 2019-09-24 Created by Adam Lu
% 

%% Hard-coded parameters

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
iP.KeepUnmatched = true;                        % allow extraneous options

% Add required inputs to the Input Parser
addRequired(iP, 'timeWindows', ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['timeWindows must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));

% Add parameter-value pairs to the Input Parser
% addParameter(iP, 'param1', param1Default);

% Read from the Input Parser
parse(iP, timeWindows, varargin{:});
% param1 = iP.Results.param1;

%% Preparation
% Count the number of windows
nWindows = count_vectors(timeWindows);
 
% Return in no more than one window
if nWindows < 2
    isOverlapping = false;
    return;
end

%% Do the job
% Extract the start and end times
startTimes = extract_elements(timeWindows, 'first');
endTimes = extract_elements(timeWindows, 'last');

% Sort by the start times
[startTimesSorted, indOriginal] = sort(startTimes);
endTimesSorted = endTimes(indOriginal);

% Test whether each start time is before 
%   the end time of the next window
overLapsPrev = [false; startTimesSorted(2:end) < endTimesSorted(1:end-1)];

% Windows are overlapping if any start time is before 
%   the end time of the next window
isOverlapping = any(startTimesSorted(2:end) < endTimesSorted(1:end-1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%