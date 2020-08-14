%% The stuff that probably has to change/be looked over between experiments.

% Root directory (may change between PC's)
settings.root_dir = 'D:\Dropbox\PhD\HIL Control\Augmentation\Bimodal Assistance (Flexion-Extension)\Parameter Identification';

% Subject specific settings.
settings.subject_id = 8;
settings.mass = 70;
settings.combined_mass = 75;
settings.leg_length = 0.93;
settings.toe_length = 0.1;

% Co-ordinate system offsets - calculate these using motion function.
settings.x_offset = 0;
settings.y_offset = 0;
settings.z_offset = 0;  

%% The stuff that probably doesn't have to change/be looked over.

% Subject-related experiment parameter calculations
settings.speed = 1.2*sqrt(0.1*9.81*settings.leg_length);
settings.force = 0.235*settings.mass;

% Data directory
settings.subject_prefix = 'S';
settings.base_dir = [settings.root_dir filesep settings.subject_prefix ...
    num2str(settings.subject_id)];

% Operation mode - online or offline.
settings.operation_mode = 'offline';

% Data inputs - markers only, grfs only, motion (both), emg (emg + grf).
settings.data_inputs = 'Motion';

% Motion metric specific settings.
settings.metric = @calculateMetabolicRate;
settings.args = {};
settings.opensim_analyses = {'IK', 'SO'};
load_file = ...
    [getenv('OPENSIM_MATLAB_HOME') filesep 'Defaults' filesep 'apo.xml'];
settings.opensim_args = {'load', load_file};  % APO force model
settings.motion_analyses = {'SO'};

% Baseline mode - none, absolute or relative.
settings.baseline_mode = 'none';
settings.baseline_filename = [];

% Experiment specific settings.
settings.inclination = 0;

% Data processing specific settings.
settings.feet = {'right'};
settings.seg_mode = 'stance';
settings.sync_index = 1;
settings.time_delays = [0, 0];
settings.vicon_translation = [0, 0, 0];
settings.vicon_rotation = [0, 0, 0];
settings.grf_system.Forward = '+y';
settings.grf_system.Up = '-z';
settings.grf_system.Right = '+x';
settings.inclination = 0;

% Valid ranges for the control parameters. NOTE: if
% multiplier*min_rise_range is less than 10, we will have problems with the
% TCP-IP solution.
settings.pext_range = [5, 25];
settings.rise_range = [25, 45];
settings.pflex_range = [50, 80];
settings.fall_range = [70, 95];

% Control parameter variables.
%settings.parameter_constraints = @(x) (parameterConstraints(x, ...
%settings.multiplier, settings.min_length));
%settings.min_length = 20;
settings.multiplier = 1;
settings.parameter_constraints = @bimodalParameterConstraints;

% Save file name - where the bayesopt results will be saved.
settings.save_file = [settings.base_dir filesep 'hil-results.mat'];

% Data filestructure.
settings.name = 'capture';
settings.format = '%03i';  % # of leading 0's in Vicon filenames 
settings.model_name = 'model.osim';
settings.adjusted_model_name = 'model_adjusted.osim';
settings.model_folder = 'Models';
settings.static_file = ['S' num2str(settings.subject_id) ' Cal 01.trc'];
settings.static_folder = 'Static';
settings.initial_walk = 'walk';
settings.cadence_folder = 'Cadence';

% Bayesian optimisation settings. 
settings.iter_func = @(x) x;
settings.max_iterations = 24;
settings.num_seed_points = 1;  % fully randomised measurements first
settings.acquisition_function = 'expected-improvement-plus';
settings.bayesopt_args = {'ExplorationRatio', 0.05};  % stuff like exploration 
                                                     % ratio would be here

%% Final set up steps

% Start parallel pool - if one isn't already created.
try
    parpool
catch
    fprintf('Parpool already active.\n');
end

if strcmp(settings.operation_mode, 'online')
    % Instruct operator to begin setting up the Vicon PC.
    input(['Execute the runViconPC script on the Vicon PC.\n'...
        'Input any key when prompted by the Vicon PC.\n']);

    % Connect to the Vicon PC.
    settings.vicon_server = connectToViconServer();

    % OpenSim model created & scaled. 
    input(['Ensure the ''' settings.static_file ...
        ''' file has been created.\nInput any key to continue.\n']);
    createScaledModel(settings);

    % OpenSim model adjusted.
    input(['Ensure the inital unassisted ''' settings.initial_walk ...
        ''' data has been collected, input any key to continue.\n']);
    [settings.model, markers, grf] = createAdjustedModel(settings);
    input(['Model adjustment completed. Input any key to confirm visual ' ...
        'analysis of model and proceed to cadence computation.\n']);

    % Optimal cadence computed.
    cadence = computeDesiredCadence(settings, markers, grf);
    fprintf('Cadence calculation completed - set metronome to %i BPM.\n', ...
        cadence);
else
    % Assume model adjustment already complete
    settings.model = [settings.base_dir filesep settings.model_folder ...
        filesep settings.adjusted_model_name];
end

%% Run HIL optimisation

% Save settings information for future reference
save([settings.base_dir filesep 'settings.mat'], 'settings');

% Run policy controller. 
input(['On the Vicon PC, change the trial name to ' ...
    sprintf(['%s' settings.format], settings.name, 1) '. Ensure that the '...
    'Vicon window\nis in full screen mode on the '...
    'wide monitor, and is live, armed and locked.\nAll setup steps '...
    'completed - input any key when ready to begin HIL policy controller.']);
runPolicyController(settings);
