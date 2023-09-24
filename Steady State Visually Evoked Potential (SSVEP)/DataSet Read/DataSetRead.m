clear
close all
clc
format compact
format short
rng(123, 'twister')

%% Data Set Read

% Get the List of Files Available
List = ls('../DataSet/Subject*');

% Memory Allocation
Data1 = [];             % Store Data for First  Stimulation Freq
Data2 = [];             % Store Data for Second Stimulation Freq
Data3 = [];             % Store Data for Third  Stimulation Freq

% Iterate Over the List and Read the Files
for i = 1:size(List, 1)
    % Create Full File Name
    FileName = ['../DataSet/' List(i, :)];

    % Read the File
    [s, h] = sload(FileName);

    % Property Extraction
    Label = h.EVENT.TYP;            % Event Type
    Pos = h.EVENT.POS;              % Event Start Index
    Fs = h.EVENT.SampleRate;        % Sampling Frequency
    TrialDuration = 5;              % Trial Duration in Seconds
    TrialLen = TrialDuration*Fs;    % Trial Length in Samples
    TrialNum = numel(Pos);          % Number of Trials
    Electrodes = h.Label;           % Available Electrode Labels

    StimFreq = [13, 21, 17];        % Stimulation Frequency

    % EEG Trial Seperation
    % 33025 Label Indicates 13 Hz Stimulation
    % 33026 Label Indicates 21 Hz Stimulation
    % 33027 Label Indicates 17 Hz Stimulation

    for j = 1:TrialNum
        Idx = Pos(j):Pos(j) + TrialLen - 1;

        if Label(j) == 33025              % 13 Hz
            Trial = s(Idx, :);
            Data1 = cat(3, Data1, Trial);

        elseif Label(j) == 33026          % 21 Hz
            Trial = s(Idx, :);
            Data2 = cat(3, Data2, Trial);

        elseif Label(j) == 33027          % 17 Hz
            Trial = s(Idx, :);
            Data3 = cat(3, Data3, Trial);
        end
    end
end

disp('Trials Seperated!')

%% Notch Filtering

% for i = 1:size(Data1, 3)
%     Data1(:, :, i) = bandstop(Data1(:, :, i), [49.6, 50.4], Fs);
%     Data2(:, :, i) = bandstop(Data2(:, :, i), [49.6, 50.4], Fs);
%     Data3(:, :, i) = bandstop(Data3(:, :, i), [49.6, 50.4], Fs);
% end

% Filter Design
[b, a] = butter(3, [49.6 50.4]/(Fs/2), 'stop');

% Filter Application
for i = 1:size(Data1, 3)
    Data1(:, :, i) = filtfilt(b, a, Data1(:, :, i));
    Data2(:, :, i) = filtfilt(b, a, Data2(:, :, i));
    Data3(:, :, i) = filtfilt(b, a, Data3(:, :, i));
end

disp('50 Hz Notch Filtered Applied for Power Noise Removal!')

%% Common Average Reference Source Localization Filtering
for i = 1:size(Data1, 3)
    Data1(:, :, i) = Data1(:, :, i) - mean(Data1(:, :, i), 2);
    Data2(:, :, i) = Data2(:, :, i) - mean(Data2(:, :, i), 2);
    Data3(:, :, i) = Data3(:, :, i) - mean(Data3(:, :, i), 2);
end

disp('CAR Filter Applied!')

%% Save Data
save ../Data Data1 Data2 Data3 StimFreq Electrodes TrialDuration Fs

disp('Data Saved!')
clear