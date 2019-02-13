% Choose the metric, arguments, baseline mode & a name.
mode = 'APO';
metric = @calculateWNPT;
args = 'hip_flexion_r';
name = 'Weight Normalised Peak Hip Torque (System)';

% Calculate baseline.
baseline = calculateBaseline(mode, metric, args);

% Calculate ground truth.
ground_truth = calculateGroundTruth(metric, baseline, args);

% Plot results.
plotGroundTruth(ground_truth, name, baseline);