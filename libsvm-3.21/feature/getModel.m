function getModel(modelType,samplesNum)
%����cal_A������model����Test�ļ��е�ͼƬ��Ч���������м�¼��model�С�
%model�洢Ϊ'\feature\models\xx.mat'��ʽ��
% modelType����Ҫģ����˾����ͣ�����dy,fg�ȵȡ�
% sampleNum�����õĲ����������
A = zeros(3,4);
sumA = zeros(3,4);

%--------------------------------��ʱ��12��modelType�ɹ�ѡ��--------------------------
file_path = [];  %ԭͼ·��
file_path_f = [];%�˾�ͼ·��
file_name = [];  %ԭͼ����
file_name_f = [];%�˾�ͼ����
for i = 1:12                      
    file_path  = [file_path;{strcat('pics\train\',num2str(i),'\0')}];   % 12��ԭͼ����12���ļ���
    file_path_f = [file_path_f;{strcat('pics\train\',num2str(i),'\',modelType)}];  % 12���˾�ͼ����12���ļ���
    
    file_name = [file_name;{strcat(file_path{end},num2str(i),'.jpg')}];  %�����12x1��cell���洢��12��ԭͼ������
    file_name_f = [file_name_f;{strcat(file_path_f{end},num2str(i),'.jpg')}];
end
saveName = strcat(fileparts(mfilename('fullpath')),'\models\',modelType,'.mat');
trainOpts = struct('times',samplesNum,'saveImgs',false,'dataName',saveName);
A = cal_A(file_name,file_name_f,trainOpts);


psnrV = []; % ģ��ԭͼ��psnr������
for fIndex = 1:6  
    figure;
    %----------------���ز���ԭͼ----------------------
    imgORI = im2double(imread(strcat('\pics\test\',num2str(fIndex),'\',num2str(fIndex),'.jpg')));
    subplot(2,2,1);
    imshow(imgORI);
    title('ԭͼ');
    %---------------���ز����˾�ͼ-------------------
    fImgORI = im2double(imread(strcat('\pics\test\',num2str(fIndex),'\',modelType,num2str(fIndex),'.jpg')));
    subplot(2,2,2);
    imshow(fImgORI);
    title(strcat(modelType,'ͼ'));


    %-----------------------�����˾�ģ��Ч��-----------------------------
    [m,n,ch] = size(imgORI);
    imgSimuOut = zeros(m,n,ch);
    imgORITmp = cat(3,imgORI,ones(m,n,1));  % ��ÿ��ԭ���ص�ĵ���ά��Ϊ4������(i,j,4) = 1
    for i = 1:m
        for j = 1:n
            imgSimuOut(i,j,:) = A*double(reshape(imgORITmp(i,j,:),4,1));
        end
    end
    psnrS = csnr(fImgORI*255,imgSimuOut*255,0,0);
    subplot(2,2,4);
    imshow(imgSimuOut);
    title(strcat('ģ���',modelType,'ͼ,PSNR = ',num2str(psnrS)));


    %------------------------�����˾���ԭЧ��----------------------------
    %ģ���˾�ת��������Ч���˾�����ҲΪ3x4���������Ͻ�3x3ΪA(:,1:3)���棬��������ΪA�ĵ����е�ȡ����
    % �Ȱ�A�ó�3x3������
    AThreeNi = inv(A(:,1:3));
    tmp = -A(:,4);
    ANi = [AThreeNi,tmp];

    [m,n,ch] = size(fImgORI);
    imgRestore = zeros(m,n,ch);
    for i = 1:m
        for j = 1:n
    %         kk = ANi*double(reshape(fimgORI(i,j,:),3,1));
            imgRestore(i,j,:) = ANi*double([reshape(fImgORI(i,j,:),3,1);1]);
        end
    end

    subplot(2,2,3);
    imshow(imgRestore);
    psnrV = [psnrV,csnr(imgORI*255,imgRestore*255,0,0)];
    title(strcat('��ԭͼ,PSNR = ',num2str(psnrV(end))));
end

%-----------------������A����Test�ļ����е�ͼƬ�Ļ�ԭЧ��psnrV��д��model��-------------------
avgPSNR = sum(psnrV)/numel(psnrV);
save(saveName,'psnrV','avgPSNR','-append');
model = load(saveName);
fprintf('ha');



