function S = MSI(X, Y)
    %MSI Mulivariate Synchronization Index
    %
    % Inputs :
    %           A ==> First Multivariate Time Serie
    %           B ==> Second Multivariate Time Serie
    %
    % Outputs :
    %           S ==> Synchronization Index


    N = size(X, 2);                             % Input Matrix Size
    HarmonicNum = size(Y, 2)/2;                 % Number of Harmonics of the Reference Signal
    P = N+2*HarmonicNum;                        % Cov Mat Dimention

    % Covariance Matrix Calculation
    CovMat = cov([X, Y]);

    C_11 = CovMat(    1:N,     1:N);
    C_22 = CovMat(N+1:end, N+1:end);
    C_12 = CovMat(    1:N, N+1:end);
    C_21 = CovMat(N+1:end,     1:N);

    % Build Transformed Corr. Matrix (R)
    R_11 = eye(N);
    R_22 = eye(2*HarmonicNum);
    R_12 = inv(sqrtm(C_11) + eps) * C_12 * inv(sqrtm(C_22) + eps);
    R_21 = inv(sqrtm(C_22) + eps) * C_21 * inv(sqrtm(C_11) + eps);

    R = [R_11 R_12
         R_21 R_22];

    % Eigen Value Decomposition
    Lambda = eig(R);
    Lambda_p = Lambda ./ sum(Lambda);         % Eigen Value Normalization

    % Synchronization Index
    S = 1 + (sum( Lambda_p .* log(Lambda_p)) / log(P));
end
