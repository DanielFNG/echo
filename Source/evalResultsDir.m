function [m, s] = evalResultsDir(save_dir)

grfs = dir(save_dir);
vals = zeros(length(grfs), 1);
for i=3:length(grfs)
    grf_data = Data([save_dir filesep grfs(i).name]);
    cop_ml = grf_data.getColumn('ground_force1_pz');
    vals(i) = abs(max(cop_ml) - min(cop_ml));
end

m = mean(vals);
s = std(vals);

end