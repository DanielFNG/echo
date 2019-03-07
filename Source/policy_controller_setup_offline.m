% Setup script for policy controller implementation. This script should be 
% modified to suit experiment/subject/control settings & used as the base 
% script to run the policy controller. 

% Save file name - where the bayesopt results will be saved.
settings.save_file = 'test-offline.mat';

% Operation mode - online or offline.
settings.operation_mode = 'offline';

% Data directory & parameter seperator. 
settings.save_file_dir = ['D:\Dropbox\PhD\HIL Control\HIL Span\Organised ' ...
    'for testing HIL\Matlab Save Files'];
settings.sep = '_';
settings.var = 'gait';

% Valid ranges for the control parameters. 
settings.rise_range = [9, 11];
settings.peak_range = [10, 12];
settings.fall_range = [13, 15];

% Control parameter variables.
settings.multiplier = 5;
min_length = 10;

% Baseline mode - absolute or relative.
settings.baseline_mode = 'absolute';
settings.baseline = 34.2397;  % HipRoM with APO.
%settings.baseline = 29.4703;  % HipRoM without APO.

% Metric specific settings.
settings.metric = @calculateROM;
settings.args = {'hip_flexion_r'};
settings.opensim_analyses = {'IK'};
settings.motion_analyses = {'IK'};

% Bayesian optimisation settings. 
settings.max_iterations = 24;
settings.acquisition_function = 'expected-improvement-plus';

% Additional arguments to the bayesopt function. 
settings.bayesopt_args = {'ExplorationRatio', 0.8};

%% Run

% Create required function handles. 
settings.parameter_constraints = ...
    @(X) (parameterConstraints(X, settings.multiplier, min_length));
settings.objective_function = @(X) (generalObjectiveFunction(X, settings));

% Run policy controller. 
runPolicyController(settings);
