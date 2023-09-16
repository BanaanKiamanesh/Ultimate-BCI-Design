function W = MultiClassCSP2(X1TrainData, X2TrainData, X3TrainData, X4TrainData, M)
    %CSP Implementation of MultiClass Common Spatial Pattern Algorithm in
    %One Vs One Met
    %
    % Inputs:
    %           X1 ==> Data of First Class
    %           X2 ==> Data of Second Class
    %           X3 ==> Data of Third Class
    %           X4 ==> Data of Fourth Class
    %           M  ==> Number of Channels to Get Selected

    % 1-Vs-2
    X1 = X1TrainData;
    X2 = X2TrainData;

    W12 = CSP(X1, X2, M);

    % 1-Vs-3
    X1 = X1TrainData;
    X2 = X3TrainData;

    W13 = CSP(X1, X2, M);

    % 1-Vs-4
    X1 = X1TrainData;
    X2 = X4TrainData;

    W14 = CSP(X1, X2, M);

    % 2-Vs-3
    X1 = X2TrainData;
    X2 = X3TrainData;

    W23 = CSP(X1, X2, M);

    % 2-Vs-4
    X1 = X2TrainData;
    X2 = X4TrainData;
    W24 = CSP(X1, X2, M);

    % 3-Vs-4
    X1 = X3TrainData;
    X2 = X4TrainData;

    W34 = CSP(X1, X2, M);

    W = cat(3, W12, W13, W14, W23, W24, W34);
end
