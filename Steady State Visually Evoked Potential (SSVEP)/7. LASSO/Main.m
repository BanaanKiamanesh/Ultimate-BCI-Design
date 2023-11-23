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
% Channels = [1 2 3];

% Channel Filtering
try
    Data = Data(:, Channels, :);
catch ME
end

%% Pre-Processing
% Filter Design
[b, a] = butter(3, [11, 100] / (Fs/2), 'bandpass');

for i = 1:size(Data, 3)                     % For Each Trial
    Data(:, :, i) = filtfilt(b, a, Data(:, :, i));
end

%% LASSO Algorithm Application

% Reference Signal Creation
Duration = 5;                       % Signal Duration in Seconds
t = linspace(0, 5, size(Data, 1));  % Time Vector
HarmonicNum = 2;                    % Number of Harmonics
lambda = 0.00001;                   % Sparse Regularization Parameter for Lasso

% MemAlloc for Reference Signals
RefSig = zeros(numel(t), 2*HarmonicNum*numel(StimFreq));

for i = 1:numel(StimFreq)
    for j = 1:HarmonicNum
        RefSig(:, 2*(i-1)*HarmonicNum + 2*j-1) = sin(2 * pi * j * StimFreq(i) * t);
        RefSig(:,   2*(i-1)*HarmonicNum + 2*j) = cos(2 * pi * j * StimFreq(i) * t);
    end
end

% MemAlloc for Predictions
Prediction = zeros(1, size(Data, 3));

for i = 1:size(Data, 3)
    Trial = Data(:, :, 1);

    W = zeros(size(RefSig, 2), numel(StimFreq));
    for j = 1:size(Data, 2)
        W(:, j) = lasso(RefSig, Trial(:, j), 'Lambda', lambda);
    end

    W = mean(abs(W), 2);

    Idx = linspace(0, numel(W), numel(StimFreq)+1);
    Rho = zeros(1, numel(StimFreq));
    for k = 1:numel(Rho)
        Rho(k) = sum(W(Idx(k)+1:Idx(k+1)));
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

%% Notes
% For the features the whole CCA correlation coefficients can be used.
% But that way the feature vector will be many times bigger.
% We can apply a feature selection section. That over complicates the problem
% and there will not be a huge difference in the results. So I prefer
% sticking to this principle for now.
