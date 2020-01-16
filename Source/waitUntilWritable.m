function fail = waitUntilWritable(file, time)
% Check if a file exists & is writable. Pause for a given time if not. Repeat. 

timeout = 30;

tic;
while ~(exist(file, 'file') == 2)
    fprintf('Waiting for file to exist.\n');
    pause(time);
    while toc > timeout
        str = input(['Long waiting time detected. Input 0 to keep waiting, ' ...
            '1 to throw an error, or 2 to assign a value of 1000.'], 's');
        if strcmp(str, '0')
            tic;
        elseif strcmp(str, '1')
            error('User error input detected.');
        elseif strcmp(str, '2')
            fail = 1;
            return
        end
    end
end

[~, values] = fileattrib(file);

while ~values.UserWrite
    fprintf('Waiting for file to be writable.\n');
    pause(time);
end

fail = 0;

end