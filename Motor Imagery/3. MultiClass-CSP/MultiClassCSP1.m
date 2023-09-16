function W = MultiClassCSP1(X1, X2, X3, X4, M)
    %CSP Implementation of MultiClass Common Spatial Pattern Algorithm in
    %One Vs All Methods
    %
    % Inputs:
    %           X1 ==> Data of First Class
    %           X2 ==> Data of Second Class
    %           X3 ==> Data of Third Class
    %           X4 ==> Data of Fourth Class
    %           M  ==> Number of Channels to Get Selected

    % 1 Vs 2 3 4
    Data1 = X1;
    Data2 = cat(3, X2, X3, X4);
    W1 = CSP(Data1, Data2, M);

    % 2 Vs 1 3 4
    Data1 = X2;
    Data2 = cat(3, X1, X3, X4);
    W2 = CSP(Data1, Data2, M);

    % 3 Vs 1 2 4
    Data1 = X3;
    Data2 = cat(3, X1, X2, X4);
    W3 = CSP(Data1, Data2, M);

    % 4 Vs 1 2 3
    Data1 = X4;
    Data2 = cat(3, X1, X2, X3);
    W4 = CSP(Data1, Data2, M);

    W = cat(3, W1, W2, W3, W4);
end