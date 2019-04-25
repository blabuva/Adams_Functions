function [y, ia, ic] = unique_custom (x, varargin)
%% Returns the unique values in x, optionally without NaN
% Usage: [y] = unique_custom (x, varargin)
% Explanation:
%       This function removes NaN values not identified by the default unique() function.
% Example(s):
%       unique_custom([3, NaN, 3, 5, NaN], 'IgnoreNaN', true)
%       [y, ia, ic] = unique_custom([3 NaN 3 5 NaN])
%               = unique([3 NaN 3 5 NaN])
%               = unique_custom([3 NaN 3 5 NaN], 'IgnoreNaN', false, 'SaveOneNaN', true)
%               = unique_custom([3 NaN 3 5 NaN], 'IgnoreNaN', false, 'SaveOneNaN', false)
%               = unique_custom([3 NaN 3 5 NaN], 'SaveOneNaN', true)
%       [y, ia, ic] = unique_custom([3 NaN 3 5 NaN], 'IgnoreNaN', true)
%                   = unique_custom([3 NaN 3 5 NaN], 'IgnoreNaN', true, 'SaveOneNaN', true)
%       [y, ia, ic] = unique_custom([3 NaN 3 5 NaN], 'IgnoreNaN', true, 'SaveOneNaN', false)
%       
% Outputs:
%       y           - All unique values in x
%                   specified as a array
% Arguments:
%       x           - Matrix to check unique values
%                   must be a array
%       varargin    - 'IgnoreNaN': Whether to include NaN as distinct elements
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'SaveOneNaN': If NaN is present, preserve one at the
%                   end. If 'IgnoreNaN' == false, 'SaveOneNaN' has no
%                   effect
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - Any other parameter-value pair for the unique() function
%
% Requires:
%
% Used by:
%       /TODO:dir/TODO:file

% File History:
% 2019-04-01 BT - Adapted from https://www.mathworks.com/matlabcentral/
%                         answers/42561-treating-nan-as-a-
%                         unique-value-instead-of-as-a-distinct#answer_52371
% 

%% Hard-coded parameters

%% Default values for optional arguments
ignoreNaNDefault = false;  	% default IgnoreNaN
saveOneNaNDefault = true; 	% default SaveOneNaN

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
addRequired(iP, 'x', ...                  % array to be operated on
    @(z) validateattributes(z, {'char', 'string', 'cell', 'numeric'}, {'nonempty'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'IgnoreNaN', ignoreNaNDefault, ...
    @(z) validateattributes(z, {'logical'}, {'scalar'}));
addParameter(iP, 'SaveOneNaN', saveOneNaNDefault, ...
    @(z) validateattributes(z, {'logical'}, {'scalar'}));

% Read from the Input Parser
parse(iP, x, varargin{:});
ignoreNaN = iP.Results.IgnoreNaN;
saveOneNaN = iP.Results.SaveOneNaN;

% Keep unmatched arguments for the unique_custom() function
otherArguments = struct2arglist(iP.Unmatched);

% Check relationships between arguments

%% Preparation
% Initial unique matrix y of x
[y, ia, ic] = unique(x, otherArguments{:});

%% Do the job

% Ignoring NaN
if ignoreNaN
    % Preserving one NaN
    if saveOneNaN
        % NaN indices, does not include last NaN if present
        indNaN = isnan(y(1:end-1));
    else
        % All NaN indices
        indNaN = isnan(y(1:end));            
    end

    % Delete all NaN elements in y, ia, and ic
    y(indNaN) = [];
    ia(indNaN) = [];
    ic(indNaN) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%