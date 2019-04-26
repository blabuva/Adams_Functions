function [vecs] = transform_vectors (vecs, amount, method, varargin)
%% Transform vectors by a binary operation
% Usage: [vecs] = transform_vectors (vecs, amount, method, varargin)
% Explanation:
%       TODO
% Example(s):
%       transform_vectors(1:10, 2*ones(10, 1), 'add')
%       transform_vectors(1:10, 2*ones(10, 1), 'subtract')
%       transform_vectors(1:10, 2*ones(10, 1), 'multiply')
%       transform_vectors(1:10, 2*ones(10, 1), 'divide')
% Outputs:
%       vecs        - transformed vectors
%                   specified as a numeric array 
%                       or a cell array of numeric arrays
% Arguments:
%       vecs        - vectors to transform
%                   must be a numeric array or a cell array of numeric arrays
%       amount      - amount to transform by
%                   must be a numeric array or a cell array of numeric arrays
%       method      - transform method 
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'add'       - add vecs by amount
%                       'subtract'  - subtract vecs by amount
%                       'multiply'  - multiply vecs by amount
%                       'divide'    - divide vecs by amount
%       varargin    - 'param1': TODO: Description of param1
%                   must be a TODO
%                   default == TODO
%                   - Any other parameter-value pair for the TODO() function
%
% Requires:
%       cd/argfun.m
%       cd/create_error_for_nargin.m
%       cd/force_column_vector.m
%
% Used by:
%       cd/plot_traces.m

% File History:
% 2019-04-26 Created by Adam Lu
% 

%% Hard-coded parameters
validMethods = {'add', 'subtract', 'multiply', 'divide'};

%% Default values for optional arguments
% param1Default = [];             % default TODO: Description of param1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 3
    error(create_error_for_nargin(mfilename));
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add required inputs to the Input Parser
addRequired(iP, 'vecs', ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vecs must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));
addRequired(iP, 'amount', ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vecs must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));
addRequired(iP, 'method', ...
    @(x) any(validatestring(x, validMethods)));

% Add parameter-value pairs to the Input Parser
% addParameter(iP, 'param1', param1Default, ...
%     % TODO: validation function %);

% Read from the Input Parser
parse(iP, vecs, amount, method, varargin{:});
method = validatestring(method, validMethods);
% param1 = iP.Results.param1;

%% Preparation
% If empty, don't do anything
if isempty(vecs)
    return
end

% If empty, don't do anything
[vecs, amount] = argfun(@force_column_vector, vecs, amount);

% TODO: Match amount to vecs

%% Do the job
switch method
    case 'add'
        vecs = vecs + amount;
    case 'subtract'
        vecs = vecs - amount;
    case 'multiply'
        vecs = vecs .* amount;
    case 'divide'
        vecs = vecs ./ amount;
    otherwise
        error('method unrecognized!');
end

%% Output results
% TODO

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%