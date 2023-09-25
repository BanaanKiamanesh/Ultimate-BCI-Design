function Rho = CCA(A, B)
    %CCA Canonical Correlation Analysis
    % Inputs :
    %           A ==> First Multivariate Time Serie
    %           B ==> Second Multivariate Time Serie
    %
    % Outputs :
    %           Rho ==> CCA Correlation Coefficient

    % Get the Serie with Higher Num of Variables as the First Arg
    if size(A, 2) <= size(B, 2)
        X = A;
        Y = B;
    else
        X = B;
        Y = A;
    end

    % Covariance Matrices Calculation
    CovMat = cov([X, Y]);

    % Covariance Matrix Seperation
    p = size(X, 2);

    C_xx = CovMat(    1:p,     1:p);
    C_yy = CovMat(p+1:end, p+1:end);
    C_xy = CovMat(    1:p, p+1:end);
    C_yx = CovMat(p+1:end,     1:p);
    % C_yx = C_xy';

    % Eigen Value Decomposition
    A = inv(C_yy + eps) * C_yx * inv(C_xx + eps) * C_xy;

    [~, Lambda] = eig(A);
    Lambda = diag(real(Lambda));
    Lambda = sort(Lambda, 'descend');

    Rho = sqrt(Lambda(1:p));
end
