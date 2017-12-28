%Chih-Yuan Yang
%10/12/13
%Distribute the computational load to extract the feature for clustering


clear
close all
clc

%setting
arr_sf = [4];
arr_sigma = [1.6];

if ispc
    folder_yang13_remote = '\\Chih-Yuan-PC\v1.2\Code\Yang13';
elseif isunix
    folder_yang13_remote = '/mnt/Chih-Yuan-PC/v1.2/Code/Yang13';
end


folder_yang13 = folder_yang13_remote;
addpath(folder_yang13_remote);
folder_code = fileparts(folder_yang13);
folder_thisproject = fileparts(folder_code);
folder_dataset = fullfile(folder_thisproject,'Dataset');
folder_filelist = fullfile(folder_dataset,'FileList');
folder_cluster_root = fullfile(folder_yang13,'Cluster');        %to save the randon select
folder_feature_root = fullfile(folder_yang13,'Feature');
folder_position_root = fullfile(folder_yang13,'Position');
folder_image = fullfile(folder_dataset,'AllFive');
fn_filelist = 'AllFive.txt';

arr_filelist = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_filelist);

featurelength_lr = 45;

num_sf = length(arr_sf);
num_sigma = length(arr_sigma);
for idx_sf = 1:num_sf
    sf = arr_sf(idx_sf);

    %I need one sigma value to read the position mat file
    for idx_sigma = 1:num_sigma
        sigma = arr_sigma(idx_sigma);

        %load record_patch_for_cluster
        folder_feature = fullfile(folder_feature_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
        U22_makeifnotexist(folder_feature);
        folder_cluster = fullfile(folder_cluster_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
        fn_record = sprintf('record_patch_for_cluster_sf%d_sigma%.1f.mat',sf,sigma);
        load(fullfile(folder_cluster,fn_record),'record_patch_for_cluster');
        num_patch_to_train_cluster_center = size(record_patch_for_cluster,1);

        %determine which files to load
        arr_file_idx_to_load = unique(record_patch_for_cluster(:,1));
        num_file_idx_to_load = length(arr_file_idx_to_load);
        data_to_train_cluster = zeros(num_patch_to_train_cluster_center,featurelength_lr);
        
        for idx_used = 1:num_file_idx_to_load
            idx_file = arr_file_idx_to_load(idx_used);
            %check whether the file exist
            fn_raw = arr_filelist{idx_file};
            fn_short = fn_raw(1:end-4);
            fn_feature = sprintf('%s_feature.mat',fn_short);
            fn_full = fullfile(folder_feature,fn_feature);
            if exist(fn_full,'file')
                fprintf('idx_file:%d skip %s\n',idx_file,fn_full);
                continue
            else
                %create an empty file
                fid = fopen(fn_full,'w+');
                fclose(fid);
            end

            fprintf('processing idx_file:%d %s\n',idx_file,fn_full);
            img_hr_raw = rgb2gray(imread(fullfile(folder_image,fn_raw)));
            feature_all = F2_GenerateFeatureFromHRImage( img_hr_raw, sf, sigma);
            
            set_match = record_patch_for_cluster(:,1) == idx_file;
            set_idx_patch = record_patch_for_cluster(set_match,2);
            feature_used = feature_all(:,set_idx_patch);       %the feature_all is column vector, 
            
            %save the file
            save(fn_full,'feature_used');
        end
    end
end
