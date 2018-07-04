


function reward_supplied_plot(AxesHandle, Action, animal_tag, reward_given)
% Plug in to Plot the amount of water delivered online.
% AxesHandle = handle of axes to plot on
% Action = specific action for plot, "init" - initialize OR "update" -  update plot

%Example usage:
%AxesHandle
% reward_supplied_plot('init')
% reward_supplied_plot('update',current_animal, current_reward )

%
% current_animal:  RFID tag of the current mouse in the corner
% current_reward (optional), the amount of reward supplied, if is not
% provided use the default settings.
%
%

% Noa 2.7.18

global BpodSystem
switch Action
    case 'init'
        %BpodSystem.ProtocolFigures.reward_supplied_plot=figure('Name', 'Total water delivered');
        if ~(isfield(BpodSystem.GUIData, 'animals'))
            error (['User must insert the animals of the current experiment to the Bpod object ' ...
                ' \n Using Prepare-to-protocol function or manually']);
        end
        axes(AxesHandle)
        BpodSystem.GUIHandles.reward_supplied_bar = bar(categorical(BpodSystem.GUIData.animals.animals_names),...
            BpodSystem.GUIData.animals.reward_supplied);
        hold(AxesHandle, 'on');
        
        
    case 'update'
        %update GUI data for the total reward given per animal (add the
        %current trial): 
        tag_ind=strcmp(BpodSystem.GUIData.animals.animals_tags,animal_tag);
        BpodSystem.GUIData.animals.reward_supplied(tag_ind)=BpodSystem.GUIData.animals.reward_supplied(tag_ind)+reward_given;
        % Here insert the units code from total reward display func.
        set(BpodSystem.GUIHandles.reward_supplied_bar,'ydata', BpodSystem.GUIData.animals.reward_supplied);
       
end
end
