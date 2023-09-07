function Y = HLaplacian(X, Xpos, Ypos)
    %LLaplacian function to apply High Laplacian Filter on EEG Signal
    % Inputs:
    %           X    ==> Input Data in Format M-by-N
    %                    where N is Channel Number
    %           Xpos ==> Electrode X Position
    %           Ypos ==> Electrode Y Position
    %
    % Outputs:
    %           Y ==> Filtered Data

    Y = zeros(size(X));

    Points = [Xpos(:), Ypos(:)]';

    for i = 1:numel(Xpos)
        RefPoint = [Xpos(i)
            Ypos(i)];

        % Memory PreAllocation for Distance Vector
        Dist = zeros(1, numel(Xpos));

        for j = 1: numel(Xpos)
            Dist(j) = sqrt(sum(RefPoint - Points(:, j)).^2);
        end

        % Get the 4 Nearest Neighbours
        [~, ind] = sort(Dist);
        NeighbourChannels = Points(:, ind(2: 5));

        % Calculate the Weights
        Dist = Dist(ind(6:9));
        W = (1 ./ Dist) / sum((1 ./ Dist));

        % Seperate Channels and Apply Weight
        SelectedChannels = zeros(size(X, 1), 4);
        for j = 1:4
            SelectedChannels(:, j) = X(:, ind(j)) * W(j);
        end

        Y(:, i) = X(:, i) - sum(SelectedChannels, 2);
    end
end