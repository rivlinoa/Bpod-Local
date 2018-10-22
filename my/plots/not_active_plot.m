


function not_active_plot(AxesHandle, Action , animal_tag )
%
% AxesHandle = handle of axes to plot on
% Action = specific action for plot, "init" - initialize OR "update" -  update plot

%Example usage:
% AxesHandle

%
% animal_tag:  RFID tag of the current mouse in the corner
%
% Noa 21.10.18

global BpodSystem
switch Action
    case 'init'
        
        if ~(isfield(BpodSystem.GUIData, 'animals'))
            error (['User must insert the animals of the current experiment to the Bpod object ' ...
                ' \n Using Prepare-to-protocol function or manually']);
        end
        axes(AxesHandle)
        BpodSystem.GUIHandles.not_active_bar = bar(categorical(BpodSystem.GUIData.animals.animals_names),...
            BpodSystem.GUIData.animals.not_active,  0.6);
        xlabel('Mouse name')
        ylabel('Visit count')
        hold(AxesHandle, 'on');
         
        
               
    case 'update'
        
        %update GUI data for the visit count (add the
        %current trial):
        tag_ind=strcmp(BpodSystem.GUIData.animals.animals_tags,animal_tag);
        BpodSystem.GUIData.animals.not_active(tag_ind)=BpodSystem.GUIData.animals.not_active(tag_ind)+1;
        set(BpodSystem.GUIHandles.not_active_bar,'ydata', BpodSystem.GUIData.animals.not_active);
      
end
end


%bar(y,'stacked')