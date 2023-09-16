function DataFiltered = SpatialFilter(Data, Type, Points, ch)
    
    Data = Data(:, ch, :);
    Type = lower(Type);

    switch Type
        case 'car'
            DataFiltered = CAR(Data);
        
        case 'low'
            DataFiltered = LLaplacian(Data, Points, 1:size(Data, 2));
       
        case 'high'
            DataFiltered = HLaplacian(Data, Points, 1:size(Data, 2));
            
        otherwise
            error("Wrong Spatial Filter Type! Only, CAR, High and Low Laplacian are Available");
    end
end