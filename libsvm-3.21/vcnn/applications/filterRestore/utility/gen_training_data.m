addpath applications/filterRestore/utility/GT_filters/
addpath applications/filterRestore/utility/GT_filters/L0smoothing/
addpath data/
fprintf('%s\t%s\n',mfilename,datestr(now));
clear;
patch_dim = 64;
num_patches = 1000;
listing = dir('data/deepeaf/BSDS500/*.jpg');
fListing = dir('data/deepeaf/fImgs/*.jpg'); 
for m = 1 : 101
    fprintf('Extracting patch batch: %d / %d\n', m, 101);
    % ��ȡÿ��matѵ��������64x64x3x1000�ġ�
    samples = zeros(patch_dim, patch_dim, 3, num_patches);
    labels = zeros(size(samples));
    for i = 1 : num_patches / 8  % 1000�Ź�Ҫ�����ȡ125��ͼ�����ظ���ÿ�����ѡȡ���Ͻǵĵ���ȡpatch
        if (mod(i,100) == 0)
            fprintf('Extracting patch: %d / %d\n', i*8, num_patches);
        end
        
        r_idx = random('unid', size(listing, 1));
        %��������˳����ͬ�����ͼƬx��Ӧ��index���ͼƬ�˾����Ӧ��index��ͬ
        I = imread(strcat('data/deepeaf/BSDS500/', listing(r_idx).name));
        fI = imread(strcat('data/deepeaf/fImgs/',fListing(r_idx).name));
        orig_img_size = size(I);
        r = random('unid', orig_img_size(1) - patch_dim + 1);
        c = random('unid', orig_img_size(2) - patch_dim + 1);
        
        % EdgeExtractֻ��������ֱ�������ȡ���������ҷ�ת���ٵ�����4��90�ȵ���ת     
        % �ͺ�����matrix��8��ȫ����̬
        patch = I(r:r+patch_dim-1, c:c+patch_dim-1, :);
        fpatch = fI(r:r+patch_dim-1, c:c+patch_dim-1, :);
        patchHoriFlipped = fliplr(patch);
        fpatch = fliplr(fpatch);  % ͬ�����з�ת
        idx_list = (i-1)*8+1:(i-1)*8+8;
        for idx = 1:4
            % samples�洢����in��Ҳ�����˲����ͼƬ���ݶ� 
            % labels�洢����vout��Ҳ����ԭʼͼƬ���ݶ�
            % 8��һ�飬1~4�洢ԭʼͼ���˲����ͼƬ��Iy, Ix, -Iy, -Ix
            % 5~8�洢��ԭʼ/�˲�ͼƬ������Գƺ��ͼƬ�� Iy, Ix, -Iy, -Ix
            % ÿ���4������ͼƬ���ҶԳ� 
              patch_rotated = im2double(imrotate(patch, (idx-1)*90));
              patch_filtered = im2double(imrotate(fpatch,(idx-1)*90));
              [vin, vout] = EdgeExtract(im2double(patch_rotated), im2double(patch_filtered));
              samples(:,:,:,idx_list(idx)) = vout;
              labels(:,:,:,idx_list(idx)) = vin;            
            
              patch_rotated = im2double(imrotate(patchHoriFlipped, (idx-1)*90));
              patch_filtered = im2double(imrotate(fpatch,(idx-1)*90));  
              [vin, vout] = EdgeExtract(im2double(patch_rotated), im2double(patch_filtered));            
              samples(:,:,:,idx_list(idx+4)) = vout;  % ��patch_filtered��Ϊsamples             
              labels(:,:,:,idx_list(idx+4)) = vin;    % ��patch_rotated��Ϊlabels
        end
    end
    samples = single(samples);
    labels = single(labels);
    % save it
    filename = strcat('data/deepeaf/certainFilter/train/patches_', num2str(m));
    save(filename, '-v7.3', 'samples', 'labels');
end

