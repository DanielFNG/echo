function [cycles, times] = processRawData(...
    markers, grfs, save_dir, osim_dir, settings, assistance_params)

    function times = process(...
            markers, grfs, save_dir, settings, assistance_params)
        times = 0;
        if isempty(markers)
            times = processGRFData(save_dir, grfs, ...
                settings.grf_system, ...
                settings.speed, settings.inclination, ...
                assistance_params, settings.feet, ...
                settings.segmentation_mode, ...
                settings.segmentation_cutoff, 'GRF');
        elseif isempty(grfs)
            processMarkerData(save_dir, markers, ...
                settings.marker_system, ...
                settings.speed, settings.feet, ...
                settings.segmentation_mode, ...
                settings.segmentation_cutoff, 'Markers');
        else
            processMotionData(save_dir, save_dir, markers, grfs, ...
                settings.marker_system, settings.grf_system, ...
                settings.x_offset, settings.y_offset, settings.z_offset, ...
                settings.time_delay, settings.speed, settings.inclination, ...
                assistance_params, settings.feet, ...
                settings.segmentation_mode, ...
                settings.segmentation_cutoff, 'Markers', 'GRF');
        end
    end

    if strcmp(settings.operation_mode, 'online')
        if ~isempty(markers)
            % Wait until raw vicon data is available.
            [path, name, ~] = fileparts(markers);
            trial_name = [path filesep name];
            waitUntilWritable([trial_name '.x2d'], 2);
            processViconData(trial_name);
        else
            [path, name, ~] = fileparts(grfs);
            trial_name = [path filesep name];
            waitUntilWritable([trial_name '.x2d'], 2);
            processViconEMG(trial_name);
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
    fprintf('\nRaw data files available. Beginning processing steps now.\n');

    % Process the data, fixing any gaps at the start/end of trials.
    try
        times = process(markers, grfs, save_dir, settings, assistance_params);
    catch err
        if strcmp(err.identifier, 'Data:Gaps')

            % Remove problematic frames from data.
            removeMissingFrames(markers, grfs);
            
            % Retry processing the gait data.
            process(markers, grfs, save_dir, settings, assistance_params);
        else
            % Try one more time incase it wasn't fully printed.
            try 
                process(markers, grfs, save_dir, settings, assistance_params);
            catch err 
                fprintf('No current fix for detected error.\n');
                beep;
                rethrow(err);
            end
        end
    end

    % Run appropriate OpenSim analyses.
    markers_folder = [save_dir filesep 'right' filesep 'Markers'];
    grf_folder = [save_dir filesep 'right' filesep 'GRF'];
    switch settings.data_inputs
        case 'Motion'
            trials = createTrials(settings.model_file, markers_folder, ...
                osim_dir, grf_folder);
        case {'GRF', 'EMG'}
            trials = createTrials(settings.model_file, [], ...
                osim_dir, grf_folder);
        case 'Markers'
            trials = createTrials(settings.model_file, markers_folder, ...
                osim_dir, []);
    end
    runBatch(settings.opensim_analyses, trials);
            
    n_samples = length(trials);

    % Create gait cycles.
    if ~strcmp(settings.data_inputs, 'EMG')
        cycles = cell(n_samples, 1);
        for i=1:n_samples
            motion = MotionData(trials{i}, settings.leg_length, ...
                settings.toe_length, settings.motion_analyses, ...
                settings.segmentation_cutoff);
            cycles{i} = GaitCycle(motion);
        end
    else
        cycles = 0;
    end

end