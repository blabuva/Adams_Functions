function vectorsCell = force_column_cell (vectorsOrig, varargin)
%% Transforms a row cell array or nonvector to a column cell array of vectors
% Usage: vectorsCell = force_column_cell (vectorsOrig, varargin)
% Explanation:
%       This is an attempt to standardize the way multiple vectors are stored
%           -- always as column cell vectors
%       1. A row cell vector is converted to a column cell vector
%       2. A non-vector cell array is transformed to a column cell vector
%           of column cell arrays
%           However, if 'ToLinear' is true, it will simply be linearized 
%           as a column cell vector
%       3. An empty numeric array or a character array are placed in a cell array
%       4. A numeric vector is forced as a column vector
%           (force_column_numeric.m is used), then placed in a cell array
%       5. A numeric non-vector array is transformed to a column cell vector
%           of column numeric vectors based on the first dimension
%
% Example(s):
%       load_examples;
%       force_column_cell(myCellNumeric2D)
%       force_column_cell(myCellRowVecs)
%       force_column_cell(myCellStr2D)
%       force_column_cell(myCellStr2D, 'ToLinear', true)
%       force_column_cell(myNumeric2D)
%       force_column_cell(myNumeric3D)
%
% Outputs:
%       vectorsCell - vectors as a column cell array
%                   specified as a column cell array
%
% Arguments:
%       vectorsOrig - original vectors
%                   Note: If an array, each column is a vector 
%                           to be placed in a cell
%                   must be a numeric array or a cell array 
%                       or a character vector
%       varargin    - 'ToLinearize': whether to linearize a cell array
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
% Requires:
%       cd/extract_columns.m
%       cd/force_column_numeric.m
%
% Used by:
%       cd/compute_rms_error.m
%       cd/construct_fullpath.m
%       cd/create_average_time_vector.m
%       cd/extract_columns.m
%       cd/filter_and_extract_pulse_response.m
%       cd/find_pulse_endpoints.m
%       cd/force_column_numeric.m
%       cd/force_row_numeric.m
%       cd/m3ha_import_raw_traces.m
%       cd/m3ha_plot_individual_traces.m
%       cd/match_format_vector_sets.m
%       cd/parse_pulse.m
%       cd/parse_pulse_response.m
%       cd/plot_all_abfs.m
%       cd/plot_struct.m
%       cd/run_neuron.m

% File History:
% 2018-10-10 Created by Adam Lu
% 2018-10-19 Now accepts character vectors
% 2018-10-27 Now places empty numeric arrays in a cell array
% 2018-12-18 Now defaults 2D cell arrays to be separated by columns
%               added 'ToLinearize' (default == 'false')
% 2018-12-19 Now uses extract_columns.m
% 

%% Default values for optional arguments
toLinearizeDefault = false;     % whether to linearize a nonvector cell array

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
addRequired(iP, 'vectorsOrig', ...
    @(x) isnumeric(x) || iscell(x) || ischar(x));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'ToLinearize', toLinearizeDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));

% Read from the Input Parser
parse(iP, vectorsOrig, varargin{:});
toLinearize = iP.Results.ToLinearize;

%% Do the job
if iscell(vectorsOrig) && ...
        (isempty(vectorsOrig) || isrow(vectorsOrig) || toLinearize)
    % Reassign as a column
    vectorsCell = vectorsOrig(:);
elseif ischar(vectorsOrig) || isnumeric(vectorsOrig) && isempty(vectorsOrig)
    % Place in a cell array
    vectorsCell = {vectorsOrig};
elseif isnumeric(vectorsOrig) || ...
        iscell(vectorsOrig) && ~isvector(vectorsOrig) && ~toLinearize
    % Force any numeric vector as a column vector
    if isnumeric(vectorsOrig)
        vectorsOrig = force_column_numeric(vectorsOrig, 'IgnoreNonVectors', true);
    end

    % Extract as a cell array
    vectorsCell = ...
        extract_columns(vectorsOrig, 'all', 'OutputMode', 'single', ...
                        'TreatCellAsArray', true);
else
    % Do nothing
    vectorsCell = vectorsOrig;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

nVectors = size(vectorsOrig, 2);

% Reassign as a column
vectorsCell = vectorsCell(:);

if iscell(vectorsOrig) && ~iscolumn(vectorsOrig)

%       cd/count_vectors.m
% Count the number of vectors
nVectors = count_vectors(vectorsOrig);

% Extract as a cell array
vectorsCell = arrayfun(@(x) vectorsOrig(:, x), ...
                        transpose(1:nVectors), ...
                        'UniformOutput', false);
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
