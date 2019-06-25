%% The stuff that probably has to change/be looked over between experiments.

% Save file name - where the bayesopt results will be saved.
settings.save_file = 'testing_emg_stuff_more_sensors.mat';

% Data inputs - markers only, grfs only, motion (both), emg (emg + grf).
settings.data_inputs = 'EMG';

% Subject specific settings.
settings.model_file = 'C:\Users\danie\Documents\GitHub\echo\Source\calum_scaled.osim';
settings.leg_length = 0.93;
settings.toe_length = 0.08;

% Motion metric specific settings.
settings.metric = [];
settings.args = [];
settings.opensim_analyses = {};
settings.motion_analyses = {'GRF'};

% Baseline mode - none, absolute or relative.
settings.baseline_mode = 'none';
settings.baseline_filename = 'emg_more';

% Data directory.
settings.base_dir = 'D:\Vicon Install Nov 2018\Normal\EMG Testing\Test With More Sensors';

%% The stuff that probably doesn't have to change/be looked over.

% Operation mode - online or offline.
settings.operation_mode = 'online';

% Experiment specific settings.
settings.speed = 0.8;
settings.direction = 'x';

% Data processing specific settings.
settings.feet = {'right'};
settings.segmentation_mode = 'stance';
settings.segmentation_cutoff = 2;
settings.time_delay = 0; %16*(1/600);  
settings.marker_rotations = {0,90,0};  
settings.grf_rotations = {0,90,0};

% Valid ranges for the control parameters. NOTE: if
% multiplier*min_rise_range is less than 10, we will have problems with the
% TCP-IP solution. 
settings.rise_range = [40, 75];
settings.peak_range = [40, 90];
settings.fall_range = [45, 99];

% Control parameter variables.
settings.multiplier = 1;
settings.min_length = 20;

% Communication - this should be an active TCPIP server. 
settings.server = t;

% Data filestructure.
settings.v_name = 'emg_more';
settings.d_name = 'emg_more';
settings.v_format = '%03i';  % # of leading 0's in Vicon (trc) filenames 
settings.d_format = '%03i';  % # of leading 0's in D-Flow (txt) filenames

% Bayesian optimisation settings. 
settings.iter_func = @(x) 2*x - 1;
settings.max_iterations = 18;
settings.acquisition_function = 'expected-improvement-plus';
settings.bayesopt_args = {'ExplorationRatio', 0.7};  % stuff like exploration ratio would be here

%% Run

% Run policy controller. 
runPolicyController(settings);

