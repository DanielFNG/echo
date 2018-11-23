function [cop_ml_all_I, m_irr, s_irr] = calcCoP_ML_I(dir)

baseline = 'baseline';
cop_ml_baseline_avg = calcAvgCoPML(baseline);
cop_ml_dir_all = getAllCoPML(dir);

n_grfs = size(cop_ml_dir_all, 1);
cop_ml_all_I = zeros(n_grfs, 1);
figure
hold on
plot(cop_ml_baseline_avg);
for i=1:n_grfs
    plot(cop_ml_dir_all(i,:));
    cop_ml_all_I(i) = sum(abs(cop_ml_dir_all(i, :) - cop_ml_baseline_avg'));
end

m_irr = mean(cop_ml_all_I);
s_irr = std(cop_ml_all_I);

end