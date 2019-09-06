%%function [output1] = create_pleth_EEG_movie (varargin)
%% Creates a synced movie from a .wmv file and a Spike2-exported .mat file in the current directory
% Usage: [output1] = create_pleth_EEG_movie (varargin)
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
%       varargin    - 'param1': TODO: Description of param1
%                   must be a TODO
%                   default == TODO
%                   - Any other parameter-value pair for TODO()
%
% Requires:
%       cd/struct2arglist.m
%       cd/all_files.m
%       cd/find_in_strings.m
%       cd/create_time_vectors.m
%       cd/read_frames.m
%       cd/create_synced_movie_trace_plot_movie.m
%
% Used by:
%       /TODO:dir/TODO:file

% File History:
% 2019-09-05 Created by Adam Lu
% 

%% Hard-coded parameters

%% TODO: Make optional arguments
spike2MatPath = '';
wmvPath = '';
eegChannelName = 'WIC_2';
% movieType = 'MPEG-4';             % Only works in Windows
movieType = 'Motion JPEG AVI';
outFolder = pwd;
movieBase = 'testEEGmovie';

%% Default values for optional arguments
% param1Default = [];             % default TODO: Description of param1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Set up Input Parser Scheme
% iP = inputParser;
% iP.FunctionName = mfilename;
% iP.KeepUnmatched = true;                        % allow extraneous options

% Add parameter-value pairs to the Input Parser
% addParameter(iP, 'param1', param1Default);

% Read from the Input Parser
% parse(iP, varargin{:});
% param1 = iP.Results.param1;

% Keep unmatched arguments for the TODO() function
% otherArguments = struct2arglist(iP.Unmatched);

%% Deal with the Spike2 MATLAB file
% Decide on the Spike2-exported mat file
if isempty(spike2MatPath)
    [~, spike2MatPath] = all_files('Extension', 'mat', 'MaxNum', 1, ...
                                    'ForceCellOutput', false);
end

% Load .mat file
spike2File = matfile(spike2MatPath);

% Get all the structure names
allStructNames = fieldnames(spike2File);

% Find the structure with EEG trace data
[~, eegStructName] = find_in_strings(eegChannelName, allStructNames);

% Extract the EEG struct
eegStruct = spike2File.(eegStructName);

% Extract the EEG trace data
traceData = eegStruct.values;

% Extract the EEG trace time info
timeStart = eegStruct.start;
siSeconds = eegStruct.interval;
nSamples = eegStruct.length;

% Construct a time vector
tVec = create_time_vectors(nSamples, 'TimeStart', timeStart, ...
                    'SamplingIntervalSeconds', siSeconds, 'TimeUnits', 's', ...
                    'BoundaryMode', 'leftadjust');

%% Deal with the movie file
% Decide on the wmv file
[~, wmvPath] = all_files('Extension', 'wmv', 'MaxNum', 1, ...
                                    'ForceCellOutput', false);

% Read all frames
[frames, vidObj] = read_frames(wmvPath);

%% Combine into a plot movie
% Create plot movie
[plotFrames, handles] = ...
    create_synced_movie_trace_plot_movie(frames, traceData, 'TimeVec', tVec);

%% Write movie to file
write_frames(plotFrames, outFolder, movieBase, movieType)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function write_frames (plotFrames, outFolder, fileBase, movieType)
%% Write frames to a file
% TODO: Pull out as write_frames.m
% TODO: Make OutFolder, FileBase, MovieType optional arguments

%% Hard-coded parameters
% TODO: Make optional arguments
extraFields = {'time', 'duration'};
plotFrameRate = [];

% Decide on the frame rate in Hz
if isempty(plotFrameRate)
    if isfield(plotFrames(1), 'duration')
        plotFrameRate = 1 / plotFrames(1).duration;
    else
        plotFrameRate = 12;
    end
end

% Remove 'time' and 'duration' to match MATLAB's frames structure
plotFramesMatlab = rmfield_custom(plotFrames, extraFields);
    
% Create a path for the movie
moviePathBase = fullfile(outFolder, fileBase);

% Create a VideoWriter object
writer = VideoWriter(moviePathBase, movieType);

% Set the frame rate in Hz
writer.FrameRate = plotFrameRate;

% Open the VideoWriter object
open(writer);

% Write frames to the file
writeVideo(writer, plotFramesMatlab);

% Close the VideoWriter object
close(writer);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outStruct = rmfield_custom (inStruct, fieldNames)
%% Removes a field from a structure only if it exists
% TODO: Pull out as rmfield_custom.m

% Initialize as the input structure
outStruct = inStruct;

% Remove fields one at a time
if iscell(fieldNames)
    for iField = 1:numel(fieldNames)
        % Remove the field if it exists
        outStruct = rmfield_if_exists(outStruct, fieldNames{iField});
    end
else
    outStruct = rmfield_if_exists(outStruct, fieldNames);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outStruct = rmfield_if_exists (inStruct, fieldName)
%% Removes a field from a structure only if it exists
% TODO: Pull out as part of rmfield_custom.m

if isfield(inStruct, fieldName)
    outStruct = rmfield(inStruct, fieldName);
else
    outStruct = inStruct;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%