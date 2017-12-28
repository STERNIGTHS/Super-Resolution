%Chih-Yuan Yang
%12/14/13
%Generate filelist

clear
close all
clc

%fn_filenamelist = 'BSD200.txt';
%foldername_process = fullfile('BSD200_Input','sf4','sigma1.6');
fn_filenamelist = 'Benchmark.txt';
foldername_process = fullfile('Benchmark_Input','sf4','sigma1.6');
%fn_filenamelist = 'AllFive.txt';
%foldername_process = fullfile('Dataset','AllFive');
fileext{1}= '.jpg';
sortnumberfilename(1) = true;
fileext{2}= '.png';
sortnumberfilename(2) = true;
fileext{3}= '.bmp';
sortnumberfilename(3) = false;



folder_ours = pwd;
folder_code = fileparts(pwd);
folder_thisproject = fileparts(folder_code);
folder_dataset = fullfile(folder_thisproject,'Dataset');
folder_source = fullfile(folder_dataset,foldername_process);
folder_filenamelist = fullfile(folder_dataset,'FileList');
%
fileextnumber = length(fileext);

fid = fopen(fullfile(folder_filenamelist,fn_filenamelist),'w+');
totalidx = 0;
for i=1:fileextnumber
    filelist = dir(fullfile(folder_source,['*' fileext{i}])); %color images
    if sortnumberfilename(i)
        filelist = F23_SortFileListByNumber(filelist,fileext{i});
    end
    filenumber = length(filelist);
    for j=1:filenumber
        totalidx = totalidx + 1;
        fprintf(fid,'%d %s\n',totalidx,filelist(j).name);
    end
end
fclose(fid);
