%% The stuff that probably has to change/be looked over between experiments.

% Data directory.
settings.base_dir = 'D:\Vicon Install Nov 2018\Normal\HIL\S0';

% Save file name - where the bayesopt results will be saved.
settings.save_file = [settings.base_dir filesep 'hil-results.mat'];

% Data inputs - markers only, grfs only, motion (both), emg (emg + grf).
settings.data_inputs = 'Motion';

% Subject specific settings.
settings.leg_length = 0.93;
settings.toe_length = 0.08;
settings.speed = 1.2;

% Assistance magnitude. 
settings.force = 10;

%% The stuff that probably doesn't have to change/be looked over.

% Operation mode - online or offline.
settings.operation_mode = 'online';

% Motion metric specific settings.
settings.metric = {@calculateMetabolicRate};
settings.args = [];
settings.opensim_analyses = {'IK', 'SO'};
settings.motion_analyses = {'SO'};

% Baseline mode - none, absolute or relative.
settings.baseline_mode = 'none';
settings.baseline_filename = [];

% Experiment specific settings.
settings.inclination = 0;

% Data processing specific settings.
settings.feet = {'right'};
settings.segmentation_mode = 'stance';
settings.segmentation_cutoff = 2;
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
settings.rise_range = [40, 75];
settings.peak_range = [40, 90];
settings.fall_range = [45, 99];

% Control parameter variables.
settings.multiplier = 1;
settings.min_length = 20;

% Communication - this should be an active TCPIP server. 
settings.server = t;

% Data filestructure.
settings.v_name = 'emg_second_go';
settings.d_name = 'emg_second_go';
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

