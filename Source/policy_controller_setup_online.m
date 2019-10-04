%% The stuff that probably has to change/be looked over between experiments.

% Root directory (may change between PC's)
settings.root_dir = 'D:\Vicon Install Nov 2018\Normal\Metabolics';

% Subject specific settings.
settings.subject_id = 2;
settings.mass = 73.5;
settings.combined_mass = 0;
settings.leg_length = 0.92;
settings.toe_length = 0.065;
settings.speed = 1.14;

% Assistance magnitude. 
settings.force = 8.82;

% Co-ordinate system offsets - calculate these using motion function.
settings.x_offset = 0;
settings.y_offset = 0;
settings.z_offset = 0;  

%% The stuff that probably doesn't have to change/be looked over.

% Data directory
seettings.subject_prefix = 'S';
settings.base_dir = [root_dir filesep settings.subject_prefix ...
    num2str(settings.subject_id)];

% Operation mode - online or offline.
settings.operation_mode = 'online';

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
settings.seg_cutoff = 2;
settings.time_delay = 0;
settings.marker_system.forward = '+z';
settings.marker_system.up = '+y';
settings.marker_system.right = '-x';
settings.grf_system.forward = '+y';
settings.grf_system.up = '-z';
settings.grf_system.right = '+x';

% Valid ranges for the control parameters. NOTE: if
% multiplier*min_rise_range is less than 10, we will have problems with the
% TCP-IP solution. 
settings.rise_range = [25, 45];
settings.peak_range = [40, 80];
settings.fall_range = [70, 95];

% Control parameter variables.
settings.multiplier = 1;
settings.min_length = 20;

% Communication - this should be an active TCPIP server. 
settings.server = t;

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
settings.max_iterations = 20;
settings.num_seed_points = 8;  % 8 fully randomised measurements first
settings.acquisition_function = 'expected-improvement-plus';
settings.bayesopt_args = {'ExplorationRatio', 0.7};  % stuff like exploration 
                                                     % ratio would be here

%% Final set up steps

% Start parallel pool - if one isn't already created.
try
    parpool
catch
    fprintf('Parpool already active.\n');
end

% Calibrate the Vicon click arguments.
settings = calibrateViconClickCoordinates(settings);

% OpenSim model created & scaled. 
input(['Ensure the ''' settings.static_file ''' file has been created, ' ...
    'input any key to continue.\n']);
createScaledModel(settings);

% OpenSim model adjusted.
input(['Ensure the inital unassisted ''' settings.initial_walk ''' data has '...
    'been collected, input any key to continue.\n']);
[settings.model, markers, grf] = createAdjustedModel(settings);
input(['Model adjustment completed. Input any key to confirm visual ' ...
    'analysis of model and proceed to cadence computation.\n']);

% Optimal cadence computed.
cadence = computeDesiredCadence(settings, markers, grf);
fprintf('Cadence calculation completed - set metronome to %i BPM.\n', cadence);

% Reminder about first calorimetry measurement. 
input(['Input any key when first calorimetry walk has been completed. ' ...
    'Remember vicon name change.\n']);

%% Run HIL optimisation

% Run policy controller. 
input(['All setup steps completed - input any key when ready ' ...
    'to begin HIL policy controller.\nENSURE THAT THE VICON WINDOW IS IN' ...
    ' FULL SCREEN MODE ON THE WIDE MONITOR AND THE MOUSE IS POSITIONED ' ...
    'ON THIS WINDOW BEFORE PRESSING ENTER.\n']);
runPolicyController(settings);

