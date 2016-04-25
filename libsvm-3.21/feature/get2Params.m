function [ accuracy,cValue,gValue,trainStr] = get2Params(trainHist,trainLabels,testHist,testLabels,iStride,jStride)
%�õ�������-c��-g
%   ������RBF�˺�����
%   ���ص�accuracyֻ�Ǿ��ȣ�cValue��gValue�ֱ��Ӧ-c��-g��ȡֵ��
%   trainStrΪѵ������
if nargin == 4
    iStride = 100;
    jStride = 0.002;
end
maxAccuracy = 0;
maxIndex = struct('i',0,'j',0);
trainStr = [];
s1 = '-t 2 -c ';
s2 = ' -g ';
s3 = ' -q';
for i=1:10
    for j = 1:150
        num1 = i*iStride;
        num1Str = num2str(num1);
        num2 = jStride*j;
        num2Str = num2str(num2);
        trainStr = [s1,num1Str,s2,num2Str,s3];  %Ҫ����ĩβ�Ŀո������ַ��������ַ�����

        model=libsvmtrain(trainLabels,trainHist(:,:),trainStr);  
        [predict,accuracy,~]=libsvmpredict(testLabels,testHist(:,:),model);
        tempAcc = maxAccuracy(1);
        maxAccuracy = max(maxAccuracy(1),accuracy(1));
        if maxAccuracy ~= tempAcc
            maxIndex.i = i;
            maxIndex.j = j;
        end      
    end
end
accuracy = maxAccuracy;
cValue = maxIndex.i*iStride;
gValue = maxIndex.j*jStride;
trainStr = [s1,num2str(cValue),s2,num2str(gValue),s3];





