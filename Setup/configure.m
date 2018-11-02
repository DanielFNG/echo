function configure()
% Adds the appropriate ECHO source directories to the Matlab path. 

% Modify the Matlab path to include the source folder.
addpath(genpath(['..' filesep 'Source']));
    
% Save resulting path.
savepath;

end
