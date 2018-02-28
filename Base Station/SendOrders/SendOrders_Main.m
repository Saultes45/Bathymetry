%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Main
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Metadata
% Written by    : Nathanaël Esnault
% Verified by   : N/A
% Creation date : 2016-03-05
% Version       : 1.0 (finished on ...)
% Modifications :
% Known bugs    :

%% Functions associated with this code :


%% Possible Improvements


%% Cleaning

startletter = 'C';
ret = {};
for i = double(startletter):double('Z')
    if exist(['' i ':\Thesis\MATLAB\SendOrders'], 'dir') == 7 % 7=> name is a folder
        ret{end+1} = [i ':\'];  %#ok<SAGROW>
    end
end
cd([ret{end} 'Thesis\MATLAB\SendOrders']);
%cd 'D:\MATLAB\Bathymetry';
clc;
close all;
clear;

%% Find the date and use it as a this test ID
formatOut = 'yyyy-mm-dd--HH-MM-SS-FFF';
RunID = datestr(now,formatOut);

%% Start using the log file
Message(1,1,1,'Asking for new file', 'UDEF',RunID); %Creating a new log file (by using the third "1" in the function parameters)
Message(1,1,0,['Local directory is : ' cd ], 'UDEF', RunID); %Loging the cd

%% Close all the COM port opened by previous matlab
AvailableToolBoxes = ver; % We do the check onl if the tool box is avalailable
if ~isempty(find(strcmp({AvailableToolBoxes.Name},'Instrument Control Toolbox'), 1))
    serialInfo = instrhwinfo('serial');
    for cpt = 1:length(serialInfo.SerialPorts) 
            fclose(serial(serialInfo.SerialPorts{cpt,1}));
            disp(['closing ' serialInfo.SerialPorts{cpt,1}]);
    end
else
    msgbox('It is impossible to pre check the availability of the COM Port because you don''t have the correct toolbox','Error','Warn');
    Message(1,1,0,'It is impossible to pre check the availability of the COM Port because you don''t have the correct toolbox', 'KO', RunID);
end


%% Open the file containing the navigation path for the USV (1/USV)
    



%% INPUT COM PORT configuration
BroadcastAntenna=serial('COM6');
BroadcastAntenna.BaudRate = 9600; %bauds
BroadcastAntenna.Terminator = 'CR/LF';
BroadcastAntenna.DataBits = 8;
BroadcastAntenna.Timeout = 3; % en s
set(BroadcastAntenna,'OutputBufferSize',512*10);% we need a large buffer size


%% Variable declaration
cpt_iteration = 0;
NumberIteration = 1000;
USV_ID = [1];
NumberOfUSVs = length(USV_ID);

%% Construction of the orders matrix
field1 = 'ID';  value1 = zeros(1,10);
field2 = 'Latitude';
field3 = 'Longitude';
field4 = 'Speed';


USV = struct(field1,zeros(NumberIteration,1),field2,zeros(NumberIteration,1),field3,zeros(NumberIteration,1),field4,zeros(NumberIteration,1));

SendOrders_TextFileImporter;


% 
% for cpt_USV = 1 : NumberOfUSVs
%     USV(cpt_USV).ID = ones(NumberIteration,1)*USV_ID(cpt_USV);
%     USV(cpt_USV).Latitude = -37 * ones(NumberIteration,1);
%     USV(cpt_USV).Longitude = 140 * ones(NumberIteration,1);
%     USV(cpt_USV).Speed = randn(NumberIteration,1);
% end

%% Main loop
Message(1,1,0,['Trying to open the COM : ' num2str(BroadcastAntenna.Name) ' with ' num2str(BroadcastAntenna.BaudRate) ' bauds'],'UDEF', RunID);
cpt = 0;

try
    
    fopen(BroadcastAntenna);
    Message(1,1,0,['Successful open of : ' num2str(BroadcastAntenna.Name) ' with ' num2str(BroadcastAntenna.BaudRate) ' bauds'],'OK', RunID);
    
    while  cpt < NumberIteration
        cpt = cpt+1;
        DataToSend = ['$ORDERS,'];
        for cpt_USV = 1 : NumberOfUSVs
            DataToSend = [DataToSend num2str(USV(cpt_USV).ID(cpt)) ',' num2str(USV(cpt_USV).Latitude(cpt)) ',' num2str(USV(cpt_USV).Longitude(cpt)) ',' num2str(USV(cpt_USV).Speed(cpt))]; %#ok<AGROW>
        end
        fprintf(BroadcastAntenna, '%s\r\n', DataToSend);
        disp(DataToSend);
        pause(1);
    end
    
catch error
    disp(error);
    occured_error = 1;
    Message(1,1,0,'Error during the main loop', 'KO', RunID);
end


fclose(BroadcastAntenna);
Message(1,1,0,'COM port closed', 'OK', RunID);
delete(BroadcastAntenna);
clear BroadcastAntenna;
