%���ｫ.mexw64�ļ���train��predictǰ������lib���Է������ú���������
% �õ���Ҫ����������
addpath(genpath('./.'));
% getModel('fs',10000);   
% close all;

%-------------------------������2�е�ע��----------------------------------
% trainLabels: ѵ��labels��Ϊ ��remain*12��*1�ľ��󡣴洢����1,...remainNum,
% 1...remainNum,...��12�顣��Ӧ��Ч����Ŀ¼�����ӦЧ����ͬ��ע��ɾ����Ч������������
% trainHist�����ƣ�trainLabels����˵�Ƕ� (remain*12)��Ч��ͼ���м�¼����trainHist
% ���ǰ�ÿ��Ч��ͼ����ת����1x256��double��Hist. ���磬����remainNumΪ12����
% trainLabels(15)���ǵڶ���ͼƬ�ĵ�����Ч��ͼ��trainHist(15,:)������Ч��ͼ��hist������ͼ��ÿ���Ҷ�ֵ�ĸ���
% ��ֱ��ͼչʾ��testLabels��testHist���ơ�

delClasses = struct('deleteClasses',{{'nh','zrlb','nx','lzp','ld'}});


[trainHist,trainLabels,testHist,testLabels] = getAllData('0',15,delClasses);

% ���е���
[a,b,c,strParams] = get2Params(trainHist,trainLabels,testHist,testLabels);

% ���Խ��
model=libsvmtrain(trainLabels,trainHist(:,:),strParams);  
save('feature/matlabGUI/preModel.mat','trainLabels','trainHist','strParams','model');



