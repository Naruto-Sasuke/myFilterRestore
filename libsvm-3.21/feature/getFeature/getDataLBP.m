function lbpHist = getDataLBP(flag,varargin)
%�õ�ͼ���LBP��������ֱ��ͼ,0Ϊ�õ�ѵ����ֱ��ͼ��1Ϊ�õ����Ե�ֱ��ͼ
% ��ȡѵ��/�������ݵ���ɫֱ��ͼ��
lbpHist=[];
if flag == 0
    % �õ�ѵ������ɫֱ��ͼ��
    % mfilename('filepath')�����������еĺ������ļ�����
    % fileparts��һ���ļ�������·���ļ�������Ϣ��ȡ�������Ǻ�fullfile���ã���ֻ��·����
    for j=1:12
        % �õ�ѵ��ͼƬ��Ŀ¼
        currentDepth = 1; % get the supper path of the current path
        currPath = fileparts(mfilename('fullpath'));% get current path
        fsep = filesep;
        pos_v = strfind(currPath,fsep);
        p = currPath(1:pos_v(length(pos_v)-currentDepth+1)-1); % -1: delete the last character '/' or '\'
        file_path=strcat(p,'\pics\train\',num2str(j),'\');
       
        file_path_list=dir(strcat(file_path,'*.jpg'));
        oriImg = regexp({file_path_list.name},'(^\d+).jpg','tokens');
        filtered = regexp({file_path_list.name},'([^0-9]\w+).jpg','tokens');  %��������
        if ischar(varargin{1}) 
             delFiltered = regexp({file_path_list.name},strcat('(',varargin{1},').jpg'),'tokens'); %ɾȥ��Ч��
        end  
%--------------------------------------------------------------------
%�������µ�Ч��ʱ���޸������ע��  12x14��12x12�����޸ġ�
%--------------------------------------------------------------------              
        
       %-- �õ����е�12��x14��Ч����colorHist����Ϊ168x256��double����
       % �����ǵõ�12��x12��Ч��������Ч����ů�ơ���Ч����Ψ������ȥ����      
 
       index = ~cellfun(@isempty,oriImg);
       xx = find(index == 1);
       tt = oriImg{xx};
       oriStr = strcat(file_path,tt{1},'.jpg');
       ori=im2double(imread(oriStr{1}));
       
        findices = ~cellfun(@isempty,filtered);
        delIndices = ~cellfun(@isempty,delFiltered); 
        yy = find(findices == 1); %�ҵ���Ϊ�յ�index
        mm = find(delIndices == 1); %����ů��Ч�����õ���mm(1)��7������Ӧ��Ч�������6
        filterNum = numel(yy);
        for i = 1:filterNum
            if ismember(i,mm-1)     %�õ����ǰ�����ԭͼ�ı�ţ��ʼ�1
                continue;     %����Ҫɾȥ��Ч��
            else
                t = filtered{yy(i)}; 
                filterStr = strcat(file_path,t{1},'.jpg');  %����strcat���ص���cell������Ҫ��{1}ת����string
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
             delFiltered = regexp({file_path_list.name},strcat('(',varargin{1},').jpg'),'tokens'); %ɾȥ��Ч��
        end
       index = ~cellfun(@isempty,oriImg);
       xx = find(index == 1);
       tt = oriImg{xx};
       oriStr = strcat(file_path,tt{1},'.jpg');
       ori = im2double(imread(oriStr{1}));

        findices = ~cellfun(@isempty,filtered);
        delIndices = ~cellfun(@isempty,delFiltered); 
        yy = find(findices == 1); 
        mm = find(delIndices == 1); %����ů��Ч�����õ���mm(1)��7������Ӧ��Ч�������6
        filterNum = numel(yy);
        for i = 1:filterNum
            if ismember(i,mm-1)     %�õ����ǰ�����ԭͼ�ı�ţ��ʼ�1
                continue;     %����Ҫɾȥ��Ч��
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
