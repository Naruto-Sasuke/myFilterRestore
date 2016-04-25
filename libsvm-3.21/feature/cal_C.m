function [A,B] = cal_C(imgs,imgfs,varargin)

if numel(imgs) ~=numel(imgfs)
    fprintf('原图与滤镜图数目不匹配\n');
    return;
end
opts = varargin{1};

imgNum = numel(imgs);
A = zeros(3,3);
B = zeros(3,1);
sumA = zeros(3,3);
sumB = zeros(3,1);

index = 1;
% for pIndex = 1:imgNum
    img = im2double(imread(imgs{1}));           %某张原图
    imgf = im2double(imread(imgfs{1}));         %与之对应的滤镜图
    [m,n,~] = size(img);
%--------------先求A矩阵-------------------------wu
%取3对点。
    while(1)
        listR = randperm(m);
        listC = randperm(n);

        testTmpf ={};  % 1x6, imgf的随机6个点
        for i = 1:6    
            testTmpf = [testTmpf,   imgf(int16(listR(i)),int16(listC(i)),:)  ];
        end
        
        detaImgf = {};   % 3x1 * 3， imgf的三对点的差值
        for i = 1:2:5    
            detaImgf = [detaImgf, reshape((testTmpf{i}-testTmpf{i+1}),3,1)];
        end
        
        testTmp = {}; % 1x6, img对应的6个点
        for i = 1:6
            testTmp = [testTmp, img(listR(i),listC(i),:)];
        end
        
        detaImg = {};  % 3x1 * 3, img对应的三对点的差值
        for i = 1:2:5
            detaImg = [detaImg, reshape((testTmp{i}-testTmp{i+1}),3,1)];
        end
        
        detaImgArr = cell2mat(detaImg);
        yOrNo1 = arrayfun(@(x)abs(x)>0.2,detaImgArr);
        numnZero1 = nnz(yOrNo1);  
        detaImgfArr = cell2mat(detaImgf);
        yOrNo2 = arrayfun(@(x)abs(x)>0.2,detaImgfArr);
        numnZero2 = nnz(yOrNo2);
        
        A = detaImgfArr*inv(detaImgArr); 
        %蓝调效果就注释下面
        isAccepted = arrayfun(@(x)x < 1.4, A);  %限定A的元素不能超过2
        acceptNum = nnz(isAccepted);
        if ( acceptNum == 9 && numnZero1 == 9 && numnZero2 == 9)
            break;
        end 
       
         
    end
    
    %再取滤镜图任意一点（不能是0或是1），再取对应的原图的点，得到B
    rRand = randi([1,m],1);
    cRand = randi([1,n],1);
    bimg = reshape(img(rRand,cRand,:),3,1);
    bimgf = reshape( imgf(rRand,cRand,:),3,1);
    bias1 = bimgf(1) - A(1)*bimg(1) - A(4)*bimg(2) - A(7)*bimg(3);
    bias2 = bimgf(2) - A(2)*bimg(1) - A(5)*bimg(2) - A(8)*bimg(3);
    bias3 = bimgf(3) - A(3)*bimg(1) - A(6)*bimg(2) - A(9)*bimg(3);
    
    %得到了B
    B = [bias1;bias2;bias3]; 
    


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
data.matrix =  [{A},{B}];
data.trainImgs = picParis;


save(data.dataName,'data');



