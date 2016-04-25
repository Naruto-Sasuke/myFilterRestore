function preLab = predictLab(imgOri,fImgOri,testLabel)
%用于GUI“开始预测按钮"

addpath(genpath('./.'));
load('premodel.mat');
testHist = colorhist(fImgOri - imgOri);
[preLab,~,~] = libsvmpredict(double(testLabel),testHist(:,:),model);


end

