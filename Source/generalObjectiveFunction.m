function result = generalObjectiveFunction(X, settings)

    global G__iteration;
    global vicon_server_connection;

    function paths = constructPaths(settings, G__iteration)
        % Construct the mid-level strings & paths for the policy controller.
        
        % File names.
        paths.name = [settings.name sprintf(settings.format, ...
            settings.iter_func(G__iteration))];
        
        % Raw marker & grf files.
        paths.files.markers = [];
        paths.files.grfs = [];
        paths.files.emg = [];
        paths.files.apo = [];
        switch settings.data_inputs
            case 'Motion'
                paths.files.markers = [settings.base_dir filesep ...
                    paths.name '.trc'];
                paths.files.grfs = [settings.base_dir filesep ...
                    paths.name '.txt'];
                paths.files.apo = [settings.base_dir filesep ...
                    paths.name '.csv'];
            case 'Markers'
                paths.files.markers = [settings.base_dir filesep ...
                    paths.name '.trc'];
            case {'GRF', 'EMG'}
                paths.files.grfs = [settings.base_dir filesep ...
                    paths.name '.txt'];
                paths.files.emg = [settings.base_dir filesep ...
                    paths.name '.csv'];
        end
        
        % Inner-level directories for saving segmentation & OpenSim results.
        paths.directories.segmented_inner = [settings.dirs.segmented ...
            filesep 'iteration' sprintf('%03i', G__iteration)];
        paths.directories.opensim_inner = [settings.dirs.opensim ...
            filesep 'iteration' sprintf('%03i', G__iteration)];
        paths.directories.motions_inner = [settings.dirs.motions ...
            filesep 'iteration' sprintf('%03i', G__iteration)];
        paths.directories.logs_inner = [settings.dirs.motions ...
            filesep 'iteration' sprintf('%03i', G__iteration)];
    end

    % Convert control parameters.
    pext = settings.multiplier*X.pext;
    rise = settings.multiplier*X.rise;
    pflex = settings.multiplier*X.pflex;
    fall = settings.multiplier*X.fall;

    if strcmp(settings.operation_mode, 'online')
        % Apply APO torque pattern.
        sendControlParameters(vicon_server_connection, ...
            pext, rise, pflex, fall); 
    end
    
    % Construct filenames & create directories.
    switch settings.baseline_mode
        case 'relative'
            baseline_paths = constructPaths(settings, 2*G__iteration - 1);
            paths = constructPaths(settings, 2*G__iteration);
        otherwise
            paths = constructPaths(settings, G__iteration);
    end
    
    % Temporary support old style of APO torques
    if strcmp(settings.apo_torques, 'predicted')
        paths.files.apo = constructAssistanceParams(...
            settings.force, pext, rise, pflex, fall);
    end
    
    % Obtain gait cycles from raw data processing.
    if strcmp(settings.baseline_mode, 'relative')
        [baseline_cycles, ~, ~, baseline_output] = processRawData(...
            baseline_paths.files.markers, baseline_paths.files.grfs, ...
            baseline_paths.directories.segmented_inner, ...
            baseline_paths.directories.opensim_inner, ...
            settings, baseline_paths.files.apo, false);
    end
    [cycles, times, fail, output] = processRawData(paths.files.markers, ...
        paths.files.grfs, paths.directories.segmented_inner, ...
        paths.directories.opensim_inner, settings, paths.files.apo);
    
    % Save gait cycles & logs
    if strcmp(settings.baseline_mode, 'relative')
        save([paths.directories.motions_inner '.mat'], 'baseline_cycles');
        save([paths.directories.logs_inner '.mat'], 'baseline_output');
    end
    save([paths.directories.motions_inner '.mat'], 'cycles');
    save([paths.directories.logs_inner '.mat'], 'output');
    
    if fail
        result = 600;
        return
    end
    
    switch settings.baseline_mode
        case 'absolute'
            % Compute & report difference from baseline.
            switch settings.data_inputs
                case 'EMG'
                    emg_data = parseEMGDataFaster(paths.files.emg);
                    result = calculateEMGScore(emg_data, times);
                otherwise
                    result = computeMeanMetricDifference(cycles, ...
                        settings.baseline, settings.metric, settings.args{:});
            end
        case 'relative'
            baseline = computeMeanMetric(...
                baseline_cycles, settings.metric, settings.args{:});
            measurement = computeMeanMetric(...
                cycles, settings.metric, settings.args{:});
            result = measurement - baseline;
        case 'none'
            switch settings.data_inputs
                case 'EMG'
                    emg_data = parseEMGDataFaster(paths.files.emg);
                    disp('EMG parsed');
                    result = calculateEMGScore(emg_data, times);
                    disp('EMG score scomputed');
                otherwise
                    % Compute & report mean metric value
                    result = computeMeanMetric(...
                        cycles, settings.metric, settings.args{:});
            end
    end

end