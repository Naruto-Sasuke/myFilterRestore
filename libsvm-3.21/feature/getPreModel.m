%这里将.mexw64文件的train和predict前方加了lib，以防与内置函数重名。
% 得到需要的所有数据
addpath(genpath('./.'));
% getModel('fs',10000);   
% close all;

%-------------------------对下面2行的注释----------------------------------
% trainLabels: 训练labels，为 （remain*12）*1的矩阵。存储的是1,...remainNum,
% 1...remainNum,...共12组。对应的效果与目录排序对应效果相同（注意删除的效果不进行排序）
% trainHist：类似，trainLabels可以说是对 (remain*12)张效果图进行记录。而trainHist
% 就是把每张效果图进行转换成1x256的double的Hist. 比如，假设remainNum为12，则
% trainLabels(15)就是第二张图片的第三种效果图。trainHist(15,:)就是这效果图的hist。将此图的每个灰度值的概率
% 用直方图展示。testLabels与testHist类似。

delClasses = struct('deleteClasses',{{'nh','zrlb','nx','lzp','ld'}});


[trainHist,trainLabels,testHist,testLabels] = getAllData('0',15,delClasses);

% 进行调参
[a,b,c,strParams] = get2Params(trainHist,trainLabels,testHist,testLabels);

% 测试结果
model=libsvmtrain(trainLabels,trainHist(:,:),strParams);  
save('feature/matlabGUI/preModel.mat','trainLabels','trainHist','strParams','model');



