clc
clear
close all
format compact
format short
rng(123, 'twister')

%% Code

% Available Data Classes
AvailableData = 'lw';

for Sbj = 1:size(AvailableData, 2)          % For Each Subject

    %% Load Data
    % Create File Name and Load Data into WorkSpace
    Filename = ['BCI-competitionIVa/data_set_IVa_a', AvailableData(Sbj), '.mat'];
    load(Filename)

    %% Extract Data Properties
    Data = double(cnt) * 0.1;       % Actual Data in Micro Volts
    ChannelNum = size(cnt, 2);      % Number of Channels
    Fs = nfo.fs;                    % Sampling Frequency
    TrialLen = 4 * Fs;              % Trial Length
    TrialStartIdx = mrk.pos;        % Trial Start Index in Data

    % Electrode Positions and Labels
    Xpos = nfo.xpos;
    Ypos = nfo.ypos;

    group = mrk.y;

    %% FilterBanking
    Step = 4;               % Filter Banking Step
    Wn = [4:Step:36
        8:Step:40];

    Folds = 5;
    for iter = 1:Folds
        X1FeatureTest = [];
        X2FeatureTest = [];
        X1FeatureTrain = [];
        X2FeatureTrain = [];

        for bn = 1:size(Wn, 2)

            %% Separate Desired Data Bands

            % Filter Design
            [b, a] = butter(3, Wn(:, bn)/(Fs/2), 'bandpass');
            % Filter Application
            BandData = filtfilt(b, a, Data);

           %% Spatial Filtering
            AvailableChannels = char(nfo.clab);
            DesiredChannels = AvailableChannels(1:4, :);
            Sys1020 = lower(['Fp1'; 'Fp2'; 'F3 '; 'F4 '; 'C3 '; 'C4 '; 'P3 '; 'P4 '; 'O1 '; 'O2 '; 'F7 '; 'F8 '; 'T3 '; 'T4 '; 'T5 '; 'T6 ']);
            Sys1010 = lower(['Fp1';'Fp2';'F7 ';'F3 ';'Fz ';'F4 ';'F8 ';'FC5';'FC1';'FC2';'FC6';'T7 ';'C3 ';'Cz ';'C4 ';'T8 ';'CP5';'CP1';'CP2';'CP6';'P7 ';'P3 ';'Pz ';'P4 ']);
            
            % Initialize an Empty Array to Store the Indices
            Channels = [];

            % Loop Through Each Row in Array1
            AvailableChannels = lower(AvailableChannels);
            for i = 1:size(AvailableChannels, 1)
                % Convert the Current Row in Array1 to a String and Remove Leading/Trailing Spaces
                Tmp = strtrim(string(AvailableChannels(i,:)));

                % Check if the Current Row in Array1 is Present in Array2
                if any(strcmp(Tmp, Sys1020), 'all')
                    % If Yes, Add the Index To the Indices Array
                    Channels = [Channels; i];
                end
            end


            Points = [Xpos'
                      Ypos'];
            type = 'car';
            BandData = SpatialFilter(BandData, type, Points, Channels);

            %% Trial Seperation
            X1 = [];
            X2 = [];

            for i = 1:length(group)
                Idx = TrialStartIdx(i):TrialStartIdx(i) + TrialLen-1;
                Trial = BandData(Idx, :);

                if group(i) == 1
                    X1 = cat(3, X1, Trial);

                elseif group(i) == 2
                    X2 = cat(3, X2, Trial);
                end
            end

            Fold1 = floor(size(X1, 3)/Folds);
            Fold2 = floor(size(X2, 3)/Folds);
            X1TestIdx = ((iter-1) * Fold1 + 1: iter * Fold1);
            X2TestIdx = ((iter-1) * Fold2 + 1: iter * Fold2);

            X1TrainIdx = 1:size(X1, 3);
            X2TrainIdx = 1:size(X2, 3);

            X1TrainIdx(X1TestIdx) = [];
            X2TrainIdx(X2TestIdx) = [];


            X1TrainData = X1(:, :, X1TrainIdx);
            X2TrainData = X2(:, :, X2TrainIdx);

            X1TestData = X1(:, :, X1TestIdx);
            X2TestData = X2(:, :, X2TestIdx);


            %% CSP Transform Creation and Application
            M = 2;
            W = CSP(X1TrainData, X2TrainData, M);

            % Apply CSP on the Trian Data
            for j = 1:size(X1TrainData, 3)
                X1Tmp = X1TrainData(:, :, j);

                Y1 = (W' * X1Tmp')';
                X1TrainTmp(:, j) = var(Y1);
            end

            for j = 1:size(X2TrainData, 3)
                X2Tmp = X2TrainData(:, :, j);

                Y2 = (W' * X2Tmp')';
                X2TrainTmp(:, j) = var(Y2);
            end

            % Apply CSP on the Test Data
            for j = 1:size(X1TestData, 3)
                X1Tmp = X1TestData(:, :, j);

                Y1 = (W' * X1Tmp')';
                X1TestTmp(:, j) = var(Y1);
            end

            for j = 1:size(X2TestData, 3)
                X2Tmp = X2TestData(:, :, j);

                Y2 = (W' * X2Tmp')';
                X2TestTmp(:, j) = var(Y2);
            end

            X1FeatureTrain = cat(1, X1FeatureTrain, X1TrainTmp);
            X2FeatureTrain = cat(1, X2FeatureTrain, X2TrainTmp);
            X1FeatureTest =  cat(1, X1FeatureTest, X1TestTmp);
            X2FeatureTest = cat(1, X2FeatureTest, X2TestTmp);

            X1TrainTmp = [];
            X2TrainTmp = [];
            X1TestTmp = [];
            X2TestTmp = [];
        end
        %% Fisher Discriminant Ratio for Feature Selection
        for k = 1:size(X1FeatureTrain, 1)
            Mean1 = mean(X1FeatureTrain(k, :));
            Mean2 = mean(X2FeatureTrain(k, :));
            Var1 = var(X1FeatureTrain(k, :));
            Var2 = var(X2FeatureTrain(k, :));

            FDR(k) = ((Mean1 - Mean2)^2) / (Var1 + Var2);
        end

        % Number of Features
        FeatureNum = 3;

        [FDR, Idx] = sort(FDR, 'descend');
        SelectionIdx = Idx(1:FeatureNum);

        X1FeatureTrain = X1FeatureTrain(SelectionIdx, :);
        X2FeatureTrain = X2FeatureTrain(SelectionIdx, :);

        X1FeatureTest = X1FeatureTest(SelectionIdx, :);
        X2FeatureTest = X2FeatureTest(SelectionIdx, :);



        TrainData  = [X1FeatureTrain, X2FeatureTrain];
        TrainLabel = [ones(1, size(X1FeatureTrain, 2)), 2 * ones(1, size(X2FeatureTrain, 2))];

        TestData  = [X1FeatureTest, X2FeatureTest];
        TestLabel = [ones(1, size(X1FeatureTest, 2)), 2 * ones(1, size(X2FeatureTest, 2))];

        %% Train SVM Classifier
        Mdl = fitcsvm(TrainData', TrainLabel);

        %% Test Classifier
        Out = predict(Mdl, TestData');
        Acc(iter) = sum(TestLabel == Out') / numel(Out) * 100;
    end

    disp(['Total Accuracy of Subject ', AvailableData(Sbj), ': ', num2str(mean(Acc)), ' %'])
    SbjAcc(Sbj) = mean(Acc);
end

disp(['Mean Accuracy of all Subject: ', num2str(mean(SbjAcc)), ' %'])