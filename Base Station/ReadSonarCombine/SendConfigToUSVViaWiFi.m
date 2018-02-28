%Generate Config files for Rpi's
%detecting all raspberry already in the profile
USVLetter2NumberConfig = {'C'; 'D'; 'Y'; 'B'; 'A'; 'A'};
%Check that there are no double letters
X = cell2mat(cellfun(@(x) double(x), USVLetter2NumberConfig, 'UniformOutput', false));
uniqueX = unique(X, 'stable');
USVLetter2NumberConfig = num2cell(char(uniqueX));

for cnt_USV = 1 : length(USVLetter2NumberConfig)
    %copy-paste every config files
    [status,cmdout] = dos(['ECHO F|xcopy /Y /R ' cd '\USVConfigFiles\Template_Config_.ini '...
        cd '\USVConfigFiles\Config_' int2str(cnt_USV) '.ini']);
    %in the ini file just change[IMU]
    
    %open the file
    fid = fopen([cd '\USVConfigFiles\Config_' int2str(cnt_USV) '.ini'], 'r' );
    i = 1;
    tline = fgetl(fid);
    Text_from_file{i} = tline; %#ok<SAGROW>
    while ischar(tline)
        i = i+1;
        tline = fgetl(fid);
        Text_from_file{i} = tline;
        if ~isempty(strfind(Text_from_file{i},'IMU_Number: '))
            % Change cell Text_from_file
            Text_from_file{i} = ['IMU_Number: ' int2str(cnt_USV)];
        end
    end
    fclose(fid);
    %     IMU_Number: 2
    Text_from_file{i+1} = -1; %#ok<SAGROW>
    % Write cell Text_from_file into txt
    fid = fopen([cd '\USVConfigFiles\Config_' int2str(cnt_USV) '.ini'], 'w');
    for i = 1:numel(Text_from_file)
        if Text_from_file{i} == -1
            fprintf(fid,'%s', Text_from_file{i});
            break
        else
            fprintf(fid,'%s\n', Text_from_file{i});
        end
    end
    fclose(fid);
end

%% Config in RPi


%try connecting to every raspberry pi and send them
[status,cmdout] = dos('netsh wlan show profile');
USVLetter2NumberConfig_Present = USVLetter2NumberConfig;
for cnt_USV = 1 : length(USVLetter2NumberConfig)
    if ~contains( cmdout, ['raspi-USV-' char(USVLetter2NumberConfig(cnt_USV))]) %%replacement for isempty(find)
        USVLetter2NumberConfig_Present{cnt_USV} = {};
    end
end
% R = cellfun(@(x) ~isempty(x),USVLetter2NumberConfig_Present); % Find empty cells
USVLetter2NumberConfig_Present = USVLetter2NumberConfig_Present(~cellfun('isempty',USVLetter2NumberConfig_Present));
% USVLetter2NumberConfig_Present{R} = [];
% USVLetter2NumberConfig_Present = USVLetter2NumberConfig;

% check that the folder containing the USV config files exists
if exist([cd '\USVConfigFiles'], 'dir') ~= 7
    disp('The folder containing the USV config files dosen''t exist');
end

for cnt_wificonnections = 1 : length(USVLetter2NumberConfig_Present)
    [status,cmdout] = dos(['netsh wlan connect name="raspi-USV-' char(USVLetter2NumberConfig_Present(cnt_wificonnections)) '"']);
    % Wait 5s for the computer network card to connect
    pause(5);
    %SSH to them and read if there is any config file existing
    [status,cmdout] = dos('putty.exe -ssh pi@10.3.141.1:22 -pw raspberry -m RPIOrders.sh');
    
    %get the number of each USV
    %for each letter in USVLetter2NumberConfig_Present we want the associated
    %USV number in USVLetter2NumberConfig (the number is the index)
    USVNumber = find(strcmp(USVLetter2NumberConfig, USVLetter2NumberConfig_Present(cnt_wificonnections)));
    if ~isempty(USVNumber)
        [status,cmdout] = dos(['pscp -v -pw raspberry ' cd '\USVConfigFiles\Config_' int2str(USVNumber) '.ini pi@10.3.141.1:/home/pi/Desktop/USV/Config_' int2str(USVNumber) '.ini']);
        if contains( cmdout, 'Server sent command exit status 0') %Introduced in R2016b
            disp('Transfer completed successfully');
        end
    end
end

% try to connect back to UoA wifi
try
    [status,cmdout] = dos('netsh wlan connect name="UoA-WiFi"');
catch error
    disp('Cannot connect back to Uni WiFi');
end
