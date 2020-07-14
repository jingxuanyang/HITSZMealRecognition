%% mealRecognition.m
% Author:  Jingxuan Yang
% E-mail:  yangjingxuan@stu.hit.edu.cn
% Date:    2020.07.14
% Project: HITSZ Meal Recognition
% Purpose: train meal neual network
% Note   :

clc;
clear;

%% load data
% set traning flag
doTraining = true;

% load ground truth data
load('HITSZMealGroundTruth.mat');

% obtain meal dataset
hitMealDataset = mealGroundTruth.LabelData;
hitMealDataset(1:4, :);

% obtain path of image files
hitMealDataset.imageFilename = fullfile(mealGroundTruth.DataSource.Source);

%% set data tables
% set training data table, 70% of total dataset
rng(0);
shuffledIndices = randperm(height(hitMealDataset));
idx = floor(0.7 * length(shuffledIndices));
trainingIdx = 1:idx;
trainingDataTbl = hitMealDataset(shuffledIndices(trainingIdx), :);

% set validation data table
validationIdx = idx + 1:idx + 1 + floor(0.1 * length(shuffledIndices));
validationDataTbl = hitMealDataset(shuffledIndices(validationIdx), :);

% set test data table, 10% of total dataset
testIdx = validationIdx(end) + 1:length(shuffledIndices);
testDataTbl = hitMealDataset(shuffledIndices(testIdx), :);

%% construct data sources
% get training data source
imdsTrain = imageDatastore(trainingDataTbl{:, 'imageFilename'});
bldsTrain = boxLabelDatastore(trainingDataTbl(:, mealGroundTruth.LabelDefinitions.Name));
trainingData = combine(imdsTrain, bldsTrain);

% get validation data source
imdsValidation = imageDatastore(validationDataTbl{:, 'imageFilename'});
bldsValidation = boxLabelDatastore(validationDataTbl(:, mealGroundTruth.LabelDefinitions.Name));
validationData = combine(imdsValidation, bldsValidation);

% get test data source
imdsTest = imageDatastore(testDataTbl{:, 'imageFilename'});
bldsTest = boxLabelDatastore(testDataTbl(:, mealGroundTruth.LabelDefinitions.Name));
testData = combine(imdsTest, bldsTest);

%% train network
% draw figure
data = read(trainingData);
I = data{1};
bbox = data{2};
annotatedImage = insertShape(I, 'Rectangle', bbox);
annotatedImage = imresize(annotatedImage, 2);
figure;
imshow(annotatedImage);

% set training parameters
inputSize = [224 224 3];
numClasses = width(hitMealDataset) - 1;
trainingDataForEstimation = transform(trainingData, @(data)preprocessData(data, inputSize));
numAnchors = 7;
[anchorBoxes, meanIoU] = estimateAnchorBoxes(trainingDataForEstimation, numAnchors);
featureExtractionNetwork = resnet50;
featureLayer = 'activation_40_relu';
lgraph = yolov2Layers(inputSize, numClasses, anchorBoxes, featureExtractionNetwork, featureLayer);

% data augmentation
augmentedTrainingData = transform(trainingData, @augmentData);

% draw augmented images
augmentedData = cell(4, 1);
for k = 1:4
    data = read(augmentedTrainingData);
    augmentedData{k} = insertShape(data{1}, 'Rectangle', data{2});
    reset(augmentedTrainingData);
end
figure
montage(augmentedData, 'BorderSize', 2);
fprintf('augmentedData\n');

% preprocess training and validation data
preprocessedTrainingData = transform(augmentedTrainingData, @(data)preprocessData(data, inputSize));
preprocessedValidationData = transform(validationData, @(data)preprocessData(data, inputSize));

% draw preprocessed training data
data = read(preprocessedTrainingData);
I = data{1};
bbox = data{2};
annotatedImage = insertShape(I, 'Rectangle', bbox);
annotatedImage = imresize(annotatedImage, 2);
figure
imshow(annotatedImage);

% set training options
options = trainingOptions('sgdm',                    ...
                          'MiniBatchSize',    16,    ...
                          'InitialLearnRate', 1e-3,  ...
                          'MaxEpochs',        300,   ...
                          'CheckpointPath',  'temp', ...
                          'ValidationData',   preprocessedValidationData);

% check whether train or not
if doTraining
    % if train from last check point
    % pretrained = load('yolov2_checkpoint__2100__2020_06_26__20_12_13.mat');
    % [detector, info] = trainYOLOv2ObjectDetector(preprocessedTrainingData, pretrained.detector, options);

    % if train from the very initial point
    [detector,info] = trainYOLOv2ObjectDetector(preprocessedTrainingData, lgraph, options);
else
    % if do not train, load pretrained detector
    pretrained = load('yolov2_checkpoint__2786__2020_06_26__18_57_21.mat'); %# ok
    detector = pretrained.detector;
end

%% verify training results
% verify training dataset
% mealTrainingDatasetRecognition;

% verify test dataset
mealTestDatasetRecognition;

%% obtain test results
fprintf('Test result:\n');
preprocessedTestData = transform(testData, @(data)preprocessData(data, inputSize));
detectionResults = detect(detector, preprocessedTestData);
[ap, recall, precision] = evaluateDetectionPrecision(detectionResults, preprocessedTestData);
