function W = myRCSP2(X1, X2, M, Alpha, Beta, Lambda, Gc1, Gc2, Sc1, Sc2, Sbj)

    G1 = Gc1(:, :, Sbj);
    G2 = Gc2(:, :, Sbj);
    s1 = Sc1(Sbj);
    s2 = Sc2(Sbj);

    %% Cov Matrix Calcaulation for Each Class
    % class 1
    Cov1 = 0;
    for i = 1:size(X1, 3)
        X1Tmp = X1(:, :, i)';
        % Normalization
        X1Tmp = X1Tmp - repmat(mean(X1Tmp, 2), 1, size(X1Tmp, 2));
        
        Cov1Tmp = (X1Tmp * X1Tmp') / trace(X1Tmp*X1Tmp');
        Cov1 = Cov1 + Cov1Tmp;
    end

    % step2: calculate R1
    Cov1 = Cov1 / size(X1, 3);
    
    % class2
    Cov2 = 0;
    for i = 1:size(X2, 3)
        X2Tmp = X2(:, :, i)';
        % Normalization
        X2Tmp = X2Tmp-repmat(mean(X2Tmp, 2), 1, size(X2Tmp, 2));
        Cov2Tmp = (X2Tmp * X2Tmp') / trace(X2Tmp*X2Tmp');
        Cov2 = Cov2 + Cov2Tmp;
    end
    % step2: calculate R2
    Cov2 = Cov2 / size(X2, 3);

    %% Cov Matrix Regularization
    I = eye(size(Cov2));
    Cp1 = (1-Beta)*s1*Cov1 + Beta*G1;
    Cpp1 = (1-Lambda)*Cp1+ Lambda*I;

    Cp2 = (1-Beta)*s2*Cov2 + Beta*G2;
    Cpp2 = (1-Lambda)* Cp2+ Lambda*I;

    %% step 3: generalized eigen value decomposition
    % J1 = w'*Cpp1*w/(w'*(Cpp2+alpha*I)*w

    A = (Cpp2+(Alpha*I));
    [U1, V1] = eig(Cpp1, A);
    V1 = diag(V1);
    [~, Idx1] = sort(V1, 'descend');
    U1 = U1(:, Idx1);

    % J2 = w'*Cpp2*w/(w'*(Cpp1+alpha*I)*w
    B = Cpp1+(Alpha*I);
    [U2, V2] = eig(Cpp2, B);
    V2 = diag(V2);
    [~, Idx2] = sort(V2, 'descend');
    U2 = U2(:, Idx2);

    W = [U1(:, 1:M), U2(:, 1:M) ]';

end
