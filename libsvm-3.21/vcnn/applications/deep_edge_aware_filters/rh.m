function rhImg = rh(I,filterType)
%看看有什么版本的锐化，能更改强度的，一遍后续进行提高psnr
%图像锐化,用于“砖墙”等还原后变模糊的情况。
% 暂时就3个比较好的：锐化，高斯模糊，砖墙
if strcmp(filterType,'GuassBlur')
	rhImg = imsharpen(I,'Radius',2,'Amount',1.5);
elseif strcmp(filterType,'zuanqiang')
    rhImg = imsharpen(I,'Radius',2,'Amount',1);
elseif strcmp(filterType,'psMasic4')   % 马赛克的效果也特别差。。
    rhImg = imsharpen(I,'Radius',2,'Amount',1.5);
elseif strcmp(filterType,'dssmx')      % 不要电视扫描线了，看着想吐
    rhImg = imsharpen(I,'Radius',2,'Amount',0.9);
else 
    rhImg = imsharpen(I,'Radius',2,'Amount',1);
end
% rhImg = I;
end
