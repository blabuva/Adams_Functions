function vectors = force_column_numeric (vectors, varargin)
%% Transform row numeric vector(s) or numeric array(s) to column numeric vector(s)
% Usage: vectors = force_column_numeric (vectors, varargin)
% Explanation:
%       Starting with a cell array of numeric vectors, 
%           this function makes sure each vector is a column vector.
%       If a single numeric vector (may be empty) is provided, 
%           the function makes sure it's a column vector.
%       If a numeric non-vector array is provided, the function 
%           force_column_cell.m is applied 
%           unless 'IgnoreNonVectors' is set to true
%
% Example(s):
%       vector = force_column_numeric(vector);
%       vectors = force_column_numeric(vectors);
%       force_column_numeric({[3, 4], [5; 6], magic(3)})
%
% Outputs:
%       vectors     - vectors transformed
%                   specified as a numeric array 
%                       or a cell array of numeric vectors
%
% Arguments:
%       vectors     - original vectors
%                   must be a numeric vector or a cell array of numeric arrays
%       varargin    - 'IgnoreNonVectors': whether to ignore non-vectors
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%
% Requires:
%       cd/force_column_cell.m
%       cd/iscellnumeric.m
%
% Used by:    
%       cd/compute_average_trace.m
%       cd/compute_single_neuron_errors.m
%       cd/compute_sweep_errors.m
%       cd/count_samples.m
%       cd/extract_columns.m
%       cd/fit_2exp.m
%       cd/force_column_cell.m
%       cd/match_format_vectors.m
%       cd/match_reciprocals.m
%       cd/m3ha_create_simulation_params.m
%       cd/plot_cfit_pulse_response.m

% File History:
% 2018-10-12 Created by Adam Lu
% 2018-10-27 Added 'IgnoreNonVectors' as an optional argument
% TODO: Deal with 3D arrays
% 

%% Default values for optional arguments
ignoreNonVectorsDefault = false;    % don't ignore non-vectors by default

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
addRequired(iP, 'vectors', ...                   % vectors
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vectors must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'IgnoreNonVectors', ignoreNonVectorsDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));

% Read from the Input Parser
parse(iP, vectors, varargin{:});
ignoreNonVectors = iP.Results.IgnoreNonVectors;

%% Do the job
if isnumeric(vectors) && ~iscolumn(vectors)
    if isempty(vectors)
        % Do nothing
    elseif isvector(vectors)
        % Reassign as a column
        vectors = vectors(:);
    else
        % Must be a non-vector
        if ~ignoreNonVectors
            % Reassign as a column cell array of column vectors
            vectors = force_column_cell(vectors);
        end
    end
elseif iscell(vectors)
    % Extract as a cell array
    %   Note: this will have a recursive effect
    vectors = cellfun(@force_column_numeric, vectors, 'UniformOutput', false);
else
    % Do nothing
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

addRequired(iP, 'vectors', ...
    @(x) isnumeric(x) && isvector(x) || ...
        iscell(x) && all(cellfun(@(x) isnumeric(x) && isvector(x), x)) );

%       vectors     - original vectors
%                   must be a numeric vector or a cell array of numeric vectors
addRequired(iP, 'vectors', ...
    @(x) isnumeric(x) || ...
        iscell(x) && all(cellfun(@(x) isnumeric(x) && isvector(x), x)) );

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%