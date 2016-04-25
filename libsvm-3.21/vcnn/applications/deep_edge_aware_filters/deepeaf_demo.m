%--------------------------------------------------------------------------------------------------------
% The system is created based on the principles described in the following papers
% [1] Li Xu, Jimmy SJ. Ren, Qiong Yan, Renjie Liao, Jiaya Jia, "Deep Edge-Aware Filters", 
% The 32nd International Conference on Machine Learning (ICML 2015). Lille, France, July 6-11, 2015
% [2] Jimmy SJ. Ren and Li Xu, "On Vectorization of Deep Convolutional Neural Networks for Vision Tasks", 
% The 29th AAAI Conference on Artificial Intelligence (AAAI-15). Austin, Texas, USA, January 25-30, 2015
%--------------------------------------------------------------------------------------------------------
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

fprintf('%s\t%s\n',mfilename,datestr(now));
global config;
% load the image you like
%I = im2double(imread('applications/deep_edge_aware_filters/images/1.png'));
Ori = im2double(imread('vcnn/applications/deep_edge_aware_filters/images/lena.jpg'));
I = im2double(imread('vcnn/applications/deep_edge_aware_filters/images/lena-psMasic4.jpg'));
% to switch among filters, just comment out the previous 'model_path' and 'beta' and
% uncomment the new ones

% 结论：对于psMasci和GuassBlur来说，mat都是1.可见颜色域几乎几乎没有改变。
model_path = 'vcnn/applications/deep_edge_aware_filters/models/psMasic4.mat';
%beta = 8.388608e+00 / 2;
% beta = 2.388608e+02 / 2;   %for 电视扫描线
% beta =  6.388608e+00 / 2;  %for 高斯2.0
beta = 6.388608e+00 / 2;  %for psMasci, 提高了一个%...
%beta = 6.388608e+02 / 2;  %for zuanqiang


 

fprintf('preparing the network...\n');
prepare_net_filter(size(I, 1), size(I, 2), model_path);

fprintf('filtering the image...\n');
tic
S = I;

h_input = [diff(S,1,2), S(:,1,:) - S(:,end,:)];
v_input = [diff(S,1,1); S(1,:,:) - S(end,:,:)];
h_input = h_input * 2;
v_input = v_input * 2;
v_input = config.NEW_MEM(v_input); %这里只是将数据转化为gpuarray
h_input = config.NEW_MEM(h_input);

out = apply_net_filter(v_input, h_input);

v = out(:,:,:,1);
h = out(:,:,:,2);
v = v / 2;
h = h / 2;
h(:, end, :) = S(:,1,:) - S(:,end,:);
v(end, :, :) = S(1,:,:) - S(end,:,:);

% 方法一
filtered = grad_process(S, v, h, beta);
imwrite(filtered,'temp.jpg');
getBestDialog('psMasic4');
load('psMasic4Mat.mat');
filtered(:,:,1) = filtered(:,:,1).*index.i;
filtered(:,:,2) = filtered(:,:,2).*index.j;
filtered(:,:,3) = filtered(:,:,3).*index.k;

% % 方法二
% load('zuanqiangMat.mat');
% filtered = grad_process1(S, v, h, beta,index);
toc

vPSNR = csnr(255*filtered,255*Ori,0,0); %还原图和原图
vPSNR2 = csnr(255*Ori,255*I,0,0);  %ps图与原图

figure;
imshow([I, filtered]); drawnow();
title(num2str(vPSNR));



