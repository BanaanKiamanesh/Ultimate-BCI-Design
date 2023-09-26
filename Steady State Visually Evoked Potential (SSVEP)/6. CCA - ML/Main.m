clc
clear
close all
format compact
format short
rng(123, 'twister')

%% Read DataSet
load('../Data.mat')

Data = cat(3, Data1, Data2, Data3);
Label = [ones(1, size(Data1, 3)), 2*ones(1, size(Data2, 3)), 3*ones(1, size(Data3, 3))];

% Selected Channels
Channels = [1 2 3];

% Channel Filtering
Data = Data(:, Channels, :);

%% Pre-Processing
% Filter Design
[b, a] = butter(3, [11, 100] / (Fs/2), 'bandpass');

for i = 1:size(Data, 3)                     % For Each Trial
    Data(:, :, i) = filtfilt(b, a, Data(:, :, i));
end

%% Feature Extraction Using CCA Algorithm
% Reference Signal Creation
Duration = 5;                       % Signal Duration in Seconds
t = linspace(0, 5, size(Data, 1));  % Time Vector
HarmonicNum = 2;                    % Number of Harmonics

% MemAlloc for Reference Signals
RefSig = zeros(numel(t), 2*HarmonicNum, numel(StimFreq));

for i = 1:numel(StimFreq)
    for j = 1:HarmonicNum
        RefSig(:, 2*j-1, i) = sin(2*pi*t*StimFreq(i)*j);
        RefSig(:,   2*j, i) = cos(2*pi*t*StimFreq(i)*j);
    end
end

% Feature Matrix MemAlloc
Features = zeros(size(Data, 3), numel(StimFreq));

for i = 1:size(Data, 3)                     % For Each Trial

    % MemAlloc for CCA Corr. Coef.
    Rho = zeros(1, numel(StimFreq));

    for s = 1:numel(StimFreq)               % For Each Stimulation Frequency
        Y = RefSig(:, :, s);
        Tmp = CCA(Data(:, :, i), Y);
        % [~, ~, Tmp] = canoncorr(Data(:, :, i), Y);

        Rho(s) = max(Tmp);
    end

    Features(i, :) = Rho;
end

%% Plotting Extracted Features
fig = figure;
set(gcf, 'Color', 'w');

% Define colors for each cluster
colors = ['r', 'g', 'b'];

% Scatter plot for each cluster
for clusterLabel = 1:3
    Idx = Label == clusterLabel;
    scatter3(Features(Idx, 1), Features(Idx, 2), Features(Idx, 3), 50, colors(clusterLabel), 'filled');
    hold on
end

xlabel('Feature 1');
ylabel('Feature 2');
zlabel('Feature 3');
title('Scatter Plot');
legend('Class 1', 'Class 2', 'Class 3');
grid on
view(-30, 30);
hold off

%% Classification
K = 5;                      % Number of Neighbors
Folds = 5;                  % Number of Folds for the KFold Cross-Validator

% MemAlloc for Result Vals
confusionMatrix = zeros(3, 3);
classAccuracies = zeros(3, 1);

% Perform K-Fold CV
Idx = crossvalind('Kfold', size(Features, 1), Folds);

for fold = 1:Folds
    % Split the data into training and testing sets
    testIdx = (Idx == fold);
    trainIdx = ~testIdx;

    trainData = Features(trainIdx, :);
    trainLabels = Label(trainIdx);
    testData = Features(testIdx, :);
    testLabels = Label(testIdx);

    % Train the KNN classifier
    knnClassifier = fitcknn(trainData, trainLabels, 'NumNeighbors', K);

    % Predict labels on the test set
    Predictions = predict(knnClassifier, testData);

    % Compute the confusion matrix for this fold
    foldConfusionMatrix = confusionmat(testLabels, Predictions, 'order', [1, 2, 3]);
    confusionMatrix = confusionMatrix + foldConfusionMatrix;
end

% Accuracy Calculation
for class = 1:3
    classAccuracies(class) = confusionMatrix(class, class) / sum(confusionMatrix(class, :));
end
totalAccuracy = sum(diag(confusionMatrix)) / sum(sum(confusionMatrix));

% Display results
fprintf('Confusion Matrix:\n');
disp(confusionMatrix);

fprintf('\nClass Accuracies:\n');
for class = 1:3
    fprintf('     >> Class %d: %.2f%%\n', class, classAccuracies(class) * 100);
end

fprintf('\n Total Accuracy: %.2f%%\n', totalAccuracy * 100);
