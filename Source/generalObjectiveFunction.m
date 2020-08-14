function result = generalObjectiveFunction(X, settings)

    global G__iteration;

    function paths = constructPaths(settings, G__iteration)
        % Construct the mid-level strings & paths for the policy controller.
        
        % File names.
        paths.name = [settings.name sprintf(settings.format, ...
            settings.iter_func(G__iteration))];
        
        % Raw marker & grf files.
        paths.files.markers = [];
        paths.files.grfs = [];
        paths.files.emg = [];
        switch settings.data_inputs
            case 'Motion'
                paths.files.markers = [settings.base_dir filesep ...
                    paths.name '.trc'];
                paths.files.grfs = [settings.base_dir filesep ...
                    paths.name '.txt'];
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
    end

    % Convert control parameters.
    pext = settings.multiplier*X.pext;
    rise = settings.multiplier*X.rise;
    pflex = settings.multiplier*X.pflex;
    fall = settings.multiplier*X.fall;

    switch settings.operation_mode

        case 'online'

            % Apply APO torque pattern.
            sendControlParameters(settings.vicon_server, ...
                pext, rise, pflex, fall);

        case 'offline'

            % Show applied APO torque parameters
            fprintf('\nApplying pext %i, rise %i, pflex %i, fall %i.\n',...
                pext, rise, pflex, fall);

    end
    
    % Construct filenames & create directories.
    paths = constructPaths(settings, G__iteration);
    
    % Construct assistance parameters.
    params = constructAssistanceParams(...
        settings.force, pext, rise, pflex, fall);
    
    % Obtain gait cycles from raw data processing.
    [cycles, fail] = processRawData(paths.files.markers, ...
        paths.files.grfs, paths.directories.segmented_inner, ...
        paths.directories.opensim_inner, settings, params);
    
    if fail
        result = 1000;
        return
    end
    
    switch settings.baseline_mode
        case 'absolute'
            % Compute & report difference from baseline.
            result = computeMeanMetricDifference(cycles, ...
                settings.metric, settings.baseline, true, ...
                settings.args{:});
        case 'relative'
            % Calculate the relative baseline for this trial, not yet
            % implemented...
        case 'none'
            % Compute & report mean metric value
            result = computeMeanMetric(...
                cycles, settings.metric, true, settings.args{:});
    end

end