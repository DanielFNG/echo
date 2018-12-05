all_dir = dir('rise*');

% CoP_ML_I = zeros(20,1);
% 
% m_irr = zeros(20,1);
% s_irr = zeros(20,1);
% for i=1:20
%    [~, m_irr(i), s_irr(i)] = calcCoP_ML_I(['rise' num2str(results.XTrace{i,1}) 'peak' num2str(results.XTrace{i,2}) 'fall' num2str(results.XTrace{i,3})]);
% end

means = [];
sdevs = [];
for i=1:length(all_dir)
    if exist([pwd filesep all_dir(i).name], 'dir')
        [m, s] = evalResultsDir(all_dir(i).name);
        means = [means m];
        sdevs = [sdevs s];
        %CoP_ML_I(i) = calcCoP_ML_I(all_dir(i).name);
    end
end