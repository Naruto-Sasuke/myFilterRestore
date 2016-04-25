% 用一张图片测试一个model
% 主要是测试lena图
modelType = 'dy';
isShow = true;


load(strcat(modelType,'.mat'));
A = data.matrix{1};
B = data.matrix{2};


tImage = 'C:\Users\Owenr\Desktop\lena\lena.jpg';
tfImage = 'C:\Users\Owenr\Desktop\lena\lena-dy.jpg';

figure;
%----------------加载测试原图----------------------
imgORI = im2double(imread(tImage));
if isShow
    subplot(2,2,1);
    imshow(imgORI);
    title('原图');
end
%---------------加载测试滤镜图-------------------
fImgORI = im2double(imread(tfImage));
if isShow
    subplot(2,2,2);
    imshow(fImgORI);
    title(strcat(modelType,'图'));
end


%-----------------------测试滤镜模拟效果-----------------------------
[m,n,ch] = size(imgORI);
imgSimuOut = zeros(m,n,ch);
%   imgORITmp = cat(3,imgORI,ones(m,n,1));  % 让每个原像素点的第三维数为4，并且(i,j,4) = 1
for i = 1:m
    for j = 1:n
%           imgSimuOut(i,j,:) = A*double(reshape(imgORITmp(i,j,:),4,1));
         imgSimuOut(i,j,:) = A* reshape(imgORI(i,j,:),3,1) + B;  % A*imgORI是3x1的，可以直接加上偏置
    end
end
psnrS = csnr(fImgORI*255,imgSimuOut*255,0,0);
if isShow
    subplot(2,2,4);
    imshow(imgSimuOut);
    title(strcat('模拟的',modelType,'图,PSNR = ',num2str(psnrS)));
end


%------------------------测试滤镜还原效果----------------------------
%模拟滤镜转换，将反效果滤镜矩阵也为3x4。其中左上角3x3为A(:,1:3)的逆，而第四列为A的第四列的取反。
% 先把A拿出3x3，求逆

[m,n,ch] = size(fImgORI);
imgRestore = zeros(m,n,ch);
for i = 1:m
    for j = 1:n
        %imgRestore(i,j,:) = ANi*double([reshape(fImgORI(i,j,:),3,1);1]);
        imgRestore(i,j,:) = A\(reshape(fImgORI(i,j,:),3,1)-B);
    end
   % fprintf('%d index, %d row\n',fIndex, i);
end

psnrV = [psnrV,csnr(imgORI*255,imgRestore*255,0,0)];
if isShow
    subplot(2,2,3);
    imshow(imgRestore);     
    title(strcat('还原图,PSNR = ',num2str(psnrV(end))));
end





