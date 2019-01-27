% Setup script for policy controller implementation. This script should be 
% modified to suit experiment/subject/control settings & used as the base 
% script to run the policy controller. 

% Save file name.
settings.save_file = 'policy_controller_results.mat';

% Control parameterisation settings. 
settings.rise_range = [30, 50];
settings.peak_range = [35, 70];
settings.fall_range = [40, 90];

% Subject specific settings.
settings.metric = @calculateROM;
settings.args = {'hip_flexion_r'};
settings.analyses = {'IK'};
settings.model_file = ...
    'C:\Users\danie\Documents\GitHub\echo\Source\chris_scaled.osim';
settings.baseline = 49.7;  % Real for fixed, 'measured' for measured

% Experiment settings. Currently set to standard for UoE setup.
settings.time_delay = 16*(1/600);  
settings.marker_rotations = {0,270,0};  
settings.grf_rotations = {0,90,0};

% Filestructure.
settings.base_dir = 'F:\Dropbox\PhD\HIL Control\Automation-test\walking';
settings.v_name = 'markers';
settings.d_name = 'NE';
settings.v_format = '%02i';  % # of leading 0's in Vicon (trc) filenames 
settings.d_format = '%04i';  % # of leading 0's in D-Flow (txt) filenames

% Bayesian optimisation settings. 
settings.max_iterations = 3;
settings.acquisition_function = 'probability-of-improvement';
settings.parameter_constraints = @parameterConstraints;

% Run policy controller. 
runPolicyController(settings);

