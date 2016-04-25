function lbpHist = getDataLBP(flag,varargin)
%得到图像的LBP纹理特征直方图,0为得到训练的直方图，1为得到测试的直方图
% 提取训练/测试数据的颜色直方图。
lbpHist=[];
if flag == 0
    % 得到训练的颜色直方图。
    % mfilename('filepath')返回正在运行的函数的文件名，
    % fileparts将一个文件的完整路径文件名等信息提取出，若是和fullfile连用，则只传路径。
    for j=1:12
        % 得到训练图片的目录
        currentDepth = 1; % get the supper path of the current path
        currPath = fileparts(mfilename('fullpath'));% get current path
        fsep = filesep;
        pos_v = strfind(currPath,fsep);
        p = currPath(1:pos_v(length(pos_v)-currentDepth+1)-1); % -1: delete the last character '/' or '\'
        file_path=strcat(p,'\pics\train\',num2str(j),'\');
       
        file_path_list=dir(strcat(file_path,'*.jpg'));
        oriImg = regexp({file_path_list.name},'(^\d+).jpg','tokens');
        filtered = regexp({file_path_list.name},'([^0-9]\w+).jpg','tokens');  %不是数字
        if ischar(varargin{1}) 
             delFiltered = regexp({file_path_list.name},strcat('(',varargin{1},').jpg'),'tokens'); %删去的效果
        end  
%--------------------------------------------------------------------
%当加入新的效果时，修改下面的注释  12x14和12x12进行修改。
%--------------------------------------------------------------------              
        
       %-- 得到所有的12张x14种效果，colorHist最终为168x256的double矩阵
       % 现在是得到12张x12种效果，其中效果“暖黄”和效果“唯美”被去掉。      
 
       index = ~cellfun(@isempty,oriImg);
       xx = find(index == 1);
       tt = oriImg{xx};
       oriStr = strcat(file_path,tt{1},'.jpg');
       ori=im2double(imread(oriStr{1}));
       
        findices = ~cellfun(@isempty,filtered);
        delIndices = ~cellfun(@isempty,delFiltered); 
        yy = find(findices == 1); %找到不为空的index
        mm = find(delIndices == 1); %比如暖黄效果，得到的mm(1)是7，而对应的效果编号是6
        filterNum = numel(yy);
        for i = 1:filterNum
            if ismember(i,mm-1)     %得到的是包括了原图的编号，故减1
                continue;     %跳过要删去的效果
            else
                t = filtered{yy(i)}; 
                filterStr = strcat(file_path,t{1},'.jpg');  %由于strcat返回的是cell，所以要用{1}转换成string
                I=im2double(imread(filterStr{1}));
                MAPPING = getmapping(16,'riu2');
                lbpHist = [lbpHist;lbp((I-ori),2,16,MAPPING,'nh')];
            end
        end        
    end
elseif flag == 1
    for j=1:6
        currentDepth = 1; % get the supper path of the current path
        currPath = fileparts(mfilename('fullpath'));% get current path
        fsep = filesep;
        pos_v = strfind(currPath,fsep);
        p = currPath(1:pos_v(length(pos_v)-currentDepth+1)-1); % -1: delete the last character '/' or '\'
        file_path=strcat(p,'\pics\test\',num2str(j),'\');
        
        file_path_list=dir(strcat(file_path,'*.jpg'));
        oriImg = regexp({file_path_list.name},'(^\d+).jpg','tokens');
        filtered = regexp({file_path_list.name},'([^0-9]\w+).jpg','tokens');  
        if ischar(varargin{1}) 
             delFiltered = regexp({file_path_list.name},strcat('(',varargin{1},').jpg'),'tokens'); %删去的效果
        end
       index = ~cellfun(@isempty,oriImg);
       xx = find(index == 1);
       tt = oriImg{xx};
       oriStr = strcat(file_path,tt{1},'.jpg');
       ori = im2double(imread(oriStr{1}));

        findices = ~cellfun(@isempty,filtered);
        delIndices = ~cellfun(@isempty,delFiltered); 
        yy = find(findices == 1); 
        mm = find(delIndices == 1); %比如暖黄效果，得到的mm(1)是7，而对应的效果编号是6
        filterNum = numel(yy);
        for i = 1:filterNum
            if ismember(i,mm-1)     %得到的是包括了原图的编号，故减1
                continue;     %跳过要删去的效果
            else
                t = filtered{yy(i)};
                filterStr = strcat(file_path,t{1},'.jpg');  
                I=im2double(imread(filterStr{1}));
                MAPPING = getmapping(16,'riu2');
                lbpHist = [lbpHist;lbp((I-ori),2,16,MAPPING,'nh')];
            end
        end 
    end
else
    sprintf('only 1 or 0 is acceptable!\n');
end
