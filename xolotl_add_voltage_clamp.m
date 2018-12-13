function [xolotlObject, clampedVoltage] = ...
                xolotl_add_voltage_clamp (xolotlObject, varargin)
%% Adds a voltage clamp to the first compartment of a xolotl object
% Usage: [xolotlObject, clampedVoltage] = ...
%               xolotl_add_voltage_clamp (xolotlObject, varargin)
% Explanation:
%       TODO
% Example(s):
%       TODO
% Outputs:
%       xolotlObject    - a created neuron with simulation parameters
%                       specified as a xolotl object
%       clampedVoltage  - clamped voltage traces added
%                       specified as a numeric array
% Arguments:
%       xolotlObject    - a created neuron with simulation parameters
%                       must be a xolotl object
%       varargin    - 'Amplitude': amplitude in mV 
%                   must be a numeric scalar
%                   default == -70 mV
%
% Requires:
%       cd/parse_xolotl_object.m
%
% Used by:
%       cd/m3ha_xolotl_test.m

% File History:
% 2018-12-13 Modified from xolotl_add_voltage_clamp.m
% TODO: Make more general by adding a 'Compartment' parameter,
%       with only the first compartment by default
% TODO: vcRs = 0.01             // Voltage clamp series resistance in MOhm
% 

%% Hard-coded parameters

%% Default values for optional arguments
amplitudeDefault = -70;     % default amplitude in mV

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
addRequired(iP, 'xolotlObject');

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'Amplitude', amplitudeDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar'}));

% Read from the Input Parser
parse(iP, xolotlObject, varargin{:});
amplitude = iP.Results.Amplitude;

%% Preparation
% Parse the xolotl object
parsedParams = parse_xolotl_object(xolotlObject);

% Extract parameters
nSamples = parsedParams.nSamples;
nCompartments = parsedParams.nCompartments;

%% Create clamped voltage(s)
% Create clamped voltage vector for the first compartment
clampedVoltage = amplitude * ones(nSamples, 1);

% Match NaNs for the other compartments
clampedVoltage = [clampedVoltage, NaN(nSamples, nCompartments - 1)];

%% Replace any voltage clamp with the new voltage clamp traces
xolotlObject.V_clamp = clampedVoltage;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%