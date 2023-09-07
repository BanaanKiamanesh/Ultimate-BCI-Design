clear
close all
clc
format short
format compact
rng(123, 'twister')

%% Code

% Available Data Classes
AvailableData = ['l', 'w'];

for i = AvailableData

    %% Load Data
    % Create File Name and Load Data into WorkSpace
    FileName = ['BCI-competitionIVa/data_set_IVa_a', i, '.mat'];
    load(FileName);

    Data = double(cnt) * 0.1;       % Actual Data in Micro Volts
    ChannelNum = size(cnt, 2);      % Number of Channels
    Fs = nfo.fs;                    % Sampling Frequency
    TrialLen = 4 * Fs;              % Trial Length
    TrialStartIdx = mrk.pos;        % Trial Start Index in Data

    % Electrode Positions and Labels
    Xpos = nfo.xpos;
    Ypos = nfo.ypos;

    Labels = nfo.clab;

    % Labels
    Y = mrk.y;
    ClassNum = numel(unique(Y));            % Number of Available Data Classes

    %% Plot EEG Electrode Skull Map
    % fig = figure('Name', [FileName, 'Electrode Map'], 'Units', 'normalized', 'OuterPosition', [0, 0, 1, 1]);
    % plot(Xpos, Ypos, '^b', 'MarkerFaceColor', 'y', 'LineWidth', 3, 'MarkerSize', 10)
    % text(Xpos + 0.02, Ypos + 0.02, Labels)
    % axis equal
    % grid minor
    % xlim([min(Xpos), max(Xpos)] * 1.3)
    % ylim([min(Ypos), max(Ypos)] * 1.3)
    % xlabel('X [cm]')
    % ylabel('Y [cm]')
    % title('Electrode Map in 10/20 System')

    %% Frequency Filtering to Extraxt Mu, Beta and Gamma
    [b, a] = butter(3, [8, 30]/(Fs/2), 'bandpass');
    Data = filtfilt(b, a, Data);

    %% Spatial Filtering
    Data = CAR(Data);                       % Common Average Filtering(CAR)
    % Data = LLaplacian(Data, Xpos, Ypos);    % Low Laplacian Filter
    % Data = HLaplacian(Data, Xpos, Ypos);    % High Laplacian Filter

    %% Data Trial Seperation
    X1 = [];
    X2 = [];

    for j = 1:numel(TrialStartIdx)
        Idx   = TrialStartIdx(j):TrialStartIdx(j) + TrialLen - 1;
        Trial = Data(Idx, :);

        if Y(j) == 1
            if isempty(X1)
                X1 = Trial;
            else
                X1 = cat(3, X1, Trial);
            end

        elseif Y(j) == 2
            if isempty(X2)
                X2 = Trial;
            else
                X2 = cat(3, X2, Trial);
            end
        end
    end

    %% Implement CSP
    % Transform Matrix Creation
    M = 1;
    W = CSP(X1, X2, M);

    % Memory PreAllocation
    Features11 = zeros(2*M, size(X1, 3));
    Features12 = zeros(2*M, size(X2, 3));
    Features21 = zeros(2*M, size(X1, 3));
    Features22 = zeros(2*M, size(X2, 3));

    % Apply Transform on First Class
    for j = 1:size(X1, 3)
        tmp = W' * X1(:, :, j)';
        Features11(:, j) = var(tmp, [], 2);
        Features21(:, j) = log10(var(tmp, [], 2) / sum(var(tmp, [], 2)));
    end

    % Apply Transform on Second Class
    for j = 1:size(X2, 3)
        tmp = W' * X2(:, :, j)';
        Features12(:, j) = var(tmp, [], 2);
        Features22(:, j) = log10(var(tmp, [], 2) / sum(var(tmp, [], 2)));
    end

    %% Plot Features
    % fig = figure('Name', [FileName, 'Features'], 'Units', 'normalized', 'OuterPosition', [0, 0, 1, 1]);
    % subplot(1, 2, 1)
    % plot(Features11(1, :), Features11(2, :), 'rs', 'LineWidth', 2, 'MarkerSize', 8)
    % hold on
    % plot(Features12(1, :), Features12(2, :), 'bo', 'LineWidth', 2, 'MarkerSize', 8)
    % grid minor
    % title('CSP Features(Var)')
    % legend('Class 1', 'Class 2')
    %
    % subplot(1, 2, 2)
    % plot(Features21(1, :), Features21(2, :), 'rs', 'LineWidth', 2, 'MarkerSize', 8)
    % hold on
    % plot(Features22(1, :), Features22(2, :), 'bo', 'LineWidth', 2, 'MarkerSize', 8)
    % grid minor
    % title('CSP Features(Log(Var))')
    % legend('Class 1', 'Class 2')

    %% Create Observation Matrix and Labels for Classification
    % X = [Features11, Features12];
    X = [Features21, Features22];
    Y = [ones(1, length(Features11)), 2*ones(1, length(Features12))];

    %% Classification Using LDA
    % Classify Using LDA with 10-Fold Cross Validation
    CVO = cvpartition(Y, 'k', 5);
    err = zeros(CVO.NumTestSets, 1);

    ConfusionMatrix = zeros(2, 2);

    for j = 1:CVO.NumTestSets
        trIdx = CVO.training(j);
        teIdx = CVO.test(j);

        LDAMdl = fitcdiscr(X(:, trIdx)', Y(trIdx), 'DiscrimType', 'linear');
        yhat = predict(LDAMdl, X(:, teIdx)');
        err(j) = sum(~strcmp(yhat, Y(teIdx)));

        ConfusionMatrix = ConfusionMatrix + confusionmat(Y(teIdx), yhat);
    end

    % Accuracy using Confusion Matrix
    Accuracy = (trace(ConfusionMatrix)) / sum(ConfusionMatrix, 'all');

    fprintf('Accuracy of Subject %c using LDA Classifier is %.3f\n', i, Accuracy);

    %% Classification Using SVM
    % Classify Using SVM with 10-Fold Cross Validation
    CVO = cvpartition(Y, 'k', 5);
    err = zeros(CVO.NumTestSets, 1);

    ConfusionMatrix = zeros(2, 2);

    for j = 1:CVO.NumTestSets
        trIdx = CVO.training(j);
        teIdx = CVO.test(j);

        SVMMdl = fitcsvm(X(:, trIdx)', Y(trIdx), 'KernelFunction', 'linear', 'Standardize', true, 'KernelScale','auto');
        yhat = predict(SVMMdl, X(:, teIdx)');
        err(j) = sum(~strcmp(yhat, Y(teIdx)));

        ConfusionMatrix = ConfusionMatrix + confusionmat(Y(teIdx), yhat);
    end

    % Accuracy using Confusion Matrix
    Accuracy = (trace(ConfusionMatrix)) / sum(ConfusionMatrix, 'all');

    fprintf('Accuracy of Subject %c using SVM Classifier is %.3f\n', i, Accuracy);

    %% Classification Using KNN
    % Classify Using KNN with 10-Fold Cross Validation
    CVO = cvpartition(Y, 'k', 5);
    err = zeros(CVO.NumTestSets, 1);

    ConfusionMatrix = zeros(2, 2);

    for j = 1:CVO.NumTestSets
        trIdx = CVO.training(j);
        teIdx = CVO.test(j);

        KNNMdl = fitcknn(X(:, trIdx)', Y(trIdx), 'NumNeighbors', 4, 'Standardize', 1, 'Distance', 'euclidean');
        yhat = predict(KNNMdl, X(:, teIdx)');
        err(j) = sum(~strcmp(yhat, Y(teIdx)));

        ConfusionMatrix = ConfusionMatrix + confusionmat(Y(teIdx), yhat);
    end

    % Accuracy using Confusion Matrix
    Accuracy = (trace(ConfusionMatrix)) / sum(ConfusionMatrix, 'all');

    fprintf('Accuracy of Subject %c using KNN Classifier is %.3f\n', i, Accuracy);
    disp("=====================================================================")

end

%% References
% [1] Y. Wang, Sh. Gao, X. Gao, Common Spatial Pattern Method for Channel Selection i Motor Imagery Based Brain-Computer Interface, Proceedings of the 2005 IEEE Engineering in Medicine and Biology 27th Annual Conference, Shanghai, 2005
% [2] H. Ramoster, J. M. Gerking, and G. Pfurtscheller, "Optimal spatial filtering of single trial EEG during imagined hand movement" IEEE Trans. Rehab. Eng. 2000
% [3] X. Yu, Ph. Chum, K. Sim, "Analysis the effect of PCA for feature reduction in non-stationary EEG based motor imagery of BCI system", 2013
% [4] https://en.wikipedia.org/wiki/Common_spatial_pattern
% DataSet ==> BCI-CompetitionIVa