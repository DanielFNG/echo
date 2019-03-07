% Setup script for policy controller implementation. This script should be 
% modified to suit experiment/subject/control settings & used as the base 
% script to run the policy controller. 

% Save file name - where the bayesopt results will be saved.
settings.save_file = 'span-results-right-hip-rom4-EIP0.8.mat';

% Operation mode - online or offline.
settings.operation_mode = 'online';

% Subject specific settings.
settings.model_file = ['F:\Dropbox\PhD\HIL Control\HIL Span\'...
    'Organised for testing HIL\Models\no_APO.osim'];
settings.leg_length = 0.92;
settings.toe_length = 0.1;

% Experiment specific settings.
settings.speed = 0.8;
settings.direction = 'x';

% Data processing specific settings.
settings.feet = {'right'};
settings.segmentation_mode = 'stance';
settings.segmentation_cutoff = 40;
settings.time_delay = 16*(1/600);  
settings.marker_rotations = {0,270,0};  
settings.grf_rotations = {0,90,0};

% Valid ranges for the control parameters. 
settings.rise_range = [45, 55];
settings.peak_range = [50, 60];
settings.fall_range = [65, 75];

% Control parameter variables.
min_length = 10;

% Baseline mode - absolute or relative.
settings.baseline_mode = 'absolute';
settings.baseline = 34.2397;  % HipRoM with APO.
%settings.baseline = 29.4703;  % HipRoM without APO.

% Metric specific settings.
settings.metric = @calculateXPMoS;
settings.args = {'x', 'min'};
settings.opensim_analyses = {'IK', 'BK'};
settings.motion_analyses = {'Markers', 'GRF', 'IK' 'BK'};

% Filestructure.
settings.base_dir = 'F:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Data';
settings.v_name = 'markers';
settings.d_name = 'NE';
settings.v_format = '%02i';  % # of leading 0's in Vicon (trc) filenames 
settings.d_format = '%04i';  % # of leading 0's in D-Flow (txt) filenames

% Bayesian optimisation settings. 
settings.max_iterations = 24;
settings.acquisition_function = 'expected-improvement-plus';

% Additional arguments to the bayesopt function. 
settings.bayesopt_args = {'ExplorationRatio', 0.8};

%% Run

% Create required function handles. 
settings.parameter_constraints = ...
    @(X) (parameterConstraints(X, 1, min_length));
settings.objective_function = @(X) (generalObjectiveFunction(X, settings));

% Run policy controller. 
runPolicyController(settings);

