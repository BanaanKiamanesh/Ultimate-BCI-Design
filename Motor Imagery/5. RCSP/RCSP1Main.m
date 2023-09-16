clc
clear
close all
format compact
format short
rng(123, 'twister')

%% Data Load
AvailableData = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];

for sbj = 1:numel(AvailableData)            % For Each Subject

    %% Load Data
    FileName = ['dataset\BCICIV_calib_ds1', AvailableData(sbj), '_100Hz.mat'] ;
    load(FileName)
    Data = double(cnt) * 0.1;
    Fs = 100;

    % Electrode Positions and Labels
    Xpos = nfo.xpos;
    Ypos = nfo.ypos;

    %% Extract Beta and Mu Band Rhythms
    % Filter Design
    [b, a] = butter(3, [8 30] / (Fs/2), 'bandpass');

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
        if any(strcmp(Tmp, Sys1010), 'all')
            % If Yes, Add the Index To the Indices Array
            Channels = [Channels; i];
        end
    end


    Points = [Xpos'
        Ypos'];
    type = 'car';
    Data = SpatialFilter(Data, type, Points, Channels);

    %% Trial Seperation
    Gp = mrk.y;
    Pos = mrk.pos;
    Fs = nfo.fs;
    TrialLen = 4 * Fs;

    X1 = [];
    X2 = [];

    for i = 1:length(Gp)
        Idx = Pos(i):Pos(i) + TrialLen-1;
        Trial = Data(Idx, :);

        if Gp(i) == 1
            X1 = cat(3, X1, Trial);

        elseif Gp(i) == -1
            X2 = cat(3, X2, Trial);
        end
    end

    %% RCSP Application
    M = 2;
    AlphaCandidates = [10e-10 10e-9 10e-8 10e-7 10e-6 10e-5 10e-4 10e-3 10e-2 10e-1];

    for AC = 1:numel(AlphaCandidates)
        Alpha = AlphaCandidates(AC);

        % Apply CSP
        Folds = 5;
        F1 = floor(size(X1, 3)/Folds);
        F2 = floor(size(X2, 3)/Folds);

        Ct = 0;

        for iter = 1:Folds
            %% Train and Test Data Split
            % Class 1
            X1TestIdx  = (iter-1)*F1+1:(iter-1)*F1+F1;
            X1TrainIdx = 1:size(X1, 3);
            X1TrainIdx(X1TestIdx) = [];
            X1TrainData = X1(:, :, X1TrainIdx);
            X1TestData  = X1(:, :, X1TestIdx);

            % Class 2
            X2TestIdx = (iter-1)*F2+1:(iter-1)*F2+F2;
            X2TrainIdx = 1:size(X2, 3);
            X2TrainIdx(X2TestIdx) = [];
            X2TrainData = X2(:, :, X2TrainIdx);
            X2TestData = X2(:, :, X2TestIdx);

            % Apply RCSP and Extract Features
            W = RCSP1(X1TrainData, X2TrainData, M, Alpha);

            FeatureTrain1 = [];
            FeatureTrain2 = [];
            FeatureTest1 = [];
            FeatureTest2 = [];

            % Train Data Feature Extract
            for Folds = 1:size(X1TrainData, 3)
                X1Tmp = X1TrainData(:, :, Folds)';
                X1Tmp = (W * X1Tmp)';
                FeatureTrain1 = cat(1, FeatureTrain1, var(X1Tmp));

                X2Tmp = X2TrainData(:, :, Folds)';
                X2Tmp = (W*X2Tmp)';
                FeatureTrain2 = cat(1, FeatureTrain2, var(X2Tmp));
            end

            % Test Data Feature Extract
            for Folds = 1:size(X1TestData, 3)
                X1Tmp = X1TestData(:, :, Folds)';
                X1Tmp = (W * X1Tmp)';
                FeatureTest1 = cat(1, FeatureTest1, var(X1Tmp));

                X2Tmp = X2TestData(:, :, Folds)';
                X2Tmp = (W * X2Tmp)';
                FeatureTest2 = cat(1, FeatureTest2, var(X2Tmp));
            end


            % Train and Test Data and Label Prep
            TrainLabel = [ones(1, size(FeatureTrain1, 1)), 2*ones(1, size(FeatureTrain2, 1))];
            TrainData  = [FeatureTrain1
                FeatureTrain2];
            TestData   = [FeatureTest1
                FeatureTest2];
            TestLabel  = [ones(1, size(FeatureTest1, 1)), 2*ones(1, size(FeatureTest2, 1))];

            %% Classifier Train
            Mdl = fitcsvm(TrainData, TrainLabel, 'standardize', 1);

            %% Classifier Test
            Out = predict(Mdl, TestData)';

            %% Classifier Validation
            ConfMat = confusionmat(TestLabel, Out);

            TotalAcc(iter) = sum(diag(ConfMat)) / sum(ConfMat(:)) * 100;
            Acc1(iter) = ConfMat(1, 1) / sum(ConfMat(1, :)) * 100;
            Acc2(iter) = ConfMat(2, 2) / sum(ConfMat(2, :)) * 100;

            Ct = Ct + ConfMat;
        end

        % Ct
        % disp(['Total Accuracy of Sbj ', num2str(sbj), ':', num2str(mean(TotalAcc)), '%'])
        % disp(['Accuracy1 of Sbj ', num2str(sbj), ':', num2str(mean(Acc1)), '%'])
        % disp(['Accuracy2 of Sbj ', num2str(sbj), ':', num2str(mean(Acc2)), '%'])

        Perf(AC) = mean(TotalAcc);
        % plot(Perf(1:AC), 'b', 'linewidth', 2, 'Marker', 'o', 'MarkerEdgeColor', 'r')
        % title(['Subject' AvailableData(sbj) 'Accuracy According to Alpha'])
        % drawnow
    end

    [Perf, performanceIdx] = sort(Perf, 'descend');
    disp(['Best accuracy of ' num2str(Perf(1)), ' is obtained with alpha of ' num2str(AlphaCandidates(performanceIdx(1)))])
end
