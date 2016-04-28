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
    % 提取每个mat训练数据是64x64x3x1000的。
    samples = zeros(patch_dim, patch_dim, 3, num_patches);
    labels = zeros(size(samples));
    for i = 1 : num_patches / 8  % 1000张共要随机抽取125次图，有重复，每次随机选取左上角的点提取patch
        if (mod(i,100) == 0)
            fprintf('Extracting patch: %d / %d\n', i*8, num_patches);
        end
        
        r_idx = random('unid', size(listing, 1));
        %由于命名顺序相同，因此图片x对应的index与该图片滤镜后对应的index相同
        I = imread(strcat('data/deepeaf/BSDS500/', listing(r_idx).name));
        fI = imread(strcat('data/deepeaf/fImgs/',fListing(r_idx).name));
        orig_img_size = size(I);
        r = random('unid', orig_img_size(1) - patch_dim + 1);
        c = random('unid', orig_img_size(2) - patch_dim + 1);
        
        % EdgeExtract只进行了竖直方向的提取，进行左右翻转，再到后面4个90度的旋转     
        % 就涵盖了matrix的8种全部形态
        patch = I(r:r+patch_dim-1, c:c+patch_dim-1, :);
        fpatch = fI(r:r+patch_dim-1, c:c+patch_dim-1, :);
        patchHoriFlipped = fliplr(patch);
        fpatch = fliplr(fpatch);  % 同样进行翻转
        idx_list = (i-1)*8+1:(i-1)*8+8;
        for idx = 1:4
            % samples存储的是in，也就是滤波后的图片的梯度 
            % labels存储的是vout，也就是原始图片的梯度
            % 8个一组，1~4存储原始图像滤波后的图片的Iy, Ix, -Iy, -Ix
            % 5~8存储着原始/滤波图片经过左对称后的图片的 Iy, Ix, -Iy, -Ix
            % 每间隔4的两张图片左右对称 
              patch_rotated = im2double(imrotate(patch, (idx-1)*90));
              patch_filtered = im2double(imrotate(fpatch,(idx-1)*90));
              [vin, vout] = EdgeExtract(im2double(patch_rotated), im2double(patch_filtered));
              samples(:,:,:,idx_list(idx)) = vout;
              labels(:,:,:,idx_list(idx)) = vin;            
            
              patch_rotated = im2double(imrotate(patchHoriFlipped, (idx-1)*90));
              patch_filtered = im2double(imrotate(fpatch,(idx-1)*90));  
              [vin, vout] = EdgeExtract(im2double(patch_rotated), im2double(patch_filtered));            
              samples(:,:,:,idx_list(idx+4)) = vout;  % 将patch_filtered作为samples             
              labels(:,:,:,idx_list(idx+4)) = vin;    % 将patch_rotated作为labels
        end
    end
    samples = single(samples);
    labels = single(labels);
    % save it
    filename = strcat('data/deepeaf/certainFilter/train/patches_', num2str(m));
    save(filename, '-v7.3', 'samples', 'labels');
end

