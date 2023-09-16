function Mdl = MultiClassSVMtrain(X1, X2, X3, X4)
    %MultiClassSVMtrain function to Train a MultiClass SVM Classifier in
    % One-Vs-All Method
    %
    % Inputs:
    %           X1 ==> Data of First Class
    %           X2 ==> Data of Second Class
    %           X3 ==> Data of Third Class
    %           X4 ==> Data of Fourth Class
    %
    % Outputs: 
    %           Mdl ==> Trained SVM Model

    % 1 Vs 2 3 4
    Data1 = X1;
    Data2 = cat(2, X2, X3, X4);

    TrainData = [Data1, Data2];
    TrainLabel = [ones(1, size(Data1, 2)), 2*ones(1, size(Data2, 2))];
    Mdl.SVM1 = fitcsvm(TrainData', TrainLabel);

    % 2 Vs 1 3 4
    Data1 = X2;
    Data2 = cat(2, X1, X3, X4);
    TrainData = [Data1, Data2];
    TrainLabel = [ones(1, size(Data1, 2)), 2*ones(1, size(Data2, 2))];
    Mdl.SVM2 = fitcsvm(TrainData', TrainLabel);

    % 3 Vs 1 2 4
    Data1 = X3;
    Data2 = cat(2, X1, X2, X4);
    TrainData = [Data1, Data2];
    TrainLabel = [ones(1, size(Data1, 2)), 2*ones(1, size(Data2, 2))];
    Mdl.SVM3 = fitcsvm(TrainData', TrainLabel);

    % 4 Vs 1 2 3
    Data1 = X4;
    Data2 = cat(2, X1, X2, X3);
    TrainData = [Data1, Data2];
    TrainLabel = [ones(1, size(Data1, 2)), 2*ones(1, size(Data2, 2))];
    Mdl.SVM4 = fitcsvm(TrainData', TrainLabel);
end