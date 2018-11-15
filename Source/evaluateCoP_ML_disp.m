function CoP_ML_disp = evaluateCoP_ML_disp(X)

fprintf('\nApply torque pattern generated by rise = %i, peak = %i, fall = %i.\n', X.rise, X.peak, X.fall);

str = input('Input name of GRF file produced.\n');

save_dir = ...
    ['rise' num2str(X.rise) 'peak' num2str(X.peak) 'fall' num2str(X.fall)];
produced_mot = [save_dir '.mot'];
produceMOT(str, produced_mot);
segmentMOT(produced_mot, save_dir);

grfs = dir(save_dir);
vals = zeros(length(grfs), 1);
for i=3:length(grfs)
    grf_data = Data([save_dir filesep grfs(i).name]);
    cop_ml = grf_data.getColumn('ground_force1_pz');
    vals(i) = abs(max(cop_ml) - min(cop_ml));
end

CoP_ML_disp = mean(vals);

end