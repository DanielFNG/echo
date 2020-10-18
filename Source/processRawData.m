function [cycles, times, fail, outputs] = processRawData(...
    markers, grfs, save_dir, osim_dir, settings, apo, wait)

    function times = process(...
            markers, grfs, save_dir, settings, apo)
        times = 0;
        if isempty(markers)
            times = processGRFData(save_dir, grfs, ...
                settings.grf_system, ...
                settings.speed, settings.inclination, ...
                apo, settings.feet, 'GRF');
        elseif isempty(grfs)
            processMarkerData(save_dir, markers, ...
                settings.marker_system, ...
                settings.speed, settings.feet, 'Markers');
        else
            processMotionData(save_dir, save_dir, markers, grfs, ...
                settings.marker_system, settings.grf_system, ...
                settings.x_offset, settings.y_offset, settings.z_offset, ...
                settings.time_delay, settings.speed, settings.inclination, ...
                apo, settings.feet, ...
                settings.seg_mode, 'Markers', 'GRF');
        end
    end

    if nargin == 6
        wait = true;
    end

    if strcmp(settings.operation_mode, 'online')
        if ~isempty(markers)
            % Wait until raw vicon data is available.
            [path, name, ~] = fileparts(markers);
            trial_name = [path filesep name];
            fail = waitUntilWritable([trial_name '.x2d'], 0.5);
            if fail
                cycles = 0;
                times = 0;
                return
            end
            if wait
                pause(4); % 4 second pause to give extra 4s of assistance - so as 
                          % not to confuse subject with audio feedback while 
                          % still recording
            end
            processViconData(trial_name);
        else
            [path, name, ~] = fileparts(grfs);
            trial_name = [path filesep name];
            waitUntilWritable([trial_name '.x2d'], 0.5);
            processViconEMG(trial_name, settings);
        end
    else
        fail = false;
    end

    % Wait until data has finished being printed.
    if ~isempty(markers)
        waitUntilWritable(markers, 2);
    end
    if ~isempty(grfs)
        waitUntilWritable(grfs, 2);
    end
    
    % Some output.
    fprintf('\nRaw data files available. Beginning processing steps now.\n');

    % Process the data, fixing any gaps at the start/end of trials.
    try
        times = process(markers, grfs, save_dir, settings, apo);
    catch
        % Try one more time incase it wasn't fully printed.
        try
            process(markers, grfs, save_dir, settings, apo);
        catch err
            rethrow(err);
        end
    end

    % Run appropriate OpenSim analyses.
    markers_folder = [save_dir filesep 'right' filesep 'Markers'];
    grf_folder = [save_dir filesep 'right' filesep 'GRF'];
    switch settings.data_inputs
        case 'Motion'
            trials = createTrials(settings.model, markers_folder, ...
                osim_dir, grf_folder);
        case {'GRF', 'EMG'}
            trials = createTrials(settings.model, [], ...
                osim_dir, grf_folder);
        case 'Markers'
            trials = createTrials(settings.model, markers_folder, ...
                osim_dir, []);
    end
    
    % For time-savings, restrict to the number of trials you can compute in
    % 1 CPU cycle. 
    if length(trials) > settings.max_trials
        trials = trials(end - settings.max_trials + 1:end);
    end
    
%     % Run IK first
%     [trials, ~] = runBatchParallel('IK', trials);
%     
%     % Prune trials with bad tracking
%     good_trials = ones(1, length(trials));
%     parfor i = 1:length(trials)
%         error_data = Data([trials{i}.results_paths.IK filesep 'default_ik_marker_errors.sto']);
%         if mean(error_data.getColumn('total_squared_error')) > 0.01
%             good_trials(i) = 0;
%         end
%     end
%     trials = trials(good_trials);
    
    % Now run SO
    [trials, outputs] = runBatchParallel(... % outputs will be useful for SO quantifying
        settings.opensim_analyses, trials, settings.opensim_args{:});
            
    n_samples = length(trials);

    % Create gait cycles.
    if ~strcmp(settings.data_inputs, 'EMG')
        cycles = cell(n_samples, 1);
        leg = settings.leg_length;  % Reduce parfor communication overhead
        toe = settings.toe_length;
        analyses = settings.motion_analyses;
        parfor i=1:n_samples
            motion = SimData(trials{i}, leg, toe, analyses);
            cycles{i} = GaitCycle(motion);
        end
    else
        cycles = 0;
    end

end