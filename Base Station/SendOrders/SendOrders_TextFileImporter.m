%% Defining the extractor
SD_EXTRACTOR.format.ALL=[];

SD_EXTRACTOR.ColumnNumber.Y1    = 1;
SD_EXTRACTOR.format.Y1          = '%f';
SD_EXTRACTOR.ColumnNumber.Y2    = 2;
SD_EXTRACTOR.format.Y2          = '%f';
SD_EXTRACTOR.ColumnNumber.Y3    = 3;
SD_EXTRACTOR.format.Y3          = '%f';

Field_Name_List = fieldnames(SD_EXTRACTOR.ColumnNumber);

for iii = 1:length(Field_Name_List)
    eval(['SD_EXTRACTOR.format.ALL = [SD_EXTRACTOR.format.ALL SD_EXTRACTOR.format.' Field_Name_List{iii} '];']);
    SD_EXTRACTOR.format.ALL = [SD_EXTRACTOR.format.ALL '\t'];
end
SD_EXTRACTOR.format.ALL = SD_EXTRACTOR.format.ALL(1:end-2);

%%
try
    for cpt_USV = 1 : NumberOfUSVs
        [FileName,PathName] = uigetfile('*.txt','Select the SD data to be imported');
        ID_file = fopen([PathName,FileName]);
        
        fgets(ID_file);
        data_tmp = textscan(ID_file, SD_EXTRACTOR.format.ALL);
        fclose(ID_file);
        % Check fo the number of imported column
        if size(data_tmp,2) == length(fieldnames(SD_EXTRACTOR.format))-1% because of the "ALL" field
            Message(1,1,0,'File Successfully Imported', 'OK', RunID);
        else
            Message(1,1,0,[num2str(length(fieldnames(SD_EXTRACTOR.format))-1) ...
                ' column(s) expected but ' num2str(size(data_tmp,2)) ' column(s) detected'], 'KO', RunID);
            Message(1,1,0,'Problem while importing the .txt file (Corrupted?)', 'KO', RunID);
            occured_error = 1;
        end
        
        
        Message(1,1,0,'.txt file successfully imported', 'OK', RunID);
        
        %% Assigning data to the right label
        USV(cpt_USV).Latitude=data_tmp{1,1};
        USV(cpt_USV).Longitude=data_tmp{1,2};
        USV(cpt_USV).Speed=data_tmp{1,3};
        
        clear data_tmp; % free some space for large data arrays
    end
catch error
    disp(error);
    occured_error = 1;
    Message(1,1,0,'Something went wrong with the SD file', 'KO', RunID);
end

%% Making sure every field has the same length
NumberIteration = min(length(USV(1).Latitude));

for cpt_USV = 1 : NumberOfUSVs
    USV(cpt_USV).ID = ones(NumberIteration,1)*USV_ID(cpt_USV);
    USV(cpt_USV).Latitude(NumberIteration+1:end) = [];
    USV(cpt_USV).Longitude(NumberIteration+1:end) = [];
    USV(cpt_USV).Speed(NumberIteration+1:end) = [];
end
