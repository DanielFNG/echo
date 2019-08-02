% This script is for analysing the results of the first 'successful' online
% Bayesian Optimisation based exoskeleton controller. I can't make sense of
% the objective function results. 

%% Clear first.
clear;

%% Common info
model = 'C:\Users\danie\Documents\GitHub\echo\Source\calum_scaled.osim';
save_dir = 'analysing_first_run';
leg_length = 0.91;
toe_length = 0.085;
analyses = {'GRF', 'IK'};
osim_analyses = {'IK'};
grf_cutoff = 2;
iterations = 20;
metric = @calculatePeak;
metric_args = {'hip_flexion_r'};
base = 'D:\Dropbox\Presentation Data\Calum Peak Hip';

%% Compute the baseline.
root = [base filesep 'baseline\right\GRF'];

[n_grfs, grfs] = getFilePaths(root, '.mot');

root = [base filesep 'baseline\right\Markers'];

[~, kinematics] = getFilePaths(root, '.trc');

cycles{n_grfs} = {};

for i=1:n_grfs
    trial = OpenSimTrial(model, kinematics{i}, save_dir, grfs{i});
    trial.run(osim_analyses);
    motion = MotionData(trial, leg_length, toe_length, analyses, grf_cutoff);
    cycles{i} = GaitCycle(motion);
end

baseline = computeMeanMetric(cycles, metric, metric_args{:});

%% Compute the result for each trial
root = [base filesep 'processed'];
result = zeros(1, iterations);
averages = zeros(1, iterations);
sdev = result;

for iter = 1:iterations
    inner = [root filesep 'iteration' sprintf('%03i', iter) filesep ...
        'right' filesep 'GRF'];
    
    [n_grfs, grfs] = getFilePaths(inner, '.mot');
    
    inner = [root filesep 'iteration' sprintf('%03i', iter) filesep ...
        'right' filesep 'Markers'];
    
    [~, kinematics] = getFilePaths(inner, '.trc');
    
    cycles = cell(1, n_grfs);
    
    cycle_data = zeros(1, n_grfs);
    
    for i=1:n_grfs
        trial = OpenSimTrial(model, kinematics{i}, save_dir, grfs{i});
        trial.run(osim_analyses);
        motion = ...
            MotionData(trial, leg_length, toe_length, analyses, grf_cutoff);
        cycles{i} = GaitCycle(motion);
    end
    
    averages(iter) = computeMeanMetric(cycles, metric, metric_args{:});
    
    [result(iter), sdev(iter)] = ...
        computeMeanMetricDifference(cycles, baseline, metric, metric_args{:});
    
end

figure;
bar(1:iterations, result);
hold on
errorbar(1:iterations, result, sdev, '.');

figure;
bar(1:iterations, averages);
%hold on
%bar(12, baseline);

