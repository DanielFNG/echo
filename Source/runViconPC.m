settings = setupViconPC();

while true
    
    if settings.vicon_server.BytesAvailable > 0
        
        switch settings.vicon_server.BytesAvailable
            
            case 1
                fread(settings.vicon_server, ...
                    settings.vicon_server.BytesAvailable);
                goLive(settings);
            case 8
                string = char(fread(settings.vicon_server, ...
                    settings.vicon_server.BytesAvailable))'; %#ok<FREAD>
                fwrite(settings.apo_server, string, 'uchar');
            otherwise
                error(['Unexpected number of bytes recevied ' ...
                    'by Vicon server.']);
        end
        
    end
    
end