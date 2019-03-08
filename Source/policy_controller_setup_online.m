% Setup script for policy controller implementation. This script should be 
% modified to suit experiment/subject/control settings & used as the base 
% script to run the policy controller. 

% Save file name - where the bayesopt results will be saved.
settings.save_file = 'test-online.mat';

% Operation mode - online or offline.
settings.operation_mode = 'online';

% Data inputs - markers only, grfs only, or both (motion).
settings.data_inputs = 'GRF';

% Subject specific settings.
settings.model_file = ['C:\Users\danie\Documents\GitHub\echo\Source\chris_scaled.osim'];
settings.leg_length = 0.92;
settings.toe_length = 0.1;

% Experiment specific settings.
settings.speed = 0.2;
settings.direction = 'x';

% Data processing specific settings.
settings.feet = {'right'};
settings.segmentation_mode = 'stance';
settings.segmentation_cutoff = 40;
settings.time_delay = 16*(1/600);  
settings.marker_rotations = {0,270,0};  
settings.grf_rotations = {0,90,0};

% Valid ranges for the control parameters. 
settings.rise_range = [9, 11];
settings.peak_range = [10, 12];
settings.fall_range = [13, 15];

% Control parameter variables.
settings.multiplier = 5;
settings.min_length = 10;

% Baseline mode - absolute or relative.
settings.baseline_mode = 'absolute';
settings.baseline_filename = 'test0001';
%settings.baseline = 35.2809;  % HipRoM with APO.
%settings.baseline = 29.3065;  % HipRoM without APO.

% Metric specific settings.
settings.metric = @calculateCoPD;
settings.args = {'x'};
settings.opensim_analyses = {};
settings.motion_analyses = {'GRF'};

% Filestructure.
settings.base_dir = 'D:\Share\Shared_Data\HIL\Protocol_Setup\08-03-19';
settings.v_name = 'markers';
settings.d_name = 'test';
settings.v_format = '%02i';  % # of leading 0's in Vicon (trc) filenames 
settings.d_format = '%04i';  % # of leading 0's in D-Flow (txt) filenames

% Bayesian optimisation settings. 
settings.max_iterations = 24;
settings.acquisition_function = 'expected-improvement-plus';

% Additional arguments to the bayesopt function. 
settings.bayesopt_args = {'ExplorationRatio', 0.8};


%% Run

% Run policy controller. 
runPolicyController(settings);

