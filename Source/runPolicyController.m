function runPolicyController(settings)

%% Create top-level results directories.
processed_dir = [settings.base_dir filesep 'processed'];
segment_dir = [settings.base_dir filesep 'gait_cycles'];
opensim_dir = [settings.base_dir filesep 'opensim'];
mkdir(processed_dir);
mkdir(segment_dir);
mkdir(opensim_dir);

% Optimisation variable construction.
rise = optimizableVariable('rise', settings.rise_range, 'Type', 'integer');
peak = optimizableVariable('peak', settings.peak_range, 'Type', 'integer');
fall = optimizableVariable('fall', settomgs/fall_range, 'Type', 'integer');
optimisation_variables = [rise, peak, fall];

% Initialise the Bayesian optimisation with a single step.
iteration = 1;
results = bayesopt(@generalObjectiveFunction, ...
    optimisation_variables, ...
    'XConstraintFcn', @parameterConstraints, ...
    'AcquisitionFunctionName', acquisition_function, ...
    'MaxObjectiveEvaluations', 1, ...
    'PlotFcn', []);

% Save the result of the initial BO step. 
save(save_file, 'results', 'iteration');

% Resume the Bayesian optimisation.
while iteration <= max_iterations - 1
    try
        iteration = iteration + 1;
        old_results = results;
        results = old_results.resume('MaxObjectiveEvaluations', 1);
    catch err
        disp(err.message);
        input('Press enter when ready to retry.\n');
        results = old_results;
    end
    save('intermediate_results.mat', 'results', 'iteration');
end

        function pass = parameterConstraints(X)
        % Constraints on Bayesian Optimisation [rise, peak, fall] parameters. 

        % Assert that rise <= peak <= fall.
        ordered_parameters = (X.rise <= X.peak) & (X.peak <= X.fall);

        % Assert minimum length of applied assistance - 10% of gait cycle.
        minimum_length = (X.fall - X.rise) > 10;

        % Combine constraints. 
        pass = ordered_parameters & minimum_length;

        end

    function result = generalObjectiveFunction(X)
        
        % Communicate with APO to apply correct torque pattern.
        % Actually in the mean-time this will be operator controlled, since one
        % will be needed for putting Vicon live anyway. A beep will tell the
        % operator to update the control parameters on the APO side during the
        % non-assisted phase of the current trial.
        fprintf('Apply rise %i, peak %i, fall %i.\n', X.rise, X.peak, X.fall);
        beep;
        
        % Every 2s check for the existence of the trial data.
        marker_name = [settings.v_name sprintf(settings.v_format, iteration)];
        grf_name = [settings.d_name sprintf(settings.d_format, iteration)];
        marker_file = ...
            [settings.base_dir filesep marker_name '.trc'];
        grf_file = ...
            [settings.base_dir filesep grf_name '.txt'];
        while true
            if exist(grf_file, 'file') && exist(marker_file, 'file')
                pause(2);  % Give an additional 2s just for finishing file writing.
                break;
            else
                pause(2);
            end
        end
        % NEED ANOTHER CHECK THAT THESE ARE WRITABLE!
        
        %% Process the files.
        
        % Assign names.
        processed_markers = [processed_dir filesep marker_name '.trc'];
        processed_grfs = [processed_dir filesep grf_name '.mot'];
        
        % Processing
        int_grf = produceMOT(grf_file, settings.base_dir);
        [markers, grfs] = ...
            synchronise(marker_file, int_grf, settings.time_delay);
        markers.rotate(settings.marker_rotations{:});
        grfs.rotate(settings.grf_rotations{:});
        
        % File creation
        markers.writeToFile(processed_markers);
        grfs.writeToFile(processed_grfs);
        
        %% Segmentation
        
        int_seg_dir = ...
            [segment_dir filesep 'iteration' sprintf('%03i', iteration)];
        mkdir(int_seg_dir);
        
        % Segment.
        %segment('left', 'stance', 40, processed_grfs, processed_markers, int_seg_dir);
        segment('right', 'stance', 40, processed_grfs, processed_markers, int_seg_dir);
        % Only doing this for right foot for now, for quicker testing.
        
        %% OpenSim compuations
        
        % Obtain the markers & grf files.
        marker_files = dir([int_seg_dir filesep '*.trc']);
        grf_files = dir([int_seg_dir filesep '*.mot']);
        
        % Create directory for results storage.
        osim_save_dir = [opensim_dir filesep 'iteration' sprintf('%03i', iteration)];
        mkdir(osim_save_dir);
        
        % Run appropriate OpenSim analyses.
        n_cycles = length(marker_files);
        hip_rom = zeros(1, n_cycles);
        for i=1:n_cycles
            
            % Create directory for results storage.
            results = [osim_save_dir filesep 'cycle' sprintf('%03i', i)];
            
            % Create OpenSimTrial
            ost = OpenSimTrial(...
                settings.model_file, ...
                [int_seg_dir filesep marker_files(i).name], ...
                results, [int_seg_dir filesep grf_files(i).name]);
            
            % Run IK.
            ost.run('IK');
            % ost{i}.run('BK');
            % ost{i}.run('ID');
            % Only doing IK for now for ease of testing.
            
            % Compute metric.
            ost_results = OpenSimResults(ost, {'IK'});
            hip_rom(i) = metric(ost_results, settings.args{:});
        end
        
        % If required, calculate the relative baseline for this trial.
        % Not for now.
        
        % Compute & report metric data.
        result = sum((hip_rom - settings.baseline).^2)/n_cycles;
        
    end

end

