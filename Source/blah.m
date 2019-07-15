root = 'D:\Dropbox\PhD\EMG Test Data (Reference)\Processed';

n_channels = 3;
reference = 0:2:36;
test = 1:2:35;

%% Modify this line here
interest = test;
%

n_iterations = length(interest);

total_a = zeros(1, n_iterations);
total_s = zeros(1, n_iterations);
avgs = zeros(n_channels, n_iterations);
stds = zeros(n_channels, n_iterations);

for num = 1:length(interest)
    iter = interest(num);
    [n, emgs] = getFilePaths(...
        [root filesep 'seg' sprintf('%03i', iter) filesep 'EMG'], '.txt');
    
    total = zeros(n, 1);
    scores = zeros(n, n_channels);
    for cycle = 1:n
        emg = Data(emgs{cycle});
        [total(cycle), scores(cycle, :)] = calculateEMGCycleScores(emg); 
    end
    total_a(num) = mean(total);
    total_s(num) = std(total);
    
    for channel = 1:n_channels
        avgs(channel, num) = mean(scores(:, channel));
        stds(channel, num) = std(scores(:, channel));
    end
    
end