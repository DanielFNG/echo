% Setup script for policy controller implementation. This script should be 
% modified to suit experiment/subject/control settings & used as the base 
% script to run the policy controller. 

% Save file name - where the bayesopt results will be saved.
settings.save_file = 'chris-online-copd-x.mat';

% Operation mode - online or offline.
settings.operation_mode = 'online';

% Data inputs - markers only, grfs only, or both (motion).
settings.data_inputs = 'GRF';

% Subject specific settings.
settings.model_file = 'C:\Users\danie\Documents\GitHub\echo\Source\chris_scaled.osim';
settings.leg_length = 0.93;
settings.toe_length = 0.08;

% Experiment specific settings.
settings.speed = 0.8;
settings.direction = 'x';

% Data processing specific settings.
settings.feet = {'right'};
settings.segmentation_mode = 'stance';
settings.segmentation_cutoff = 2;
settings.time_delay = 16*(1/600);  
settings.marker_rotations = {0,270,0};  
settings.grf_rotations = {0,90,0};

% Valid ranges for the control parameters. NOTE: if
% multiplier*min_rise_range is less than 10, we will have problems with the
% TCP-IP solution. 
settings.rise_range = [30, 50];
settings.peak_range = [35, 70];
settings.fall_range = [40, 90];

% Control parameter variables.
settings.multiplier = 1;
settings.min_length = 10;

% Baseline mode - none, absolute or relative.
settings.baseline_mode = 'absolute';
settings.baseline_filename = 'baseline';
%settings.baseline = 35.2809;  % HipRoM with APO.
%settings.baseline = 29.3065;  % HipRoM without APO.

% Communication - this should be an active TCPIP server. 
settings.server = t;

% Metric specific settings.
settings.metric = @calculateCoPD;
settings.args = {'x'};
settings.opensim_analyses = {};
settings.motion_analyses = {'GRF'};

% Filestructure.
settings.base_dir = 'D:\Share\Shared_Data\HIL\Data Collection\CoPD-X';
settings.v_name = 'markers';
settings.d_name = 'grf';
settings.v_format = '%02i';  % # of leading 0's in Vicon (trc) filenames 
settings.d_format = '%04i';  % # of leading 0's in D-Flow (txt) filenames

% Bayesian optimisation settings. 
settings.max_iterations = 24;
settings.acquisition_function = 'expected-improvement';

% Additional arguments to the bayesopt function. 
settings.bayesopt_args = {};%{'ExplorationRatio', 0.8};


%% Run

% Run policy controller. 
runPolicyController(settings);

