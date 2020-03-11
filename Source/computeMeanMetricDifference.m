function [result, sdev] = ...
    computeMeanMetricDifference(input, metric, comp, flag, varargin)
% Computes the mean absolute difference over GaitCycles between a metric & a 
% given value. Note that compared to computeMeanMetric this is for analysing
% the difference from some baseline value, and also that here the absolute
% value of the metric difference is taken rather than the signed value.
%
% Input:
%        input - cell array of gait cycles, can be nested
%        metric - reference to metric function to be used
%        comp - baseline, or value for comparison
%        flag - if true, remove outliers from metric results
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
    
    % Remove outliers if requested.
    if flag
        while any(isoutlier(sample_data))
            sample_data = sample_data(~isoutlier(sample_data));
        end
    end
    
    % Compute mean metric value.
    result = mean(abs(sample_data - comp));
    sdev = std(abs(sample_data - comp));

end