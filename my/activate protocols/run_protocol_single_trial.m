%% Run protocol single trial 
% has to recieve protocol name as input, and possibly a settings name 
% run_protocol_single_trial('protocolName', 'subjectName', ['settingsName']) - Runs
%    the protocol "protocolName". subjectName is required. settingsName is
%    optional. All 3 are names as they would appear in the launch manager
%    (i.e. do not include full path or file extension).


function run_protocol_single_trial(varargin)
global BpodSystem
        if nargin < 2
            error('You must insert both protocol and subject names')
        else
            protocolName = varargin{1};
            subjectName = varargin{2};
            if nargin > 2
                settingsName = varargin{3};
            else
                settingsName = 'DefaultSettings';
            end
        end
        
%Find the protocol folder inside bpod local :
 BpodSystem.Path.ProtocolFolder = BpodSystem.SystemSettings.ProtocolFolder;
            ProtocolPath = fullfile(BpodSystem.Path.ProtocolFolder, protocolName);
            
            if ~exist(ProtocolPath)
                % Look 1 level deeper
                RootContents = dir(BpodSystem.Path.ProtocolFolder);
                nItems = length(RootContents);
                Found = 0;
                y = 3;
                while Found == 0 && y <= nItems
                    if RootContents(y).isdir
                        ProtocolPath = fullfile(BpodSystem.Path.ProtocolFolder, RootContents(y).name, protocolName);
                        if exist(ProtocolPath)
                            Found = 1;
                        end
                    end
                    y = y + 1;
                end
            end
            if ~exist(ProtocolPath)
                error(['Error: Protocol "' protocolName '" not found.'])
            end
            
            % I shold tell it where to look for setting files, and then
            % where to store them in the data folder. 
            SettingsFileName = fullfile(ProtocolPath, 'Settings', [settingsName '.mat']);
            if ~exist(SettingsFileName)
                error(['Error: Settings file: ' settingsName '.mat does not exist for protocol: ' protocolName  '.'])
            end
            
            BpodSystem.GUIData.ProtocolName = protocolName;
            BpodSystem.GUIData.SubjectName = subjectName;
            BpodSystem.GUIData.SettingsFileName = SettingsFileName;
            BpodSystem.Path.Settings = SettingsFileName;
            BpodSystem.Status.CurrentProtocolName = protocolName;
            BpodSystem.Status.CurrentSubjectName = subjectName;
            SettingStruct = load(BpodSystem.Path.Settings);
            %BpodSystem.ProtocolSettings = SettingStruct;
            tmp_fiels_names = fieldnames(SettingStruct);
            FieldName=tmp_fiels_names{1};
            BpodSystem.ProtocolSettings = eval(['SettingStruct.' FieldName]);
            
            
            ProtocolRunFile = fullfile(ProtocolPath, [protocolName '.m']);
            addpath(ProtocolRunFile);
            run(ProtocolRunFile);
            
            
            