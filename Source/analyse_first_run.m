% This script is for analysing the results of the first 'successful' online
% Bayesian Optimisation based exoskeleton controller. I can't make sense of
% the objective function results. 

%% Common info
model = 'C:\Users\danie\Documents\GitHub\echo\Source\chris_scaled.osim';
kinematics = [];
save_dir = 'analysing_first_run';
leg_length = 0.92;
toe_length = 0.08;
analyses = {'GRF'};
grf_cutoff = 2;
iterations = 20;
metric = @calculateCoPD;
metric_args = {'x'};
base = 'D:\Dropbox\PhD\HIL Control\CoPD-X-MoreData';

%% Compute the baseline.
root = [base filesep 'baseline\right\GRF'];

[n_grfs, grfs] = getFilePaths(root, '.mot');

cycles{n_grfs} = {};

for i=1:n_grfs
    trial = OpenSimTrial(model, kinematics, save_dir, grfs{i});
    motion = MotionData(trial, leg_length, toe_length, analyses, grf_cutoff);
    cycles{i} = GaitCycle(motion);
end

baseline = computeMeanMetric(cycles, metric, metric_args{:});

%% Compute the result for each trial
root = [base filesep 'processed'];
result = zeros(1, iterations);
sdev = result;

for iter = [1:11,13:iterations]
    inner = [root filesep 'iteration' sprintf('%03i', iter) filesep ...
        'right' filesep 'GRF'];
    
    [n_grfs, grfs] = getFilePaths(inner, '.mot');
    
    cycles = cell(1, n_grfs);
    
    for i=1:n_grfs
        trial = OpenSimTrial(model, kinematics, save_dir, grfs{i});
        motion = ...
            MotionData(trial, leg_length, toe_length, analyses, grf_cutoff);
        cycles{i} = GaitCycle(motion);
    end
    
    [result(iter), sdev(iter)] = ...
        computeMeanMetricDifference(cycles, baseline, metric, metric_args{:});
    
end

figure;
bar(1:iterations, result);
hold on
errorbar(1:iterations, result, sdev, '.');

