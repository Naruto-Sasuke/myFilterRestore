function [ trainHist,trainLabels,testHist,testLabels] = getAllData(feaType,totalFilters,varargin)
%�õ�ѵ�����������ݣ����洢��
%   feaType��������������
%   '0'�� �õ���ɫֱ��ͼ
%   '1':  �õ�LBPֱ��ͼ
%   totalFilters:�ܹ����˾���Ŀ
%   vararginΪһ��struct��fieldΪdeleteClasses������Ҫɾ�����˾��������ơ�
%   ע�⣺�õ���label����Ŀ¼��Ч������˳����ͬ������ȥ����Щɾ���ģ���-----------------------
file_path=fullfile(fileparts(mfilename('fullpath')));
opts.type = feaType;
opts.matName = [];
opts.existData = false;
opts.trainData = [];
opts.testData = [];
opts.deleteReg = {}; %Ҫɾ�������͵�������ʽ
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
% �������µ�Ч��ʱ���޸���������� 14������fs��ld��rg 
%-------------------------------------------------------------------------
if ~opts.existData
    %ѵ����labels  
    trainLabels=[];
    remainNum = totalFilters - numel(varargin{1}.deleteClasses);   %ʣ���˾���Ч����Ŀ

    for i=1:remainNum 
        trainLabels=[trainLabels i*ones(12,1)];
    end
    trainLabels=reshape(trainLabels',12*remainNum,1); %���1...remainNum,1...remainNum,..��12��
    
    %���Ե�labels
    testLabels=[];
    for i=1:remainNum  
        testLabels=[testLabels i*ones(6,1)];
    end
    testLabels=reshape(testLabels',6*remainNum,1);  %���1...remainNum,1...remainNum,..��6��
    %��ȡ����

    trainHist = opts.trainData(0,opts.deleteReg{end});
    testHist = opts.testData(1,opts.deleteReg{end}); 

    savePath = strcat(file_path,'\',opts.matName);
    save(savePath,'trainHist','trainLabels','testHist','testLabels');
else
    dataPath = strcat(file_path,'\',opts.matName);
    load(dataPath);
end

