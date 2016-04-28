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
GUIimgStr = [];    %原图编号
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
    normalFiltersNum = numel(GUIfilterList);  %一般为10个
    isNormalF = 0;   % 是否为普通滤镜，1表示是
    for i=1:normalFiltersNum
         if(strcmp(GUIfilterList{i},GUImodelType))
              isNormalF = 1;
              break;
         end
    end
    if isNormalF         % 普通滤镜
        %------加载模型,   针对颜色域的模型
        currPath = fileparts(mfilename('fullpath'));
        load(strcat(currPath,'\feature\models\',GUImodelType));  % 加载了data到工作区
        A = data.matrix{1};
        B = data.matrix{2};
        [m,n,ch] = size(oriImg);
        imgRestore = zeros(m,n,ch);  
        steps = m;  %总共处理行数
        step = 0;   
        hwaitbar = waitbar(0,'开始模拟');
        pause(0.2);
        for i = 1:m 
            for j = 1:n
                imgRestore(i,j,:) = A\(reshape(fImgORI(i,j,:),3,1)-B);         
            end
            step = step + 1;
            waitbar(step/steps,hwaitbar,['共' num2str(m) '行' ',正在处理' num2str(step) '/' num2str(m) ', ' num2str(fix(step/steps*100)) '%']);
        end
        close(hwaitbar);
        figure;
        psnrTest = csnr(oriImg*255,imgRestore*255,0,0);

        imshow([fImgORI,oriImg,imgRestore]);
        title(strcat('从左至右： 滤镜图 原图 还原图,PSNR = ',num2str(psnrTest)));
    else  %特殊滤镜, 调用VCNN来处理
        speFilter = []; %特殊滤镜
        for i = 1:numel(GUICNNfilterList)
            if strcmp(GUImodelType,GUICNNfilterList{i})
                speFilter = GUICNNfilterList{i};
                % 这里调用VCNN的model
                steps = 1000;
                h = msgbox('该过程可能需要十几秒...');
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
    str = [pname fname];                            %滤镜图的名字
    GUIfimgOri = im2double(imread(str));            %滤镜图数据   
    oriName = [pname ,strcat(GUIindexStr,'.jpg')];    %获得所对应的原图的名字和数据
    GUIoriImg = im2double(imread(oriName));
end
if sel1 ~= 0 && sel2 ~= 0
    image(GUIfimgOri,'Parent',handles.imgfAxes);    % 显示滤镜图
    image(GUIoriImg,'Parent',handles.imgAxes);
end
guidata(hObject,handles);



function filterPop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function imgIndexPop_Callback(hObject, eventdata, handles)
sel2 = get(handles.imgIndexPop,'value') -1;   %第一个是提示语
currPath = fileparts(mfilename('fullpath'));
global GUIindexStr GUImodelType GUIfimgOri GUIoriImg;
if sel2 ~= 0
    GUIindexStr = num2str(sel2);
else
    return;
end
pname = strcat(currPath,'\feature\pics\test\',GUIindexStr,'\');
fname = strcat(GUImodelType,GUIindexStr,'.jpg');
str = [pname fname];                            %滤镜图的名字
GUIfimgOri = im2double(imread(str));            %滤镜图数据   

oriName = [pname ,strcat(GUIindexStr,'.jpg')];    %获得所对应的原图的名字和数据
GUIoriImg = im2double(imread(oriName));
sel1 = get(handles.filterPop,'value')-1;
if sel1 ~= 0 && sel2 ~= 0
    image(GUIfimgOri,'Parent',handles.imgfAxes);    % 显示滤镜图
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
filterList = {'淡雅','复古','反色','冷蓝','流年','暖化','柔光','唯美','优格','自然美肤'};
% CNNfilterList = {'锐化','砖墙'};
steps = 1000;
h = waitbar(0,'正在预测');
for i = 1:steps
    waitbar(i/steps,h,'即将完成...');
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
sel0 = get(hObject,'value') - 1; % 获得选择是普通滤镜或是特殊滤镜
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


% --- 特殊滤镜,直接选择lena图片
function spePop_Callback(hObject, eventdata, handles)
sel3 = get(hObject,'value') - 1;
global GUImodelType GUICNNfilterList GUIoriImg GUIfimgOri;
if sel3 ~= 0
    if sel3 == 1  %锐化图
        GUImodelType = GUICNNfilterList{sel3};
        GUIoriImg = im2double(imread('vcnn/applications/filterRestore/images/lena.jpg'));
        GUIfimgOri = im2double(imread('vcnn/applications/filterRestore/images/lena-rh.jpg'));
        image(GUIfimgOri,'Parent',handles.imgfAxes);    % 显示滤镜图
        image(GUIoriImg,'Parent',handles.imgAxes);
    elseif sel3 == 2 %砖墙图
        GUImodelType = GUICNNfilterList{sel3};
        GUIoriImg = im2double(imread('vcnn/applications/filterRestore/images/lena.jpg'));
        GUIfimgOri = im2double(imread('vcnn/applications/filterRestore/images/lena-zuanqiang.jpg'));
        image(GUIfimgOri,'Parent',handles.imgfAxes);    % 显示滤镜图
        image(GUIoriImg,'Parent',handles.imgAxes);
    elseif sel3 == 3 %马赛克
        GUImodelType = GUICNNfilterList{sel3};
        GUIoriImg = im2double(imread('vcnn/applications/filterRestore/images/lena.jpg'));
        GUIfimgOri = im2double(imread('vcnn/applications/filterRestore/images/lena-psMasic4.jpg'));
        image(GUIfimgOri,'Parent',handles.imgfAxes);    % 显示滤镜图
        image(GUIoriImg,'Parent',handles.imgAxes);
    elseif sel3 == 4 %电视扫描线
        GUImodelType = GUICNNfilterList{sel3};
        GUIoriImg = im2double(imread('vcnn/applications/filterRestore/images/lena.jpg'));
        GUIfimgOri = im2double(imread('vcnn/applications/filterRestore/images/lena-dssmx.jpg'));
        image(GUIfimgOri,'Parent',handles.imgfAxes);    % 显示滤镜图
        image(GUIoriImg,'Parent',handles.imgAxes);
    elseif sel3 == 5 %高斯模糊
        GUImodelType = GUICNNfilterList{sel3};
        GUIoriImg = im2double(imread('vcnn/applications/filterRestore/images/lena.jpg'));
        GUIfimgOri = im2double(imread('vcnn/applications/filterRestore/images/lena-GuassBlur.jpg'));
        image(GUIfimgOri,'Parent',handles.imgfAxes);    % 显示滤镜图
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
