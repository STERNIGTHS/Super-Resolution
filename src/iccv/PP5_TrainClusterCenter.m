%Chih-Yuan Yang
%10/12/13
%load feature from folder_feature to train cluster center

clc
clear
close all

%setting
arr_sf = [4];
arr_sigma = [1.6];

folder_yang13 = pwd;
folder_code = fileparts(folder_yang13);
folder_thisproject = fileparts(folder_code);
folder_dataset = fullfile(folder_thisproject,'Dataset');
folder_filelist = fullfile(folder_dataset,'FileList');
folder_feature_root = fullfile(folder_yang13,'Feature');
folder_cluster_root = fullfile(folder_yang13,'Cluster');
fn_filelist = 'AllFive.txt';

arr_filelist = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_filelist);

num_sf = length(arr_sf);
num_sigma = length(arr_sigma);
num_patch_to_train_cluster_center = 2e5;
featurelength_lr = 45;

for idx_sf = 1:num_sf
    sf = arr_sf(idx_sf);

    %I need one sigma value to read the position mat file
    for idx_sigma = 1:num_sigma
        sigma = arr_sigma(idx_sigma);
        
        %load the training patch set
        folder_cluster = fullfile(folder_cluster_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
        fn_load = sprintf('record_patch_for_cluster_sf%d_sigma%.1f.mat',sf,sigma);
        loaddata = load(fullfile(folder_cluster,fn_load),'record_patch_for_cluster');
        record_patch_for_cluster = loaddata.record_patch_for_cluster;
        clear loaddata

        %determine folder_feature by sf and sigma
        folder_feature = fullfile(folder_feature_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
        
        arr_file_idx_to_load = unique(record_patch_for_cluster(:,1));
        num_file_idx_to_load = length(arr_file_idx_to_load);
        data_to_train_cluster = zeros(num_patch_to_train_cluster_center,featurelength_lr);
        
        idx_feature_end = 0;
        for idx_used = 1:num_file_idx_to_load
            idx_feature_start = idx_feature_end + 1;
            idx_file = arr_file_idx_to_load(idx_used);
            %check whether the file exist
            fn_raw = arr_filelist{idx_file};
            fn_short = fn_raw(1:end-4);
            fn_feature = sprintf('%s_feature.mat',fn_short);
            fn_full = fullfile(folder_feature,fn_feature);

            loaddata = load(fn_full,'feature_used');
            feature_used = loaddata.feature_used;       %here, column vector
            num_instance = size(feature_used,2);
            idx_feature_end = idx_feature_start + num_instance -1;
            data_to_train_cluster(idx_feature_start:idx_feature_end,:) = feature_used';     %here, row vector
        end
        
        %train cluster
        seed = RandStream('mcg16807','Seed',0); 
        RandStream.setGlobalStream(seed) 

        %cluster the features
        num_iteration = 100;      %use a small iteratio nnumber for sanity test
        num_cluster = 4096;
        opts = statset('Display','iter','MaxIter',num_iteration);
        %[IDX, C] = kmeans(feature_10percent,num_clusterk,'start','cluster','emptyaction','drop','options',opts);     %use uniform option to prevent randomness
        [IDX, C] = kmeans(data_to_train_cluster,num_cluster,'emptyaction','drop','options',opts);     %use uniform option to prevent randomness
        %fn_save = sprintf('ClusterResults_sf%d_sigma%.1f.mat',sf,sigma);
        %save(fullfile(folder_cluster,fn_save),'IDX','C');
        
        %save the sorted C
        arr_training_instance = hist(IDX,num_cluster);
        [arr_training_instance_sort,IX] = sort(arr_training_instance,'descend');
        clustercenter = C(IX,:);
        
        fn_save = sprintf('ClusterCenter_sf%d_sigma%.1f.mat',sf,sigma);
        save(fullfile(folder_cluster,fn_save),'clustercenter');
        
    end
end