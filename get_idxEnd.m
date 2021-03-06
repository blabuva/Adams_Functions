function idxEnd = get_idxEnd (idxPeak, fullDecayTime, interStimulusInterval)
%% Get the index of the end of an event
% Usage: idxEnd = get_idxEnd (idxPeak, fullDecayTime, interStimulusInterval)
%
% Used by:
%       cd/minEASE_gui_examine_events.m

% File History:
%   2018-02-08 Moved from minEASE_gui_examine_events.m

if ~isnan(fullDecayTime)
    % Use the index of "full decay point"
    idxEnd = idxPeak + fullDecayTime;
else
    if isnan(interStimulusInterval)
        % Event is removed, so use the peak index
        idxEnd = idxPeak;
    else
        % Use the index just before next event breakpoint
        idxEnd = idxPeak + interStimulusInterval - 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
