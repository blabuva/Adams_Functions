function [avgTrace, paramsUsed] = compute_average_trace (traces, varargin)
%% Computes the average of traces that are not necessarily the same length
% Usage: [avgTrace, paramsUsed] = compute_average_trace (traces, varargin)
% Explanation:
%       TODO
% Example(s):
%       TODO
% Outputs:
%       avgTrace    - the average trace
%                   specified as a numeric column vector
% Arguments:    
%       traces      - traces to average
%                   Note: If a cell array, each element must be a vector
%                         If an array, each column is a vector
%                   must be a numeric array or a cell array of numeric vectors
%       varargin    - 'NSamples': number of samples in the average trace
%                   must be a nonnegative integer scalar
%                   default == minimum of the lengths of all traces
%                   - 'AlignMethod': method for alignment
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'LeftAdjust'  - Align to the left
%                       'RightAdjust' - Align to the right
%                   default == 'LeftAdjust'
%                   
% Requires:
%       cd/iscellnumeric.m
%
% Used by:    
%       cd/find_passive_params.m
%       cd/force_column_numeric.m

% File History:
% 2018-10-11 Created by Adam Lu
% 

%% Hard-coded parameters
validAlignMethods = {'leftadjust', 'rightadjust'};

%% Default values for optional arguments
nSamplesDefault = [];               % set later
alignMethodDefault  = 'leftadjust'; % align to the left by default

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

% Add required inputs to the Input Parser
addRequired(iP, 'traces', ...                   % vectors
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['traces must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'NSamples', nSamplesDefault, ...
    @(x) validateattributes(x, {'numeric'}, ...
                                {'nonnegative', 'integer', 'scalar'}));
addParameter(iP, 'AlignMethod', alignMethodDefault, ...
    @(x) any(validatestring(x, validAlignMethods)));

% Read from the Input Parser
parse(iP, traces, varargin{:});
nSamples = iP.Results.NSamples;
alignMethod = validatestring(iP.Results.AlignMethod, validAlignMethods);

%% Preparation
% Set default number of samples
if isempty(nSamples)
    if iscell(traces)
        % Use the minimum length of all traces
        nSamples = min(cellfun(@length, traces));
    else
        % Use the number of rows
        nSamples = size(traces, 1);
    end
end

% If in a cell array, force each trace to be a column vector
traces = force_column_numeric(traces);

%% Do the job
% Return if there are no samples
if nSamples == 0
    avgTrace = [];
    return
end

% Align and truncate traces to the desired number of samples
switch alignMethod
case 'leftadjust'
    % Always start from 1
    if iscell(traces)
        tracesTruncated = cellfun(@(x) x(1:nSamples), traces, ...
                                    'UniformOutput', false);
    else
        tracesTruncated = traces(1:nSamples, :);
    end
case 'rightadjust'
    % Always end at end
    if iscell(traces)
        tracesTruncated = cellfun(@(x) x((end-nSamples+1):end), traces, ...
                                    'UniformOutput', false);
    else
        tracesTruncated = traces((end-nSamples+1):end, :);
    end
otherwise
    error('The align method %s is not implemented yet!!', alignMethod);
end        

% Combine into a numeric array
if iscell(traces)
    % Place each column vector into a column of an array
    tracesArray = horzcat(tracesTruncated{:});
else
    % Already a numeric array
    tracesArray = tracesTruncated;
end

% The average trace is the mean of all truncated traces (all columns)
avgTrace = mean(tracesArray, 2);

%% Output info
paramsUsed.nSamples = nSamples;
paramsUsed.alignMethod = alignMethod;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

if iscell(traces) && ~all(cellfun(@iscolumn, traces))
    traces = cellfun(@(x) x(:), traces, 'UniformOutput', false);
end

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%