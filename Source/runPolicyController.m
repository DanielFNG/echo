function runPolicyController(settings)
% Runs policy controller given adequete settings. 
%
% This function is designed to be called from the policy_controller_setup 
% script.

% Create top-level filestructure.
dirs.processed = [settings.base_dir filesep 'processed'];
dirs.segmented = [settings.base_dir filesep 'gait_cycles'];
dirs.opensim = [settings.base_dir filesep 'opensim'];
createDirectories(dirs);

% Construct optimisation variables. 
rise = optimizableVariable('rise', settings.rise_range, 'Type', 'integer');
peak = optimizableVariable('peak', settings.peak_range, 'Type', 'integer');
fall = optimizableVariable('fall', settings.fall_range, 'Type', 'integer');
optimisation_variables = [rise, peak, fall];

% Initialise Bayesian optimisation with a single step, & save result.
iteration = 1;
results = bayesopt(@generalObjectiveFunction, ...
    optimisation_variables, ...
    'XConstraintFcn', settings.parameter_constraints, ... 
    'AcquisitionFunctionName', settings.acquisition_function, ...
    'ExplorationRatio', 0.8, ...
    'MaxObjectiveEvaluations', 1, ...
    'PlotFcn', []);
save(settings.save_file, 'results', 'iteration');

% Run Bayesian optimisation for remaining steps. 
while iteration <= settings.max_iterations - 1
    iteration = iteration + 1;
    old_results = results;
    try
        results = old_results.resume('MaxObjectiveEvaluations', 1);
    catch err
        disp(err.message);
        input('Press enter when ready to retry.\n');
        results = old_results;
        iteration = iteration - 1;
    end
    save(settings.save_file, 'results', 'iteration');
end

    function result = generalObjectiveFunction(X)
    % General objective function for Bayesian optimisation.
    %
    % This is defined within this file to allow access to the settings 
    % structure, containing necessary information such as model filename
    % for example.
    %
    % This function by necessity carries out a few different steps:
    %   1) Applies the APO torque pattern suggested by bayesopt
    %   2) Waits for the corresponding motion data to be collected
    %   3) Processes & segments the motion data
    %   4) Runs the necessary OpenSim analyses on the data
    %   5) Computes & averages the metric data for each collected gait cycle.
        
        % Apply APO torque pattern - currently operator controlled.
        %fprintf('Apply rise %i, peak %i, fall %i.\n', X.rise, X.peak, X.fall);
        %beep;
        
        % Construct filenames & create directories. 
        %paths = constructPaths(settings, dirs, iteration);
        %createDirectories(paths.directories);
        
        % Every 2s check for writability of the trial data.            
        %waitUntilWritable(paths.files.markers, 2);
        %waitUntilWritable(paths.files.grfs, 2);   
        
        % Span marker paths.
        %marker_file = [settings.base_dir filesep num2str(X.rise*5) '_' num2str(X.peak*5) '_' num2str(X.fall*5) '.trc'];
        %grf_file = [settings.base_dir filesep num2str(X.rise*5) '_' num2str(X.peak*5) '_' num2str(X.fall*5) '.txt'];
        
        % Processing. Use a try/catch loop to automatically deal with missing 
        % markers in the Vicon data - sometimes this slips through. 
%         try
%             processMotionData(paths.directories.segmented_inner_markers, ...
%                 paths.directories.segmented_inner_grf, ...
%                 marker_file, grf_file, ...
%                 settings.marker_rotations, settings.grf_rotations, ...
%                 settings.time_delay, ...
%                 settings.feet, settings.segmentation_mode, ...
%                 settings.segmentation_cutoff);
%         catch err
%             if strcmp(err.identifier, 'Data:Gaps')
%                 
%                 % Remove problematic frames from data.
%                 removeMissingFrames(marker_file, grf_file);
%                 
%                 % Retry processing the gait data. 
%                 processMotionData(paths.directories.segmented_inner_markers, ...
%                 paths.directories.segmented_inner_grf, ...
%                 marker_file, grf_file, ...
%                 settings.marker_rotations, settings.grf_rotations, ...
%                 settings.time_delay, ...
%                 settings.feet, settings.segmentation_mode, ...
%                 settings.segmentation_cutoff);
%             else
%                 fprintf('No current fix for detected error.\n');
%                 rethrow(err);
%             end
%         end     
        
%         % Run appropriate OpenSim analyses.
%         [n_cycles, gait_cycle_markers] = ...
%             getFilePaths([paths.directories.segmented_inner_markers filesep 'right'], '.trc');
%         [~, gait_cycle_grfs] = ...
%             getFilePaths([paths.directories.segmented_inner_grf filesep 'right'], '.mot');

        save_file_dir = ['D:\Dropbox\PhD\HIL Control\HIL Span\Organised for'...
            ' testing HIL\Matlab Save Files'];
        load([save_file_dir filesep num2str(5*X.rise) '_' num2str(5*X.peak) '_' ...
            num2str(5*X.fall) '.mat'], 'ost');
        
        n_samples = length(ost);
        metric_data = zeros(1, n_samples);
        for i=1:n_samples
            metric_data(i) = settings.metric(ost{i}, settings.args{:});
        end
        
        % If required, calculate the relative baseline for this trial.
        % Not for now.
        
        % Compute & report metric data.
        result = sum(abs(metric_data - settings.baseline))/n_samples;
        
    end

end

