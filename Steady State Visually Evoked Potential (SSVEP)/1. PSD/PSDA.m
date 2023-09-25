function SNR = PSDA(Sig, Fs, StimFreq, NeighborsNum, HarmonicNum)
    %PSDA Power Spectral Density Analysis for SSVEP BCI
    %
    % INPUTS:
    %           Sig  ==> M-by-N EEG Signal where N is the Number of Channels
    %           Fs ==> Sampling Freq
    %           StimFreq ==> Stimulation Freq
    %           NeighborsNum  ==> Number of Neighbors
    %           HarmonicNum ==> Number of Harmonics
    %
    % OUTPUTS:
    %           SNR: SNR of Stimualtion Frequency


    % MemAlloc for the SNR Values
    SNR = zeros(1, size(Sig, 2));

    for i = 1:size(Sig, 2)           % For Each Channel

        X = Sig(:, i);

        % Fourier Transform
        SigLen = size(X, 1);                             % Signal Length
        XFFT = fft(X, SigLen);                           % FFT of the Signal
        XFFT = XFFT(1: floor(SigLen/2) + 1);             % Remove Half of the FFT
        Pow = abs(XFFT) .^ 2;                            % Get the Power
        FreqAxis = linspace(0, Fs/2, floor(SigLen/2)+1); % Create Frequency Axis

        FRes = Fs / SigLen;                              % Frequency Resolution
        Step = FRes * (NeighborsNum / 2);                % Frequency Neighbothood

        % MemAlloc for Power of Each Harmonic
        S_k = zeros(1, HarmonicNum);

        for Harm = 1:HarmonicNum                   % For Each Harmonic

            IdxNum = find((FreqAxis >= (Harm*StimFreq) - 0.2)  & (FreqAxis <= (Harm*StimFreq) + 0.2));
            IdxDen = find((FreqAxis >= (Harm*StimFreq) - Step) & (FreqAxis <= (Harm*StimFreq) + Step));

            S_k(Harm) = 10 * log10(( NeighborsNum* max(Pow(IdxNum)) ) /  (sum(Pow(IdxDen)) - max(Pow(IdxNum))));
        end

        SNR(i) = max(S_k);
    end

    % Return Maximum SNR Value as the Result
    SNR = max(SNR);
end
