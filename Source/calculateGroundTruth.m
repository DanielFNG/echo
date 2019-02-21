function result = calculateGroundTruth(metric, baseline, varargin)

    root = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Matlab Save Files';
    
    rise_vals = [45, 50, 55];
    peak_vals = [50, 55, 60];
    fall_vals = [65, 70, 75];
    
    n_rise = length(rise_vals);
    n_peak = length(peak_vals);
    n_fall = length(fall_vals);
    
    result = zeros(n_rise, n_peak, n_fall);
    
    for rise = 1:n_rise
        for peak = 1:n_peak
            for fall = 1:n_fall
                r = rise_vals(rise);
                p = peak_vals(peak);
                f = fall_vals(fall);
                if r <= p && p <= f
                    load([root filesep num2str(r) '_' num2str(p) '_' ...
                        num2str(f) '.mat'], 'ost');
                    n_samples = length(ost);
                    metric_data = zeros(1, n_samples);
                    for i=1:n_samples
                        gait_cycle = GaitCycle(ost{i});
                        metric_data(i) = metric(gait_cycle, varargin{:});
                    end
                    result(rise, peak, fall) = sum(abs(metric_data - baseline))/n_samples;
                else
                    result(rise, peak, fall) = 100;
                end
            end
        end
    end

end