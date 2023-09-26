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

%% CCA Algorithm Application

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

% Memory Allocation for Prediction Vector
Prediction = zeros(size(Label));

for i = 1:size(Data, 3)                     % For Each Trial

    % MemAlloc for CCA Corr. Coef.
    Rho = zeros(1, numel(StimFreq));

    for s = 1:numel(StimFreq)               % For Each Stimulation Frequency
        Y = RefSig(:, :, s);
        Rho(s) = max(CCA(Data(:, :, i), Y));

        % [~, ~, Tmp] = canoncorr(Data(:, :, i), Y);
        % Rho(s) = max(Tmp);
    end

    [~, Idx] = max(Rho);
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
