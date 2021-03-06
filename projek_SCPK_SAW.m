function varargout = projek_SCPK_SAW(varargin)
% PROJEK_SCPK_SAW MATLAB code for projek_SCPK_SAW.fig
%      PROJEK_SCPK_SAW, by itself, creates a new PROJEK_SCPK_SAW or raises the existing
%      singleton*.
%
%      H = PROJEK_SCPK_SAW returns the handle to a new PROJEK_SCPK_SAW or the handle to
%      the existing singleton*.
%
%      PROJEK_SCPK_SAW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJEK_SCPK_SAW.M with the given input arguments.
%
%      PROJEK_SCPK_SAW('Property','Value',...) creates a new PROJEK_SCPK_SAW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before projek_SCPK_SAW_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to projek_SCPK_SAW_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help projek_SCPK_SAW

% Last Modified by GUIDE v2.5 24-Jun-2021 18:34:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @projek_SCPK_SAW_OpeningFcn, ...
                   'gui_OutputFcn',  @projek_SCPK_SAW_OutputFcn, ...
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


% --- Executes just before projek_SCPK_SAW is made visible.
function projek_SCPK_SAW_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to projek_SCPK_SAW (see VARARGIN)

% Choose default command line output for projek_SCPK_SAW
handles.output = hObject;

set(handles.tablekeputusan,'Data','');
set(handles.tabelrangking,'Data','');
set(handles.tabelnormalisasi,'Data','');

global baik;
global sedang;
global rusak;
global rusakberat;
global data;
global kecamatan;

baik = ' ';
sedang = ' ';
rusak = ' ';
rusakberat = ' ';
data = ' ';
kecamatan = ' ';
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes projek_SCPK_SAW wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = projek_SCPK_SAW_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadfile.
function loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data;
global kecamatan;
try
opts = detectImportOptions('data jalan rusak.csv');
opts = setvartype(opts,'Kecamatan','char');

dataKeputusan = readtable('data jalan rusak.csv', opts);
dataKeputusan = table2cell(dataKeputusan);

opts1 = detectImportOptions('data jalan rusak.csv');
opts1 = setvartype(opts1,'Baik','double');
opts1 = setvartype(opts1,'RusakBerat','double');
opts1.SelectedVariableNames = [3,4,5,6];

data = readtable('data jalan rusak.csv', opts1);
data = table2array(data);

opts2 = detectImportOptions('data jalan rusak.csv');
opts2 = setvartype(opts2,'Kecamatan','char');
opts2.SelectedVariableNames = 'Kecamatan';

kecamatan = readtable('data jalan rusak.csv', opts2);
kecamatan = table2array(kecamatan);

set(handles.tablekeputusan,'Data',dataKeputusan);
catch
    errordlg('Pastikan terdapat file data jalan rusak.csv', 'File tidak ditemukan');
end
% --- Executes on button press in carisolusi.
function carisolusi_Callback(hObject, eventdata, handles)
% hObject    handle to carisolusi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global baik;
global sedang;
global rusak;
global rusakberat;
global data;
global kecamatan;

if(data == ' ')
 errordlg('Pastikan file sudah di load', 'Data tidak ditemukan');
elseif(baik == ' ' || sedang == ' ' || rusak == ' ' || rusakberat == ' ')
    errordlg('Pastikan pembobotan sudah diisi', 'Bobot tidak ditemukan');
else
    k=[0,1,1,1];
    w=[baik, sedang, rusak, rusakberat];% bobot untuk masing-masing kriteria

    %tahapan 1. normalisasi matriks
    %matriks m x n dengan ukuran sebanyak variabel data (input)
    [m,n]=size (data); 
    R=zeros (m,n); %membuat matriks R, yang merupakan matriks kosong
    V = [m n];
    for j=1:n
        if k(j)==1 %statement untuk kriteria dengan atribut keuntungan
            R(:,j)=data(:,j)./max(data(:,j));
        else
            R(:,j)=min(data(:,j))./data(:,j);
        end
    end

    %tahapan kedua, proses perangkingan
    for i=1:m
        V(i)= sum(w.*R(i,:));
    end

    nilai = sort(V, 'descend');
    temp = strings(1,m);
    for i=1:m
      for j=1:m
        if(nilai(i) == V(j))
            temp(i) = kecamatan(j);
            break
        end
      end
    end

    hasil = strings(m,2);
    normalisasi = strings(m,5);
    for i=1:m
        normalisasi(i,1) = kecamatan(i);
        for j=1:n
            normalisasi(i,(j+1)) = R(i,j);
        end
        hasil(i,1) = temp(i);
        hasil(i,2) = nilai(i);
    end
    hasil = cellstr(hasil);
    normalisasi = cellstr(normalisasi);
    
    hasilakhir = "Perbaikan jalan di prioritaskan untuk Wilayah " + temp(1) + " terlebih dahulu.";
    
    set(handles.tabelrangking,'Data', hasil);
    set(handles.tabelnormalisasi,'Data', normalisasi);
    set(handles.hasilakhir,'String',hasilakhir);
    
    msgbox(hasilakhir,'Berhasil','help');
end



% --- Executes on button press in resetData.
function resetData_Callback(hObject, eventdata, handles)
% hObject    handle to resetData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data;
global kecamatan;

data = ' ';
kecamatan = ' ';
set(handles.tablekeputusan,'Data','');



function sedang_Callback(hObject, eventdata, handles)
% hObject    handle to sedang (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sedang as text
%        str2double(get(hObject,'String')) returns contents of sedang as a double


% --- Executes during object creation, after setting all properties.
function sedang_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sedang (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rusak_Callback(hObject, eventdata, handles)
% hObject    handle to rusak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rusak as text
%        str2double(get(hObject,'String')) returns contents of rusak as a double


% --- Executes during object creation, after setting all properties.
function rusak_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rusak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function baik_Callback(hObject, eventdata, handles)
% hObject    handle to baik (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baik as text
%        str2double(get(hObject,'String')) returns contents of baik as a double


% --- Executes during object creation, after setting all properties.
function baik_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baik (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rusakberat_Callback(hObject, eventdata, handles)
% hObject    handle to rusakberat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rusakberat as text
%        str2double(get(hObject,'String')) returns contents of rusakberat as a double


% --- Executes during object creation, after setting all properties.
function rusakberat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rusakberat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in simpanbobot.
function simpanbobot_Callback(hObject, eventdata, handles)
% hObject    handle to simpanbobot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global baik;
global sedang;
global rusak;
global rusakberat;

inputbaik = get(handles.baik,'String');
inputsedang = get(handles.sedang,'String');
inputrusak = get(handles.rusak,'String');
inputrusakberat = get(handles.rusakberat,'String');

if(isempty(inputbaik) || isempty(inputsedang) || isempty(inputrusak) || isempty(inputrusakberat))
    msgbox('Lengkapi Seluruh Pembobotan!','Gagal','error');
else
    baik = str2double(inputbaik);
    sedang = str2double(inputsedang);
    rusak = str2double(inputrusak);
    rusakberat = str2double(inputrusakberat);
    msgbox('Pembobotan Berhasil tersimpan!','Berhasil','help');
end



% --- Executes during object creation, after setting all properties.
function tabelrangking_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tabelrangking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function hasilakhir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hasilakhir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
