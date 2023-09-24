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
Channels = [1 2];

Data = Data(:, Channels, :);

%% Apply PSD with Parameters
NeighborsNum = 30;              % Number of Neighbor Samples
HarmonicNum = 2;                % Number of Harmonics

% Memory Allocation for Prediction Vector
Prediction = zeros(size(Label));

% Apply for All the Trials
for i = 1:size(Data, 3)
    % SNR of the Signal for Each Stimulation Freq
    S = zeros(size(StimFreq));

    for k = 1:numel(StimFreq)
        S(k) = PSDA(Data(:, :, i), Fs, StimFreq(k), NeighborsNum, HarmonicNum);
    end

    [~, Idx] = max(S);
    Prediction(i) = Idx;
end

%% Validaton
% Confusion Matrix Creation
ConfMat = confusionmat(Label, Prediction);

% Get the Accuracy of the Confusion Matrix
TotalAccuracy = sum(diag(ConfMat)) / sum(ConfMat(:)) *100;
Acc1 = ConfMat(1, 1) / sum(ConfMat(1, :)) * 100;
Acc2 = ConfMat(2, 2) / sum(ConfMat(2, :)) * 100;
Acc3 = ConfMat(3, 3) / sum(ConfMat(3, :)) * 100;

% Display Results
disp(['Total Accuracy: ', num2str(TotalAccuracy), ' %'])
disp(['Class 1 Accuracy: ', num2str(Acc1), ' %'])
disp(['Class 2 Accuracy: ', num2str(Acc2), ' %'])
disp(['Class 3 Accuracy: ', num2str(Acc3), ' %'])
