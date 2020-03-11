function goLive(settings)

    moveAndClick(settings.live_x, settings.live_y);
    pause(1);
    moveAndClick(settings.arm_x, settings.arm_y);
    moveAndClick(settings.lock_x, settings.lock_y);

end