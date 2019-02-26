function result = calculateBaseline(type, metric, varargin)

    root = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Results';
    
    switch type
        case 'APO'
            baseline = load([root filesep 'gait-baseline-APO.mat']);
        case 'no_APO'
            baseline = load([root filesep 'gait-baseline-no_APO.mat']);
    end
    
    n_osts = length(baseline.gait);
    metric_data = zeros(1, n_osts);
    for i=1:n_osts
        n_samples = length(baseline.gait{i});
        sample_data = zeros(1, n_samples);
        for j=1:n_samples
            gait_cycle = baseline.gait{i}{j};
            sample_data(j) = metric(gait_cycle, varargin{:});
        end
        metric_data(i) = mean(sample_data);
    end
    result = mean(metric_data);
    
end