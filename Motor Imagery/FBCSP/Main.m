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

    %% Train / Test Data Split
    % Index Creation
    Ratio = 0.8;                                        % Test Train Ratio
    TrainDataIdx = (1:floor(size(X1, 3) * Ratio));      % Train Data Indices
    TestDataIdx  = (TrainDataIdx(end) + 1:size(X1, 3)); % Test Data Indices
    
    % Data Separation
    XTrain = cat(3, X1(:, :, TrainDataIdx), X2(:, :, TrainDataIdx));
    XTest = cat(3, X1(:, :, TestDataIdx), X2(:, :, TestDataIdx));

    YTrain = [ones(1, numel(TrainDataIdx)), ones(1, numel(TrainDataIdx))*2];
    YTest = [ones(1, numel(TestDataIdx)), ones(1, numel(TestDataIdx))*2];

end

%% References
% [1] Y. Wang, Sh. Gao, X. Gao, Common Spatial Pattern Method for Channel Selection i Motor Imagery Based Brain-Computer Interface, Proceedings of the 2005 IEEE Engineering in Medicine and Biology 27th Annual Conference, Shanghai, 2005
% [2] H. Ramoster, J. M. Gerking, and G. Pfurtscheller, "Optimal spatial filtering of single trial EEG during imagined hand movement" IEEE Trans. Rehab. Eng. 2000
% [3] X. Yu, Ph. Chum, K. Sim, "Analysis the effect of PCA for feature reduction in non-stationary EEG based motor imagery of BCI system", 2013
% [4] https://en.wikipedia.org/wiki/Common_spatial_pattern
% [5] DataSets ==> BCI-CompetitionIVa / BCI-CompetitionIV