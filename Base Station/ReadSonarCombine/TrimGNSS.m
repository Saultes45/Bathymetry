%1st Find the TFF with the RMC message
% $GNRMC,,V,,,,,,,,,,N*4D
% $GNRMC,032503.00,A,3651.90468,S,17443.38978,E,0.502,244.42,020218,,,A*6A
cnt_start = 1;
IndexStartGPS = ones(length(GPSMessage),1)*NaN;
cnt_stop = 1;
IndexStopGPS = ones(length(GPSMessage),1)*NaN;
IndexRMC = 0;
for cnt_GPS = 1 : length(GPSMessage)
    if strcmp(GPSMessage{cnt_GPS}(1:length('$GNRMC')),'$GNRMC')
        IndexRMC = cnt_GPS;
        %find the index of the first and 2nd comma
        Separator = strfind(GPSMessage{cnt_GPS},',');
        % This might be improved since the message might have a consistent
        % size when fix (at least the beigining)
        strfind(GPSMessage{cnt_GPS}, ',');
        %parse and see if empty
        j = 0;
        if ~isnan(str2double(GPSMessage{cnt_GPS}(Separator(1)+1:Separator(2)-1)))
            if cnt_start > 1
                if IndexStartGPS(cnt_start) > IndexStartGPS(cnt_start-1) + 1
                    IndexStartGPS(cnt_start) = cnt_GPS;
                    cnt_start = cnt_start + 1;
                end
            else
                IndexStartGPS(cnt_start) = cnt_GPS;
                cnt_start = cnt_start + 1;
            end
        elseif cnt_start > 1
            if  cnt_stop > 1
                if IndexStopGPS(cnt_stop) > IndexStopGPS(cnt_stop - 1) + 1
                    IndexStopGPS(cnt_stop) = cnt_GPS;
                    cnt_stop = cnt_stop + 1;
                end
            else
                IndexStopGPS(cnt_stop) = cnt_GPS;
                cnt_stop = cnt_stop + 1;
            end
        end
    end
end

if isempty(find(~isnan(IndexStopGPS)))
    IndexStopGPS(1) = IndexRMC;
end
IndexStartGPS(find(isnan(IndexStartGPS))) = [];
IndexStopGPS(find(isnan(IndexStopGPS))) = [];

%delete all lines
for cnt = 1:length(GPSMessage)
    for cnt2 = 1 : length(IndexStartGPS)
        if cnt >= IndexStartGPS(cnt2) && cnt <= IndexStopGPS(cnt2)
        else
            GPSMessage{cnt} = {};
            GPSTime{cnt} = {};
        end
    end
end
GPSMessage = GPSMessage(~cellfun('isempty',GPSMessage));
GPSTime = GPSTime(~cellfun('isempty',GPSTime));
