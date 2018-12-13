folders = dir('hiprom-rise*');

means = [];
sdevs = [];
for i=1:length(folders)
    folders(i).name
    [m, s] = evalHipResultsDir(folders(i).name);
    means = [means m];
    sdevs = [sdevs s];
end