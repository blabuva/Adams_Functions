function [output1] = m3ha_network_compare_ipsc (reqarg1, varargin)
%% Compare an evoked IPSC against the recorded IPSC
% Usage: [output1] = m3ha_network_compare_ipsc (reqarg1, varargin)
% Explanation:
%       TODO
%
% Example(s):
%       TODO
%
% Outputs:
%       output1     - TODO: Description of output1
%                   specified as a TODO
%
% Arguments:
%       reqarg1     - TODO: Description of reqarg1
%                   must be a TODO
%       varargin    - 'param1': TODO: Description of param1
%                   must be a TODO
%                   default == TODO
%                   - Any other parameter-value pair for TODO()
%
% Requires:
%       ~/Adams_Functions/create_error_for_nargin.m
%       ~/Adams_Functions/struct2arglist.m
%       /TODO:dir/TODO:file
%
% Used by:
%       /TODO:dir/TODO:file

% File History:
% 2020-01-10 Created by Adam Lu
% 

%% Hard-coded parameters
spExtension = 'singsp';



%% Default values for optional arguments
param1Default = [];             % default TODO: Description of param1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1    % TODO: 1 might need to be changed
    error(create_error_for_nargin(mfilename));
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;
iP.KeepUnmatched = true;                        % allow extraneous options

% Add required inputs to the Input Parser
addRequired(iP, 'reqarg1');

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'param1', param1Default);

% Read from the Input Parser
parse(iP, reqarg1, varargin{:});
param1 = iP.Results.param1;

% Keep unmatched arguments for the TODO() function
otherArguments = struct2arglist(iP.Unmatched);

% Check relationships between arguments
% TODO

%% Preparation
% TODO

%% Do the job
% Load default GABAB IPSC parameters
% TODO: m3ha_load_ipsc_params.m

% Compute GABAB IPSC
% TODO

% 

% Locate the TC neuron data for each pharm condition
all_files('Extension', spExtension);


%% Output results
% TODO

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%