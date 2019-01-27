function createDirectories(dir_struct)
% Create directories given a stucture holding directory paths.

dirs = fieldnames(dir_struct);
for i=1:length(dirs)
    mkdir(dirs(i));
end

end