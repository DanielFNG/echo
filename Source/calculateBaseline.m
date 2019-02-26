function result = calculateBaseline(type, metric, speed, varargin)

    root = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Results';
    
    switch type
        case 'APO'
            baseline = load([root filesep 'baseline-APO.mat']);
        case 'no_APO'
            baseline = load([root filesep 'baseline-no_APO.mat']);
    end
    
    n_osts = length(baseline.osts);
    metric_data = zeros(1, n_osts);
    for i=1:n_osts
        n_samples = length(baseline.osts{i});
        sample_data = zeros(1, n_samples);
        for j=1:n_samples
            motion_data = MotionData(baseline.osts{i}{j}, {'Markers', 'GRF', 'BK', 'IK'}, speed, 'x');
            gait_cycle = GaitCycle(motion_data);
            sample_data(j) = metric(gait_cycle, varargin{:});
        end
        metric_data(i) = mean(sample_data);
    end
    result = mean(metric_data);
    
end