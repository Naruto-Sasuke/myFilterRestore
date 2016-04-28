function varargout = GUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
global GUIoriImg GUIfimgOri GUIimgStr GUImodelType  GUIfilterList GUICNNfilterList;
GUIfilterList = {'dy','fg','fs','ll','ln','nhua','rg','wm','yg','zrmf'};
GUICNNfilterList = {'rh','zuanqiang','psMasic4','dssmx','GuassBlur'};
GUIoriImg = [];
GUIfimgOri = [];
GUIimgStr = [];    %ԭͼ���
GUImodelType = [];
% GUICNNmodelType = [];
set(handles.filterPop,'enable','inactive');
set(handles.imgIndexPop,'enable','inactive');
set(handles.spePop,'enable','inactive');

guidata(hObject, handles);


function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;



% --- Executes on button press in simuBtn.
function simuBtn_Callback(hObject, eventdata, handles)
    global GUIoriImg  GUIfimgOri GUImodelType GUIfilterList GUICNNfilterList;
    fImgORI = GUIfimgOri;
    oriImg = GUIoriImg;
    normalFiltersNum = numel(GUIfilterList);  %һ��Ϊ10��
    isNormalF = 0;   % �Ƿ�Ϊ��ͨ�˾���1��ʾ��
    for i=1:normalFiltersNum
         if(strcmp(GUIfilterList{i},GUImodelType))
              isNormalF = 1;
              break;
         end
    end
    if isNormalF         % ��ͨ�˾�
        %------����ģ��,   �����ɫ���ģ��
        currPath = fileparts(mfilename('fullpath'));
        load(strcat(currPath,'\feature\models\',GUImodelType));  % ������data��������
        A = data.matrix{1};
        B = data.matrix{2};
        [m,n,ch] = size(oriImg);
        imgRestore = zeros(m,n,ch);  
        steps = m;  %�ܹ���������
        step = 0;   
        hwaitbar = waitbar(0,'��ʼģ��');
        pause(0.2);
        for i = 1:m 
            for j = 1:n
                imgRestore(i,j,:) = A\(reshape(fImgORI(i,j,:),3,1)-B);         
            end
            step = step + 1;
            waitbar(step/steps,hwaitbar,['��' num2str(m) '��' ',���ڴ���' num2str(step) '/' num2str(m) ', ' num2str(fix(step/steps*100)) '%']);
        end
        close(hwaitbar);
        figure;
        psnrTest = csnr(oriImg*255,imgRestore*255,0,0);

        imshow([fImgORI,oriImg,imgRestore]);
        title(strcat('�������ң� �˾�ͼ ԭͼ ��ԭͼ,PSNR = ',num2str(psnrTest)));
    else  %�����˾�, ����VCNN������
        speFilter = []; %�����˾�
        for i = 1:numel(GUICNNfilterList)
            if strcmp(GUImodelType,GUICNNfilterList{i})
                speFilter = GUICNNfilterList{i};
                % �������VCNN��model
                steps = 1000;
                h = msgbox('�ù��̿�����Ҫʮ����...');
                pause(1);
                close(h);
                matGUICNN(speFilter,i);               
                break;
            end
        end

    end
        
function filterPop_Callback(hObject, eventdata, handles)
sel1 = get(hObject,'value') - 1;
global GUIfilterList GUImodelType GUIindexStr  GUIfimgOri GUIoriImg;
if sel1 ~= 0
    GUImodelType = GUIfilterList{sel1}; 
else
    return;
end
sel2 = get(handles.imgIndexPop,'value')-1;
currPath = fileparts(mfilename('fullpath'));
if sel2 ~= 0
    GUIindexStr = num2str(sel2);
    pname = strcat(currPath,'\feature\pics\test\',GUIindexStr,'\');
    fname = strcat(GUImodelType,GUIindexStr,'.jpg');
    str = [pname fname];                            %�˾�ͼ������
    GUIfimgOri = im2double(imread(str));            %�˾�ͼ����   
    oriName = [pname ,strcat(GUIindexStr,'.jpg')];    %�������Ӧ��ԭͼ�����ֺ�����
    GUIoriImg = im2double(imread(oriName));
end
if sel1 ~= 0 && sel2 ~= 0
    image(GUIfimgOri,'Parent',handles.imgfAxes);    % ��ʾ�˾�ͼ
    image(GUIoriImg,'Parent',handles.imgAxes);
end
guidata(hObject,handles);



function filterPop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function imgIndexPop_Callback(hObject, eventdata, handles)
sel2 = get(handles.imgIndexPop,'value') -1;   %��һ������ʾ��
currPath = fileparts(mfilename('fullpath'));
global GUIindexStr GUImodelType GUIfimgOri GUIoriImg;
if sel2 ~= 0
    GUIindexStr = num2str(sel2);
else
    return;
end
pname = strcat(currPath,'\feature\pics\test\',GUIindexStr,'\');
fname = strcat(GUImodelType,GUIindexStr,'.jpg');
str = [pname fname];                            %�˾�ͼ������
GUIfimgOri = im2double(imread(str));            %�˾�ͼ����   

oriName = [pname ,strcat(GUIindexStr,'.jpg')];    %�������Ӧ��ԭͼ�����ֺ�����
GUIoriImg = im2double(imread(oriName));
sel1 = get(handles.filterPop,'value')-1;
if sel1 ~= 0 && sel2 ~= 0
    image(GUIfimgOri,'Parent',handles.imgfAxes);    % ��ʾ�˾�ͼ
    image(GUIoriImg,'Parent',handles.imgAxes);
end

guidata(hObject,handles);




function imgIndexPop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function predictBtn_Callback(hObject, eventdata, handles)
global GUIoriImg GUIfimgOri GUIfilterList GUICNNfilterList;
sel1 = get(handles.filterPop,'value')-1;
sel2 = get(handles.imgIndexPop,'value')-1;
filterList = {'����','����','��ɫ','����','����','ů��','���','Ψ��','�Ÿ�','��Ȼ����'};
% CNNfilterList = {'��','שǽ'};
steps = 1000;
h = waitbar(0,'����Ԥ��');
for i = 1:steps
    waitbar(i/steps,h,'�������...');
end
close(h);
if sel1 ~= 0 && sel2 ~= 0
    preLab = predictLab(GUIoriImg,GUIfimgOri,sel1);
    set(handles.predictTxt,'String',filterList{preLab});
else
    return;
end








% --- Executes on selection change in filterTypeSelPop.
function filterTypeSelPop_Callback(hObject, eventdata, handles)
sel0 = get(hObject,'value') - 1; % ���ѡ������ͨ�˾����������˾�
if sel0 ~= 0
    if sel0 == 1
        set(handles.filterPop,'enable','on');
        set(handles.imgIndexPop,'enable','on');
        set(handles.spePop,'enable','inactive');
    elseif sel0 == 2
        set(handles.filterPop,'enable','inactive');
        set(handles.imgIndexPop,'enable','inactive');
        set(handles.spePop,'enable','on');
    end
else
    set(handles.filterPop,'enable','inactive');
    set(handles.imgIndexPop,'enable','inactive');
    set(handles.spePop,'enable','inactive');
    return;
end




% --- Executes during object creation, after setting all properties.
function filterTypeSelPop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- �����˾�,ֱ��ѡ��lenaͼƬ
function spePop_Callback(hObject, eventdata, handles)
sel3 = get(hObject,'value') - 1;
global GUImodelType GUICNNfilterList GUIoriImg GUIfimgOri;
if sel3 ~= 0
    if sel3 == 1  %��ͼ
        GUImodelType = GUICNNfilterList{sel3};
        GUIoriImg = im2double(imread('vcnn/applications/filterRestore/images/lena.jpg'));
        GUIfimgOri = im2double(imread('vcnn/applications/filterRestore/images/lena-rh.jpg'));
        image(GUIfimgOri,'Parent',handles.imgfAxes);    % ��ʾ�˾�ͼ
        image(GUIoriImg,'Parent',handles.imgAxes);
    elseif sel3 == 2 %שǽͼ
        GUImodelType = GUICNNfilterList{sel3};
        GUIoriImg = im2double(imread('vcnn/applications/filterRestore/images/lena.jpg'));
        GUIfimgOri = im2double(imread('vcnn/applications/filterRestore/images/lena-zuanqiang.jpg'));
        image(GUIfimgOri,'Parent',handles.imgfAxes);    % ��ʾ�˾�ͼ
        image(GUIoriImg,'Parent',handles.imgAxes);
    elseif sel3 == 3 %������
        GUImodelType = GUICNNfilterList{sel3};
        GUIoriImg = im2double(imread('vcnn/applications/filterRestore/images/lena.jpg'));
        GUIfimgOri = im2double(imread('vcnn/applications/filterRestore/images/lena-psMasic4.jpg'));
        image(GUIfimgOri,'Parent',handles.imgfAxes);    % ��ʾ�˾�ͼ
        image(GUIoriImg,'Parent',handles.imgAxes);
    elseif sel3 == 4 %����ɨ����
        GUImodelType = GUICNNfilterList{sel3};
        GUIoriImg = im2double(imread('vcnn/applications/filterRestore/images/lena.jpg'));
        GUIfimgOri = im2double(imread('vcnn/applications/filterRestore/images/lena-dssmx.jpg'));
        image(GUIfimgOri,'Parent',handles.imgfAxes);    % ��ʾ�˾�ͼ
        image(GUIoriImg,'Parent',handles.imgAxes);
    elseif sel3 == 5 %��˹ģ��
        GUImodelType = GUICNNfilterList{sel3};
        GUIoriImg = im2double(imread('vcnn/applications/filterRestore/images/lena.jpg'));
        GUIfimgOri = im2double(imread('vcnn/applications/filterRestore/images/lena-GuassBlur.jpg'));
        image(GUIfimgOri,'Parent',handles.imgfAxes);    % ��ʾ�˾�ͼ
        image(GUIoriImg,'Parent',handles.imgAxes);
    end   
else
    return;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function spePop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
