function preLab = predictLab(imgOri,fImgOri,testLabel)
%����GUI����ʼԤ�ⰴť"

addpath(genpath('./.'));
load('premodel.mat');
testHist = colorhist(fImgOri - imgOri);
[preLab,~,~] = libsvmpredict(double(testLabel),testHist(:,:),model);


end

