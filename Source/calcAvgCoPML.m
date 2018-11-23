function cop_ml_avg = calcAvgCoPML(directory)

grfs = dir([directory filesep '*.mot']);
n_grfs = length(grfs);
cop_ml_all = zeros(n_grfs, 100);
for i=1:n_grfs
    grf_data = Data([directory filesep grfs(i).name]);
    cop_ml = grf_data.getColumn('ground_force1_pz');
    cop_ml_all(i, :) = stretchVector(cop_ml, 100);
end

cop_ml_avg = zeros(100, 1);
for i=1:100
    cop_ml_avg(i) = mean(cop_ml_all(:, i));
end

cop_ml_avg = cop_ml_avg/cop_ml_avg(1)*100 - 100;

end

