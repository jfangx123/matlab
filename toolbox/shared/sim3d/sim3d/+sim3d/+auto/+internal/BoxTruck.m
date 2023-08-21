classdef BoxTruck

    properties(Constant=true)
        FrontBumper=struct(...
        'translation',single([5.10,0,0.60]),...
        'rotation',single([0,0,0]),...
        'scale',single([1,1,1]));
        RearBumper=struct(...
        'translation',single([-5.00,0,0.60]),...
        'rotation',single([0,0,pi]),...
        'scale',single([1,1,1]));
        RightMirror=struct(...
        'translation',single([2.90,1.60,2.10]),...
        'rotation',single([0,-pi/2,0]),...
        'scale',single([1,1,1]));
        LeftMirror=struct(...
        'translation',single([2.90,-1.60,2.10]),...
        'rotation',single([0,-pi/2,0]),...
        'scale',single([1,1,1]));
        RearviewMirror=struct(...
        'translation',single([2.60,0.20,2.60]),...
        'rotation',single([0,0,0]),...
        'scale',single([1,1,1]));
        HoodCenter=struct(...
        'translation',single([3.80,0,2.10]),...
        'rotation',single([0,0,0]),...
        'scale',single([1,1,1]));
        RoofCenter=struct(...
        'translation',single([1.30,0,4.20]),...
        'rotation',single([0,0,0]),...
        'scale',single([1,1,1]));
    end

end