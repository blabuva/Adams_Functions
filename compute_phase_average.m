function [phaseAverage, indSelected] = compute_phase_average (values, varargin)
%% Computes the average of values over the last of a phase
% Usage: [phaseAverage, indSelected] = compute_phase_average (values, varargin)
% Explanation:
%       TODO
% Example(s):
%       TODO
% Outputs:
%       phaseAverage    - average value over the last of the phase
%                       specified as a numeric scalar
% Arguments:
%       values      - values for a phase
%                   must be a numeric vector
%       varargin    - 'ReturnLastTrial': whether to return last attempt
%                                           instead of NaNs if criteria not met
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'NToAverage': number of values to average
%                   must be a positive integer scalar
%                   default == 5
%                   - 'Indices': indices for the subvectors to extract 
%                       Note: if provided, would override 'EndPoints'
%                   must be a numeric vector with 2 elements
%                       or a numeric array with 2 rows
%                       or a cell array of numeric vectors with 2 elements
%                   default == set in select_similar_values.m
%                   - 'EndPoints': endpoints for the phase
%                   must be a numeric vector with 2 elements
%                       or a numeric array with 2 rows
%                       or a cell array of numeric vectors with 2 elements
%                   default == set in select_similar_values.m
%                   - 'SelectionMethod': the selection method
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'notNaN'        - select any non-NaN value
%                       'maxRange2Mean' - select vales so that the maximum 
%                                           range is within a percentage 
%                                           of the mean
%                   default == 'maxRange2Mean'
%                   - 'MaxRange2Mean': maximum percentage of range versus mean
%                   must be a nonnegative scalar
%                   default == 40%
%                   - Any other parameter-value pair for 
%                       the select_similar_values() function
%
% Requires:
%       cd/create_error_for_nargin.m
%       cd/select_similar_values.m
%       cd/struct2arglist.m
%
% Used by:
%       cd/plot_struct.m

% File History:
% 2019-05-13 Created by Adam Lu
% 2019-05-15 Add 'SelectionMethod' as an optional argument
% 2019-05-16 Add 'ReturnLastTrial' as an optional argument
% 2019-05-16 Now uses nanmean() instead of mean()
% 

%% Hard-coded parameters
validSelectionMethods = {'notNaN', 'maxRange2Mean'};

%% Default values for optional arguments
returnLastTrialDefault = false; % return NaN if criteria not met by default
nToAverageDefault = 5;          % select 5 values by default
indicesDefault = [];            % set in extract_subvectors.m
endPointsDefault = [];          % set in select_similar_values.m
selectionMethodDefault = 'maxRange2Mean';   
                                % select using maxRange2Mean by default
% maxRange2MeanDefault = 40;      % range is not more than 40% of mean by default
maxRange2MeanDefault = 200;      % range is not more than 40% of mean by default

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
addRequired(iP, 'values', ...
    @(x) validateattributes(x, {'numeric', 'cell'}, {'2d'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'ReturnLastTrial', returnLastTrialDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'NToAverage', nToAverageDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'positive', 'integer', 'scalar'}));
addParameter(iP, 'Indices', indicesDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['Indices must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'EndPoints', endPointsDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['EndPoints must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'SelectionMethod', selectionMethodDefault, ...
    @(x) any(validatestring(x, validSelectionMethods)));
addParameter(iP, 'MaxRange2Mean', maxRange2MeanDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'nonnegative', 'scalar'}));

% Read from the Input Parser
parse(iP, values, varargin{:});
returnLastTrial = iP.Results.ReturnLastTrial;
nToAverage = iP.Results.NToAverage;
indices = iP.Results.Indices;
endPoints = iP.Results.EndPoints;
selectionMethod = validatestring(iP.Results.SelectionMethod, ...
                                    validSelectionMethods);
maxRange2Mean = iP.Results.MaxRange2Mean;

% Keep unmatched arguments for the select_similar_values() function
otherArguments = struct2arglist(iP.Unmatched);

%% Do the job
% Select values similar to the last phase value
[valSelected, indSelected] = ...
    select_similar_values(values, 'ReturnLastTrial', returnLastTrial, ...
                        'EndPoints', endPoints, 'Indices', indices, ...
                        'NToSelect', nToAverage, 'Direction', 'backward', ...
                        'SelectionMethod', selectionMethod, ...
                        'MaxRange2Mean', maxRange2Mean, ...
                        otherArguments{:});

% Copmute the phase average
phaseAverage = nanmean(valSelected);
% phaseAverage = compute_stats(values, 'mean', 'Indices', indSelected);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%