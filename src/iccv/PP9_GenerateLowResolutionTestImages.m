%Chih-Yuan Yang
%11/24/2015
%PP9: This file is used to generate low-resoltuion test images under a
%range of scaling factor (2~8) and a range of Gaussian kernel width
%(0.4~2.0).

clear
close all
clc

folder_pwd = pwd;
folder_code = fileparts(pwd);
folder_project = fileparts(folder_code);
folder_dataset = fullfile(folder_project,'Dataset');
folder_filenamelist = fullfile(folder_dataset,'FileList');
%folder_images_lowresolution = fullfile(folder_dataset,'BSD200_Input');
%fn_filenamelist = 'BSD200.txt';
%folder_source = fullfile(folder_dataset,'BSD200_GroundTruth');
folder_images_lowresolution = fullfile(folder_dataset,'Benchmark_Input');
fn_filenamelist = 'Benchmark.txt';
folder_source = fullfile(folder_dataset,'Benchmark_GroundTruth');

%load filenamelist
list_filename = U5_ReadFileNameList(fullfile(folder_filenamelist,fn_filenamelist));
num_file = length(list_filename);
arr_sigma = [0.4, 0.6, 0.8,1.0,1.2,1.4,1.6,1.8, 2.0];
arr_sf = [2,3,4,5,6,8];
num_sf = length(arr_sf);
num_sigma = length(arr_sigma);
for idx_sf = 1:num_sf
    sf = arr_sf(idx_sf);
    foldername_sf = sprintf('sf%d',sf);
    folder_sf = fullfile(folder_images_lowresolution,foldername_sf);
    for idx_sigma = 1:num_sigma
        sigma = arr_sigma(idx_sigma);
        hsize = ceil(3*sigma)*2+1;
        kernel = fspecial('gaussian',hsize,sigma);
        foldername_sigma = sprintf('sigma%0.1f',sigma);
        folder_sigma = fullfile(folder_sf,foldername_sigma);
        for idx_file = 1:num_file
            fn_name = list_filename{idx_file};
            fn_short = fn_name(1:end-4);
            img_gt = im2double(imread(fullfile(folder_source,fn_name)));
            img_lr = F19c_GenerateLRImage_GaussianKernel(img_gt,sf,sigma);
            %save file option
            fn_write = sprintf('%s.png',fn_short);
            U22_makeifnotexist(folder_sigma);
            imwrite(img_lr,fullfile(folder_sigma,fn_write));
        end
    end
end