modelType = 'dy';
isShow = true;
isOldOrNewTest = true;  % true��ʾ��oldTest��ͼ����������ͼ   ��ʱ���Ǿ���������oldTest�ĵ��ģ����ţ���������ͼ
%--------------------------------��ʱ��12��modelType�ɹ�ѡ��--------------------------

load(strcat(modelType,'.mat'));
A = data.matrix{1};
B = data.matrix{2};


psnrV = []; % ģ��ԭͼ��psnr������
for fIndex = 1:6  
    fprintf('��%d��\n',fIndex);
    figure;
    %----------------���ز���ԭͼ----------------------
    if isOldOrNewTest
        imgORI = im2double(imread(strcat('\pics\oldTest\test\',num2str(fIndex),'\',num2str(fIndex),'.jpg')));
    else
        imgORI = im2double(imread(strcat('\pics\test\',num2str(fIndex),'\',num2str(fIndex),'.jpg')));
    end
    if isShow
        subplot(2,2,1);
        imshow(imgORI);
        title('ԭͼ');
    end
    %---------------���ز����˾�ͼ-------------------
    if isOldOrNewTest
       fImgORI = im2double(imread(strcat('\pics\oldTest\test\',num2str(fIndex),'\',modelType,num2str(fIndex),'.jpg')));
    else
        fImgORI = im2double(imread(strcat('\pics\test\',num2str(fIndex),'\',modelType,num2str(fIndex),'.jpg')));
    end
    if isShow
        subplot(2,2,2);
        imshow(fImgORI);
        title(strcat(modelType,'ͼ'));
    end


    %-----------------------�����˾�ģ��Ч��-----------------------------
    [m,n,ch] = size(imgORI);
    imgSimuOut = zeros(m,n,ch);
 %   imgORITmp = cat(3,imgORI,ones(m,n,1));  % ��ÿ��ԭ���ص�ĵ���ά��Ϊ4������(i,j,4) = 1
    for i = 1:m
        for j = 1:n
 %           imgSimuOut(i,j,:) = A*double(reshape(imgORITmp(i,j,:),4,1));
             imgSimuOut(i,j,:) = A* reshape(imgORI(i,j,:),3,1) + B;  % A*imgORI��3x1�ģ�����ֱ�Ӽ���ƫ��
        end
    end
    psnrS = csnr(fImgORI*255,imgSimuOut*255,0,0);
    if isShow
        subplot(2,2,4);
        imshow(imgSimuOut);
        title(strcat('ģ���',modelType,'ͼ,PSNR = ',num2str(psnrS)));
    end


    %------------------------�����˾���ԭЧ��----------------------------
    %ģ���˾�ת��������Ч���˾�����ҲΪ3x4���������Ͻ�3x3ΪA(:,1:3)���棬��������ΪA�ĵ����е�ȡ����
    % �Ȱ�A�ó�3x3������

    [m,n,ch] = size(fImgORI);
    imgRestore = zeros(m,n,ch);
    for i = 1:m
        for j = 1:n
            %imgRestore(i,j,:) = ANi*double([reshape(fImgORI(i,j,:),3,1);1]);
            imgRestore(i,j,:) = A\(reshape(fImgORI(i,j,:),3,1)-B);
        end
       % fprintf('%d index, %d row\n',fIndex, i);
    end
    fprintf('��%dģ�����\n',fIndex);
    psnrV = [psnrV,csnr(imgORI*255,imgRestore*255,0,0)];
    if isShow
        subplot(2,2,3);
        imshow(imgRestore);     
        title(strcat('��ԭͼ,PSNR = ',num2str(psnrV(end))));
    end
end




