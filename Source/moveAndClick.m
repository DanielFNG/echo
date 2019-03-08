function moveAndClick(x, y)

    %screens = java.awt.GraphicsEnvironment. ...
    %    getLocalGraphicsEnvironment().getScreenDevices();
    %mouse = java.awt.Robot(screens(1));
    
    import java.awt.event.*;
    mouse = java.awt.Robot();
    
    mouse.mouseMove(0, 0);
    mouse.mouseMove(x, y);
    mouse.mousePress(InputEvent.BUTTON1_MASK);
    mouse.mouseRelease(InputEvent.BUTTON1_MASK);
    
end