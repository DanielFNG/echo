function waitUntilWritable(file, time)

if nargin < 2
    time = 2;
end

[~, values] = fileattrib(file);

while ~values.UserWrite
    pause(time);
end

end