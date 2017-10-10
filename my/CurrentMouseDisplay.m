function CurrentMouseDisplay(varargin)
% CurrentMouseDisplay('init') - initializes a window that displays the RFID
% of the current mouse
% CurrentMouseDisplay('update', ID) - updates the cuurent mouse display with
% a new RFID tag.
global BpodSystem
Op = varargin{1};
if nargin > 1
    ID = varargin{2};
end
Op = lower(Op);
switch Op
    case 'init'
        BpodSystem.ProtocolFigures.CurrentMouseDisplay = figure('Position', [50 700 150 150],'name','Total Reward','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off', 'Color', [.6 .6 1]);
        BpodSystem.GUIHandles.CurrentMouseDisplay = struct;
        BpodSystem.GUIHandles.CurrentMouseDisplay.Label = uicontrol('Style', 'text', 'String', 'Mouse inside:', 'units', 'normalized', 'Position', [.15 .7 .7 .15], 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', [.7 .7 1]);
        BpodSystem.GUIHandles.CurrentMouseDisplay.ID = uicontrol('Style', 'text', 'String', [''], 'units', 'normalized', 'Position', [.1 .25 .8 .25], 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', [.7 .7 1]);
        
    case 'update'
        set(BpodSystem.GUIHandles.CurrentMouseDisplay.ID, 'String', ID);
end