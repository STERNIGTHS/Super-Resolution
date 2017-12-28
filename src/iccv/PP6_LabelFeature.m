%Chih-Yuan Yang
%10/13/13

clear
close all
clc

arr_sf =    [4];
arr_sigma = [1.6];

if ispc
    folder_yang13_remote = '\\Chih-Yuan-PC\v1.2\Code\Yang13';
elseif isunix
    folder_yang13_remote = '/mnt/Chih-Yuan-PC/v1.2/Code/Yang13';
end

addpath(folder_yang13_remote)
folder_code = fileparts(folder_yang13_remote);
folder_thisproject = fileparts(folder_code);
folder_dataset = fullfile(folder_thisproject,'Dataset');
folder_filelist = fullfile(folder_dataset,'FileList');
folder_feature_root = fullfile(folder_yang13_remote,'Feature');
folder_cluster_root = fullfile(folder_yang13_remote,'Cluster');
folder_label_root = fullfile(folder_yang13_remote,'Label');
folder_allfive = fullfile(folder_dataset,'AllFive');

num_setting = length(arr_sf);
fn_filelist = 'AllFive.txt';
arr_filelist = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_filelist);

for idx_setting = 1:num_setting
    sf = arr_sf(idx_setting);
    sigma = arr_sigma(idx_setting);

    folder_cluster = fullfile(folder_cluster_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));

    %load the cluster center
    fn_load = sprintf('ClusterCenter_sf%d_sigma%.1f.mat',sf,sigma);
    loaddata = load(fullfile(folder_cluster,fn_load),'clustercenter');
    clustercenter = loaddata.clustercenter;
    num_cluster = size(clustercenter,1);
    clear loaddata

    %determine folder_feature by sf and sigma
    folder_feature = fullfile(folder_feature_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
    folder_label = fullfile(folder_label_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
    U22_makeifnotexist(folder_label);
    for idx_file = 1:num_file
        fn_raw = arr_filelist{idx_file};
        fn_short = fn_raw(1:end-4);
        fn_save = sprintf('%s_label.mat',fn_short);
        %create a file
        fn_full = fullfile(folder_label,fn_save);
        if ~exist(fn_full,'file')
            fid = fopen(fn_full,'w+');
            fclose(fid);
            fprintf('labeling %d %s\n',idx_file,fn_full);
        else
            fprintf('skip %d %s\n',idx_file,fn_full);
            continue
        end

        %label each file, and save it
        img_raw = rgb2gray(imread(fullfile(folder_allfive, fn_raw)));
        feature = F2_GenerateFeatureFromHRImage(img_raw,sf,sigma);      %each column is a feature

        num_inst = size(feature,2);
        arr_label = zeros(num_inst,1);
        for i=1:num_inst
            feature_this = feature(:,i);
            feature_this_row_type = feature_this';
            diff = repmat(feature_this_row_type,[num_cluster,1]) - clustercenter;        %each row of clustercenter is a feature
            l2norm = sqrt(sum(diff.^2,2));
            [~,idx_this] = min(l2norm);
            arr_label(i) = idx_this;
        end
        %save the result
        save(fn_full,'arr_label');
    end
end

