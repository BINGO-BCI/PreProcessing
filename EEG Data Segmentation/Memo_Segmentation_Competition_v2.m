clear all; close all
addpath(genpath("./Data")) % Add data to path
addpath(genpath("./Dependencies")) % Add depencies to path
myLogReport={};
%subID = 6;
%recordingDay = 3;
for subID = 1:20
    subID
    for recordingDay = 1:3
        clearvars -except subID recordingDay Sub myLogReport
        if subID<10
            textSubID = "./Data/BINGO_S0";
        else
            textSubID = "./Data/BINGO_S";
        end
        myData = load_xdf(strcat(textSubID, num2str(subID), "_DAY", num2str(recordingDay), ".xdf")); % Load data
        for iStream = 1:length(myData)
            if strcmp(myData{iStream}.info.type,'Markers')
                tmpMarkers= myData{iStream}.time_series;
                dataMarkers = {tmpMarkers{2,:}};
                timeMarkers = myData{iStream}.time_stamps;
            end
            if strcmp(myData{iStream}.info.type,'EEG')
                dataEEG = double(myData{iStream}.time_series);
                timeEEG = myData{iStream}.time_stamps;
                fsEEG = round(myData{iStream}.info.effective_srate);
            end
        end

        if timeEEG(end)-timeEEG(1)<timeMarkers(end)-timeMarkers(1)
            myLogReport{end+1} = (strcat('check EEG duration ',textSubID, num2str(subID), "_DAY", num2str(recordingDay), ".xdf"));
        end

        if fsEEG <299
            myLogReport{end+1} = (strcat('check EEGfs ',textSubID, num2str(subID), "_DAY", num2str(recordingDay), ".xdf"));
        end

        [b,a]=butter(3, [1 145]/(fsEEG/2));
        filteredEEG=filtfilt(b,a,dataEEG')';
        wo = 50/(300/2);
        bw = wo/35;
        [b,a] = iirnotch(wo,bw);
        filteredEEG=filtfilt(b,a,filteredEEG')';
        excludedSensors = [16,17,20,21,24];
        filteredEEG = filteredEEG(setdiff([1:24],excludedSensors),:);



        ALL_DATA.data=filteredEEG;
        ALL_DATA.srate=fsEEG;
        ALL_DATA.nbchan=size(filteredEEG,1);

        % ASR-based Cleaning
        ALLDATA_asr = clean_asr(ALL_DATA,10);
        asrCleanEEG=double(ALLDATA_asr.data);
        asrCleanEEG=asrCleanEEG';
        denoisedEEG = asrCleanEEG';
        load chanlocs_dsi24.mat

        %         windowLength = (1.0*fsEEG);
        %         N = size(asrCleanEEG,1);%windowLength*10;     % 10s of data, so 9 window positions.
        %         useAcc = 0;             % We don't have accelerometer data.
        %         denoisedEEG = [];
        %
        %         for windowPosition = 1:windowLength:N
        %             window = windowPosition:(windowPosition+windowLength)-1;
        %             if window(end)<=N
        %                 % Use FORCe...
        %                 %             tic;
        %                 [cleanSegmentEEG] = FORCe( asrCleanEEG(window,:)', fsEEG, chans, useAcc );
        %                 %             disp(['Time taken to clean 1s EEG = ' num2str(toc) 's.']);
        %                 disp(num2str(windowPosition/N));
        %                 % Put together the cleaned EEG time series.
        %                 denoisedEEG = [denoisedEEG cleanSegmentEEG];
        %             end
        %         end
        %         % EEG_clean = EEG_clean';


        %pspectrum(filteredEEG(1,:), fsEEG)
        %% Trial Segmentation
        for i=1:length(timeMarkers)
            idxStartEEG(i) = find(abs((timeEEG-timeMarkers(i)))==min(abs(timeEEG-timeMarkers(i))));
        end
        %trialStartTime = idxStartEEG(9:465);
        trialsEEG = [];
        trialsVisualEEG = [];
        labels = [];
        uniqueMarkers1 = {'Alpha','Bravo','Charlie','Delta','Echo','Foxtrot','Golf','Hotel','India','Juliett','Kilo','Lima','Mike'};
        uniqueMarkers2 = {'November', 'Oscar', 'Papa', 'Quebec','Romeo', 'Sierra', 'Tango','Uniform','Victor','Whiskey', 'X-Ray', 'Yankee', 'Zulu'};

        if recordingDay==1
            uniqueMarkers = uniqueMarkers1;
        elseif recordingDay==2
            uniqueMarkers = uniqueMarkers2;
        elseif recordingDay==3
            uniqueMarkers = cat(2, uniqueMarkers1, uniqueMarkers2);
        end

        trialsIndexStart = find(strcmp(dataMarkers, 'EXP_trials'));
        for i=trialsIndexStart+1:length(dataMarkers)
            tmp = find(strcmp(uniqueMarkers, dataMarkers{i}));
            if ~isempty(tmp)
                trialsEEG(end+1,:,:) = denoisedEEG(:,idxStartEEG(i)+0*fsEEG:idxStartEEG(i)+4*fsEEG-1);

                %trialsVisualEEG(end+1,:,:) = filteredEEG(:,idxStartEEG(i)+0*fsEEG:idxStartEEG(i)+1.5*fsEEG);
                labels{end+1}=uniqueMarkers{tmp};
            else
                dataMarkers{i};
            end
        end

        if recordingDay==1
            if length(labels) ~=455
                myLogReport{end+1} = (strcat('check number of trials ',textSubID, num2str(subID), "_DAY", num2str(recordingDay), ".xdf"));
            end
        elseif recordingDay==2
            if length(labels) ~=455
                myLogReport{end+1} = (strcat('check number of trials ',textSubID, num2str(subID), "_DAY", num2str(recordingDay), ".xdf"));
            end
        elseif recordingDay==3
            if length(labels) ~=260
                myLogReport{end+1} = (strcat('check number of trials ',textSubID, num2str(subID), "_DAY", num2str(recordingDay), ".xdf"));
            end
        end

        eyesOpenIndex = find(strcmp(dataMarkers, 'EO'));
        eyesOpenRestingEEG = denoisedEEG(:,idxStartEEG(eyesOpenIndex):idxStartEEG(eyesOpenIndex)+60*fsEEG-1);
        eyesClosedIndex = find(strcmp(dataMarkers, 'EC'));
        eyesClosedRestingEEG = denoisedEEG(:,idxStartEEG(eyesClosedIndex):idxStartEEG(eyesClosedIndex)+60*fsEEG-1);

        Sub.(strcat("S", num2str(subID))).(strcat("DAY", num2str(recordingDay))).eyesClosedRestingEEG = eyesClosedRestingEEG;
        Sub.(strcat("S", num2str(subID))).(strcat("DAY", num2str(recordingDay))).eyesOpenRestingEEG = eyesOpenRestingEEG;
        Sub.(strcat("S", num2str(subID))).(strcat("DAY", num2str(recordingDay))).trials = trialsEEG;
        Sub.(strcat("S", num2str(subID))).(strcat("DAY", num2str(recordingDay))).labels = labels;
        Sub.(strcat("S", num2str(subID))).(strcat("DAY", num2str(recordingDay))).fs = fsEEG;
        Sub.(strcat("S", num2str(subID))).(strcat("DAY", num2str(recordingDay))).time = [1:size(trialsEEG,3)]/fsEEG-2.5;
        %Sub.(strcat("S", num2str(subID))).(strcat("DAY", num2str(recordingDay))).chanlocs = chans;
        unique(labels);

    end
end

fNames = fieldnames(Sub);
Test.trials = [];
Test.labels = {};
Test.usage = {};
labelsCount = zeros(1,26);
uniqueMarkers = cat(2, uniqueMarkers1, uniqueMarkers2);
for n = 1:length(fNames)
    Data.(fNames{n}).Day1.Calibration.eyesClosedRestingEEG = Sub.(fNames{n}).DAY1.eyesClosedRestingEEG;
    Data.(fNames{n}).Day1.Calibration.eyesOpenRestingEEG = Sub.(fNames{n}).DAY1.eyesOpenRestingEEG;
    Data.(fNames{n}).Day2.Calibration.eyesClosedRestingEEG = Sub.(fNames{n}).DAY2.eyesClosedRestingEEG;
    Data.(fNames{n}).Day2.Calibration.eyesOpenRestingEEG = Sub.(fNames{n}).DAY2.eyesOpenRestingEEG;
    Data.(fNames{n}).Day1.Train.trials = Sub.(fNames{n}).DAY1.trials;
    Data.(fNames{n}).Day1.Train.labels = Sub.(fNames{n}).DAY1.labels;
    Data.(fNames{n}).Day1.Train.time = Sub.(fNames{n}).DAY1.time;
    Data.(fNames{n}).Day2.Train.trials = Sub.(fNames{n}).DAY2.trials;
    Data.(fNames{n}).Day2.Train.labels = Sub.(fNames{n}).DAY2.labels;
    Data.(fNames{n}).Day2.Train.time = Sub.(fNames{n}).DAY2.time;
    %Train.(fNames{n}).Day2 = Sub.(fNames{n}).DAY2;
    Data.Info.fs = 300;
    Data.Info.Chanlocs = chans;
    Test.trials(end+1:end+260,:,:) = Sub.(fNames{n}).DAY3.trials(:,:,[1:size(trialsEEG,3)]/fsEEG-2.5 >0);
    for i=1:260
        Test.labels{end+1} = Sub.(fNames{n}).DAY3.labels{i};
        Test.usage{end+1} = 'Private'
        tmp = find(strcmp(uniqueMarkers, Sub.(fNames{n}).DAY3.labels{i}));
        labelsCount(tmp) = labelsCount(tmp)+1;
        if mod(labelsCount(tmp),2) == 0
            Test.usage{end} = 'Public'
        end
    end
end
Test.usage = Test.usage';
Test.labels = Test.labels';


