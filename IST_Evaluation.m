function varargout = IST_Evaluation(varargin)
% IST_EVALUATION MATLAB code for IST_Evaluation.fig
%      IST_EVALUATION, by itself, creates a new IST_EVALUATION or raises the existing
%      singleton*.
%
%      H = IST_EVALUATION returns the handle to a new IST_EVALUATION or the handle to
%      the existing singleton*.
%
%      IST_EVALUATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IST_EVALUATION.M with the given input arguments.
%
%      IST_EVALUATION('Property','Value',...) creates a new IST_EVALUATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IST_Evaluation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IST_Evaluation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IST_Evaluation

% Last Modified by GUIDE v2.5 13-Apr-2020 20:25:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @IST_Evaluation_OpeningFcn, ...
    'gui_OutputFcn',  @IST_Evaluation_OutputFcn, ...
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
end

% --- Executes just before IST_Evaluation is made visible.
function IST_Evaluation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IST_Evaluation (see VARARGIN)

% Choose default command line output for IST_Evaluation
addpath('./SLIC');

handles.output = hObject;
set(gcf, 'Name', 'Phan mem khoanh vung Z Line');
set(handles.ImageView, 'XLimMode', 'manual');
set(handles.ImageView, 'YLimMode', 'manual');
set(handles.ImageView, 'XLim', [0 640]);
set(handles.ImageView, 'YLim', [0 480]);
set(handles.ImageView, 'NextPlot', 'add');

set(handles.ImageView, 'XTick', []);
set(handles.ImageView, 'YTick', []);
set(handles.ImageView, 'XTickLabel', []);
set(handles.ImageView, 'YTickLabel', []);
set(handles.ImageView, 'XColor', [1 1 1]);
set(handles.ImageView, 'YColor', [1 1 1]);
global segMode;
segMode = 1;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes IST_Evaluation wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = IST_Evaluation_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end
% --- Executes on button press in OpenFolder.
function OpenFolder_Callback(hObject, eventdata, handles)
% hObject    handle to OpenFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

folderName = uigetdir;
handles.folderName = folderName;
handles.predictFolder = fullfile(fileparts(handles.folderName), 'Predicts');

folderFiles = dir(handles.folderName);
handles.fileList = natsortfiles({folderFiles(~[folderFiles.isdir]).name});
set(handles.FolderView, 'String', handles.fileList);
guidata(hObject, handles);
myString = sprintf('Chon che do, roi chon 1 anh de hien thi.');
set(handles.description, 'String', myString);
end
% --- Executes on selection change in FolderView.
function FolderView_Callback(hObject, eventdata, handles)
% hObject    handle to FolderView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FolderView contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FolderView

global img;
global BGPixel;
global FGPixel;
global origfile;
global logFile summary cmtFile ptFlag;
set(handles.zero2, 'Value', 1);
set(handles.zero3, 'Value', 1);
set(handles.zero4, 'Value', 1);
set(handles.commentBox, 'String', '');
set(handles.saveComments, 'Value', 0);
set(handles.checkedSave, 'Visible', 'off');
set(handles.text5, 'Visible', 'off');
global segMode ; 
global sp spAll;
ptFlag = 0;
nRegion = 1000;
thresh = 100;
alpha = str2num(get(handles.alpha, 'String'));
color = get(handles.colorChosen, 'Value');
global Z;
global segRefine;
global imgRes;
% variables when performing in a new image
BGPixel = [];
FGPixel = [];
handles.mAction = [0 0];
handles.brushCount = 0;
guidata(hObject, handles);
if strcmp(get(handles.figure1, 'SelectionType'), 'normal')
    indexSelected = get(handles.FolderView, 'Value');
    fileList = get(handles.FolderView, 'String');
    fileName = fileList{indexSelected};
    [path, origfile, ext] = fileparts(fileName);
    ShowImage(fullfile(handles.folderName, strcat(origfile, ext)), handles.ImageView);            
end

switch segMode
    case 1
        logFile = fullfile(handles.ml1, strcat(origfile, '_log', '.txt'));
        cmtFile = fullfile(handles.ml1, strcat(origfile, '_comment', '.txt'));
        summary = fullfile(handles.ml1, 'summary.csv');
    case 2
        logFile = fullfile(handles.ml2, strcat(origfile, '_log', '.txt'));
        cmtFile = fullfile(handles.ml2, strcat(origfile, '_comment', '.txt'));
        summary = fullfile(handles.ml2, 'summary.csv');
    case 3
        logFile = fullfile(handles.ml3, strcat(origfile, '_log', '.txt'));
        cmtFile = fullfile(handles.ml3, strcat(origfile, '_comment', '.txt'));
        summary = fullfile(handles.ml3, 'summary.csv');
    case 4
        logFile = fullfile(handles.ml4, strcat(origfile, '_log', '.txt'));
        cmtFile = fullfile(handles.ml4, strcat(origfile, '_comment', '.txt'));
        summary = fullfile(handles.ml4, 'summary.csv');
end
logging('Start', 1, 0);
f = waitbar(0, 'Xin hay doi...');
switch segMode
    case 3
        %% create super pixels
        waitbar(.5, f, 'Xin hay doi...');
        sp  = mexGenerateSuperPixel(double(img), nRegion);
        sp = sp + 1;
        %%% draw regions on original images
        [imgRes, feat] = segToImg2(double(img), sp);
        Y = pdist(feat, 'mahalanobis');
        Z = linkage(Y);
    case 4
        %% create super pixels
        waitbar(.5, f, 'Xin hay doi...');
        UnetPredict = double(imread(fullfile(handles.predictFolder,strcat(origfile,'_predict.png'))));       
        [~, UnetPredictMask] = SegbyUnet(img, UnetPredict, thresh);  
        sp  = mexGenerateSuperPixel(double(img), nRegion, 10);
        sp = sp + 1;
        spAll = sp;
        [imgRes, feat, segRefine] = segToImg3(img, sp, UnetPredict, UnetPredictMask);
        Y = pdist(feat, 'mahalanobis');
        Z = linkage(Y);
        size(Z);
        axes(handles.ImageView);
        imshow(imgRes);
        drawnow;
    case 2
        waitbar(.5, f, 'Xin hay doi...');
        UnetPredict =double(imread(fullfile(handles.predictFolder,strcat(origfile,'_predict.png'))));        
        [~, imgMask] = SegbyUnet(img,UnetPredict,thresh);
        imgRes = drawtoImg2(imgMask, img, alpha, color);
        axes(handles.ImageView);
        imshow(imgRes);
        drawnow;
end
logging('Loaded', 0, 0);
waitbar(1, f, 'Da xong');
close(f);
guidata(hObject, handles);
end
%% Function for generating mask from


function ShowImage(imgpath, view)
global img;
j = ~contains(imgpath, '.jpg');
p = ~contains(imgpath, '.png');
J = ~contains(imgpath, '.JPG');
P = ~contains(imgpath, '.PNG');
e = ~contains(imgpath, '.jpeg');
E = ~contains(imgpath, '.JPEG');
if j || J || p || P || e || E
    img = imread(imgpath);
    img = imresize(img, [480 640]);
    axes(view);
    axis image;
    cla;
    imshow(img);
    drawnow;
else
    msgbox('Hãy chon 1 tap tin anh.', 'Luu y', 'help');
end
end

function logging(action, s, e)
global logFile;
global summary;
log = fopen(logFile, 'a+');
if s
    text = datestr(datetime('now'));
    fprintf(log, strcat(text, ': ', action, '\n'));
    tic;
elseif e
    k = toc;
    a = [action k];
    dlmwrite(summary, a, '-append');
    fprintf(log, 'cost: %f\n', k);
else
    text = datestr(datetime('now'));
    fprintf(log, strcat(text, ': ', action, '\n'));
end
fclose(log);
end

% --- Executes during object creation, after setting all properties.
function FolderView_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FolderView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes on button press in saveImage.
function saveImage_Callback(hObject, eventdata, handles)
% hObject    handle to saveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global origfile segMode;
global FGPixel BGPixel;
global maskAll;
global ptFlag;
global img;
global imgRes;
name = get(handles.userName, 'String');
imgN = strcat(origfile, '.png');
if segMode ~= 1
    if ptFlag == 0
        msgbox('Vui long danh gia diem hieu qua cho anh nay', 'Thong tin', 'help');
    else
        if ~isempty(name) && exist(handles.folder, 'dir')    
            switch segMode            
                case 2
                    loc = fullfile(handles.mr2, imgN);
                    imwrite(imgRes, loc);
                    
                case 3
                    loc = fullfile(handles.mr3, imgN);
                    locM = fullfile(handles.mk3, imgN);
                    logF = fullfile(handles.ml3, strcat(origfile, '_foreground','.csv'));
                    logB = fullfile(handles.ml3, strcat(origfile, '_background','.csv'));
                    imwrite(imgRes, loc);
                    imwrite(maskAll, locM);
        
                    csvwrite(logF, FGPixel);
                    
                    csvwrite(logB, BGPixel);
                case 4
                    loc = fullfile(handles.mr4, imgN);
                    locM = fullfile(handles.mk4, imgN);
                    logF = fullfile(handles.ml4, strcat(origfile, '_foreground','.csv'));
                    logB = fullfile(handles.ml4, strcat(origfile, '_background','.csv'));
                    imwrite(imgRes, loc);
                    imwrite(maskAll, locM);
                    
                    csvwrite(logF, FGPixel);
                    
                    csvwrite(logB, BGPixel);
            end
           
            logging(strcat('Image no.', num2str(handles.imgCount)), 0, 0);
            logging([handles.imgCount handles.mAction], 0, 1);
            list = get(handles.savedList, "String");
            temp = char(list);
            st = sprintf('__(%d)', segMode);
            s = strcat(imgN, st);
            n = strvcat(temp, s);
            set(handles.savedList, 'String', cellstr(n));
            m = length(handles.savedList.String);
            handles.savedList.Value = m;
            set(handles.checkedSave, 'Visible', 'on');
            
            handles.imgCount = handles.imgCount + 1;
            guidata(hObject, handles);
            
        else
            msgbox('Vui long dien ten va tao lai thu muc.', 'Thu lai', 'help');
        end
    end    
else
    [m, n, ~] = size(img);
    maskAll = poly2mask(floor(FGPixel(:,1)), floor(FGPixel(:,2)),m,n);
    imgRes  = drawtoImg2(maskAll, img, 1, 2);
    loc = fullfile(handles.mr1, imgN); 
    locM = fullfile(handles.mk1, imgN);
    logF = fullfile(handles.ml1, strcat(origfile, '_foreground','.csv'));
    imwrite(imgRes, loc);
    imwrite(maskAll, locM);
    csvwrite(logF, FGPixel);
    
    logging(strcat('Image no.', num2str(handles.imgCount)), 0, 0);
    logging([handles.imgCount handles.mAction], 0, 1);
    list = get(handles.savedList, "String");
    temp = char(list);
    st = sprintf('__(%d)', segMode);
    s = strcat(imgN, st);
    n = strvcat(temp, s);
    set(handles.savedList, 'String', cellstr(n));
    m = length(handles.savedList.String);
    handles.savedList.Value = m;
    set(handles.checkedSave, 'Visible', 'on');
    handles.imgCount = handles.imgCount + 1;
    guidata(hObject, handles);
    
   
end

end

% --- Executes when selected object is changed in modeSelect.
function modeSelect_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in modeSelect
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global segMode;
switch get(hObject, 'Tag')
    case 'manual'
        set(handles.description, 'String', 'Su dung chuot trai de khoanh vung Z-Line.');
        set(handles.quiz2, 'Visible', 'off');
        %set(handles.quiz1, 'Visible', 'on');
        set(handles.quiz3, 'Visible', 'off');
        set(handles.quiz4, 'Visible', 'off');
        
        segMode = 1;
    case 'unetSeg'
        set(handles.description, 'String', 'Nhan vao tung anh de cho ra hinh anh tu phan vung, khong can thao tac chuot.');
        set(handles.quiz2, 'Visible', 'on');
        %set(handles.quiz1, 'Visible', 'off');
        set(handles.quiz3, 'Visible', 'off');
        set(handles.quiz4, 'Visible', 'off');
        
        segMode = 2;
    case 'bptSeg'
        set(handles.description, 'String', 'Su dung chuot trai de danh dau vung thuoc Z-Line va chuot phai de danh dau vung khong thuoc Z-Line.');
        set(handles.quiz2, 'Visible', 'off');
        %set(handles.quiz1, 'Visible', 'off');
        set(handles.quiz3, 'Visible', 'off');
        set(handles.quiz4, 'Visible', 'on');
       
        segMode = 3;
    case 'bptUnetSeg'
        set(handles.description, 'String', 'Su dung chuot trai de danh dau vung thuoc Z-Line va chuot phai de danh dau vung khong thuoc Z-Line, chi danh dau trong vung mau trang.');
        set(handles.quiz2, 'Visible', 'off');
        %set(handles.quiz1, 'Visible', 'off');
        set(handles.quiz3, 'Visible', 'on');
        set(handles.quiz4, 'Visible', 'off');
        
        segMode = 4;
end
cla(handles.ImageView);
end




% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject,  eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global paintFlag;
paintFlag = 0;
global origfile;

origfile = '';
guidata(hObject, handles);
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global x0 y0 x y paintFlag origfile;

paintFlag = 1;
cp = get(handles.ImageView, 'CurrentPoint');
x = cp(1,1);
y = cp(1,2);
if x > 640 || y > 480 || x < 0 || y < 0
    set(handles.ImageView, 'XLim', [0 640], 'YLim', [0 480]);
end
handles.redColor = [1 1 0];
handles.blueColor = [0 0 1];
guidata(hObject, handles);

if isempty(origfile)
    paintFlag = 0;
end

if paintFlag
    handles.brushCount = handles.brushCount + 1;
    mouse = get(hObject, 'SelectionType');
    switch mouse
        case 'normal'
            plot(handles.ImageView, x, y, 'Color', handles.redColor);
            handles.mAction(1) = handles.mAction(1) + 1;
            logging(strcat('Foreground #', num2str(handles.brushCount)) , 0, 0);
        case 'alt'
            plot(handles.ImageView, x, y, 'Color', handles.blueColor);
            handles.mAction(2) = handles.mAction(2) + 1;
            logging(strcat('Background #', num2str(handles.brushCount)) , 0, 0);
    end
end
x0 = x;
y0 = y;
guidata(hObject, handles);
end


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global x0 y0 x y paintFlag FGPixel BGPixel;
global segMode;


x0 = x;
y0 = y;
cp = get(handles.ImageView, 'CurrentPoint');
x = cp(1,1);
y = cp(1,2);

if x > 640 || y > 480 || x < 0 || y < 0
    paintFlag = 0;
end

if paintFlag
    handles.lineWidth = str2num(get(handles.sizeBrush, 'String'));
    switch get(hObject, 'SelectionType')
        
        case 'normal'
            if segMode ~= 2
                plot(handles.ImageView, [x0 x], [y0 y], 'LineWidth', handles.lineWidth, 'Color', handles.redColor);
                FGPixel = vertcat(FGPixel, [x y handles.brushCount]);
            end
        case 'alt'
            if segMode == 3 || segMode == 4
                plot(handles.ImageView, [x0 x], [y0 y], 'LineWidth', handles.lineWidth, 'Color', handles.blueColor);
                BGPixel = vertcat(BGPixel, [x y handles.brushCount]);
            end
    end
end


guidata(hObject, handles);
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global paintFlag sp spAll img FGPixel BGPixel Z segRefine segMode;

global maskAll;
global imgRes;

alpha = str2num(get(handles.alpha, 'String'));
color = get(handles.colorChosen, 'Value');
cp = get(handles.ImageView, 'CurrentPoint');
x = cp(1,1);
y = cp(1,2);
if x > 640 || y > 480 || x < 0 || y < 0
    paintFlag = 0;
end
if paintFlag
    if (segMode == 3 || segMode == 4) && (handles.mAction(1) >= 1) && (handles.mAction(2) >=1)
        if segMode == 4
            sp = segRefine;
        end
        FGMark = getRegID(sp, floor(FGPixel(:, 1:2)));
        BGMark = getRegID(sp, floor(BGPixel(:, 1:2)));
        [FGMark, BGMark] = refineMarkers(FGMark, BGMark);
        segID = segmentBPT(Z, FGMark, BGMark);
        if segMode ==4
            
                FGMark = getRegID(spAll, floor(FGPixel(:, 1:2)));
                mask2 = drawtoImg(FGMark, spAll);
            
            segID = unique(segID);
            mask1 = drawtoImg(segID, sp);
            
            maskAll = (mask1 == 1) | (mask2 == 1);
            imgRes = drawtoImg2(maskAll, img, alpha, color);
            
        elseif segMode == 3
            %if max(FGPixel(:, 3)) > max(BGPixel(:, 3))
                segID = [FGMark; segID'];
            %else
            %    segID = [BGMark; segID'];
            %end
            segID = unique(segID);
            maskAll = drawtoImg(segID, sp);
            imgRes = drawtoImg2(maskAll, img, alpha, color);
            
        end
        axes(handles.ImageView);
        imshow(imgRes);
        
        logging('BPT', 0, 0);
    end
    
end

paintFlag = 0;

end


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
% if strcmp(eventdata.Modifier, 'control') 
%     switch eventdata.Key
%         case 'z'
%             items = findobj(handles.ImageView, 'Type', 'Line');
%             delete(items(1));
%         case 'v'
%             delete(findobj(handles.ImageView, 'Type', 'Line'));
%     end
% else
%     index = get(handles.FolderView, 'Value');
%     switch eventdata.Key
%         case 'up'
%             index = index + 1;
%             set(handles.FolderView, 'Value', index);
%             ShowImage(strcat(handles.FolderName, handles.fileList{index}), handles.ImageView);
%         case 'down'
%             index = index - 1;
%             set(handles.FolderView, 'Value', index);
%             ShowImage(strcat(handles.FolderName, handles.fileList{index}), handles.ImageView);
%     end
% end
end

% % --- Executes on button press in clearAll.
% function clearAll_Callback(hObject, eventdata, handles)
% % hObject    handle to clearAll (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% global segMode sp FGPixel BGPixel origfile img imgDraw segRefine;
% nRegion = 500;
% FGPixel = [];
% BGPixel = [];
% handles.mAction = [0 0];
% handles.brushCount = 0;
% f = waitbar(0,'Xin hay doi');
% switch segMode
%     case 1
%         delete(findobj(handles.ImageView, 'Type', 'Line'));
%     case 3
%         waitbar(.5,f,'Xin hay doi');
%         %% create super pixels
%         sp  = mexGenerateSuperPixel(double(img), nRegion);
%         %%% draw regions on original images
%         [imgDraw, feat] = segToImg2(img,sp);
%         Y = pdist(feat);
%         Z = linkage(Y);
%     case 4
%         %% create super pixels
%          %% create super pixels
%         waitbar(.5, f, 'Xin hay doi...');
%         UnetPredict = double(imread(fullfile(handles.predictFolder,strcat(origfile,'_predict.png'))));
%         
%         [temp, UnetPredictMask] = SegbyUnet(img, UnetPredict, 100);
%         
%         sp  = mexGenerateSuperPixel(double(img), nRegion, 10);
%         sp = sp + 1;
%         [imgDraw, feat, segRefine] = segToImg3(img, sp, UnetPredict, UnetPredictMask);
%         Y = pdist(feat);
%         Z = linkage(Y);
%         size(Z);
%         axes(handles.ImageView);
%         drawnow;
%         imshow(imgDraw);
%         
%     case 2
%         waitbar(.5,f,'Xin hay doi');        
%         UnetPredict =double(imread(fullfile(handles.predictFolder,strcat(origfile,'_predict.png'))));
%         
%         imgRes = SegbyUnet(img,UnetPredict, 100);
%         axes(handles.ImageView);
%         drawnow;
%         imshow((imgRes));
% end
% waitbar(1,f,'Da xong');
% close(f);
% logging('Clear all', 0, 0);
% 
% 
% end


% --- Executes on button press in zoomEnabled.
function zoomEnabled_Callback(hObject, eventdata, handles)
% hObject    handle to zoomEnabled (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zoomEnabled
global enabled;
switch get(hObject, 'Value')
    case 1
        handles.ImageView;
        zoom on;
        logging('zoom on', 0, 0);
    case 0
        handles.ImageView;
        zoom off;
        logging('zoom off', 0, 0);
end
end

% --- Executes on key press with focus on FolderView and none of its controls.
function FolderView_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to FolderView (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

end



function sizeBrush_Callback(hObject, eventdata, handles)
% hObject    handle to sizeBrush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sizeBrush as text
%        str2double(get(hObject,'String')) returns contents of sizeBrush as a double

end
% --- Executes during object creation, after setting all properties.
function sizeBrush_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sizeBrush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function opaBrush_Callback(hObject, eventdata, handles)
% hObject    handle to opaBrush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of opaBrush as text
%        str2double(get(hObject,'String')) returns contents of opaBrush as a double


end
% --- Executes during object creation, after setting all properties.
function opaBrush_CreateFcn(hObject, eventdata, handles)
% hObject    handle to opaBrush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in USizeB.
function USizeB_Callback(hObject, eventdata, handles)
% hObject    handle to USizeB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
size = get(handles.sizeBrush, 'String');
num = str2num(size);
num = num + 1;
set(handles.sizeBrush, 'String', num2str(num));
end
% --- Executes on button press in DSizeB.
function DSizeB_Callback(hObject, eventdata, handles)
% hObject    handle to DSizeB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
size = get(handles.sizeBrush, 'String');
num = str2num(size);
num = num - 1;
if num < 0
    num = 0;
end
set(handles.sizeBrush, 'String', num2str(num));
end


function userName_Callback(hObject, eventdata, handles)
% hObject    handle to userName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of userName as text
%        str2double(get(hObject,'String')) returns contents of userName as a double

end
% --- Executes during object creation, after setting all properties.
function userName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to userName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes when selected object is changed in quiz3.
function quiz3_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in quiz3 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%global ptFile;
global ptFlag;
switch get(hObject, 'Tag')
    case 'zero4'
        points = 0;
    case 'radiobutton29'
        points = 1;
    case 'radiobutton30'
        points = 2;
    case 'radiobutton31'
        points = 3;
    case 'radiobutton32'
        points = 4;
    case 'radiobutton33'
        points = 5; 
    case 'radiobutton34'
        points = 6;
    case 'radiobutton35'
        points = 7;
    case 'radiobutton36'
        points = 8;
    case 'radiobutton37'
        points = 9;
    case 'radiobutton38'
        points = 10;
end
ptFlag = 1;
p = sprintf('%d points', points);
logging(p, 0, 0);
end
% --- Executes when selected object is changed in quiz1.
function quiz1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in quiz1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% global ptFlag;
% switch get(hObject, 'Tag')
%     case 'radiobutton9'
%         points = 1;
%     case 'radiobutton10'
%         points = 2;
%     case 'radiobutton11'
%         points = 3;
%     case 'radiobutton12'
%         points = 4;
%     case 'radiobutton13'
%         points = 5; 
%     case 'radiobutton14'
%         points = 6;
%     case 'radiobutton15'
%         points = 7;
%     case 'radiobutton16'
%         points = 8;
%     case 'radiobutton17'
%         points = 9;
%     case 'radiobutton18'
%         points = 10;
% end
% ptFlag = 1;
% p = sprintf('%d points', points);
% logging(p, 0, 0);
end
% --- Executes when selected object is changed in quiz2.
function quiz2_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in quiz2 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global ptFlag;
switch get(hObject, 'Tag')
    case 'zero1'
        points = 0;
    case 'radiobutton19'
        points = 1;
    case 'radiobutton20'
        points = 2;
    case 'radiobutton21'
        points = 3;
    case 'radiobutton22'
        points = 4;
    case 'radiobutton23'
        points = 5; 
    case 'radiobutton24'
        points = 6;
    case 'radiobutton25'
        points = 7;
    case 'radiobutton26'
        points = 8;
    case 'radiobutton27'
        points = 9;
    case 'radiobutton28'
        points = 10;
end
ptFlag = 1;
p = sprintf('%d points', points);
logging(p, 0, 0);
end
% --- Executes when selected object is changed in quiz4.
function quiz4_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in quiz4 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%global ptFile;
global ptFlag;
switch get(hObject, 'Tag')
    case 'zero3'
        points = 0;
    case 'radiobutton39'
        points = 1;
    case 'radiobutton40'
        points = 2;
    case 'radiobutton41'
        points = 3;
    case 'radiobutton42'
        points = 4;
    case 'radiobutton43'
        points = 5; 
    case 'radiobutton44'
        points = 6;
    case 'radiobutton45'
        points = 7;
    case 'radiobutton46'
        points = 8;
    case 'radiobutton47'
        points = 9;
    case 'radiobutton48'
        points = 10;
end
ptFlag = 1;
p = sprintf('%d points', points);
logging(p, 0, 0);
end



function commentBox_Callback(hObject, eventdata, handles)
% hObject    handle to commentBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of commentBox as text
%        str2double(get(hObject,'String')) returns contents of commentBox as a double

end
% --- Executes during object creation, after setting all properties.
function commentBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to commentBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in .
function redraw_Callback(hObject, eventdata, handles)
% hObject    handle to redraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FGPixel BGPixel segMode;
global sp spAll;
global img imgRes;
global maskAll;
global Z;
global segRefine;

alpha = str2num(get(handles.alpha, 'String'));
color = get(handles.colorChosen, 'Value');
if segMode == 1
    item = findobj(handles.ImageView, 'Type', 'Line');
    delete(item(1));
else
    %[uFGr, uFGc] = find(FGPixel(:, 3) == handles.brushCount, 1);
    idxFG = find(FGPixel(:, 3) == handles.brushCount);
    if ~isempty(idxFG)
        %FGPixel(uFGr:end, :) = [];
        %disp(FGPixel);
        FGPixel(idxFG, :) = [];
        handles.brushCount = handles.brushCount - 1;
        handles.mAction(1) = handles.mAction(1) - 1;
        guidata(hObject, handles);
        logging(strcat('Delete F#', num2str(handles.brushCount)), 0, 0)
    else
        %[uBGr, uBGc] = find(BGPixel(:, 3) == handles.brushCount, 1);
        idxBG = find(BGPixel(:, 3) == handles.brushCount);        
        BGPixel(idxBG, :) = [];
        handles.brushCount = handles.brushCount - 1;
        handles.mAction(2) = handles.mAction(2) - 1;
        guidata(hObject, handles);
        logging(strcat('Delete B#', num2str(handles.brushCount)), 0, 0)
    end
    if (segMode == 3 || segMode == 4) && (handles.mAction(1) >= 1) && (handles.mAction(2) >=1)
        if segMode == 4
            sp = segRefine; 
        end
        FGMark = getRegID(sp, floor(FGPixel(:, 1:2)));
        BGMark = getRegID(sp, floor(BGPixel(:, 1:2)));
        
        [FGMark, BGMark] = refineMarkers(FGMark, BGMark);
        
        segID = segmentBPT(Z, FGMark, BGMark);
        
        if segMode ==4
            FGMark = getRegID(spAll, floor(FGPixel(:, 1:2)));
            segID = unique(segID);
            mask1 = drawtoImg(segID, sp);
            mask2 = drawtoImg(FGMark, spAll);
            maskAll = (mask1 == 1) | (mask2 == 1);
            imgRes = drawtoImg2(maskAll, img, alpha, color);
        elseif segMode == 3
            segID = [FGMark; segID'];
            segID = unique(segID);
            maskAll = drawtoImg(segID, sp);
            imgRes = drawtoImg2(maskAll, img, alpha, color);
        end
        axes(handles.ImageView);
        imshow(imgRes);
        %guidata(hObject, handles);
        logging('BPT', 0, 0);
        
    end
end
end


% --- Executes on button press in saveComments.
function saveComments_Callback(hObject, eventdata, handles)
% hObject    handle to saveComments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveComments
global cmtFile;
%cmtText = fullfile(handles.folder, strcat('comment', '_', num2str(handles.cmtCount), '.txt'));
cmtText = fopen(cmtFile, 'w+');
text = get(handles.commentBox, 'String');
fprintf(cmtText, text);
fclose(cmtText);
guidata(hObject, handles);
set(handles.text5, 'Visible', 'on');
end

% --- Executes on button press in userFolder.
function userFolder_Callback(hObject, eventdata, handles)
% hObject    handle to userFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder = './BS';
mkdir(folder);
name = get(handles.userName, 'String');
if ~isempty(name)
    handles.folder = fullfile(folder, name);    
    guidata(hObject, handles);
    if ~exist(handles.folder, 'dir')
        handles.imgCount = 1;
        mode1 = 'Khoanh bang tay';
        mode2 = 'Tu dong';
        mode3 = 'Danh dau vung';
        mode4 = 'Tu dong va danh dau vung';
        
        
        result = 'Results';
        %marker = 'Marker';
        mask = 'Mask';
        logFol = 'Logs';
        %saved = 'saved.txt';
       
        % mode 1
        handles.mk1 = fullfile(handles.folder, mode1, mask);
        handles.mr1 = fullfile(handles.folder, mode1, result);
        handles.ml1 = fullfile(handles.folder, mode1, logFol);
        %handles.saved1 = fullfile(handles.ml1, saved);
        mkdir(handles.mr1);
        mkdir(handles.ml1);
        mkdir(handles.mk1);
        
        % mode 2
        handles.mk2 = fullfile(handles.folder, mode2, mask);
        handles.mr2 = fullfile(handles.folder, mode2, result);
        handles.ml2 = fullfile(handles.folder, mode2, logFol);
        %handles.saved2 = fullfile(handles.ml2, saved);
        mkdir(handles.mk2);
        mkdir(handles.mr2);
        mkdir(handles.ml2);
        
        % mode 3
        %handles.mm3 = fullfile(handles.folder, mode3, marker);
        handles.mk3 = fullfile(handles.folder, mode3, mask);
        handles.mr3 = fullfile(handles.folder, mode3, result);
        handles.ml3 = fullfile(handles.folder, mode3, logFol);
        %handles.saved3 = fullfile(handles.ml3, saved);
        %mkdir(handles.mm3);
        mkdir(handles.mk3);
        mkdir(handles.mr3);
        mkdir(handles.ml3);
        
        % mode 4
        %handles.mm4 = fullfile(handles.folder, mode4, marker);
        handles.mk4 = fullfile(handles.folder, mode4, mask);
        handles.mr4 = fullfile(handles.folder, mode4, result);
        handles.ml4 = fullfile(handles.folder, mode4, logFol);
        %handles.saved4 = fullfile(handles.ml4, saved);
        %mkdir(handles.mm4);
        mkdir(handles.mk4);
        mkdir(handles.mr4);
        mkdir(handles.ml4);
        guidata(hObject, handles);
        
        set(handles.description, 'String', ...
            sprintf('Da tao thu muc cua nguoi dung %s, hay chon 1 thu muc anh', name));
        set(handles.savedList, 'String', []);
    else
        msgbox('Vui long nhap ten khac.', 'Thong tin', 'help');
    end
else
    msgbox('Vui long nhap ten.', 'Thông tin', 'help');
end


end




% --- Executes on selection change in savedList.
function savedList_Callback(hObject, eventdata, handles)
% hObject    handle to savedList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns savedList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from savedList

indexSelected = get(handles.savedList, 'Value');
fileList = get(handles.savedList, 'String');
fileName = fileList{indexSelected};
k = str2num(fileName(end-1));
fileName = fileName(1:end-5);
switch k
    case 1
        f = fullfile(handles.mr1, fileName);
    case 2
        f = fullfile(handles.mr2, fileName);
    case 3
        f = fullfile(handles.mr3, fileName);
    case 4
        f = fullfile(handles.mr4, fileName);
end
image = imread(f);
axes(handles.ImageView);
imshow(image);
drawnow;
a = sprintf('Neu ban muon sua anh nay, click vao ten cua anh nay o trong danh sach ben trai roi sua va luu lai.');
set(handles.description, 'String', a);
end
% --- Executes during object creation, after setting all properties.
function savedList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savedList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end





% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end



function alpha_Callback(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alpha as text
%        str2double(get(hObject,'String')) returns contents of alpha as a double

end
% --- Executes during object creation, after setting all properties.
function alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in UAlphaB.
function UAlphaB_Callback(hObject, eventdata, handles)
% hObject    handle to UAlphaB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
size = get(handles.alpha, 'String');
num = str2num(size);
num = num + 0.1;
if num > 1
    num = 1;
end
set(handles.alpha, 'String', num2str(num));

end
% --- Executes on button press in DAlphaB.
function DAlphaB_Callback(hObject, eventdata, handles)
% hObject    handle to DAlphaB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
size = get(handles.alpha, 'String');
num = str2num(size);
num = num - 0.1;
if num < 0
    num = 0;
end
set(handles.alpha, 'String', num2str(num));
end
% --- Executes on selection change in colorChosen.
function colorChosen_Callback(hObject, eventdata, handles)
% hObject    handle to colorChosen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns colorChosen contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colorChosen

end
% --- Executes during object creation, after setting all properties.
function colorChosen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorChosen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
