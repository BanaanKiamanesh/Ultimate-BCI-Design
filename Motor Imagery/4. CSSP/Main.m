clc
clear
close all
format compact
format short
rng(123, 'twister')

%% Load Data and Operate
AvailableData = 'abcdefg';

for Sbj = AvailableData             % For each Subject

    %% Load Data
    FileName = ['dataset\BCICIV_calib_ds1' Sbj '_100Hz.mat'] ;
    load(FileName)

    Data = double(cnt) * 0.1;
    Fs = 100;

    % Electrode Positions and Labels
    Xpos = nfo.xpos;
    Ypos = nfo.ypos;

    %% Beta and Mu Band Rhythm Extraction
    % Filter Design
    [b, a] = butter(3, [8 30]/(Fs/2), 'bandpass');

    % Filter Application
    Data = filtfilt(b, a, Data);

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
    Data = SpatialFilter(Data, type, Points, Channels);

    %% step 4: seperate trials
    Gp = mrk.y;
    Pos = mrk.pos;
    Fs = nfo.fs;
    TrialLen = 4 * Fs;

    Data1 = [];
    Data2 = [];

    for i = 1:length(Gp)
        ind = Pos(i):Pos(i) + TrialLen-1;
        Trial = Data(ind, :);

        if Gp(i) == 1
            Data1 = cat(3, Data1, Trial);

        elseif Gp(i) == -1
            Data2 = cat(3, Data2, Trial);
        end
    end

    %% CSSP Application
    M = 1;
    Tau = 2;

    Folds = 5;
    F1 = floor(size(Data1, 3)/Folds);
    F2 = floor(size(Data2, 3)/Folds);

    TotalConfMat = 0;

    for iter = 1:Folds

        %% Test and Train Data Seperation
        % Class 1
        X1TestIdx = (iter-1) * F1+1:(iter-1) * F1+F1;
        X1TrainIdx = 1:size(Data1, 3);
        X1TrainIdx(X1TestIdx) = [];

        X1TrainData = Data1(:, :, X1TrainIdx);
        X1TestData = Data1(:, :, X1TestIdx);

        % Class 2
        X2TestIdx = (iter-1) * F2+1:(iter-1) * F2+F2;
        X2TrainIdx = 1:size(Data2, 3);
        X2TrainIdx(X2TestIdx) = [];

        X2TrainData = Data2(:, :, X2TrainIdx);
        X2TestData = Data2(:, :, X2TestIdx);

        %% CSSP Application and Feature Extraction
        W = CSSP(X1TrainData, X2TrainData, Tau, M);

        % Train Data Feature Extraction
        FeatureTrain1 = [];
        FeatureTrain2 = [];

        for Folds = 1:size(X1TrainData, 3)
            X1Tmp = X1TrainData(:, :, Folds)';
            X1Tmp = [X1Tmp(:, 1:end-Tau);X1Tmp(:, Tau+1:end)];
            X1Tmp = (W * X1Tmp)';
            FeatureTrain1 = cat(1, FeatureTrain1, var(X1Tmp));

            X2Tmp = X2TrainData(:, :, Folds)';
            X2Tmp = [X2Tmp(:, 1:end-Tau);X2Tmp(:, Tau+1:end)];
            X2Tmp = (W * X2Tmp)';
            FeatureTrain2 = cat(1, FeatureTrain2, var(X2Tmp));
        end

        % Train Data Feature Extraction
        FeatureTest1 = [];
        FeatureTest2 = [];

        for Folds = 1:size(X1TestData, 3)
            X1Tmp = X1TestData(:, :, Folds)';
            X1Tmp = [X1Tmp(:, 1:end-Tau);X1Tmp(:, Tau+1:end)];
            X1Tmp = (W * X1Tmp)';
            FeatureTest1 = cat(1, FeatureTest1, var(X1Tmp));

            X2Tmp = X2TestData(:, :, Folds)';
            X2Tmp = [X2Tmp(:, 1:end-Tau);X2Tmp(:, Tau+1:end)];
            X2Tmp = (W * X2Tmp)';
            FeatureTest2 = cat(1, FeatureTest2, var(X2Tmp));
        end

        % Train and Test Data and Label Prep
        TrainLabel = [ones(1, size(FeatureTrain1, 1)), 2 * ones(1, size(FeatureTrain2, 1))];
        TrainData  = [FeatureTrain1
            FeatureTrain2];
        TestData   = [FeatureTest1
            FeatureTest2];
        TestLabel  = [ones(1, size(FeatureTest1, 1)), 2 * ones(1, size(FeatureTest2, 1))];

        %% Train Classifier
        % Mdl = fitcsvm(TrainData, TrainLabel, 'Standardize', 1);
        Mdl = fitcknn(TrainData, TrainLabel, 'NumNeighbors', 3);

        %% Test Classifier
        Out = predict(Mdl, TestData)';

        %% Classifier Validation
        ConfMat = confusionmat(TestLabel, Out);
        TotalAccuracy(iter) = sum(diag(ConfMat)) / sum(ConfMat(:)) * 100;

        % Accuracy Check
        Acc1(iter) = ConfMat(1, 1) / sum(ConfMat(1, :)) * 100;
        Acc2(iter) = ConfMat(2, 2) / sum(ConfMat(2, :)) * 100;
        TotalConfMat = TotalConfMat + ConfMat;
    end
    % Ct
    disp(['Total Accuracy of Subject ', num2str(Sbj), ' : ', num2str(mean(TotalAccuracy)), ' %'])
    % disp(['accuracy1 of Sbj ', num2str(Sbj), ':', num2str(mean(Acc1)), '%'])
    % disp(['accuracy2 of Sbj ', num2str(Sbj), ':', num2str(mean(Acc2)), '%'])

end

%% results: m = 1, svm, car, tau = 1, 8-30HZ
% mean accuracy among all subjects:70.8571%

%% results: m = 2, svm, car, tau = 2, 8-30HZ
% mean accuracy among all subjects:74.3571%

%% results: m = 2, knn, low, tau = 2, 8-30HZ
% mean accuracy among all subjects:75.2143%

%% results: m = 1, knn, low, tau = 2, 8-30HZ
% mean accuracy among all subjects:76.4286%
