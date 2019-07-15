[n, names] = getFilePaths('D:\Dropbox\PhD\EMG Test Data (More Sensors)', '.csv');
[~, grfs] = getFilePaths('D:\Dropbox\PhD\EMG Test Data (More Sensors)', '.txt');

test = zeros(1, n);
c1_avgs = zeros(1, n);
c1_stds = zeros(1, n);
c2_avgs = zeros(1, n);
c2_stds = zeros(1, n);
comb_avgs = zeros(1, n);
comb_stds = zeros(1, n);

for i=1:n
    subdir = ['D:\Dropbox\PhD\EMG Test Data (More Sensors)\processed\iteration' sprintf('%03i', i), '\right\GRF'];
    [m, grfs] = getFilePaths(subdir, '.mot');
    times = cell(1, m);
    for j=1:m
        grf = Data(grfs{j});
        times{j} = grf.getTimesteps();
    end
    emg = parseEMGDataFaster(names{i});
    score = calculateEMGScore(emg, times);
    test(i) = score;
%     c1_avgs(i) = mean(array{1});
%     c1_stds(i) = std(array{1});
%     c2_avgs(i) = mean(array{2});
%     c2_stds(i) = std(array{2});
%     comb_avgs(i) = mean(combined);
%     comb_stds(i) = std(combined);
end