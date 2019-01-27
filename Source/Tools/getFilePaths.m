function [n_files, paths] = getFilePaths(directory, extension)
% Return paths to files of a given extension in a directory. 

files = dir([directory filesep '*' extension]);
n_files = length(files);
paths = cell(1, n_files);
for i=1:n_files
    paths{i} = [directory filesep files(i).name];
end

end