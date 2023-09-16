function W = RCSP1(X1, X2, M, Alpha)
    %RCSP Implementation of Regularized Common Spatial Pattern Algorithm
    %for a Double BCI System using Objective Function Regularization
    %
    % Inputs:
    %           X1 ==> Data of First Class
    %           X2 ==> Data of Second Class
    %           M ==> Number of Channels to Get Selected
    %           Alpha ==> Regularization Coefficient

    %% Rb_h Calculation
    Rb_h = 0;
    for i = 1:size(X1, 3)
        Data = X1(:, :, i)';

        % Normalize Data
        for j = 1:size(Data, 1)
            Data(j, :) = Data(j, :) - mean(Data(j, :));
        end

        % Add all
        Rb_h = Rb_h + (Data*Data')/trace(Data*Data');
    end

    %% Rb_f Calculation
    Rb_f = 0;
    for i = 1:size(X2, 3)
        Data = X2(:, :, i)';

        % Normalize Data
        for j = 1:size(Data, 1)
            Data(j, :) = Data(j, :) - mean(Data(j, :));
        end

        % Add all
        Rb_f = Rb_f + (Data*Data')/trace(Data*Data');
    end

    %% Caluculate Mean Rb_h and Rb_f
    Rb_h = Rb_h / size(X1, 3);
    Rb_f = Rb_f / size(X2, 3);

    %% Generalized Eigen Value Decomposition
    A = Rb_f + Alpha*eye(size(Rb_f));
    [U1, V1] = eig(Rb_h, A);
    [~, Idx] = sort(diag(V1), 'descend');
    U1 = U1(:, Idx);

    B = Rb_h + Alpha*eye(size(Rb_h));
    [U2, V2] = eig(Rb_f, B);
    [~, Idx] = sort(diag(V2), 'descend');
    U2 = U2(:, Idx);

    W = [U1(:, 1:M), U2(:, 1:M)]';
end