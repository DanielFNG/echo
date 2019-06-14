function result = generalObjectiveFunction(X, settings)

    global G__iteration;

    function paths = constructPaths(settings, G__iteration)
        % Construct the mid-level strings & paths for the policy controller.
        
        % File names.
        paths.strings.markers = ...
            [settings.v_name sprintf(settings.v_format, G__iteration)];
        paths.strings.grfs = ...
            [settings.d_name sprintf(settings.d_format, G__iteration)];
        
        % Raw marker & grf files.
        paths.files.markers = [];
        paths.files.grfs = [];
        paths.files.emg = [];
        switch settings.data_inputs
            case 'Motion'
                paths.files.markers = [settings.base_dir filesep ...
                    paths.strings.markers '.trc'];
                paths.files.grfs = [settings.base_dir filesep ...
                    paths.strings.grfs '.txt'];
            case 'Markers'
                paths.files.markers = [settings.base_dir filesep ...
                    paths.strings.markers '.trc'];
            case {'GRF', 'EMG'}
                paths.files.grfs = [settings.base_dir filesep ...
                    paths.strings.grfs '.txt'];
                paths.files.emg = [settings.base_dir filesep ...
                    paths.strings.grfs '.csv'];
        end
        
        % Inner-level directories for saving segmentation & OpenSim results.
        paths.directories.segmented_inner = [settings.dirs.segmented ...
            filesep 'iteration' sprintf('%03i', G__iteration)];
        paths.directories.opensim_inner = [settings.dirs.opensim ...
            filesep 'iteration' sprintf('%03i', G__iteration)];
    end

    % Convert control parameters.
    rise = settings.multiplier*X.rise;
    peak = settings.multiplier*X.peak;
    fall = settings.multiplier*X.fall;

    switch settings.operation_mode

        case 'online'

            % Apply APO torque pattern.
            %sendControlParameters(settings.server, rise, peak, fall);
            fprintf('\nApply rise %i, peak %i, fall %i.\n', rise, peak, fall);
            beep;
            input('Press any key to continue.');

            % Construct filenames & create directories.
            paths = constructPaths(settings, G__iteration);

            % Obtain gait cycles from raw data processing.
            [cycles, times] = processRawData(paths.files.markers, ...
                paths.files.grfs, paths.directories.segmented_inner, ...
                paths.directories.opensim_inner, settings);

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
            % Compute & report mean metric value
            result = ...
                computeMeanMetric(cycles, settings.metric, settings.args{:});
    end

end