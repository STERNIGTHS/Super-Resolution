%Chih-Yuan Yang
%10/12/13
%Generate the reocrd of feature to train cluster center

clear
close all
clc

%setting
arr_sf = [4];
arr_sigma = [1.6];

folder_yang13 = pwd;
folder_code = fileparts(folder_yang13);
folder_thisproject = fileparts(folder_code);
folder_dataset = fullfile(folder_thisproject,'Dataset');
folder_filelist = fullfile(folder_dataset,'FileList');
folder_cluster_root = fullfile(folder_yang13,'Cluster');        %to save the randon select
folder_position_root = fullfile(folder_yang13,'Position');
fn_filelist = 'AllFive.txt';

arr_filelist = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_filelist);

num_sf = length(arr_sf);
num_sigma = length(arr_sigma);
for idx_sf = 1:num_sf
    sf = arr_sf(idx_sf);

    %I need one sigma value to read the position mat file
    for idx_sigma = 1:num_sigma
        sigma = arr_sigma(idx_sigma);
        
        %determine folder_feature by sf and sigma
%        folder_feature = fullfile(folder_feature_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
        folder_position = fullfile(folder_position_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
        arr_num_patch_each_file = zeros(num_file,1);
        idx_file_overall = 0;
        for idx_file = 1:num_file
            fn_file = arr_filelist{idx_file};
            fn_short = fn_file(1:end-4);
            %load the position.mat to know the num_feature contained in
            %one file
            fn_position = sprintf('%s_position.mat',fn_short);
            fn_position_full = fullfile(folder_position,fn_position);
            fprintf('%d load %s\n',idx_file,fn_position_full);
            loaddata = load(fn_position_full,'table_position_center');
            num_patch = size(loaddata.table_position_center,2);
            arr_num_patch_each_file(idx_file) = num_patch;
        end
        num_patch_total = sum(arr_num_patch_each_file);

        %after knowing the total patch number, record them
        %the num_patch_total is too large, the system will be down
        num_patch_to_train_cluster_center = 2e5;
        
        seed = RandStream('mcg16807','Seed',0); 
        RandStream.setGlobalStream(seed) 
        
        arr_rand = rand(num_patch_to_train_cluster_center,1);
        arr_idx_patch_unsort = ceil(arr_rand * num_patch_total);
        arr_idx_patch = sort(arr_idx_patch_unsort,'ascend');
        %I need to fill this record
        record_patch_for_cluster = zeros(num_patch_to_train_cluster_center,2);   %idx_file, idx_patch 
        
        %conver the patch index to the format of idx_dataset, idx_file, idx_patch 
        %initial
        idx_file = 1;       %this is the index for query
        %use data in arr_num_patch_each_file
        idx_patch_overall_start = 1;
        idx_patch_overall_end = idx_patch_overall_start + arr_num_patch_each_file(idx_file) -1;
        for idx_to_fill = 1:num_patch_to_train_cluster_center
            idx_patch_overall_query = arr_idx_patch(idx_to_fill);
            while ~(idx_patch_overall_start <= idx_patch_overall_query && idx_patch_overall_query <= idx_patch_overall_end)
                idx_file = idx_file + 1;
                idx_patch_overall_start = idx_patch_overall_end + 1;
                idx_patch_overall_end = idx_patch_overall_start + arr_num_patch_each_file(idx_file) -1;
            end
            
            %use current date to fill the record
            idx_patch_in_image = idx_patch_overall_query - idx_patch_overall_start + 1;
            record_patch_for_cluster(idx_to_fill,:) = [idx_file, idx_patch_in_image];
            %end
        end
        
        %save the arr_patch_record_for_cluster
        folder_save = fullfile(folder_cluster_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
        U22_makeifnotexist(folder_save);
        fn_save = sprintf('record_patch_for_cluster_sf%d_sigma%.1f.mat',sf,sigma);
        save(fullfile(folder_save,fn_save),'record_patch_for_cluster');
    end
end



