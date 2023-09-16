clc
clear
close all
format compact
format short
rng(123, 'twister')

%% Read Data

AvailableData = '12456789';

for Sbj = AvailableData
    FileName = ['dataset\A0' Sbj 'T.gdf'];
    [Signal, h] = sload(FileName);
    Fs = 250;

    %% Missing Value Removal
    indx = find(isnan(Signal));
    Signal(indx) = 0;

    %% Band-Pass Filtering to Extract Mu and Beta Rhythms
    % Filter Design
    order = 3;
    fl = 8;
    fh = 30;
    wn = [fl fh] / (Fs/2);
    type = 'bandpass';
    [b, a] = butter(order, wn, type);

    % Filter Application
    Signal = filtfilt(b, a, Signal(:, 1:22));

    %% Separate Data Trials
    Gp = h.EVENT.TYP;
    Pos = h.EVENT.POS;
    TrialLen = h.EVENT.DUR;

    % Empty Data Arrays
    X1 = [];
    X2 = [];
    X3 = [];
    X4 = [];

    for i = 1:length(Gp)

        Idx = Pos(i): Pos(i) + TrialLen(i)-1;
        Trial = Signal(Idx, :);

        if Gp(i) == 769
            X1 = cat(3, X1, Trial);

        elseif Gp(i) == 770
            X2 = cat(3, X2, Trial);

        elseif Gp(i) == 771
            X3 = cat(3, X3, Trial);

        elseif Gp(i) == 772
            X4 = cat(3, X4, Trial);
        end
    end

    %% Apply 6 Folds Cross Validation
    Folds = 6;
    F1 = floor(size(X1, 3) / Folds);
    F2 = floor(size(X2, 3) / Folds);
    F3 = floor(size(X3, 3) / Folds);
    F4 = floor(size(X4, 3) / Folds);

    C = 0;
    for iter = 1:Folds

        % Create Test and Train Data Separation Indices
        X1TestIdx = (iter-1)*F1+1 : iter*F1;
        X2TestIdx = (iter-1)*F2+1 : iter*F2;
        X3TestIdx = (iter-1)*F3+1 : iter*F3;
        X4TestIdx = (iter-1)*F4+1 : iter*F4;

        X1TrainIdx = 1:size(X1, 3);
        X2TrainIdx = 1:size(X2, 3);
        X3TrainIdx = 1:size(X3, 3);
        X4TrainIdx = 1:size(X4, 3);

        X1TrainIdx(X1TestIdx) = [];
        X2TrainIdx(X2TestIdx) = [];
        X3TrainIdx(X3TestIdx) = [];
        X4TrainIdx(X4TestIdx) = [];

        % Seperate Train and Test Data
        X1Train = X1(:, :, X1TrainIdx);
        X2Train = X2(:, :, X2TrainIdx);
        X3Train = X3(:, :, X3TrainIdx);
        X4Train = X4(:, :, X4TrainIdx);

        X1Test = X1(:, :, X1TestIdx);
        X2Test = X2(:, :, X2TestIdx);
        X3Test = X3(:, :, X3TestIdx);
        X4Test = X4(:, :, X4TestIdx);

        %% Apply CSP
        % Create CSP Transform Matrix
        M = 4;
        W = MultiClassCSP2(X1Train, X2Train, X3Train, X4Train, M);

        % Creater Empty Feature Array
        TrainFeature1 = [];
        TrainFeature2 = [];
        TrainFeature3 = [];
        TrainFeature4 = [];
        TestFeature1 = [];
        TestFeature2 = [];
        TestFeature3 = [];
        TestFeature4 = [];

        % Apply CSP on Train Data
        for i = 1:size(X1Train, 3)
            X1Tmp = X1Train(:, :, i)';
            TrainFeature1 = cat(2, TrainFeature1, FeatureExtractor(X1Tmp, W));

            X2Tmp = X2Train(:, :, i)';
            TrainFeature2 = cat(2, TrainFeature2, FeatureExtractor(X2Tmp, W));

            X3Tmp = X3Train(:, :, i)';
            TrainFeature3 = cat(2, TrainFeature3, FeatureExtractor(X3Tmp, W));

            X4Tmp = X4Train(:, :, i)';
            TrainFeature4 = cat(2, TrainFeature4, FeatureExtractor(X4Tmp, W));
        end

        % Apply CSP on Test Data
        for i = 1:size(X1Test, 3)
            X1Tmp = X1Test(:, :, i)';
            TestFeature1 = cat(2, TestFeature1, FeatureExtractor(X1Tmp, W));

            X2Tmp = X2Test(:, :, i)';
            TestFeature2 = cat(2, TestFeature2, FeatureExtractor(X2Tmp, W));

            X3Tmp = X3Test(:, :, i)';
            TestFeature3 = cat(2, TestFeature3, FeatureExtractor(X3Tmp, W));

            X4Tmp = X4Test(:, :, i)';
            TestFeature4 = cat(2, TestFeature4, FeatureExtractor(X4Tmp, W));
        end


        % Create Final Test and Train Data with Labels
        TestData = [TestFeature1, TestFeature2, TestFeature3, TestFeature4];
        TestLabel = [ones(1, size(TestFeature1, 2)), ...
                     2*ones(1, size(TestFeature2, 2)), ...
                     3*ones(1, size(TestFeature3, 2)), ...
                     4*ones(1, size(TestFeature4, 2))];

        %% Train MultiClass SVM Classifier
        Mdl = MultiClassSVMtrain(TrainFeature1, TrainFeature2, TrainFeature3, TrainFeature4);

        %% Test Classifier Model
        Out = MultiClassSVMclassify(Mdl, TestData);
        C = C + confusionmat(TestLabel, Out);
    end

    %% Accuracy Check

    % Print Confusion Matrix
    disp('Confusion Matrix : ')
    disp(C)

    % Print Inner Class Accuracy
    accuracy = sum(diag(C)) / sum(C(:)) * 100;
    accuracy1 = C(1, 1) / sum(C(1, :)) * 100;
    accuracy2 = C(2, 2) / sum(C(2, :)) * 100;
    accuracy3 = C(3, 3) / sum(C(3, :)) * 100;
    accuracy4 = C(4, 4) / sum(C(4, :)) * 100;

    disp(['total Accuracy: ', num2str(accuracy), ' %'])
    disp([' Accuracy1: ', num2str(accuracy1), ' %'])
    disp([' Accuracy2: ', num2str(accuracy2), ' %'])
    disp([' Accuracy3: ', num2str(accuracy3), ' %'])
    disp([' Accuracy4: ', num2str(accuracy4), ' %'])
end
