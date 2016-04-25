function matrixAIndex = cal_A(imgs,imgfs,varargin)
%根据多对图像计算平均的模拟转换矩阵A
% img为原始图像(imgNum*1的cell，分别存储着imgNum张原图的完整名字),
% imgf为滤镜后的图像(imgNum*1的cell，分别存储着imgNum张滤镜图的完整名字)
% varargin为一些配置信息，包括model名称，取点个数,是否保留训练图像等。
% model包括取点个数，训练图对。
% ||A*beta - y||^2, 去掉alpha通道，A为3x4，beta为4x4，即4个点的[r;g;b;1]的竖向组合。
% y是3x4,是由滤镜后4个对应点的[r';g';b']的竖向组合。
if numel(imgs) ~=numel(imgfs)
    fprintf('原图与滤镜图数目不匹配\n');
    return;
end
opts = varargin{1};
times = 0;
if isempty(opts.times)
    times = 1000;                %默认1000次取点
else
    times = opts.times;
end
imgNum = numel(imgs);
matrixA = zeros(3,4);

for pIndex = 1:imgNum
    img = im2double(imread(imgs{pIndex}));           %某张原图
    imgf = im2double(imread(imgfs{pIndex}));         %与之对应的滤镜图
  
    [m,n,~] = size(img);
    matrixAIndex = zeros(3,4);   %某张图求出的矩阵A
    count = 0;                   %丢弃矩阵的个数
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
picParis = []; %训练图对。最终会变成 imgNum*2的cell，每个cell是存储图像的cell。每一行是一对训练图。
if opts.saveImgs 
    for i = 1:imgNum
        picParis = [picParis;{ {imread(imgs{i})},{imread(imgfs{i})} }]; %像这种图像用cell保存
    end
    data.saveImgs = true;
else
    data.saveImgs = false;
end
if ~isempty(opts.dataName)
    data.dataName = opts.dataName;
else
    t = strcat(fileparts(mfilename('fullpath')),'\models\','data.mat');
    data.dataName = t;  %默认名
end
data.matrixA =  matrixA;
data.trainImgs = picParis;
data.times = times;

save(data.dataName,'data');



