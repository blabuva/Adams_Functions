function paramsTable = m3ha_network_change_params (paramsTable, namesToChange, valsToChange, varargin)
%% Change parameter values in a parameters table
% Usage: paramsTable = m3ha_network_change_params (paramsTable, namesToChange, valsToChange, varargin)
% Outputs:
%       paramsTable     - updated parameters table
%                       specified as a table
%
% Arguments:     
%       paramsTable     - a parameters table with a 'Value' column
%                       must be a table
%       namesToChange   - the name(s) of the parameter(s) to change
%                       must be a string/char vec or 
%                           a cell array of strings/char vecs
%       valsToChange    - the values(s) of the parameter(s) to change
%                       must be a numeric array
%       varargin    - 'ExperimentName': name of the experiment of interest
%                   must be an unambiguous, case-insensitive match 
%                       to one of the following: 
%                       'RTCl'  - chloride accumulation/extrusion model for 
%                                 Peter; updates 'cp_amp', 'cp_per', 'cp_num'
%                       'm3ha'  - GABA-B receptor network
%                       'noexp' - no experiment provided; do nothing
%                   default == 'noexp'
%
% Requires:    
%       cd/find_in_strings.m
%       cd/is_var_in_table.m
%       cd/m3ha_network_update_params.m
%
% Used by:    
%       cd/m3ha_network_launch.m
%       TODO: Change specification
%       /media/adamX/RTCl/neuronlaunch.m

% File History:
% 2017-05-03 Moved from m3ha_network_update_params.m
% 2017-05-03 Moved trial number update back to neuronlaunch.m
% 2017-05-03 Changed so that it reads namesToChange and valsToChange
% 2018-05-08 Changed tabs to spaces and limited width to 80
% 2019-10-31 Now uses tables

%% Hard-coded parameters
validExperiments = {'RTCl', 'm3ha', 'noexp'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 3
    error(['Not enough input arguments, ', ...
            'type ''help %s'' for usage'], mfilename);
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add required inputs to an input Parser
addRequired(iP, 'paramsTable', ...
    @(x) validateattributes(x, {'table'}, {'2d'}));
addRequired(iP, 'namesToChange', ...
    @(x) validateattributes(x, {'char', 'string', 'cell'}, {'2d'}));
addRequired(iP, 'valsToChange', ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));

% Add parameter-value pairs to the input Parser
addParameter(iP, 'ExperimentName', 'noexp', ...
    @(x) any(validatestring(x, validExperiments)));

% Read from the input Parser
parse(iP, paramsTable, namesToChange, valsToChange, varargin{:});
experimentname = validatestring(iP.Results.ExperimentName, validExperiments);

%% Preparation
% Make sure the table has a 'Value' column
if ~is_var_in_table('Value', paramsTable)
    disp('"Value" must be a column of the table!');
    return
end

%% Change parameter(s)

paramsTable(namesToChange, 'Value') = valsToChange;

if iscell(namesToChange)
    % One or more parameters to change
    nToChange = numel(namesToChange);    % number of parameters to change
    for p = 1:nToChange
        indp = find_in_strings(namesToChange{p}, paramnames);
        paramvals(indp) = valsToChange(p);
    end
else
    % Only one parameter to change
    indp = find_in_strings(namesToChange, paramnames);
    paramvals(indp) = valsToChange;
end

%% Update dependent parameters for particular experiments
[paramvals] = m3ha_network_update_params(paramnames, paramvals, ...
                            'ExperimentName', experimentname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
