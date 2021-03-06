% Set input file
date = '20140717';
prot = 'CI';

% Run through all possible files

for celln = 1:1:5
    for protn = 0:1:4
        for recn = 1:1:7
            file = sprintf('PClamp_Data/%s%02d_%s%d_%d.abf', date, celln, prot, protn, recn);
            if exist(file, 'file') == 2 % if file exists

                % Read file to alldata
                [alldata, si] = abf2load(file); % si is the sampling interval in usec

                % Find data parameters
                nsweeps = size(alldata, 3);     % Number of sweeps
                ntimepoints = size(alldata,1);  % Number of time points

                % Find vector for timepoints in msec
                timepoints = ( si/1000 : si/1000 : ntimepoints * si/1000 )';

                % Find spikes
                is_local_maximum = zeros(size(alldata));
                is_local_minimum = zeros(size(alldata));
                is_spike = zeros(size(alldata));
                for i = 1:nsweeps
                    % Finds all local maxima and minima
                    for j = 2:ntimepoints-1
                        is_local_maximum(j,1,i) = alldata(j,1,i) > alldata(j-1,1,i) && alldata(j,1,i) >= alldata(j+1,1,i);
                        is_local_minimum(j,1,i) = alldata(j,1,i) < alldata(j-1,1,i) && alldata(j,1,i) <= alldata(j+1,1,i);
                    end

                    % Finds all spike peaks 
                    % Criteria for a spike: 
                    %  (1) Must be a local maximum 10 mV higher than the previous local minimum
                    for j = 2:ntimepoints-1
                        if is_local_maximum(j,1,i)
                            plmin = j-1; % possible index of previous local minimum
                            while ~ (is_local_minimum(plmin,1,i) || plmin == 1) 
                                plmin = plmin - 1;
                            end
                %             flmin = j+1; % possible index of following local minimum
                %             while ~ (is_local_minimum(flmin,1,i) || flmin == ntimepoints) 
                %                 flmin = flmin + 1;
                %             end
                %             flmax = j+1; % possible index of following local maximum
                %             while ~ (is_local_maximum(flmax,1,i) || flmax == ntimepoints) 
                %                 flmax = flmax + 1;
                %             end
                %             if plmin > 1 && flmin < ntimepoints
                            if plmin > 1
                                % Compare rise in membrane potential to thresholds (10 mV)
                                is_spike(j,1,i) = alldata(j,1,i) - alldata(plmin,1,i) > 10;
                %                is_spike(j,1,i) = alldata(j,1,i) - alldata(plmin,1,i) > 20;
                %                is_spike(j,1,i) = alldata(j,1,i) - alldata(plmin,1,i) > 10 && ...
                %                     (alldata(j,1,i) - alldata(flmin,1,i) > 10 || alldata(flmax,1,i) - alldata(j,1,i) < 10);
                            end
                        end
                    end
                    %  (2) Must be 5 mV higher than the minimum value between the spike and the following spike
                    for j = 2:ntimepoints-1
                        if is_spike(j,1,i)
                            fspike = j+1; % possible index of following spike
                            while ~ (is_spike(fspike,1,i) || fspike == ntimepoints) 
                                fspike = fspike + 1;
                            end
                            is_spike(j,1,i) = alldata(j,1,i) - min(alldata(j:fspike,1,i)) > 5;
                        end
                    end
                end

                % Plot each sweep individually
                for i = 1:nsweeps
                    cdata = alldata(:,1,i);
                    spike_indices = find(is_spike(:,1,i));
                    figure(i)
                    plot(timepoints, cdata, 'k')
                    hold on
                    plot(timepoints(spike_indices), cdata(spike_indices), 'xr')
                    % axis([0 10000 -160 40])
                    axis([0 4000 -160 40])
                    % xlim([0 4000])
                    title(sprintf('Data for %s%02d_%s%d_%d.abf, Sweep #%d', date, celln, prot, protn, recn, i), 'interpreter', 'none')
                    xlabel('Time (ms)')
                    ylabel('Membrane Potential (mV)')
                    saveas(gcf, sprintf('PClamp_Data/%s%02d_%s%d_%d_sweep%d', date, celln, prot, protn, recn, i), 'png')
                    hold off
                end

                % Plot all data together
                figure(nsweeps + 1)
                jmap = colormap(jet);
                for i = 1:nsweeps
                    cdata = alldata(:,1,i);
                    plot(timepoints, cdata, 'color', jmap((i * floor(size(jmap,1)/10)), :))
                    hold on;
                end
                hold off
                %axis([0 10000 -160 40])
                axis([0 4000 -160 40])
                title(sprintf('Data for %s%02d_%s%d_%d.abf', date, celln, prot, protn, recn), 'interpreter', 'none')
                xlabel('Time (ms)')
                ylabel('Membrane Potential (mV)')
                % HOW TO GENERALIZE THE FOLLOWING?
                legend('Sweep #1','Sweep #2','Sweep #3','Sweep #4','Sweep #5','Sweep #6','Sweep #7','Sweep #8','Sweep #9','Sweep #10')
                saveas(gcf, sprintf('PClamp_Data/%s%02d_%s%d_%d_all', date, celln, prot, protn, recn), 'png')

                % For debug
                c_is_local_maximum = is_local_maximum(:,:,1);
                c_is_local_minimum = is_local_minimum(:,:,1);
                c_is_spike = is_spike(:,:,1);
                c_data = alldata(:,1,1);

            end
        end
    end
end