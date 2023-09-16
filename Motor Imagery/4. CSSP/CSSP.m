function W = CSSP(X1, X2, Tau, M)
    %CSSP Implementation of Common Spatial Pattern Algorithm for a Double BCI System
    %
    % Inputs:
    %           X1  ==> Data of First Class
    %           X2  ==> Data of Second Class
    %           M   ==> Number of Channels to Get Selected
    %           Tau ==> CSSP Shifting Parameter
    %
    % Inputs:
    %           W ==> CSSP Transform

    %% Rb_h Calculation
    Rb_h = 0;
    for i = 1:size(X1, 3)
        Data = X1(:, :, i)';
        Data = [Data(:, 1:end-Tau); Data(:, Tau+1:end)];

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
        Data = [Data(:, 1:end-Tau); Data(:, Tau+1:end)];


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
    [U, V] = eig(Rb_h, Rb_f);
    [~, Idx] = sort(diag(V), 'descend');
    U = U(:, Idx);

    W = [U(:, 1:M), U(:, end-M+1:end)]';
end