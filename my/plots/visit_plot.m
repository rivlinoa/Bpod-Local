


function visit_plot(AxesHandle, Action , animal_tag )
% Plug in to Plot the amount of water delivered online.
% AxesHandle = handle of axes to plot on
% Action = specific action for plot, "init" - initialize OR "update" -  update plot

%Example usage:
% AxesHandle
% reward_supplied_plot(AxesHandle,'init')
% reward_supplied_plot(AxesHandle,'update',current_animal)

%
% animal_tag:  RFID tag of the current mouse in the corner
%
%
%

% Noa 2.7.18

global BpodSystem
switch Action
    case 'init'
        
        if ~(isfield(BpodSystem.GUIData, 'animals'))
            error (['User must insert the animals of the current experiment to the Bpod object ' ...
                ' \n Using Prepare-to-protocol function or manually']);
        end
        axes(AxesHandle)
        BpodSystem.GUIHandles.visit_count_bar = bar(categorical(BpodSystem.GUIData.animals.animals_names),...
            BpodSystem.GUIData.animals.visit_count);
        hold(AxesHandle, 'on');
        
        
        
        
        
    case 'update'
        
        %update GUI data for the visit count (add the
        %current trial):
        tag_ind=strcmp(BpodSystem.GUIData.animals.animals_tags,animal_tag);
        BpodSystem.GUIData.animals.visit_count(tag_ind)=BpodSystem.GUIData.animals.visit_count(tag_ind)+1;
        set(BpodSystem.GUIHandles.visit_count_bar,'ydata', BpodSystem.GUIData.animals.visit_count);
      
end
end
