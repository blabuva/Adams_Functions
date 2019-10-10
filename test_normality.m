function [isNormal, pTable] = test_normality (data, varargin)
%% Test whether set(s) of values are normally distributed
% Usage: [isNormal, pTable] = test_normality (data, varargin)
% Explanation:
%       TODO
%
% Example(s):
%       [a, b] = test_normality(randn(100, 1))
%       [a, b] = test_normality({randn(100, 1), rand(100, 1)})
%
% Outputs:
%       isNormal    - whether each group is normal
%                   specified as a logical vector
%       pTable      - table of p values
%                   specified as a table
%
% Arguments:
%       data        - data to test
%                   must be a vector or a cell array of vectors
%       varargin    - 'SigLevel': significance level for tests
%                   must be a positive scalar
%                   default == 0.05
%                   - Any other parameter-value pair for the TODO() function
%
% Requires:
%       cd/compute_weighted_average.m
%       cd/create_error_for_nargin.m
%       cd/force_column_cell.m
%       cd/struct2arglist.m
%
% Used by:
%       /TODO:dir/TODO:file

% File History:
% 2019-09-01 Created by Adam Lu
% 

%% Hard-coded parameters

%% Default values for optional arguments
sigLevelDefault = 0.05;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(create_error_for_nargin(mfilename));
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;
% iP.KeepUnmatched = true;                        % allow extraneous options

% Add required inputs to the Input Parser
addRequired(iP, 'data');

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'SigLevel', sigLevelDefault);

% Read from the Input Parser
parse(iP, data, varargin{:});
sigLevel = iP.Results.SigLevel;

% Keep unmatched arguments for the TODO() function
% otherArguments = struct2arglist(iP.Unmatched);

%% Preparation
% Force as a cell array
data = force_column_cell(data);

%% Do the job
% Apply the Lilliefors test for normality to each group
if numel(x) >= 4
    [~, pNormLill] = ...
        cellfun(@(x) lillietest(x, 'Alpha', sigLevel), data);
else
    pNormLill = NaN;
end

% Apply the Anderson-Darling test for normality to each group
[~, pNormAd] = cellfun(@(x) adtest(x, 'Alpha', sigLevel), data);

% Apply the Jarque-Bera test for normality to each group
[~, pNormJb] = cellfun(@(x) jbtest(x, sigLevel), data);

% Place all p values for normality together in a matrix
%   Note: each row is a group; each column is a different test
pNormMat = [pNormLill, pNormAd, pNormJb];

% Take the geometric mean of the p values from different tests
pNormAvg = compute_weighted_average(pNormMat, 'DimToOperate', 2, ...
                                        'AverageMethod', 'geometric', ...
                                        'IgnoreNan', true);

% Normality is satified if p value is not less than the significance level
isNormal = pNormAvg >= sigLevel;

%% Output results
pTable = table(pNormAvg, pNormLill, pNormAd, pNormJb);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%