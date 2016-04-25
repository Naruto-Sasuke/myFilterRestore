function model = getModel3(modelType,isShow)
%这个主要是调用cal_CC, 即第二种方法的均值求A，B法。

%--------------------------------暂时有12种modelType可供选择--------------------------
file_path = [];  %原图路径
file_path_f = [];%滤镜图路径
file_name = [];  %原图名字
file_name_f = [];%滤镜图名字
for i = 1:12                      
    file_path  = [file_path;{strcat('pics\train\',num2str(i),'\0')}];   % 12幅原图，在12个文件夹
    file_path_f = [file_path_f;{strcat('pics\train\',num2str(i),'\',modelType)}];  % 12幅滤镜图，在12个文件夹
    
    file_name = [file_name;{strcat(file_path{end},num2str(i),'.jpg')}];  %最后变成12x1的cell，存储了12张原图的名字
    file_name_f = [file_name_f;{strcat(file_path_f{end},num2str(i),'.jpg')}];
end
saveName = strcat(fileparts(mfilename('fullpath')),'\models\',modelType,'.mat');
trainOpts = struct('saveImgs',false,'dataName',saveName);
[A,B] = cal_CC(file_name,file_name_f,trainOpts);



psnrV = []; % 模拟原图的psnr的向量
for fIndex = 1:6  
    fprintf('第%d张\n',fIndex);
    figure;
    %----------------加载测试原图----------------------
    imgORI = im2double(imread(strcat('\pics\test\',num2str(fIndex),'\',num2str(fIndex),'.jpg')));
    if isShow
        subplot(2,2,1);
        imshow(imgORI);
        title('原图');
    end
    %---------------加载测试滤镜图-------------------
    fImgORI = im2double(imread(strcat('\pics\test\',num2str(fIndex),'\',modelType,num2str(fIndex),'.jpg')));
    if isShow
        subplot(2,2,2);
        imshow(fImgORI);
        title(strcat(modelType,'图'));
    end


%     %-----------------------测试滤镜模拟效果-----------------------------
%     [m,n,ch] = size(imgORI);
%     imgSimuOut = zeros(m,n,ch);
%  %   imgORITmp = cat(3,imgORI,ones(m,n,1));  % 让每个原像素点的第三维数为4，并且(i,j,4) = 1
%     for i = 1:m
%         for j = 1:n
%  %           imgSimuOut(i,j,:) = A*double(reshape(imgORITmp(i,j,:),4,1));
%              imgSimuOut(i,j,:) = A* reshape(imgORI(i,j,:),3,1) + B;  % A*imgORI是3x1的，可以直接加上偏置
%         end
%     end
%     psnrS = csnr(fImgORI*255,imgSimuOut*255,0,0);
%     if isShow
%         subplot(2,2,4);
%         imshow(imgSimuOut);
%         title(strcat('模拟的',modelType,'图,PSNR = ',num2str(psnrS)));
%     end


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

%-----------------把利用A测试Test文件夹中的图片的还原效果psnrV，写入model中-------------------
avgPSNR = sum(psnrV)/numel(psnrV);
tmpName = saveName(1:end-4);
newName = strcat(tmpName,num2str(roundn(avgPSNR,-2)),'.mat'); %保留2位小数
save(saveName,'psnrV','avgPSNR','-append');
movefile(saveName,newName); %将mat文件名加入avgPSNR信息。
model = load(newName);



