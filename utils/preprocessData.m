function data = preprocessData(data, targetSize)
    % Resize image and bounding boxes to the targetSize.
    scale = targetSize(1:2) ./ size(data{1}, [1 2]);
    data{1} = imresize(data{1}, targetSize(1:2));

    boxEstimate = round(data{2});
    % fprintf('preprocessData\n');
    % pause;
    boxEstimate(:, 1) = max(boxEstimate(:, 1), 1);
    boxEstimate(:, 2) = max(boxEstimate(:, 2), 1);

    data{2} = bboxresize(data{2}, scale);
end