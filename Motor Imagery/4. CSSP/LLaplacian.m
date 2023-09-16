function DataFiltered = LLaplacian(Data, Points, Channels)
    %LLaplacian Function to Apply Low Laplacian Filter on EEG Signal
    % Inputs:
    %           Data     ==> Input Data in Format M-by-N
    %                          where N is Channel Number
    %
    %           Points   ==> Electrode XY Position
    %
    %           Channels ==> Number of EEG Channels
    %
    % Outputs:
    %           Y ==> Filtered Data

    for n = 1:length(Channels)                 % For each Channel

        % Calculate the Distance to the other Electrodes
        A = Points(:, Channels(n));

        for i = 1:size(Points, 2)
            B = Points(:, i);
            Dist(i) = sqrt(sum((A-B) .^ 2));
        end

        % Sort the Distance and get the Electrodes
        [Dist, Idx] = sort(Dist);
        NeighborCandid = Points(:, Idx(2:9));
        CandidIdx = Idx(2:9);
        CandidDist = Dist(2:9);

        % Get the Nearest Electrodes Along X-Axis
        for i = 1: size(NeighborCandid, 2)
            X1 = A(1);
            X2 = NeighborCandid(1, i);
            DistX(i) = sqrt(sum((X1-X2) .^ 2));
        end
        [DistX, IdxX] = sort(DistX);


        % Get the Nearest Electrodes Along Y-Axis
        for i = 1: size(NeighborCandid, 2)
            Y1 = A(2);
            Y2 = NeighborCandid(2, i);
            DistY(i) = sqrt(sum((Y1-Y2) .^ 2));
        end
        [DistY, IdxY] = sort(DistY);

        Idx = IdxX;

        neighbors = NeighborCandid(:, Idx);
        d = CandidDist(Idx);
        IdxX = CandidIdx(Idx);

        % Calculating the Weights
        W = (1./d) / (sum((1./d)));

        for i = 1:4
            DataNeighbors(:, i) = Data(:, IdxX(i)) * W(i);
        end

        % Apply Weighted Sum
        SUM = sum(DataNeighbors, 2);

        % Subtract from the Channel
        DataFiltered(:, n) = Data(:, Channels(n)) - SUM;
    end
end
