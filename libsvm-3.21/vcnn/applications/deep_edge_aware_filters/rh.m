function rhImg = rh(I,filterType)
%������ʲô�汾���񻯣��ܸ���ǿ�ȵģ�һ������������psnr
%ͼ����,���ڡ�שǽ���Ȼ�ԭ���ģ���������
% ��ʱ��3���ȽϺõģ��񻯣���˹ģ����שǽ
if strcmp(filterType,'GuassBlur')
	rhImg = imsharpen(I,'Radius',2,'Amount',1.5);
elseif strcmp(filterType,'zuanqiang')
    rhImg = imsharpen(I,'Radius',2,'Amount',1);
elseif strcmp(filterType,'psMasic4')   % �����˵�Ч��Ҳ�ر���
    rhImg = imsharpen(I,'Radius',2,'Amount',1.5);
elseif strcmp(filterType,'dssmx')      % ��Ҫ����ɨ�����ˣ���������
    rhImg = imsharpen(I,'Radius',2,'Amount',0.9);
else 
    rhImg = imsharpen(I,'Radius',2,'Amount',1);
end
% rhImg = I;
end
