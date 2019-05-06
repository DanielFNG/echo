%% The stuff that probably has to change/be looked over between experiments.

% Save file name - where the bayesopt results will be saved.
settings.save_file = 'calum_peak_hip.mat';

% Data inputs - markers only, grfs only, or both (motion).
settings.data_inputs = 'Motion';

% Subject specific settings.
settings.model_file = 'C:\Users\danie\Documents\GitHub\echo\Source\calum_scaled.osim';
settings.leg_length = 0.91;
settings.toe_length = 0.085;

% Metric specific settings.
settings.metric = @calculatePeak;
settings.args = {'hip_flexion_r'};
settings.opensim_analyses = {'IK'};
settings.motion_analyses = {'GRF', 'IK'};

% Data directory.
settings.base_dir = 'D:\Share\Shared_Data\HIL\Data Collection With Kinematics\Calum Peak Hip';

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
settings.time_delay = 16*(1/600);  
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
settings.min_length = 10;

% Baseline mode - none, absolute or relative.
settings.baseline_mode = 'absolute';
settings.baseline_filename = 'baseline';

% Communication - this should be an active TCPIP server. 
settings.server = t;

% Data filestructure.
settings.v_name = 'markers';
settings.d_name = 'grf';
settings.v_format = '%02i';  % # of leading 0's in Vicon (trc) filenames 
settings.d_format = '%04i';  % # of leading 0's in D-Flow (txt) filenames

% Bayesian optimisation settings. 
settings.max_iterations = 20;
settings.acquisition_function = 'expected-improvement';
settings.bayesopt_args = {};  % stuff like exploration ratio would be here

%% Run

% Run policy controller. 
runPolicyController(settings);

