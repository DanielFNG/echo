function [m, s] = evalResultsDir(save_dir)

cycles = dir([save_dir filesep '.trc']);
vals = zeros(length(cycles), 1);
for i=1:length(cycles)
    ost = OpenSimTrial('../chris_scaled.osim', [save_dir filesep cycles(i).name], 'temp');
    cop_ml = cycle_data.getColumn('ground_force1_pz');
    vals(i) = abs(max(cop_ml) - min(cop_ml));
end

m = mean(vals);
s = std(vals);

end