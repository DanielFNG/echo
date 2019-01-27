function waitUntilWritable(file, time)
% Check if a file is writable. Pause for a given time if not. Repeat. 

if nargin < 2
    time = 2;
end

[~, values] = fileattrib(file);

while ~values.UserWrite
    pause(time);
end

end