function matGUICNN(filterType, fIndex)
%���ڣ�GUIģ���ݶ���ԭ
% filterType: 'rh',...
% fIndex ,�����rh�Ļ�����Ϊ1���Դ�����
% 



addpath applications/deep_edge_aware_filters/
addpath applications/deep_edge_aware_filters/utility/
addpath applications/deep_edge_aware_filters/models/
addpath applications/deep_edge_aware_filters/images/
addpath utils/
addpath cuda/
addpath mem/
addpath layers/
addpath layers_adapters/
addpath pipeline/

global config;
% load the image you like
I = [];  %�˾�ͼ
Ori = im2double(imread('vcnn/applications/deep_edge_aware_filters/images/lena.jpg')); %ԭͼ
model_path = [];
%������Ч���Ļ�ԭ�⣬����Ч���Ļ�ԭ��Ҫ�����񻯺�������
if strcmp(filterType,'rh')
    I = im2double(imread('vcnn/applications/deep_edge_aware_filters/images/lena-rh.jpg'));
    model_path = 'vcnn/applications/deep_edge_aware_filters/models/rh.mat';
%    beta = 2.388608e+00 / 2;  PSNR = 28
%    beta = ...........+01/2;  PSNR = 25
%    beta = 2.388608e+02 / 2;  PSNR = 24  Խ��Խģ���ˡ���
     beta = 1.388608e+00 / 2;
elseif strcmp(filterType,'zuanqiang')
    I = im2double(imread('vcnn/applications/deep_edge_aware_filters/images/lena-zuanqiang.jpg'));
    model_path = 'vcnn/applications/deep_edge_aware_filters/models/zuanqiang.mat';
    beta = 2.388608e+02 / 2;
elseif strcmp(filterType,'psMasic4')
    I = im2double(imread('vcnn/applications/deep_edge_aware_filters/images/lena-psMasic4.jpg'));
    model_path = 'vcnn/applications/deep_edge_aware_filters/models/psMasic4.mat';
    beta = 6.388608e+00 / 2;
elseif strcmp(filterType,'dssmx')
    I = im2double(imread('vcnn/applications/deep_edge_aware_filters/images/lena-dssmx.jpg'));
    model_path = 'vcnn/applications/deep_edge_aware_filters/models/dssmx.mat';
    beta = 2.388608e+02 / 2;
elseif strcmp(filterType,'GuassBlur')
    I = im2double(imread('vcnn/applications/deep_edge_aware_filters/images/lena-GuassBlur.jpg'));
    model_path = 'vcnn/applications/deep_edge_aware_filters/models/GuassBlur.mat';
    beta =  6.388608e+00 / 2;
else     %�Ժ�����µ�Ч��
    
end




fprintf('preparing the network...\n');
prepare_net_filter(size(I, 1), size(I, 2), model_path);

fprintf('filtering the image...\n');
tic
S = I;

h_input = [diff(S,1,2), S(:,1,:) - S(:,end,:)];
v_input = [diff(S,1,1); S(1,:,:) - S(end,:,:)];
h_input = h_input * 2;
v_input = v_input * 2;
v_input = config.NEW_MEM(v_input);
h_input = config.NEW_MEM(h_input);

out = apply_net_filter(v_input, h_input);

v = out(:,:,:,1);
h = out(:,:,:,2);
v = v / 2;
h = h / 2;
h(:, end, :) = S(:,1,:) - S(:,end,:);
v(end, :, :) = S(1,:,:) - S(end,:,:);

filtered = grad_process(S, v, h, beta);
toc
currPath = fileparts(mfilename('fullpath'));



if strcmp('rh',filterType)
    % do nothing
else  %����Ч����ԭ������ɫ�ı估�񻯵ĺ�������
    % ������ɫ��ԭ
    load(strcat(currPath,'\models\',filterType,'Mat.mat'));
    filtered(:,:,1) = filtered(:,:,1).*index.i;
    filtered(:,:,2) = filtered(:,:,2).*index.j;
    filtered(:,:,3) = filtered(:,:,3).*index.k;
    filtered = rh(filtered,filterType);
end

%���滹ԭͼ
imgName = strcat(filterType,num2str(beta),'.jpg');
imwrite(filtered,imgName);

figure;

imshow([I,Ori,filtered]); drawnow();
ofPSNR = roundn(csnr(Ori*255,filtered*255,0,0),-2);  %ԭͼ�뻹ԭͼPSNR
iOPSNR = roundn(csnr(I*255,Ori*255,0,0),-2);         %ԭͼ���˾�ͼPSNR

Iycbcr = rgb2ycbcr(I);
fycbcr = rgb2ycbcr(filtered);
oycbcr = rgb2ycbcr(Ori);
ofSSIM = roundn(ssim_index(Iycbcr(:,:,1)*255,fycbcr(:,:,1)*255),-2);  %ԭͼ�뻹ԭͼSSIM
ioSSIM = roundn(ssim_index(Iycbcr(:,:,1)*255,oycbcr(:,:,1)*255),-2);       %ԭͼ���˾�ͼSSIM

filterList = {'��','שǽ','������','����ɨ����','��˹ģ��'};  % �Ժ��������Ч��
set(gca,'FontSize',13);
title(['��������: ' filterList{fIndex} 'ͼ ','ԭͼ ��ԭͼ' ' PSNR1 = ' num2str(iOPSNR) ...
    ' PSNR2 = ' num2str(ofPSNR) '  SSIM1 = ' num2str(ioSSIM) ' SSIM2 = ' num2str(ofSSIM)]);

end

