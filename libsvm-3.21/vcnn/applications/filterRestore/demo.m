addpath applications/filterRestore/
addpath applications/filterRestore/utility/
addpath applications/filterRestore/models/
addpath applications/filterRestore/images/
addpath utils/
addpath cuda/
addpath mem/
addpath layers/
addpath layers_adapters/
addpath pipeline/

fprintf('%s\t%s\n',mfilename,datestr(now));
global config;
% load the image you like
%I = im2double(imread('applications/filterRestore/images/1.png'));
Ori = im2double(imread('vcnn/applications/filterRestore/images/lena.jpg'));
I = im2double(imread('vcnn/applications/filterRestore/images/lena-psMasic4.jpg'));
% to switch among filters, just comment out the previous 'model_path' and 'beta' and
% uncomment the new ones

% ���ۣ�����psMasci��GuassBlur��˵��mat����1.�ɼ���ɫ�򼸺�����û�иı䡣
model_path = 'vcnn/applications/filterRestore/models/psMasic4.mat';
%beta = 8.388608e+00 / 2;
% beta = 2.388608e+02 / 2;   %for ����ɨ����
% beta =  6.388608e+00 / 2;  %for ��˹2.0
beta = 6.388608e+00 / 2;  %for psMasci, �����һ��%...
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
v_input = config.NEW_MEM(v_input); %����ֻ�ǽ�����ת��Ϊgpuarray
h_input = config.NEW_MEM(h_input);

out = apply_net_filter(v_input, h_input);

v = out(:,:,:,1);
h = out(:,:,:,2);
v = v / 2;
h = h / 2;
h(:, end, :) = S(:,1,:) - S(:,end,:);
v(end, :, :) = S(1,:,:) - S(end,:,:);

% ����һ
filtered = grad_process(S, v, h, beta);
imwrite(filtered,'temp.jpg');
getBestDialog('psMasic4');
load('psMasic4Mat.mat');
filtered(:,:,1) = filtered(:,:,1).*index.i;
filtered(:,:,2) = filtered(:,:,2).*index.j;
filtered(:,:,3) = filtered(:,:,3).*index.k;

% % ������
% load('zuanqiangMat.mat');
% filtered = grad_process1(S, v, h, beta,index);
toc

vPSNR = csnr(255*filtered,255*Ori,0,0); %��ԭͼ��ԭͼ
vPSNR2 = csnr(255*Ori,255*I,0,0);  %psͼ��ԭͼ

figure;
imshow([I, filtered]); drawnow();
title(num2str(vPSNR));



