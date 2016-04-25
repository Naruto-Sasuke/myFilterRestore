function matrixAIndex = cal_A(imgs,imgfs,varargin)
%���ݶ��ͼ�����ƽ����ģ��ת������A
% imgΪԭʼͼ��(imgNum*1��cell���ֱ�洢��imgNum��ԭͼ����������),
% imgfΪ�˾����ͼ��(imgNum*1��cell���ֱ�洢��imgNum���˾�ͼ����������)
% vararginΪһЩ������Ϣ������model���ƣ�ȡ�����,�Ƿ���ѵ��ͼ��ȡ�
% model����ȡ�������ѵ��ͼ�ԡ�
% ||A*beta - y||^2, ȥ��alphaͨ����AΪ3x4��betaΪ4x4����4�����[r;g;b;1]��������ϡ�
% y��3x4,�����˾���4����Ӧ���[r';g';b']��������ϡ�
if numel(imgs) ~=numel(imgfs)
    fprintf('ԭͼ���˾�ͼ��Ŀ��ƥ��\n');
    return;
end
opts = varargin{1};
times = 0;
if isempty(opts.times)
    times = 1000;                %Ĭ��1000��ȡ��
else
    times = opts.times;
end
imgNum = numel(imgs);
matrixA = zeros(3,4);

for pIndex = 1:imgNum
    img = im2double(imread(imgs{pIndex}));           %ĳ��ԭͼ
    imgf = im2double(imread(imgfs{pIndex}));         %��֮��Ӧ���˾�ͼ
  
    [m,n,~] = size(img);
    matrixAIndex = zeros(3,4);   %ĳ��ͼ����ľ���A
    count = 0;                   %��������ĸ���
    for i = 1:times
        rgbBeta = [];
        rgby = [];
        listR = randperm(m);
        listC = randperm(n);
        r = [listR(1),listR(2),listR(3),listR(4)];
        c = [listC(1),listC(2),listC(3),listC(4)];
        for j = 1:4
            rgb = img(r(j),c(j),:);
            rgbBeta = [rgbBeta,double([reshape(rgb,3,1);1])];
            rgbf = imgf(r(j),c(j),:);
            rgby = [rgby,double([reshape(rgbf,3,1)])];
        end
     %   matrixTmp = rgby*(rgbBeta.'*rgbBeta)^-1*rgbBeta.';

        rgbBetaNi = pinv(rgbBeta);
        if (sum(rgbBetaNi>2)>=1)
            count = count+1;
            continue;
        end

        matrixTmp = rgby*rgbBetaNi;    
        matrixAIndex = matrixAIndex + matrixTmp;
    end
    disp(count);
    matrixAIndex = matrixAIndex./(times-count);
    matrixA  = matrixA + matrixAIndex;
    
end
matrixA = matrixA./imgNum;
picParis = []; %ѵ��ͼ�ԡ����ջ��� imgNum*2��cell��ÿ��cell�Ǵ洢ͼ���cell��ÿһ����һ��ѵ��ͼ��
if opts.saveImgs 
    for i = 1:imgNum
        picParis = [picParis;{ {imread(imgs{i})},{imread(imgfs{i})} }]; %������ͼ����cell����
    end
    data.saveImgs = true;
else
    data.saveImgs = false;
end
if ~isempty(opts.dataName)
    data.dataName = opts.dataName;
else
    t = strcat(fileparts(mfilename('fullpath')),'\models\','data.mat');
    data.dataName = t;  %Ĭ����
end
data.matrixA =  matrixA;
data.trainImgs = picParis;
data.times = times;

save(data.dataName,'data');



