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
            %fprintf('\nApply pext %i, rise %i, pflex %i, fall %i.\n', pext, rise, pflex, fall);
            %input('Press any key to continue.');

            % Construct filenames & create directories.
            paths = constructPaths(settings, G__iteration);
            
            % Construct assistance parameters.
            params = constructAssistanceParams(...
                settings.force, pext, rise, pflex, fall);

            % Obtain gait cycles from raw data processing.
            [cycles, times] = processRawData(paths.files.markers, ...
                paths.files.grfs, paths.directories.segmented_inner, ...
                paths.directories.opensim_inner, settings, params);

        case 'offline'

            % Load motion data.
            sep = settings.sep;
            S = load([settings.save_file_dir filesep num2str(rise) sep ...
                num2str(peak) sep num2str(fall) '.mat'], settings.var);
            cycles = S.(settings.var);

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
            % Calculate the relative baseline for this trial, not yet
            % implemented...
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