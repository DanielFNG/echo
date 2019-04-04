function [result, sdev] = ...
    computeMeanMetricDifference(input, comp, metric, varargin)
% Computes the mean difference over GaitCycles between a metric & a given value.
%
% Input:
%        input - cell array of gait cycles, can be nested
%        comp - baseline, or value for comparison
%        metric - reference to metric function to be used
%        varargin - additional arguments to metric function
% Output:
%         result - mean value of metric over all gait cycles

    % Flatten the input data to obtain a single row of GaitCycles.
    if isa(input{1}, 'cell')
        input = horzcat(input{:});
    end
    
    % Compute the metric value for each GaitCycle.
    n_samples = length(input);
    sample_data = zeros(1, n_samples);
    for i=1:n_samples
        gait_cycle = input{i};
        sample_data(i) = metric(gait_cycle, varargin{:});
    end
    
    % Remove outliers.
    sample_data = sample_data(~isoutlier(sample_data));
    
    % Compute mean metric value.
    result = mean(abs(sample_data - comp));
    sdev = std(abs(sample_data - comp));

end