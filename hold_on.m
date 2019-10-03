function wasHold = hold_on
%% Holds on and returns previous status
% Usage: wasHold = hold_on
% Explanation:
%       TODO
%
% Example(s):
%       wasHold = hold_on;
%       hold_off(wasHold);
%
% Outputs:
%       wasHold     - whether the current axes was held on
%                   specified as a logical scalar
%
% Used by:
%       cd/plot_chevron.m
%       cd/plot_tuning_curve.m

% File History:
% 2019-10-02 Created by Adam Lu

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Do the job
if ~ishold
    wasHold = false;
    hold on
else
    wasHold = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%