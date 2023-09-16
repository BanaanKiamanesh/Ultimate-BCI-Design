function F = FeatureExtractor(X, W)
    %%FeatureExtractor Function to Extract Features Based on CSP Suggestion
    %
    % Inputs:
    %       X ==> Data
    %       W ==> CSP Transform Matrix
    %
    % Ouputs:
    %       F ==> Feature Vector
    %

    for i = 1:size(W, 3)
        Y = (W(:, :, i)' * X)';
        Tmp(:, i) = log10(var(Y) / sum(var(Y)));
    end

    F = Tmp(:);
end