%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Main
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Metadata
% Written by    : Nathanaël Esnault
% Verified by   : N/A
% Creation date : 2016-01-12
% Version       : 1.0 (finished on ...)
% Modifications :
% Known bugs    :

%% Functions associated with this code :

%% Possible Improvements

%% Cleaning

% startletter = 'C';
% ret = {};
% for i = double(startletter):double('Z')
%     if exist(['' i ':\Thesis\MATLAB\ReadSonarCombine'], 'dir') == 7 % 7=> name is a folder
%         ret{end+1} = [i ':\'];  %#ok<SAGROW>
%     end
% end
% cd([ret{end} 'Thesis\MATLAB\ReadSonarCombine']);

ret{1} = 'C:\Users\bathy\Desktop\ReadSonarCombine';

%% Find the date and use it as a clc;
% close all;
% clc
% clear;
%this test ID
formatOut = 'yyyy-mm-dd--HH-MM-SS-FFF';
RunID = datestr(now,formatOut);


%% Start using the log file
% Message(1,1,1,'Asking for new file', 'UDEF',RunID); %Creating a new log file (by using the third "1" in the function parameters)
% Message(1,1,0,['Local directory is : ' cd ], 'UDEF', RunID); %Loging the cd

%% Local variable definition
PrepareRPiWiFi      = 0;
TrimGNSSNoFix       = 1;
TrimSONAROutOfWater = 1;
DoStatisics         = 1;
TestID              = '083606';

%%
if PrepareRPiWiFi
    SendConfigToUSVViaWiFi;
end

%% Main process
smallLOGDateFormat = 'yyyymmdd-HH:MM:SS:FFF';

%% Open the sonar file and get the data

% filename = [ret{end} 'Thesis\MATLAB\ReadSonarCombine\combined\smallLOGtest1.log'];
filename = [ret{end} '\Thesis\MATLAB\ReadSonarCombine\combined (1)\DepthLogs\smallLOG_' TestID '.log'];
delimiter = ' ';
formatSpec = '%s%C%[^\n\r]';
fileID = fopen(filename,'r');
% dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);

SonarTime = dataArray{:, 1};
SonarMessage = dataArray{:, 2};
SonarMessage = cellstr(SonarMessage);
%Remove the cells that contains '<undefined>'
BadSonarMessage = find(cell2mat(cellfun(@(x) strcmp(x, '<undefined>'), SonarMessage, 'UniformOutput', false)));
for cnt = 1:length(BadSonarMessage)
    SonarMessage{BadSonarMessage(cnt)} = {};
    SonarTime{BadSonarMessage(cnt)} = {};
end


try
    datenum(SonarTime, smallLOGDateFormat);
catch error
    %     SonarMessage{end}=[];
    SonarTime{end}=[];
end

SonarMessage = SonarMessage(~cellfun('isempty',SonarMessage));
SonarTime = SonarTime(~cellfun('isempty',SonarTime));

MinIndex = min(length(SonarMessage), length(SonarTime));
for cnt = MinIndex:length(SonarMessage)
    SonarMessage{cnt} = {};
end
for cnt = MinIndex:length(SonarTime)
    SonarTime{cnt} = {};
end

SonarMessage = SonarMessage(~cellfun('isempty',SonarMessage));
SonarTime = SonarTime(~cellfun('isempty',SonarTime));


clearvars filename delimiter formatSpec fileID dataArray ans;

%% Open the GPS file and get the data
% filename = [ret{end} 'Thesis\MATLAB\ReadSonarCombine\combined\smallLOGtest2.log'];
filename = [ret{end} '\Thesis\MATLAB\ReadSonarCombine\combined (1)\GNSSLogs\smallLOG_' TestID '.log'];
delimiter = ' ';
formatSpec = '%s%C%[^\n\r]';
fileID = fopen(filename,'r');
% dataArray2 = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
dataArray2 = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
GPSTime = dataArray2{:, 1};
GPSMessage = cellstr(dataArray2{:, 2});

try
    datenum(GPSTime, smallLOGDateFormat);
catch error
    %     GPSMessage{end}=[];
    GPSTime{end}=[];
end

GPSMessage = GPSMessage(~cellfun('isempty',GPSMessage));
GPSTime = GPSTime(~cellfun('isempty',GPSTime));

BadGPSMessage = find(cell2mat(cellfun(@(x) isempty(x), SonarMessage, 'UniformOutput', false)));
BadGPSTime = find(cell2mat(cellfun(@(x) isempty(x), GPSTime, 'UniformOutput', false)));
GPSIsEmpty = unique([BadGPSMessage; BadGPSTime]);
for cnt = 1:length(GPSIsEmpty)
    GPSMessage{GPSIsEmpty(cnt)} = {};
    GPSTime{GPSIsEmpty(cnt)} = {};
end

GPSMessage = GPSMessage(~cellfun('isempty',GPSMessage));
GPSTime = GPSTime(~cellfun('isempty',GPSTime));

MinIndex = min(length(GPSMessage), length(GPSTime));
for cnt = MinIndex:length(GPSMessage)
    GPSMessage{cnt} = {};
end
for cnt = MinIndex:length(GPSTime)
    GPSTime{cnt} = {};
end

GPSMessage = GPSMessage(~cellfun('isempty',GPSMessage));
GPSTime = GPSTime(~cellfun('isempty',GPSTime));

clearvars filename delimiter formatSpec fileID dataArray ans;

%% Filter all the GNSS no fix and SONAR outside water
if TrimGNSSNoFix
    TrimGNSS;
end

if TrimSONAROutOfWater
    TrimSonar;
end

%% Create a chronological matrix
timeArray = ones(length(GPSTime)+length(SonarTime),1)*NaN;
timeArraySonar  = cell2mat(cellfun(@(x) datenum(x, smallLOGDateFormat), SonarTime,  'UniformOutput', false));
timeArrayGPS    = cell2mat(cellfun(@(x) datenum(x, smallLOGDateFormat), GPSTime,    'UniformOutput', false));

timeArray = [timeArrayGPS;...
    timeArraySonar];
[timeArraySorted,timeArraySortedIndexes] = sort(timeArray);


%% Create a combined file

% Write cell Text_from_file into txt
fid = fopen([cd '\FinalFile_' TestID '.txt'], 'w'); %Open or create new file for writing. Discard existing contents, if any.
for i = 1:length(timeArray)
    if i == length(timeArray)
        if timeArraySortedIndexes(i) <= length(GPSTime)
            fprintf(fid,'%s\n', char(GPSMessage(timeArraySortedIndexes(i))));
        else
            fprintf(fid,'%s\n', char(SonarMessage(timeArraySortedIndexes(i)-length(GPSTime))));
        end
    else
        if timeArraySortedIndexes(i) <= length(GPSTime)
            fprintf(fid,'%s\n', char(GPSMessage(timeArraySortedIndexes(i))));
        else
            fprintf(fid,'%s\n', char(SonarMessage(timeArraySortedIndexes(i)-length(GPSTime))));
        end
    end
end
fclose(fid);

%% Statistics
if DoStatisics
    GenerateStatistics;
end

%% Saving data
% SaveSensorDataFileName = [cd '\Data\' RunID '-SonarData.mat'];
% save(SaveSensorDataFileName, 'sonarDepth', 'sonarTime');
