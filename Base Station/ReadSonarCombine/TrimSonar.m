%1st Find the TFF with the DPT/DBT/DBS message
% BAD: $AADPT,40.24,0.00*72
% GOOD: $AADPT,1.78,0.00*4E

% BAD: $AADBT,40.24,0.00*72
% GOOD: $AADBT,1.78,0.00*4E

% BAD: $AADBS,40.24,0.00*72
% GOOD: $AADBS,1.78,0.00*4E

cnt_start = 1;
IndexStartSonar = ones(length(SonarMessage),1)*NaN;
cnt_stop = 1;
IndexStopSonar = ones(length(SonarMessage),1)*NaN;
IndexDPT = 0;
for cnt_Sonar = 1 : length(SonarMessage)
    if strcmp(SonarMessage{cnt_Sonar}(1:length('$AADPT')),'$AADPT')
        IndexDPT = cnt_Sonar;
        %find the index of the first and 2nd comma
        Separator = strfind(SonarMessage{cnt_Sonar},',');
        % This might be improved since the message might have a consistent
        % size when fix (at least the beigining)
        strfind(SonarMessage{cnt_Sonar}, ',');
        %parse and see if empty
        j = 0;
        if ~isnan(str2double(SonarMessage{cnt_Sonar}(Separator(1)+1:Separator(2)-1)))
            if str2double(SonarMessage{cnt_Sonar}(Separator(1)+1:Separator(2)-1)) < 5
                if cnt_start > 1
                    if IndexStartSonar(cnt_start) > IndexStartSonar(cnt_start-1) + 1
                        IndexStartSonar(cnt_start) = cnt_Sonar;
                        cnt_start = cnt_start + 1;
                    end
                else
                    IndexStartSonar(cnt_start) = cnt_Sonar;
                    cnt_start = cnt_start + 1;
                end
            elseif cnt_start > 1
                if  cnt_stop > 1
                    if IndexStopSonar(cnt_stop) > IndexStopSonar(cnt_stop - 1) + 1
                        IndexStopSonar(cnt_stop) = cnt_Sonar;
                        cnt_stop = cnt_stop + 1;
                    end
                else
                    IndexStopSonar(cnt_stop) = cnt_Sonar;
                    cnt_stop = cnt_stop + 1;
                end
            end
        elseif cnt_start > 1
            if  cnt_stop > 1
                if IndexStopSonar(cnt_stop) > IndexStopSonar(cnt_stop - 1) + 1
                    IndexStopSonar(cnt_stop) = cnt_Sonar;
                    cnt_stop = cnt_stop + 1;
                end
            else
                IndexStopSonar(cnt_stop) = cnt_Sonar;
                cnt_stop = cnt_stop + 1;
            end
        end
    end
end

if isempty(find(~isnan(IndexStopSonar), 1))
    IndexStopSonar(1) = IndexDPT;
end
IndexStartSonar(find(isnan(IndexStartSonar))) = [];
IndexStopSonar(find(isnan(IndexStopSonar))) = [];

%delete all lines
for cnt = 1:length(SonarMessage)
    for cnt2 = 1 : length(IndexStartSonar)
        if cnt >= IndexStartSonar(cnt2) && cnt <= IndexStopSonar(cnt2)
        else
            SonarMessage{cnt} = {};
            SonarTime{cnt} = {};
        end
    end
end
SonarMessage = SonarMessage(~cellfun('isempty',SonarMessage));
SonarTime = SonarTime(~cellfun('isempty',SonarTime));