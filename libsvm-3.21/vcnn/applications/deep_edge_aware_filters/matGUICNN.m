function matGUICNN(filterType, fIndex)
%用于：GUI模拟梯度域还原
% filterType: 'rh',...
% fIndex ,如果是rh的话，就为1，以此类推
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
I = [];  %滤镜图
Ori = im2double(imread('vcnn/applications/deep_edge_aware_filters/images/lena.jpg')); %原图
model_path = [];
%除了锐化效果的还原外，其他效果的还原都要加上锐化后续操作
if strcmp(filterType,'rh')
    I = im2double(imread('vcnn/applications/deep_edge_aware_filters/images/lena-rh.jpg'));
    model_path = 'vcnn/applications/deep_edge_aware_filters/models/rh.mat';
%    beta = 2.388608e+00 / 2;  PSNR = 28
%    beta = ...........+01/2;  PSNR = 25
%    beta = 2.388608e+02 / 2;  PSNR = 24  越来越模糊了。。
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
else     %以后加入新的效果
    
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
else  %其他效果还原加上颜色改变及锐化的后续操作
    % 进行颜色域还原
    load(strcat(currPath,'\models\',filterType,'Mat.mat'));
    filtered(:,:,1) = filtered(:,:,1).*index.i;
    filtered(:,:,2) = filtered(:,:,2).*index.j;
    filtered(:,:,3) = filtered(:,:,3).*index.k;
    filtered = rh(filtered,filterType);
end

%保存还原图
imgName = strcat(filterType,num2str(beta),'.jpg');
imwrite(filtered,imgName);

figure;

imshow([I,Ori,filtered]); drawnow();
ofPSNR = roundn(csnr(Ori*255,filtered*255,0,0),-2);  %原图与还原图PSNR
iOPSNR = roundn(csnr(I*255,Ori*255,0,0),-2);         %原图与滤镜图PSNR

Iycbcr = rgb2ycbcr(I);
fycbcr = rgb2ycbcr(filtered);
oycbcr = rgb2ycbcr(Ori);
ofSSIM = roundn(ssim_index(Iycbcr(:,:,1)*255,fycbcr(:,:,1)*255),-2);  %原图与还原图SSIM
ioSSIM = roundn(ssim_index(Iycbcr(:,:,1)*255,oycbcr(:,:,1)*255),-2);       %原图与滤镜图SSIM

filterList = {'锐化','砖墙','马赛克','电视扫描线','高斯模糊'};  % 以后加上其他效果
set(gca,'FontSize',13);
title(['从左至右: ' filterList{fIndex} '图 ','原图 还原图' ' PSNR1 = ' num2str(iOPSNR) ...
    ' PSNR2 = ' num2str(ofPSNR) '  SSIM1 = ' num2str(ioSSIM) ' SSIM2 = ' num2str(ofSSIM)]);

end

