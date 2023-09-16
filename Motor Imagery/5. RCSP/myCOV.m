function [Cov1, Cov2, TrialNum] = myCOV(X1, X2)
    %MYCOV function to Extract the Covariance Matrix of Datas for
    %Regularized Covariance Matrix in RCSP Algo

    % R1 Calc
    Cov1 = 0;
    for i = 1:size(X1, 3)
        X1Tmp = X1(:, :, i)';
        % Normalization
        X1Tmp = X1Tmp - repmat(mean(X1Tmp, 2), 1, size(X1Tmp, 2));
        Cov1Tmp = (X1Tmp*X1Tmp')/trace(X1Tmp*X1Tmp');
        Cov1 = Cov1+ Cov1Tmp;
    end

    Cov1 = Cov1 / size(X1, 3);

    % R2 Calc
    Cov2 = 0;
    for i = 1:size(X2, 3)
        X2Tmp = X2(:, :, i)';
        % Normalization
        X2Tmp = X2Tmp-repmat(mean(X2Tmp, 2), 1, size(X2Tmp, 2));
        Cov2Tmp = (X2Tmp*X2Tmp')/trace(X2Tmp*X2Tmp');
        Cov2 = Cov2+ Cov2Tmp;
    end

    Cov2 = Cov2 / size(X2, 3);

    TrialNum = [size(X1, 3)
                size(X2, 3)];
end