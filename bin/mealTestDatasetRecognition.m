%% mealTestDatasetRecognition.m
% Author:  Jingxuan Yang
% E-mail:  yangjingxuan@stu.hit.edu.cn
% Date:    2020.07.14
% Project: HITSZ Meal Recognition
% Purpose: verify test dataset
% Note   :

%% verify test dataset
% print hints
fprintf('Verifying test dataset\n');

% draw result figure
figure;

% loop all test figures
for i = 1:size(testDataTbl, 1)

    % read and detect test figure i
    I = imread(testDataTbl.imageFilename{i});
    I = imresize(I, inputSize(1:2));
    [bboxes, scores, labels] = detect(detector, I);

    % obtain detected meal labels
    if size(bboxes, 1) == 0
        labelStr = {'nothing detected'};
        fprintf('nothing detected: %s\n', trainingDataTbl.imageFilename{i});
    else
        labelStr = cell(size(bboxes, 1), 1);
        for ii = 1:size(bboxes, 1)
            labelStr{ii} = [char(labels(ii)) num2str(scores(ii), '%0.2f')];
        end
    end
    
    % insert a label and a rectangle to show detected results
    I = insertObjectAnnotation(I, 'rectangle', bboxes, labelStr);
    
    % add price to the top left of the figure
    price = length([labelStr{:}]);
    priceStr = strcat('Price: ', num2str(price), 'RMB');
    pricePosition = [2 2];
    I = insertText(I, pricePosition, priceStr, 'BoxColor', 'red',   ...
                                               'TextColor','white', ...
                                               'FontSize', 16);
                          
    % show image
    imshow(I);
    
    % wait for user operations
    pause;

end % w.r.t. for i
