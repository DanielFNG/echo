% Choose the metric, arguments, baseline mode & a name.
mode = 'APO';
metric = @calculateMoS;
args = {40, 0.8, 0.92, 'x', 'min'};
name = 'MoSAX';

% Calculate baseline.
baseline = calculateBaseline(mode, metric, args{:});

% Calculate ground truth.
ground_truth = calculateGroundTruth(metric, baseline, args{:});

% Plot results.
plotGroundTruth(ground_truth, name, baseline);