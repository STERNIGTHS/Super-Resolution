%Chih-Yuan Yang
%10/12/13
%goal: extract LR features from images, and record the position
%when the cluster centers are known, the feature will be further labeled
clear
close all
clc

arr_sf = [4];
arr_sigma = [1.6];


if ispc
    %folder_yang13_remote = pwd;
    folder_yang13_remote = '\\Chih-Yuan-PC\v1.2\Code\Yang13';
elseif isunix
    folder_yang13_remote = '/mnt/Chih-Yuan-PC/v1.2/Code/Yang13';
end

addpath(folder_yang13_remote);
folder_yang13 = folder_yang13_remote;
folder_code = fileparts(folder_yang13);
folder_ours = fullfile(folder_code,'Ours');
addpath(folder_ours);
folder_thisproject = fileparts(folder_code);
folder_dataset = fullfile(folder_thisproject,'Dataset');
folder_filelist = fullfile(folder_dataset,'FileList');
folder_feature_root = fullfile(folder_yang13,'Feature');
folder_position_root = fullfile(folder_yang13,'Position');
folder_image = fullfile(folder_dataset,'AllFive');
fn_filelist = 'AllFive.txt';

arr_filelist = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_filelist);

patchsize = 7;     %patch size
patchsize_half = (patchsize-1)/2;
featurelength_lr = 45;
patch_to_vector_exclude_corner = [2:6 8:42 44:48];
thd = 0.05;
num_smoothgradient = 200;




num_sf = length(arr_sf);
num_sigma = length(arr_sigma);
for idx_sf = 1:num_sf
    sf = arr_sf(idx_sf);
    featurelength_hr = (sf * 3)^2;
    for idx_sigma = 1:num_sigma
        sigma = arr_sigma(idx_sigma);
        
        %determine folder_feature by sf and sigma
        folder_position = fullfile(folder_position_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
        U22_makeifnotexist(folder_position);
        %generate LR features only, the amount of HR feature is too large
        %to save in a hard drive
        %run through all images
        for idx_file = 1:num_file
            %check files, if the file exist, then skip
            fn_file = arr_filelist{idx_file};
            fn_short = fn_file(1:end-4);
            fn_position = sprintf('%s_position.mat',fn_short);
            fn_position_full = fullfile(folder_position,fn_position);
            if exist(fn_position_full,'file')
                fprintf('%d skip %s\n',idx_file, fn_position_full);
                continue
            end

            %create an empty file for parallel process
            fid = fopen(fn_position_full,'w+');
            fclose(fid);

            fprintf('%d extracting %s\n',idx_file, fn_position_full);
            %reduce some position to make the img_hr_raw consistent
            %with PP4a_TrainClusterCenter_LessHardDriveAccess
            img_hr_raw = rgb2gray(imread(fullfile(folder_image,fn_file)));
            [~, table_position_center] = F2_GenerateFeatureFromHRImage(img_hr_raw,sf,sigma);
            save(fn_position_full,'table_position_center');
        end
    end
end
