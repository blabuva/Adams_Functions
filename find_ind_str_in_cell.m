function varargout = find_ind_str_in_cell(str, cellArray, varargin)
%% Returns all indices of a particular string (could be represented by substrings) in a list of strings
% Usage: [indices, elements] = find_ind_str_in_cell(str, cellArray, varargin)
% Explanation:
%   This works like the strcmp() or strcmpi function in Matlab, 
%       especially when 'SearchMode' == 'exact'.
%   However, this returns indices and not logical arrays,
%       and returns the corresponding elements.
%   Also, default is 'SearchMode' == 'substrings', which allows str to be 
%       a substring of a match in cellArray.
% Example(s):
%       cell = {'Mark''s fish', 'Peter''s fish', 'Katie''s sealion'};
%       find_ind_str_in_cell('fish', cell)
%       find_ind_str_in_cell('Peter', cell)
%       find_ind_str_in_cell({'Katie', 'lion'}, cell)
%       find_ind_str_in_cell('fish', cell, 'MaxNum', 1)
%       find_ind_str_in_cell('Fish', cell, 'IgnoreCase', 1)
%       find_ind_str_in_cell('Fish', cell, 'IgnoreCase', false)
%       find_ind_str_in_cell('sealion', cell, 'SearchMode', 'ex')
%       find_ind_str_in_cell('sealion', cell, 'SearchMode', 'sub')
% Outputs:
%       indices     - indices of the cell array containing that exact string
%                       or containing a substring or all substrings provided; 
%                       could be empty
%                   specified as a numeric array
%       elements    - elements of the cell array corresponding to those indices
%                   specified as a cell array if more than one indices 
%                       or the element if only one index; or an empty string
% Arguments:
%       str         - string(s) or substring(s) of interest
%                       If str is a cell array, all substrings must 
%                           exist in the string to be matched
%                   must be a string/character array or 
%                       a cell array of strings/character arrays
%       cellArray   - a cell array that contains strings
%                   must be a string/character array or 
%                       a cell array of strings/character arrays
%       varargin    - 'SearchMode': the search mode
%                   must be an unambiguous, case-insensitive match to one of:
%                       'exact'         - str must be identical to 
%                                           an element in cellArray
%                       'substrings'    - str can be a substring or 
%                                           a cell array of substrings
%                       'regexp'        - str is considered a regular expression
%                   if searchMode is 'exact' or 'regexp', 
%                       str cannot be a cell array
%                   default == 'substrings'
%                   - 'IgnoreCase': whether to ignore differences in letter case
%                   must be logical 1 (true) or 0 (false)
%                   default == false
%                   - 'MaxNum': maximum number of indices to find
%                   must be empty or a positive integer scalar
%                   default == numel(cellArray)
%                   - 'ReturnNan': Return NaN instead of empty if nothing found
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%
% Requires:
%       cd/compute_combined_trace.m
%       cd/create_error_for_nargin.m
%       cd/find_custom.m
%
% Used by:
%       cd/find_index_in_array.m
%       cd/ispositiveintegerscalar.m
%       cd/increment_editbox.m
%       cd/m3ha_correct_unbalanced_bridge.m
%       cd/m3ha_import_raw_traces.m
%       cd/m3ha_xolotl_plot.m
%       cd/plot_swd_raster.m
%       cd/renamevars.m
%       cd/update_params.m
%       cd/validate_string.m
%       cd/xolotl_compartment_index.m
%       cd/ZG_extract_all_IEIs.m
%       cd/ZG_extract_all_data.m
%       /home/Matlab/minEASE/minEASE.m
%       /home/Matlab/minEASE/combine_eventInfo.m
%       /home/Matlab/minEASE/extract_from_minEASE_output_filename.m
%       /home/Matlab/minEASE/read_params.m
%       /home/Matlab/minEASE/gui_examine_events.m
%       /home/Matlab/EEG_gui/EEG_gui.m
%       /home/Matlab/EEG_gui/plot_EEG_event_raster.m
%       /media/adamX/m3ha/data_dclamp/dclampPassiveFitter.m
%       /media/adamX/m3ha/data_dclamp/PlotHistogramsRefineThreshold.m
%       /media/adamX/m3ha/data_dclamp/test_sweep.m
%       /media/adamX/m3ha/data_dclamp/remove_E092810_0000.m
%       /media/adamX/m3ha/data_dclamp/compare_statistics.m
%       /media/adamX/m3ha/optimizer4gabab/optimizergui_4compgabab.m
%       /media/adamX/m3ha/optimizer4gabab/optimizer_4compgabab.m
%       /media/adamX/m3ha/optimizer4gabab/compare_neuronparams.m
%       /media/adamX/RTCl/neuronlaunch.m
%       /media/adamX/RTCl/raster_plot.m
%       /media/adamX/RTCl/tuning_curves.m
%       /media/adamX/RTCl/single_neuron.m

% 2016-09--- Created
% 2016-10-13 moved to Adams_Functions
% 2016-11-30 Added searchMode
% 2017-04-05 Fixed the size of str_cell so that it can take column or row arrays
% 2017-04-26 Now str can be a cell array of substrings too
% 2017-04-27 Improved inputParser scheme
% 2017-05-09 Added elements as output
% 2017-05-25 Changed line width and indentation
% 2017-06-09 Fixed the returned element to be of original case
% 2018-05-01 Added MaxNum as a parameter
% 2018-08-02 Added 'regexp' as a SearchMode
% 2019-01-04 Now uses compute_combined_trace.m instead of intersect_over_cells.m
% 2019-01-04 Simplified code with contains()
% 2019-01-09 Added 'ReturnNan' as an optional argument
% 2019-01-09 Now uses find_custom.m

%% Hard-coded constants
validSearchModes = {'exact', 'substrings', 'regexp'};

%% Default values for optional arguments
searchModeDefault = 'substrings';       % default search mode
ignoreCaseDefault = false;              % whether to ignore case by default
maxNumDefault = [];                     % will be changed to numel(cellArray)
returnNanDefault = false;   % whether to return NaN instead of empty 
                            %   if nothing found by default

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 2
    error(create_error_for_nargin(mfilename));
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add required inputs to the Input Parser
addRequired(iP, 'str', ...              % a string/substrings of interest
    @(x) assert(ischar(x) || iscellstr(x) || isstring(x), ...
        ['str must be a character array or a string array ', ...
            'or cell array of character arrays!']));
addRequired(iP, 'cellArray', ...        % template strings
    @(x) assert(ischar(x) || iscellstr(x) || isstring(x), ...
        ['cellArray must be a character array or a string array ', ...
            'or cell array of character arrays!']));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'SearchMode', searchModeDefault, ...   % the search mode
    @(x) any(validatestring(x, validSearchModes)));
addParameter(iP, 'IgnoreCase', ignoreCaseDefault, ...   % whether to ignore case
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'MaxNum', maxNumDefault, ...       % maximum number of indices
    @(x) assert(isempty(x) || ispositiveintegerscalar(x), ...
                'MaxNum must be either empty or a positive integer scalar!'));
addParameter(iP, 'ReturnNan', returnNanDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));

% Read from the Input Parser
parse(iP, str, cellArray, varargin{:});
searchMode = validatestring(iP.Results.SearchMode, validSearchModes);
ignoreCase = iP.Results.IgnoreCase;
maxNum = iP.Results.MaxNum;
returnNan = iP.Results.ReturnNan;

% Check relationships between arguments
if iscell(str) && ...
    (strcmpi(searchMode, 'exact') || strcmpi(searchMode, 'regexp'))
    error(['First input cannot be a cell array if ', ...
            'SearchMode'' is ''exact'' or ''rexexp''!']);
end

%% Prepare for the search
% Count the number of indices
nIndices = numel(cellArray);

% Set the maximum number of indices if not provided
if isempty(maxNum)
    maxNum = nIndices;
end

%% Find the indices
switch searchMode
case 'exact'        % String must be an exact match
    % Construct a cell array with the same size as cellArray 
    %   but with str duplicated throughout
    str_cell = cell(size(cellArray));    % a cell array to store copies of str
    for k = 1:numel(cellArray)
        % Make the kth element the same as str
        str_cell{k} = str;
    end

    % Find indices that corresponds to str exactly in cellArray, 
    %   case-insensitive if IgnoreCase is set to true
    if ignoreCase
        indices = find_custom(cellfun(@strcmpi, cellArray, str_cell), ...
                                maxNum, 'ReturnNan', returnNan);
    else
        indices = find_custom(cellfun(@strcmp, cellArray, str_cell), ...
                                maxNum, 'ReturnNan', returnNan);
    end
case 'substrings'   % String can be a substring or a cell array of substrings
    % Convert each string to lower case if IgnoreCase is set to true
    if ignoreCase
        cellArrayMod = cellfun(@lower, cellArray, 'UniformOutput', false);
    else
        cellArrayMod = cellArray;
    end

    % Find indices that contain str in cellArrayMod
    if iscell(str)        % if str is a cell array of substrings
        % Test whether each element contains each substring
        if iscell(str)
            hasEachStr = cellfun(@(x) contains(cellArrayMod, x, ...
                                        'IgnoreCase', ignoreCase), ...
                                str, 'UniformOutput', false);
        else
            hasEachStr = arrayfun(@(x) contains(cellArrayMod, x, ...
                                        'IgnoreCase', ignoreCase), ...
                                str, 'UniformOutput', false);
        end

        % Test whether each element contains all substrings
        hasStr = compute_combined_trace(hasEachStr, 'all');
    else                    % if str is a single substring
        % Test whether each element of the cell array contain the substring
        hasStr = contains(cellArrayMod, str, 'IgnoreCase', ignoreCase);    
    end

    % Find the indices that contain the substring
    indices = find_custom(hasStr, maxNum, 'ReturnNan', returnNan);
case 'regexp'   % String is considered a regular expression
    % Find all starting indices in the strings for the matches
    if ignoreCase
        startIndices = regexpi(cellArray, str);
    else
        startIndices = regexp(cellArray, str);
    end

    % Test whether each str is in the cell array
    isInCell = ~isemptycell(startIndices);

    % Find all indices in the cell array for the matches
    indices = find_custom(isInCell, maxNum, 'ReturnNan', returnNan);
end

%% Return the elements too
if nargout > 1
    if ~isempty(indices) && any(isnan(indices))
        elements = NaN;
    elseif ~isempty(indices) 
        if numel(indices) > 1
            elements = cellArray(indices);
        else
            elements = cellArray{indices};
        end
    else
        elements = '';
    end
end

%% Outputs
varargout{1} = indices;
if nargout > 1
    varargout{2} = elements;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

validSearchModes = {'exact', 'substrings'};

if strcmpi(searchMode, 'exact')             % String must be exact
elseif strcmpi(searchMode, 'substrings')    % String can be a substring 
                                            % or a cell array of substrings
end

indicesEachStr = contains(cellArrayMod, strMod);

% Find the indices that contain the substring
indicesarray = strfind(cellArrayMod, strMod);
indices = find(~cellfun(@isempty, indicesarray), maxNum);

% Convert substring to lower case if IgnoreCase is set to true
if ignoreCase
    strMod = lower(str);
else
    strMod = str;
end

indicesarray = strfind(cellArrayMod, strMod(k));    
indicesEachStr{k} = find(~cellfun(@isempty, indicesarray));

% Convert each substring to lower case if IgnoreCase is set to true
if ignoreCase
    strMod = cellfun(@lower, str, 'UniformOutput', false);
else
    strMod = str;
end

nStrs = numel(str);
indicesEachStr = cell(1, nStrs);
for k = 1:nStrs
    % Test whether each element of the cell array contain the substring
    hasStr = contains(cellArrayMod, str(k), 'IgnoreCase', ignoreCase);

    % 
    indicesEachStr{k} = find(hasStr);
end

% Find the indices that contain all substrings by intersection
indices = intersect_over_cells(indicesEachStr);
%       cd/intersect_over_cells.m

% If more than maxNum indices found, 
%   restrict to the first maxNum indices
if length(indices) > maxNum
    indices = indices(1:maxNum);
end

indices = find(~cellfun(@isempty, startIndices), maxNum);

@(x) assert(ischar(x) || iscell(x) && (min(cellfun(@ischar, x)) || ...
            min(cellfun(@isstring, x))) || isstring(x), ...
            ['First input must be either a string/character array ', ...
            'or a cell array of strings/character arrays!']));
@(x) assert(iscell(x) && (min(cellfun(@ischar, x)) || ...
            min(cellfun(@isstring, x))), ...
            ['Second input must be a cell array ', ...
            'of strings/character arrays!']));

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%