% Choose the metric, arguments, baseline mode & a name.
mode = 'APO';
metric = @calculateXPMoS;
args = {'x', 'min'};
name = 'XPMoS';

% Calculate baseline.
baseline = calculateBaseline(mode, metric, args{:});

% Calculate ground truth.
ground_truth = calculateGroundTruth(metric, baseline, args{:});

% Plot results.
plotGroundTruth(ground_truth, name, baseline);