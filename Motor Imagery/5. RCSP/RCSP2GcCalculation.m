clc
clear
close all
format compact
format short
rng(123, 'twister')

%% Data Load
AvailableData = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];

for sbj = 1:numel(AvailableData)            % For Each Subject

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
    TrialLen = 4* Fs;

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

    [Cov1, Cov2, TrialNum] = myCOV(X1, X2);
    C1(:, :, sbj) = Cov1;
    C2(:, :, sbj) = Cov2;

    Ntr(:, sbj) = TrialNum;

    X1 = [];
    X2 = [];
end

Nt1 = sum(Ntr(1, :));
Nt2 = sum(Ntr(2, :));

for sbj = 1:size(C1, 3)
    Idx = 1:size(C1, 3);
    Idx(sbj) = [];
    gc1 = 0;
    gc2 = 0;
    for j = Idx
        Cov1 = C1(:, :, j);
        Cov2 = C2(:, :, j);
        N1 = Ntr(1, j);
        N2 = Ntr(2, j);

        gc1 = gc1+ (N1/Nt1) * Cov1;
        gc2 = gc2+ (N2/Nt2) * Cov2;
    end
    Gc1(:, :, sbj) = gc1;
    Gc2(:, :, sbj) = gc2;
    Sc1(sbj) = Ntr(1, sbj)/Nt1;
    Sc2(sbj) = Ntr(2, sbj)/Nt2;
end

save GenericM Gc1 Gc2 Sc1 Sc2
