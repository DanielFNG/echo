% This script runs the ground truth analysis pipeline. Note the following:
%
% 1) The 'baseline' parameter should point to a Matlab save file containing
%    a 2D cell array of GaitCycle objects. These are averaged in their entirety.
%
% 2) The 'data_root' parameter should point to a folder, which itself
%    contains a Matlab save file for every working combination of the
%    control parameters. For example: it should contain '45_50_65.mat'
%    which refers to the data when (peak, rise, fall) = (45, 50, 65).

% Parameterisation settings. 
parameters.rise = [45, 50, 55];
parameters.peak = [50, 55, 60];
parameters.fall = [65, 70, 75];

% Paths to data files.
baseline = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Results\gait-baseline-APO.mat';
%baseline = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Results\gait-baseline-no_APO.mat';
data_root = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Matlab Save Files';

% Data loading.
baseline = load(baseline);

% Choose the metric, arguments, baseline mode & a name.
metric = @calculateXPMoS;
args = {'x', 'min'};
name = 'XPMoS';

% Calculate baseline.
baseline = computeMeanMetric(baseline.gait, metric, true, args{:});

% Calculate ground truth.
ground_truth = calculateGroundTruth(...
    data_root, parameters, metric, baseline, args{:});

% Plot results.
plotGroundTruth(ground_truth, baseline);

% Plot control colour plot.
plotControlColours(parameters, ground_truth);