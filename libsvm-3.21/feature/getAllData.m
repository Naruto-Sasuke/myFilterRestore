function [ trainHist,trainLabels,testHist,testLabels] = getAllData(feaType,totalFilters,varargin)
%得到训练的所有数据，并存储。
%   feaType是数据特征类型
%   '0'： 得到颜色直方图
%   '1':  得到LBP直方图
%   totalFilters:总共的滤镜数目
%   varargin为一个struct，field为deleteClasses，包含要删除的滤镜类型名称。
%   注意：得到的label与在目录的效果排列顺序相同（按照去掉那些删除的）。-----------------------
file_path=fullfile(fileparts(mfilename('fullpath')));
opts.type = feaType;
opts.matName = [];
opts.existData = false;
opts.trainData = [];
opts.testData = [];
opts.deleteReg = {}; %要删除的类型的正则表达式
if isstruct(varargin{1})
    numClass = numel(varargin{1}.deleteClasses);
    opts.deleteReg{end+1} = strcat('(',varargin{1}.deleteClasses{1},'_?\d*)');
    for i = 2:numClass 
        opts.deleteReg{end+1} = strcat(opts.deleteReg{end},'|(',varargin{1}.deleteClasses{i},'_?\d*)');
    end     
end



switch feaType
    case '0'
        opts.matName = 'colorHistData.mat';
        opts.existData = exist(opts.matName,'file');
        opts.trainData = @(x,y)getDataHist(x,y);
        opts.testData = @(x,y)getDataHist(x,y);
    case '1'
        opts.matName = 'lbpHistData.mat';
        opts.existData = exist(opts.matName,'file');
        opts.trainData = @(x,y)getDataLBP(x,y);
        opts.testData = @(x,y)getDataLBP(x,y);
end

%-------------------------------------------------------------------------
% 当加入新的效果时，修改下面的数字 14，加了fs，ld，rg 
%-------------------------------------------------------------------------
if ~opts.existData
    %训练的labels  
    trainLabels=[];
    remainNum = totalFilters - numel(varargin{1}.deleteClasses);   %剩余滤镜的效果数目

    for i=1:remainNum 
        trainLabels=[trainLabels i*ones(12,1)];
    end
    trainLabels=reshape(trainLabels',12*remainNum,1); %变成1...remainNum,1...remainNum,..共12组
    
    %测试的labels
    testLabels=[];
    for i=1:remainNum  
        testLabels=[testLabels i*ones(6,1)];
    end
    testLabels=reshape(testLabels',6*remainNum,1);  %变成1...remainNum,1...remainNum,..共6组
    %提取特征

    trainHist = opts.trainData(0,opts.deleteReg{end});
    testHist = opts.testData(1,opts.deleteReg{end}); 

    savePath = strcat(file_path,'\',opts.matName);
    save(savePath,'trainHist','trainLabels','testHist','testLabels');
else
    dataPath = strcat(file_path,'\',opts.matName);
    load(dataPath);
end

