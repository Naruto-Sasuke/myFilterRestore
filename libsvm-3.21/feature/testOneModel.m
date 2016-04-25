modelType = 'dy';
isShow = true;
isOldOrNewTest = true;  % true表示用oldTest的图，否则用新图   暂时还是决定淡雅用oldTest的第四，五张，其他用新图
%--------------------------------暂时有12种modelType可供选择--------------------------

load(strcat(modelType,'.mat'));
A = data.matrix{1};
B = data.matrix{2};


psnrV = []; % 模拟原图的psnr的向量
for fIndex = 1:6  
    fprintf('第%d张\n',fIndex);
    figure;
    %----------------加载测试原图----------------------
    if isOldOrNewTest
        imgORI = im2double(imread(strcat('\pics\oldTest\test\',num2str(fIndex),'\',num2str(fIndex),'.jpg')));
    else
        imgORI = im2double(imread(strcat('\pics\test\',num2str(fIndex),'\',num2str(fIndex),'.jpg')));
    end
    if isShow
        subplot(2,2,1);
        imshow(imgORI);
        title('原图');
    end
    %---------------加载测试滤镜图-------------------
    if isOldOrNewTest
       fImgORI = im2double(imread(strcat('\pics\oldTest\test\',num2str(fIndex),'\',modelType,num2str(fIndex),'.jpg')));
    else
        fImgORI = im2double(imread(strcat('\pics\test\',num2str(fIndex),'\',modelType,num2str(fIndex),'.jpg')));
    end
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
    fprintf('第%d模拟完成\n',fIndex);
    psnrV = [psnrV,csnr(imgORI*255,imgRestore*255,0,0)];
    if isShow
        subplot(2,2,3);
        imshow(imgRestore);     
        title(strcat('还原图,PSNR = ',num2str(psnrV(end))));
    end
end




