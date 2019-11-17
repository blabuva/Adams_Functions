function errorStruct = compute_lts_errors (ltsTableSim, ltsTableReal, varargin)
%% Computes low-threshold spike errors for single neuron data
% Usage: errorStruct = compute_lts_errors (ltsTableSim, ltsTableReal, varargin)
% Explanation:
%       TODO
%
% Example(s):
%       TODO
%
% Outputs:
%       errorStruct - a structure of all the errors computed, with fields:
%                       ltsAmpErrors
%                       ltsDelayErrors
%                       ltsSlopeErrors
%                       avgLtsAmpError
%                       avgLtsDelayError
%                       avgLtsSlopeError
%                       avgLtsError
%                   specified as a scalar structure
% Arguments:    
%       ltsTableSim - a table of lts features from simulated voltage traces
%                   must be a table with columns:
%                       ltsPeakTime
%                       ltsPeakValue
%                       maxSlopeValue
%       ltsTableReal- a table of lts features from real voltage traces
%                   must be a table with columns:
%                       ltsPeakTime
%                       ltsPeakValue
%                       maxSlopeValue
%       varargin    - 'BaseNoise': baseline noise value(s)
%                   must be a numeric vector
%                   default == none provided
%                   - 'SweepWeights': sweep weights for averaging
%                   must be empty or a numeric vector with length == nSweeps
%                   default == set in compute_weighted_average.m
%                   - 'FeatureWeights': LTS feature weights for averaging
%                   must be empty or a numeric vector with length == nSweeps
%                   default == [1, 1, 1]
%                   - 'LtsExistError': a dimensionless error that penalizes 
%                               a misprediction of the existence/absence of LTS
%                   must be empty or a numeric vector with length == nSweeps
%                   default == 20
%                   - 'NormalizeError': whether to normalize errors 
%                                       by an initial error
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'InitLtsError': initial low-threshold spike errors
%                   must be empty or a numeric vector with length == nSweeps
%                   default == []
%
% Requires:
% TODO
%       cd/argfun.m
%       cd/count_samples.m
%       cd/count_vectors.m
%       cd/compute_rms_error.m
%       cd/compute_weighted_average.m
%       cd/create_time_vectors.m
%       cd/extract_subvectors.m
%       cd/find_window_endpoints.m
%       cd/force_column_vector.m
%       cd/iscellnumericvector.m
%       cd/isnumericvector.m
%       cd/match_row_count.m
%       cd/normalize_by_initial_value.m
%
% Used by:
%       cd/compute_single_neuron_errors.m

% File History:
% 2019-11-15 Adapted from compute_sweep_errors.m
% 2019-11-16 Added 'FeatureWeights' as an optional argument
% 2019-11-16 Added 'LtsExistError' as an optional argument
% 

%% Hard-coded parameters
% Consistent with singleneuronfittin58.m
defaultLtsFeatureWeights = [1; 2; 3];   % default weights for optimizing 
                                        %   LTS statistics
defaultLtsExistError = 20;              % how much error (dimensionless) to 
                                        %   penalize a sweep that mispredicted 
                                        %   the existence/absence of LTS

%% Default values for optional arguments
baseNoiseDefault = [];          % set later
sweepWeightsDefault = [];       % set in compute_weighted_average.m
featureWeightsDefault = [];     % set later
ltsExistErrorDefault = [];      % set later
normalizeErrorDefault = false;  % don't normalize errors by default
initLtsErrorDefault = [];   % no initial error values by default

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
addRequired(iP, 'ltsTableSim', ...
    @(x) validateattributes(x, {'table'}, {'2d'}));
addRequired(iP, 'ltsTableReal', ...
    @(x) validateattributes(x, {'table'}, {'2d'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'BaseNoise', baseNoiseDefault, ...
    @(x) assert(isnumericvector(x), 'BaseNoise must be a numeric vector!'));
addParameter(iP, 'SweepWeights', sweepWeightsDefault, ...
    @(x) assert(isnumericvector(x), 'SweepWeights must be a numeric vector!'));
addParameter(iP, 'FeatureWeights', featureWeightsDefault, ...
    @(x) assert(isnumericvector(x), 'FeatureWeights must be a numeric vector!'));
addParameter(iP, 'LtsExistError', ltsExistErrorDefault, ...
    @(x) assert(isnumericvector(x), 'LtsExistError must be a numeric vector!'));
addParameter(iP, 'NormalizeError', normalizeErrorDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'InitLtsError', initLtsErrorDefault, ...
    @(x) assert(isnumericvector(x), 'InitLtsError must be a numeric vector!'));

% Read from the Input Parser
parse(iP, ltsTableSim, ltsTableReal, varargin{:});
baseNoise = iP.Results.BaseNoise;
sweepWeights = iP.Results.SweepWeights;
featureWeights = iP.Results.FeatureWeights;
ltsExistError = iP.Results.LtsExistError;
normalizeError = iP.Results.NormalizeError;
initLtsError = iP.Results.InitLtsError;

%% Preparation
% Decide on LTS feature weights
if isempty(featureWeights)
    featureWeights = defaultLtsFeatureWeights;
end

% Decide on LTS existence error
if isempty(ltsExistError)
    ltsExistError = defaultLtsExistError;
end

% Extract low-threshold spike feature values to compute error for 
%   from both conditions
ltsPeakTimeSim = ltsTableSim.ltsPeakTime;
ltsPeakValueSim = ltsTableSim.ltsPeakValue;
maxSlopeValueSim = ltsTableSim.maxSlopeValue;

ltsPeakTimeReal = ltsTableReal.ltsPeakTime;
ltsPeakValueReal = ltsTableReal.ltsPeakValue;
maxSlopeValueReal = ltsTableReal.maxSlopeValue;

% Extract other feature values for uncertainty calculations
peakWidthSim = ltsTableReal.peakWidth;
peakWidthReal = ltsTableReal.peakWidth;
peakPromSim = ltsTableReal.peakProm;
peakPromReal = ltsTableReal.peakProm;
maxNoiseReal = ltsTableReal.maxNoise;

% Decide on baseline noise
if isempty(baseNoise)
    baseNoise = maxNoise;
end

% Compute default sweep weights
if isempty(sweepWeights)
    % Compute sweep weights based on baseNoise
    sweepWeights = 1 ./ baseNoise;

    % Normalize so that it sums to one
    sweepWeights = sweepWeights / sum(sweepWeights);
end

% Count the number of sweeps
nSweeps = max(height(ltsTableSim), height(ltsTableReal));

% Match row counts for sweep-dependent variables with the number of sweeps
[ltsPeakTimeSim, ltsPeakValueSim, maxSlopeValueSim, ...
        ltsPeakTimeReal, ltsPeakValueReal, maxSlopeValueReal, ...
        baseNoise, sweepWeights] = ...
    argfun(@(x) match_row_count(x, nSweeps), ...
            ltsPeakTimeSim, ltsPeakValueSim, maxSlopeValueSim, ...
            ltsPeakTimeReal, ltsPeakValueReal, maxSlopeValueReal, ...
            baseNoise, sweepWeights);

%% Modify sweep weights for LTS errors
% Initialize LTS sweep weights with sweep weights
ltsSweepWeights = sweepWeights;

% Determine whether each sweep has an LTS
noLTS = any(isnan([ltsPeakTimeSim, ltsPeakValueSim, maxSlopeValueSim, ...
                ltsPeakTimeReal, ltsPeakValueReal, maxSlopeValueReal]), 2);

% Make the sweeps with no LTS weight zero
%   Note: One cannot compute an error if both simulated and real traces
%           don't have a LTS
ltsSweepWeights(noLTS) = 0;

%% Compute feature uncertainties
% The amplitude uncertainty should be close to baseline noise
ltsAmpUncertainty = abs(baseNoise);

% The peak delay uncertainty should be close to peak width
ltsDelayUncertainty = abs(peakWidthReal);

% Compute the normalized error for peak prominence
peakPromNormError = abs((peakPromSim - peakPromReal) ./ peakPromReal);

% Compute the normalized error for peak width
peakWidthNormError = abs((peakWidthSim - peakWidthReal) ./ peakWidthReal);

% The slope uncertainty can be computed from a propagation of errors
slopeUncertainty = sqrt(peakPromNormError .^ 2 + peakWidthNormError .^ 2) ...
                    .* abs(maxSlopeValueReal);

%% Compute errors
% Compute dimensionless LTS errors for each sweep
ltsAmpErrors = compute_feature_error(ltsPeakValueReal, ltsPeakValueSim, ...
                                            ltsAmpUncertainty, ltsExistError);
ltsDelayErrors = compute_feature_error(ltsPeakTimeReal, ltsPeakTimeSim, ...
                                            ltsDelayUncertainty, ltsExistError);
ltsSlopeErrors = compute_feature_error(maxSlopeValueReal, maxSlopeValueSim, ...
                                            slopeUncertainty, ltsExistError);

% Compute weighted-root-mean-squared-averaged LTS errors (dimensionless)
[avgLtsAmpError, avgLtsDelayError, avgLtsSlopeError] = ...
    argfun(@(x) compute_weighted_average(x, 'Weights', ltsSweepWeights, ...
                        'IgnoreNaN', true, 'AverageMethod', 'root-mean-square');
            ltsAmpErrors, ltsDelayErrors, ltsSlopeErrors);

% Put the feature errors together
featureErrors = [avgLtsAmpError; avgLtsDelayError; avgLtsSlopeError];

% Average LTS error (dimensionless) is the weighted average of 
%   the LTS feature errors, weighted by featureWeights
avgLtsError = compute_weighted_average(featureErrors, ...
                'Weights', featureWeights, ...
                'AverageMethod', 'linear', 'IgnoreNaN', true);

% If requested, make errors dimensionless by 
%   storing or dividing by an initial error value
if normalizeError
    [normAvgLtsError, initLtsError] = ...
        normalize_by_initial_value(avgLtsError, initLtsError);
end

%% Store in output errors structure
errorStruct.ltsAmpErrors = ltsAmpErrors;
errorStruct.ltsDelayErrors = ltsDelayErrors;
errorStruct.ltsSlopeErrors = ltsSlopeErrors;
errorStruct.ltsSweepWeights = ltsSweepWeights;
errorStruct.avgLtsAmpError = avgLtsAmpError;
errorStruct.avgLtsDelayError = avgLtsDelayError;
errorStruct.avgLtsSlopeError = avgLtsSlopeError;
errorStruct.avgLtsError = avgLtsError;

% Store normalized errors
if normalizeError
    errorStruct.initLtsError = initLtsError;
    errorStruct.normAvgLtsError = normAvgLtsError;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function featureError = compute_feature_error (valueReal, valueSim, ...
                                                uncertainty, featureExistError)
%% Computes feature error based on feature existence for each sweep

% Initialize errors
featureError = nan(size(valueReal));

% Put values side by side
allValues = [valueReal, valueSim];

% Determine whether each sweep each condition has no features
noFeature = isnan(allValues);

% Determine whether feature does not exist in either conditions
noFeatureInBoth = all(noFeature, 2);

% The feature error is not available in this case
featureError(noFeatureInBoth) = NaN;

% Determine whether feature exists in one condition but not the other
hasFeatureInOneOnly = any(noFeature, 2) & ~all(noFeature, 2);

% The feature error is a fixed feature existence error 
%   (higher than typical errors) in this case
featureError(hasFeatureInOneOnly) = featureExistError;

% Determine whether feature exists in both conditions
hasFeatureInBoth = ~any(noFeature, 2);

% Compute the normalized difference between simulated and real feature values
normalizedDifference = diff(allValues, 1, 2) / abs(uncertainty);

% The feature error is the normalized difference in this case
featureError(hasFeatureInBoth) = normalizedDifference(hasFeatureInBoth);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

if normalizeError
    [normAvgLtsAmpError, initLtsAmpError] = ...
        normalize_by_initial_value(avgLtsAmpError, initLtsAmpError);
    [normAvgLtsDelayError, initLtsDelayError] = ...
        normalize_by_initial_value(avgLtsDelayError, initLtsDelayError);
    [normAvgLtsSlopeError, initLtsSlopeError] = ...
        normalize_by_initial_value(avgLtsSlopeError, initLtsSlopeError);
end
featureErrors = [normAvgLtsAmpError; normAvgLtsDelayError; normAvgLtsSlopeError];
errorStruct.initLtsAmpError = initLtsAmpError;
errorStruct.normAvgLtsAmpError = normAvgLtsAmpError;
errorStruct.initLtsDelayError = initLtsDelayError;
errorStruct.normAvgLtsDelayError = normAvgLtsDelayError;
errorStruct.initLtsSlopeError = initLtsSlopeError;
errorStruct.normAvgLtsSlopeError = normAvgLtsSlopeError;

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
