function runPolicyController(settings, load_file)
% Runs policy controller given adequete settings. 
%
% This function is designed to be called from the policy_controller_setup 
% script.

global vicon_server_connection;

if strcmp(settings.operation_mode, 'online')
    % Create top-level filestructure.
    settings.dirs.baseline = [settings.base_dir filesep 'baseline'];
    settings.dirs.segmented = [settings.base_dir filesep 'processed'];
    settings.dirs.opensim = [settings.base_dir filesep 'opensim'];
    createDirectories(settings.dirs);
end

if strcmp(settings.baseline_mode, 'absolute')
    
    % Some handy output.
    fprintf('\nBeginning baseline computation step.\n');
    input(['Press return confirm you have changed filenames in '...
        'D-Flow and Nexus.'], 's');
    fprintf('\nPlease collect baseline data.\n');
    
    % Construct paths to marker & grf files of baseline data.
    grfs = [];
    markers = [];
    switch settings.data_inputs
        case 'Motion'
            markers = [settings.base_dir filesep ...
                settings.baseline_filename '.trc'];
            grfs = [settings.base_dir filesep ...
                settings.baseline_filename '.txt'];
        case 'Markers'
            markers = [settings.base_dir filesep ...
                settings.baseline_filename '.trc'];
        case {'GRF', 'EMG'}
            grfs = [settings.base_dir filesep ...
                settings.baseline_filename '.txt'];
    end
    
    % Obtain gait cycles from raw data processing.
    osim_dir = [settings.dirs.opensim filesep 'baseline'];
    assistance_params = [];
    [cycles, times] = processRawData(markers, grfs, settings.dirs.baseline, ...
        osim_dir, settings, assistance_params);
    
    switch settings.data_inputs
        case 'EMG'
            if strcmp(settings.data_inputs, 'EMG')
                emg = [settings.base_dir filesep ...
                    settings.baseline_filename '.csv'];
            end
            
            % Load emg data.
            emg_data = parseEMGDataFaster(emg);
            
            % Obtain baseline EMG data.
            settings.baseline = calculateEMGScore(emg_data, times);
        otherwise
            % Compute the mean value of the metric from the baseline data, & use
            % this as the baseline going forward.
            settings.baseline = computeMeanMetric(...
                cycles, settings.metric, settings.args{:});
    end
    
    % More handy output.
    input(['\nBaseline computation complete.\nPress return once you have' ...
        ' finished changing filenames in Nexus and D-Flow in preparation ' ...
        'for HIL data collection.'], 's');
end

% Create required function handles.
objective_function = @(X) (generalObjectiveFunction(X, settings));

% Construct optimisation variables.
pext = optimizableVariable('pext', settings.pext_range, 'Type', 'integer');
rise = optimizableVariable('rise', settings.rise_range, 'Type', 'integer');
pflex = ...
    optimizableVariable('pflex', settings.pflex_range, 'Type', 'integer');
fall = optimizableVariable('fall', settings.fall_range, 'Type', 'integer');
optimisation_variables = [pext, rise, pflex, fall];

global G__iteration;
results = cell(settings.max_iterations, 1);
if nargin == 1
    % Initialise Bayesian optimisation with a single step, & save result.
    G__iteration = 1;
    results{1} = bayesopt(objective_function, ...
        optimisation_variables, ...
        'XConstraintFcn', settings.parameter_constraints, ... 
        'AcquisitionFunctionName', settings.acquisition_function, ...
        'MaxObjectiveEvaluations', 1, ...
        'NumSeedPoints', settings.num_seed_points, ...
        'PlotFcn', [], ...
        settings.bayesopt_args{:});
    save(settings.save_file, 'results', 'G__iteration');
else
    % Load an existing save
    loaded_data = load(load_file);
    G__iteration = loaded_data.G__iteration;
    results = loaded_data.results;
end
    

% Run Bayesian optimisation for remaining steps. 
while G__iteration <= settings.max_iterations - 1
    G__iteration = G__iteration + 1;
    try
        results{G__iteration} = results{G__iteration - 1}.resume(...
            'MaxObjectiveEvaluations', 1);
    catch err
        disp(err.message);
        beep;
        while true 
            str = input(['Press enter to retry from this iteration, or ' ...
                'integer i > 1 to retry from iteration i. Input 0 to '...
                'prompt Vicon/APO reconnection process then retry.\n'], 's');
            if isempty(str)
                G__iteration = G__iteration - 1;
                break;
            else
                num = str2num(str); %#ok<ST2NM>
                if ~isempty(num) && num >= 0
                    if num == 0
                        input(['Execute the runViconPC script on the '...
                            'Vicon PC.\nInput any key when prompted by '...
                            'the Vicon PC.\n']);
                        vicon_server_connection = connectToViconServer();
                        G__iteration = G__iteration - 1;
                        break;
                    else
                        results(num:end) = {0};
                        G__iteration = num - 1;
                        break
                    end
                end
            end
        end
    end
    save(settings.save_file, 'results', 'G__iteration');
end

% We've finished, so save the final results now.
final_result = results{end};
save(settings.save_file, 'final_result', 'results', 'G__iteration');

end

