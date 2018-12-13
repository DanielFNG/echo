function [m, s] = evalHipResultsDir(save_dir)

cycles = dir([save_dir filesep '*.trc']);
vals = zeros(length(cycles), 1);
for i=1:length(cycles)
    ost = OpenSimTrial('chris_scaled.osim', [save_dir filesep cycles(i).name], ['temp' num2str(i)]);
    ost.run('IK');
    ik = Data(['temp' num2str(i) filesep 'IK' filesep 'ik.mot']);
    hip = ik.getColumn('hip_flexion_r');
    vals(i) = abs(max(hip) - min(hip));
end

m = mean(vals);
s = std(vals);

end