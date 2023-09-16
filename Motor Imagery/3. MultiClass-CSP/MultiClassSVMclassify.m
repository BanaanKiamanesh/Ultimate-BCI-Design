function Out = MultiClassSVMclassify(Mdl, TestData)
    %MultiClassSVMclassify Function to Predict a Data Based on a Pre-Trained MultiClass SVM Classifier
    %
    % Inputs:
    %           TestData ==> Prediction Data
    %
    % Outputs: 
    %           Out ==> SVM Classifier

    for i = 1:size(TestData, 2)
        X = TestData(:, i);
        Y = predict(Mdl.SVM1, X');

        if Y == 1
            Out(i) = 1;

        elseif Y == 2
            Y = predict(Mdl.SVM2, X');

            if Y == 1
                Out(i) = 2;

            elseif Y == 2
                Y = predict(Mdl.SVM3, X');

                if Y == 1
                    Out(i) = 3;

                elseif Y == 2
                    Y = predict(Mdl.SVM4, X');

                    if Y == 1
                        Out(i) = 4;

                    elseif Y == 2
                        Out(i) = nan;
                    end
                end
            end
        end
    end
end
