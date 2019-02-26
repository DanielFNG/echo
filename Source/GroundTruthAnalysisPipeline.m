% Choose the metric, arguments, baseline mode & a name.
mode = 'APO';
metric = @calculateXPMoS;
args = {0.92, 'x', 'min'};
name = 'XPMoS';
speed = 0.8;

% Calculate baseline.
baseline = calculateBaseline(mode, metric, speed, args{:});

% Calculate ground truth.
ground_truth = calculateGroundTruth(metric, baseline, speed, args{:});

% Plot results.
plotGroundTruth(ground_truth, name, baseline);