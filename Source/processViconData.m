function processViconData(trial, settings)

    timeout = 30;

    vicon = ViconNexus();
    
    try
        vicon.OpenTrial(trial, timeout);
    catch
        pause(0.5);
        vicon.OpenTrial(trial, timeout);
    end

    vicon.RunPipeline('Reconstruct And Label', '', timeout);

    vicon.RunPipeline('HIL Small Gaps', '', timeout);
    vicon.RunPipeline('HIL Medium Gaps', '', timeout);
    vicon.RunPipeline('Fill Big Gaps', '', timeout);
    
    vicon.RunPipeline('Filter', '', timeout);

    vicon.RunPipeline('Export GRF Full Frames Only', '', timeout);
    vicon.RunPipeline('Export TRC Full Frames Only', '', timeout);
    vicon.SaveTrial(timeout);
    
    % Tell the Vicon PC to go live again.
    fwrite(settings.vicon_server, '0', 'uchar');

end


