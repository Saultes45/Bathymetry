%% Gathering data

info.GNSSDuration = datevec(max(timeArrayGPS) - min(timeArrayGPS));
info.GNSSExecTimeHours = info.GNSSDuration(4);
info.GNSSExecTimeMinutes = info.GNSSDuration(5);
info.GNSSExecTimeSeconds = info.GNSSDuration(6);

info.SonarDuration = datevec(max(timeArraySonar) - min(timeArraySonar));
info.SonarExecTimeHours = info.SonarDuration(4);
info.SonarExecTimeMinutes = info.SonarDuration(5);
info.SonarExecTimeSeconds = info.SonarDuration(6);

info.TotalNumberOfMessages = length(SonarMessage) + length(GPSMessage);
info.PercentOfGNSSMessages = (length(GPSMessage) / info.TotalNumberOfMessages) * 100;
info.PercentOfSonarMessages = (length(SonarMessage) / info.TotalNumberOfMessages) * 100;

%% Find all the Sonar messages that contains the DPT
% $AADPT,40.24,0.00*72
cnt = 1;
for cnt_Sonar = 1 : length(SonarMessage)
   if strcmp(SonarMessage{cnt_Sonar}(4:6), 'DPT')
       IndeXDPT(cnt) = cnt_Sonar; %#ok<SAGROW>
       cnt = cnt + 1; 
   end
end
% DPTMessages = cellfun(@x GPSMessage{x}, , 'UniformOutput', 'false');

DPTTime = timeArraySonar(IndeXDPT); % the number of days from January 0, 0000
info.SonarAquisitionPeriod = diff(DPTTime) * 24 * 3600; %transformation to number of sec
% figure(), semilogy(info.SonarAquisitionPeriod, 'rx-'); xlabel('Sample Number [N/A]'); ylabel('Elapsed time betwen messages [s]');grid on;

%% Find all the GPS messages that contains the RMC
cnt = 1;
for cnt_GPS = 1 : length(GPSMessage)
   if strcmp(GPSMessage{cnt_GPS}(4:6), 'RMC')
       IndeXRMC(cnt) = cnt_GPS; %#ok<SAGROW>
       cnt = cnt + 1; 
   end
end
% DPTMessages = cellfun(@x GPSMessage{x}, , 'UniformOutput', 'false');

RMCTime = timeArrayGPS(IndeXRMC); % the number of days from January 0, 0000
info.GPSAquisitionPeriod = diff(RMCTime) * 24 * 3600; %transformation to number of sec
figure(), semilogy(info.GPSAquisitionPeriod, 'rx-'); xlabel('Sample number [N/A]'); ylabel('Elapsed time between 2 messages [s]');grid on;

% calculate the sample distance
info.GPSAquisitionDistance = 0;


%% Creating string for dialogbox
DialogBoxMessage = {...
    ['GNSS Execution time: '                                num2str(info.GNSSExecTimeHours) 'h, ' num2str(info.GNSSExecTimeMinutes) 'm, ' num2str(info.GNSSExecTimeSeconds) 's'],...
    ['Sonar Execution time: '                               num2str(info.SonarExecTimeHours) 'h, ' num2str(info.SonarExecTimeMinutes) 'm, ' num2str(info.SonarExecTimeSeconds) 's'],...
    ['Number of GNSS messages: '                            num2str(length(GPSMessage))],...
    ['Number of Sonar messages: '                           num2str(length(SonarMessage))],...
    ['Total messages: '                                     num2str(info.TotalNumberOfMessages)],...
    ['% of GNSS/Sonar messages: '                           num2str(info.PercentOfGNSSMessages, '%4.1f') '% / ' num2str(info.PercentOfSonarMessages, '%4.1f') '%'],...
    ['GNSS/Sonar Talker''s ID: '                            GPSMessage{1}(2:3) ' / ' SonarMessage{1}(2:3)],...
    ['Max/Min/Mean time [s] between 2 Sonar measurements: ' num2str(max(info.SonarAquisitionPeriod),    '%10.1f') ' ' num2str(min(info.SonarAquisitionPeriod),  '%10.1f') ' ' num2str(mean(info.SonarAquisitionPeriod), '%10.1f')],...
    ['Max/Min/Mean time [s] between 2 GNSS solutions: '     num2str(max(info.GPSAquisitionPeriod),      '%10.1f') ' ' num2str(min(info.GPSAquisitionPeriod),    '%10.1f') ' ' num2str(mean(info.GPSAquisitionPeriod),   '%10.1f')],...
    ['Max/Min/Mean distance[m] between 2 measurements: '    num2str(max(info.GPSAquisitionDistance),      '%10.1f') ' ' num2str(min(info.GPSAquisitionDistance),    '%10.1f') ' ' num2str(mean(info.GPSAquisitionDistance),   '%10.1f')]...
    };

DialogBoxMessage_CRLF = cell(1,length(DialogBoxMessage));
for cpt = 1 : length(DialogBoxMessage)
    DialogBoxMessage_CRLF{cpt}=sprintf('%s\r',DialogBoxMessage{cpt});
end

%% Clipboard
mat2clip(DialogBoxMessage_CRLF);
msgbox('Message copied to clipboard','Operation Completed','help');


%% Message box
msgbox_message=msgbox(DialogBoxMessage,'Operation Completed','help');
set(msgbox_message, 'Position', [303.2500  256.3333  400.0000  155.5000]);