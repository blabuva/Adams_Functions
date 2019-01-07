function stdErr = nanstderr(X)
%% Calculate the standard error of the mean excluding NaN values
% Usage: stdErr = nanstderr(X)
%
% Used by:
%		/media/adamX/Paula_IEIs/paula_iei4.m
%       /home/Matlab/Adams_Functions/ZG_fit_IEI_distributions.m
%
% 2017-12-14 Created

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stdErr = nanstd(X)./sqrt(length(X(~isnan(X))));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%