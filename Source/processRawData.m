function [cycles, times, fail] = processRawData(...
    markers, grfs, save_dir, osim_dir, settings, assistance_params)

    function [times, status] = process(...
            markers, grfs, save_dir, settings, assistance_params)
        times = 0;
        if isempty(markers) % OLD - NEEDS UPDATING WITH M-D-P
            times = processGRFData(save_dir, grfs, ...
                settings.grf_system, ...
                settings.speed, settings.inclination, ...
                assistance_params, settings.feet, 'GRF');
        elseif isempty(grfs) % OLD - NEEDS UPDATING WITH M-D-P
            processMarkerData(save_dir, markers, ...
                settings.marker_system, ...
                settings.speed, settings.feet, 'Markers');
        else
            % Construct folder paths struct
            folders.Markers = markers;
            folders.GRF = grfs;
            
            % Construct batch settings
            batch_settings.SaveDirectory = save_dir;
            batch_settings.info = false;
            batch_settings.CoordinateTranslation = ...
                settings.CoordinateTranslation;
            batch_settings.CoordinateRotation = ...
                settings.CoordinateRotation;
            batch_settings.GRFSystem = settings.grf_system;
            batch_settings.Inclination = 0;
            batch_settings.Speed = settings.speed;
            batch_settings.GRFDelay = 0;
            batch_settings.SegmentationMode = 'Stance';
            batch_settings.Feet = 'Right';
            
            % Process batch of data
            status = batchProcessData(folders, batch_settings);
        end
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
            pause(4); % 4 second pause to give extra 4s of assistance - so 
                      % as not to confuse subject with audio feedback while 
                      % still recording
            processViconData(trial_name, settings);
        else
            [path, name, ~] = fileparts(grfs);
            trial_name = [path filesep name];
            waitUntilWritable([trial_name '.x2d'], 0.5);
            processViconEMG(trial_name, settings);
        end
    end

    % Wait until data has finished being printed.
    if ~isempty(markers)
        waitUntilWritable(markers, 2);
    end
    if ~isempty(grfs)
        waitUntilWritable(grfs, 2);
    end
    
    % Some output.
    fprintf(...
        '\nRaw data files available. Beginning processing steps now.\n');

    % Process the data, fixing any gaps at the start/end of trials.
    [times, status] = process(...
        markers, grfs, save_dir, settings, assistance_params);
    if status ~= 0
        % Try one more time incase it wasn't fully printed.
        [~, status] = process(...
            markers, grfs, save_dir, settings, assistance_params);
        rethrow(err);
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
    
    % Temporary measure to restrict ourselves to <= 4 trials.
    if length(trials) > 4
        trials = trials(end - 3:end);
    end
    
    trials = runBatchParallel(...
        settings.opensim_analyses, trials, settings.opensim_args{:});
            
    n_samples = length(trials);

    % Create gait cycles.
    if ~strcmp(settings.data_inputs, 'EMG')
        cycles = cell(n_samples, 1);
        leg = settings.leg_length;  % Reduce parfor communication overhead
        toe = settings.toe_length;
        analyses = settings.motion_analyses;
        parfor i=1:n_samples
            motion = MotionData(trials{i}, leg, toe, analyses);
            cycles{i} = GaitCycle(motion);
        end
    else
        cycles = 0;
    end

end