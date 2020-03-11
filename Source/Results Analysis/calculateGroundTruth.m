function result = calculateGroundTruth(...
    root, parameters, metric, baseline, varargin)
% Compute ground truth matrix for a given set of arguments.
%
% Input:
%        root - directory where results files are stored, files must be
%               named 'P_R_F.mat', where P, R and F are replaced by
%               suitable values of rise, peak and fall, respectively.
%               Suitable values are those specified by the 'parameters'
%               struct (see below).
%        parameters - struct with fields rise, peak & fall each of which is
%                     an array of parameter values for that field
%        metric - the metric function to be used
%        baseline - the baseline to be used
%        varargin - arguments for the metric, if any
    
    n_rise = length(parameters.rise);
    n_peak = length(parameters.peak);
    n_fall = length(parameters.fall);
    
    result = zeros(n_rise, n_peak, n_fall);
    
    for rise = 1:n_rise
        for peak = 1:n_peak
            for fall = 1:n_fall
                r = parameters.rise(rise);
                p = parameters.peak(peak);
                f = parameters.fall(fall);
                if r <= p && p <= f
                    data = load([root filesep num2str(r) '_' num2str(p) '_' ...
                        num2str(f) '.mat'], 'gait');
                    
                    result(rise, peak, fall) = computeMeanMetricDifference(...
                        data.gait, metric, baseline, true, varargin{:});
                else
                    result(rise, peak, fall) = 100;
                end
            end
        end
    end

end