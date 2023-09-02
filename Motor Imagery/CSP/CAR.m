function Y = CAR(X)
    %CAR function to apply Common Averge Reference Filter on EEG Signal
    % Inputs:
    %           X ==> Input Data in Format M-by-N
    %                 where N is Channel Number
    % Outputs:
    %           Y ==> Filtered Data

    Y = X - mean(X, 2);
end