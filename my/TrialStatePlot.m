%% 
% TrialStatePlot(AxesHandle, 'init', (nTrialsToShow)) - initiates plot
% TrialStatePlot(AxesHandle, 'update', TrialNumber , TrialState,  tag, nTrialToShow) - updates the plot

function TrialStatePlot(AxesHandle, Action, varargin)

global BpodSystem
%default number of trials to display
nTrialsToShow = 90;
    
switch Action
    
    case 'init'
        %initialize pokes plot
        
        
        
        %axes(AxesHandle);
        figure (AxesHandle)
        hold on
        %plot in specified axes
        Xdata = []; Ydata = [];
        BpodSystem.GUIHandles.RewardTrialLine = line(Xdata,Ydata,'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',3);
        BpodSystem.GUIHandles.PreMatureTrialLine = line(Xdata,Ydata,'LineStyle','none','Marker','o','MarkerEdge','y','MarkerFace','y', 'MarkerSize',3);
        BpodSystem.GUIHandles.LateTrialLine = line(Xdata,Ydata,'LineStyle','none','Marker','o','MarkerEdge','m','MarkerFace','m', 'MarkerSize',3);
        BpodSystem.GUIHandles.SideTrialLine = line(Xdata,Ydata,'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',3);
        BpodSystem.GUIHandles.OmittedTrialLine = line(Xdata,Ydata,'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','b', 'MarkerSize',3);
        
             
        xlabel('Trial#', 'FontSize', 18);
        ylabel('Animal tag', 'FontSize', 16);
        
        
    case 'update'
        if nargin > 4 %custom number of trials
            nTrialsToShow =varargin{4};
        end
        CurrentTrial = varargin{1};
        TrialState = varargin{2};
        tag = varargin{3};
       
        if CurrentTrial<1
            CurrentTrial = 1;
        end
                
        % recompute xlim
%         if CurrentTrial>nTrialsToShow
%                 [mn, mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow);
%                 set(AxesHandle,'XLim',[mn-1 mx+1]); %Replaced this with a trimmed "display" copy of the data for speed - JS 2017
%         end 
        
                
        Xdata = CurrentTrial;
        Ydata = categorical(tag);
             
        figure (AxesHandle)
        %Update the current Trial
        if ~isempty(TrialState)
            switch TrialState
                case 'Reward'
                    %set(BpodSystem.GUIHandles.RewardTrialLine, 'xdata', Xdata, 'ydata', Ydata);
                    line(Xdata,Ydata,'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
                case 'PreMature'
                    %set(BpodSystem.GUIHandles.PreMatureTrialLine, 'xdata', Xdata, 'ydata', Ydata);
                    line(Xdata,Ydata,'LineStyle','none','Marker','o','MarkerEdge','y','MarkerFace','y', 'MarkerSize',6);
                case 'Late'
                    %set(BpodSystem.GUIHandles.LateTrialLine, 'xdata', Xdata, 'ydata', Ydata);
                    line(Xdata,Ydata,'LineStyle','none','Marker','o','MarkerEdge','m','MarkerFace','m', 'MarkerSize',6);
                case 'Side'
                    %set(BpodSystem.GUIHandles.SideTrialLine, 'xdata', Xdata, 'ydata', Ydata);
                    line(Xdata,Ydata,'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
                case 'Omitted'
                    %set(BpodSystem.GUIHandles.OmittedTrialLine, 'xdata', Xdata, 'ydata', Ydata);
                    line(Xdata,Ydata,'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','b', 'MarkerSize',6);
            end 
        end
end

end

% function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
% FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
% mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
% mx = mn + nTrialsToShow - 1;
% end


