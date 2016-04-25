function model = getModel3(modelType,isShow)
%�����Ҫ�ǵ���cal_CC, ���ڶ��ַ����ľ�ֵ��A��B����

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
trainOpts = struct('saveImgs',false,'dataName',saveName);
[A,B] = cal_CC(file_name,file_name_f,trainOpts);



psnrV = []; % ģ��ԭͼ��psnr������
for fIndex = 1:6  
    fprintf('��%d��\n',fIndex);
    figure;
    %----------------���ز���ԭͼ----------------------
    imgORI = im2double(imread(strcat('\pics\test\',num2str(fIndex),'\',num2str(fIndex),'.jpg')));
    if isShow
        subplot(2,2,1);
        imshow(imgORI);
        title('ԭͼ');
    end
    %---------------���ز����˾�ͼ-------------------
    fImgORI = im2double(imread(strcat('\pics\test\',num2str(fIndex),'\',modelType,num2str(fIndex),'.jpg')));
    if isShow
        subplot(2,2,2);
        imshow(fImgORI);
        title(strcat(modelType,'ͼ'));
    end


%     %-----------------------�����˾�ģ��Ч��-----------------------------
%     [m,n,ch] = size(imgORI);
%     imgSimuOut = zeros(m,n,ch);
%  %   imgORITmp = cat(3,imgORI,ones(m,n,1));  % ��ÿ��ԭ���ص�ĵ���ά��Ϊ4������(i,j,4) = 1
%     for i = 1:m
%         for j = 1:n
%  %           imgSimuOut(i,j,:) = A*double(reshape(imgORITmp(i,j,:),4,1));
%              imgSimuOut(i,j,:) = A* reshape(imgORI(i,j,:),3,1) + B;  % A*imgORI��3x1�ģ�����ֱ�Ӽ���ƫ��
%         end
%     end
%     psnrS = csnr(fImgORI*255,imgSimuOut*255,0,0);
%     if isShow
%         subplot(2,2,4);
%         imshow(imgSimuOut);
%         title(strcat('ģ���',modelType,'ͼ,PSNR = ',num2str(psnrS)));
%     end


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

%-----------------������A����Test�ļ����е�ͼƬ�Ļ�ԭЧ��psnrV��д��model��-------------------
avgPSNR = sum(psnrV)/numel(psnrV);
tmpName = saveName(1:end-4);
newName = strcat(tmpName,num2str(roundn(avgPSNR,-2)),'.mat'); %����2λС��
save(saveName,'psnrV','avgPSNR','-append');
movefile(saveName,newName); %��mat�ļ�������avgPSNR��Ϣ��
model = load(newName);



