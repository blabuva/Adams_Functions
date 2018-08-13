function [avgSlope, startSlope, endSlope, indsUsed, isUnbalanced] = ...
            compute_average_initial_slopes (tvecCpr, vvecCpr, varargin)
%% Computes the average initial slope from a current pulse response
% Usage: [avgSlope, startSlope, endSlope, indsUsed, isUnbalanced] = ...
%           compute_average_initial_slopes (tvecCpr, vvecCpr, varargin)
%
% Arguments:    
%       tvecCpr     - time vector of the current pulse response
%                   must be a numeric vector
%       vvecCpr     - voltage vector of the current pulse response
%                   must be a numeric vector
%       varargin    - 'IvecCpr': current vector of the current pulse response
%                   must be a numeric vector
%                   default == [] (not used)
%                   - 'NSamples': Range of samples in slope calculation
%                   must be a numeric scalar
%                   default == 2 samples
%                   
%
% Requires:
%       /home/Matlab/Adams_Functions/find_pulse_response_endpoints.m
%
% Used by:    
%       /home/Matlab/Adams_Functions/correct_unbalanced_bridge.m
%       /media/adamX/m3ha/data_dclamp/find_initial_slopes.m

% File History:
% 2018-07-25 BT - Adapted from find_initial_slopes.m
% 2018-08-10 AL - Now checks number of arguments
% 2018-08-11 AL - Made IvecCpr and NSamples optional parameters
% 2018-08-12 AL - Now uses the current pulse start/end points
%                   to define a region of interest
% 2018-08-12 AL - Changed signal2Noise to 10
% 2018-08-13 AL - Moved code to find_pulse_response_endpoints.m

%% Hard-coded parameters

%% Default values for optional arguments
defaultIvecCpr = [];                % don't use current vector by default
defaultNSamples = 2;                % use consecutive samples by default

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 2
    error(['Not enough input arguments, ', ...
            'type ''help %s'' for usage'], mfilename);
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add required inputs to the Input Parser
addRequired(iP, 'tvecCpr', ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addRequired(iP, 'vvecCpr', ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'IvecCpr', defaultIvecCpr, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'NSamples', defaultNSamples, ...       
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive', 'integer'}));

% Read from the Input Parser
parse(iP, tvecCpr, vvecCpr, varargin{:});
ivecCpr = iP.Results.IvecCpr;
nSamples = iP.Results.NSamples;

%% Find the endpoints of the pulse response
[idxCprStart, idxCprEnd, isUnbalanced] = ...
            find_pulse_response_endpoints(tvecCpr, vvecCpr, 'IvecCpr', ivecCpr);

%% Compute the average slope
% Compute slope right after current pulse start
idxFirst1 = idxCprStart;
idxLast1 = idxCprStart + nSamples - 1;
startSlope = (vvecCpr(idxLast1) - vvecCpr(idxFirst1)) / ...
             (tvecCpr(idxLast1) - tvecCpr(idxFirst1));

% Compute slope right after current pulse end
idxFirst2 = idxCprEnd;
idxLast2 = idxCprEnd + nSamples - 1;
endSlope = (vvecCpr(idxLast2) - vvecCpr(idxFirst2)) / ...
           (tvecCpr(idxLast2) - tvecCpr(idxFirst2));

% Compute average slope (reverse the sign of the start slope first)
avgSlope = mean([-startSlope, endSlope]);

%% Store the indices used
indsUsed = [idxFirst1, idxLast1, idxFirst2, idxLast2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

% Compute slope right after current pulse start
idxFirst1 = idxCpStart;
idxLast1 = idxCpStart + nSamples - 1;
startSlope1 = compute_slope(tvecCpr, vvecCpr, idxFirst1, idxLast1);

% Compute slope right after current pulse end
idxFirst2 = idxCpEnd;
idxLast2 = idxCpEnd + nSamples - 1;
endSlope2 = compute_slope(tvecCpr, vvecCpr, idxFirst2, idxLast2);

% Compute slope right after current pulse start
idxFirst3 = idxCpStart2;
idxLast3 = idxCpStart2 + nSamples - 1;
startSlope3 = compute_slope(tvecCpr, vvecCpr, idxFirst3, idxLast3);

% Compute slope right after current pulse end
idxFirst4 = idxCpEnd2;
idxLast4 = idxCpEnd2 + nSamples - 1;
endSlope4 = compute_slope(tvecCpr, vvecCpr, idxFirst4, idxLast4);

% Choose the more negative of the start slopes 
%  and the more positive of the end slopes
startSlope = min([startSlope1, startSlope3]);
endSlope = max([endSlope2, endSlope4]);

addRequired(iP, 'nSamples', ...
    @(x) validateattributes(x, {'numeric'}, {'scalar'}));
parse(iP, tvecCpr, vvecCpr, ivecCpr, nSamples);

function [avgSlope, startSlope, endSlope, indsUsed] = compute_average_initial_slopes (tvecCpr, vvecCpr, ivecCpr, nSamples)

% Note: function calls are slower
%       /home/Matlab/Adams_Functions/compute_slope.m
startSlope = compute_slope(tvecCpr, vvecCpr, idxFirst1, idxLast1);
endSlope = compute_slope(tvecCpr, vvecCpr, idxFirst2, idxLast2);

% Crop the voltage trace
vvecCropped = vvecCpr((idxCprStart + 1):end);


%}

