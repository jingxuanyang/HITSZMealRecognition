%% saveGroundTruth.m
% Author:  Jingxuan Yang
% E-mail:  yangjingxuan@stu.hit.edu.cn
% Date:    2020.07.13
% Project: HITSZ Meal Recognition
% Purpose: save ground truth file
% Note   :

clc;
clear;

%% load label data
labelDataLoaded = load('HITSZMealLabel');

% set file extention
extendXML = '.xml';
extendJPG = '.jpg';

% initialize filename and label
imageFilenames = {};
labelData = cell(0, size(labelDataLoaded.labelDefs, 1));

%% obtain label data
i = 1;
numImages = 242;
while i <= numImages
    
    % obtain xml file name
    stri = num2str(i, '%d');
    filenameXML = strcat(stri, extendXML);
    
    % show iteration progress
    fprintf('searching for: %s\n', filenameXML);
    
    % obtain jpg file name
    filenameJPG = strcat(stri, extendJPG);
    
    % if filename does not exist, jump out
    if ~exist(filenameXML, 'file')
        continue;
    end
    
    % obtain image path
    imageFile = fullfile(pwd, filenameJPG);
    imageFilenames = [imageFilenames; imageFile]; %# ok
    
    % obtain xml file content
    xmlFile = xmlRead(filenameXML);
    labelLine = cell(0, size(labelDataLoaded.labelDefs, 1));

    for j = 1:length(xmlFile.object)
        
        % obtain label name
        labelName = xmlFile.object(j).name;

        % seems do nothing
        for k = 1:size(labelDataLoaded.labelDefs, 1)
            if labelName == string(labelDataLoaded.labelDefs{k, 1})
                break;
            end
        end
        
        % obtain x and y limits
        xmin = xmlFile.object(j).bndbox.xmin;
        ymin = xmlFile.object(j).bndbox.ymin;
        xmax = xmlFile.object(j).bndbox.xmax;
        ymax = xmlFile.object(j).bndbox.ymax;
        
        % calculate label range: xmin, ymin, width and height
        labelLine(1, k) = {[xmin, ymin, xmax - xmin, ymax - ymin]};

    end % w.r.t. for j

    % add new label line to existing label data
    labelData = [labelData; labelLine]; %# ok
    
    % enter next iteration
    i = i + 1;
    
end % w.r.t. while i

% obtain ground truth data source
dataSource = groundTruthDataSource(imageFilenames);

% obtain label data as table format
labelDataTable = cell2table(labelData);

% set label definitions to label data table
for i = 1:size(labelDataLoaded.labelDefs, 1)
    labelDataTable.Properties.VariableNames(1, i) = table2cell(labelDataLoaded.labelDefs(i, 1));
end

%% save ground truth
% obtain ground truth of dataset
mealGroundTruth = groundTruth(dataSource, labelDataLoaded.labelDefs, labelDataTable);

% save ground truth as mat file
save('HITSZMealGroundTruth.mat', 'mealGroundTruth');
