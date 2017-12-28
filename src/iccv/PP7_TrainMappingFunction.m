%Chih-Yuan Yang
%10/10/13
%Modify the code from PP7o of ICCV13
%The file should run after PP4, when all features are labeled
%It is best to run this code on a 32G machine rather than 24G machine, when
%the scaling factor is 2
clear
close all
clc

arr_sf = [4];
arr_sigma = [1.6];

folder_yang13 = pwd;
folder_code = fileparts(folder_yang13);
folder_thisproject = fileparts(folder_code);
folder_dataset = fullfile(folder_thisproject,'Dataset');
folder_filelist = fullfile(folder_dataset,'FileList');
folder_feature_root = fullfile(folder_yang13,'Feature');
folder_position_root = fullfile(folder_yang13,'Position');
folder_label_root =  fullfile(folder_yang13,'Label');
folder_cluster_root =  fullfile(folder_yang13,'Cluster');
folder_regressor_root =  fullfile(folder_yang13,'Regressor');
folder_num_inst_root =  fullfile(folder_yang13,'Num_Inst');
folder_image = fullfile(folder_dataset,'AllFive');
arr_filelist = U5_ReadFileNameList(fullfile(folder_filelist,'AllFive.txt'));
num_files = length(arr_filelist);

sf = arr_sf(1);
sigma = arr_sigma(1);

folder_feature = fullfile(folder_feature_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
folder_position = fullfile(folder_position_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
folder_label = fullfile(folder_label_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
folder_cluster = fullfile(folder_cluster_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
folder_regressor = fullfile(folder_regressor_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
folder_num_inst = fullfile(folder_num_inst_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
U22_makeifnotexist(folder_regressor);
U22_makeifnotexist(folder_num_inst);

%load all raw image into memory
%fprintf('loading preload mat\n');
%folder_preload = fullfile(folder_dataset, 'PreloadMat');
%fn_preloadmat = 'arr_img_hr_ui8_AllFive.mat';
%load(fullfile(folder_preload,fn_preloadmat),'arr_img_hr_ui8');
arr_img_hr_ui8 = cell(num_files,1);
for idx_image = 1:num_files
    fn_raw = arr_filelist{idx_image};
    fprintf('load image %d %s\n',idx_image,fn_raw);
    img_read = imread(fullfile(folder_image,fn_raw));
    arr_img_hr_ui8{idx_image} = rgb2gray(img_read);
end
clear img_read

%It takes too much memory here when scaling factor is 2, 24G memory is
%insufficient convert to LR generate the LR image when needed
arr_img_lr = cell(num_files,1);
num_pre_computed_lr_image = 2000;
for idx_image = 1:num_pre_computed_lr_image
    fn_raw = arr_filelist{idx_image};
    fprintf('convert to lr image %d %s\n',idx_image,fn_raw);
    arr_img_lr{idx_image} = F19c_GenerateLRImage_GaussianKernel(arr_img_hr_ui8{idx_image},sf,sigma);
end

%load label
arr_labels = cell(num_files,1);
for idx_image = 1:num_files
    fn_raw = arr_filelist{idx_image};
    fn_short = fn_raw(1:end-4);
    fn_label = sprintf('%s_label.mat',fn_short);
    fprintf('load label %d %s\n',idx_image,fn_label);
    loaddata = load(fullfile(folder_label,fn_label),'arr_label');
    arr_labels{idx_image} = uint16(loaddata.arr_label);      %to save space
end

%load position
arr_position = cell(num_files,1);
for idx_image = 1:num_files
    fn_raw = arr_filelist{idx_image};
    fn_short = fn_raw(1:end-4);
    fn_position = sprintf('%s_position.mat',fn_short);
    fprintf('load position %d %s\n',idx_image,fn_position);
    loaddata = load(fullfile(folder_position,fn_position),'table_position_center');
    arr_position{idx_image} = uint16(loaddata.table_position_center);     %to save sapce
end

ps = 7;     %patch size
featurelength_lr = 45;
featurelength_hr = (3*sf)^2;
patchtovectorindexset = [2:6 8:42 44:48];
patchsize_half = (ps-1)/2;

thd_sufficient = 1000;
idx_label_start = 1;
idx_label_end = 4096;

warning('off','MATLAB:rankDeficientMatrix');

for idx_label = idx_label_start:idx_label_end
    %check, if a label is being worked by a thread, skip to the next label
    fn_regressor = sprintf('Regressor_%d.mat',idx_label);
    fn_full = fullfile(folder_regressor,fn_regressor);
    if ~exist(fn_full,'file')
        fid = fopen(fn_full,'w+');
        fclose(fid);
        fprintf('running %s\n',fn_full);
    else
        fprintf('skip %s\n',fn_full);
        continue
    end

    feature_accu = [];
    targetvalue_accu = [];
    coef_matrix = cell(1,featurelength_hr);
    idx_inst = 0;
    for idx_image = 1:num_files
        arr_match = arr_labels{idx_image} == idx_label;
        if nnz( arr_match) > 0
            %extract the feature from raw image
            img_hr = im2double(arr_img_hr_ui8{idx_image});
            if idx_image <= num_pre_computed_lr_image
                img_lr = arr_img_lr{idx_image};
            else
                img_lr = F19c_GenerateLRImage_GaussianKernel(img_hr,sf,sigma);
            end
            [h_lr, w_lr] = size(img_lr);
            set_match = find(arr_match);
            num_set_inst = length(set_match);
            %find the r,c by set_match;
            for idx_set_inst = 1:num_set_inst
                r = arr_position{idx_image}(1,set_match(idx_set_inst));
                c = arr_position{idx_image}(2,set_match(idx_set_inst));
                r1 = r-1;
                r2 = r+1;
                c1 = c-1;
                c2 = c+1;
                rh = (r1-1)*sf+1;        %why is this 2? I want the 12x12, maybe there is a typo of the previous version
                rh1 = r2*sf;
                ch = (c1-1)*sf+1;
                ch1 = c2*sf;
                patch_lr = img_lr(r-patchsize_half:r+patchsize_half,c-patchsize_half:c+patchsize_half);
                vector_lr_excludeedge = patch_lr(patchtovectorindexset);
                vector_mean = mean(vector_lr_excludeedge);
                idx_inst = idx_inst + 1;
                feature_accu(idx_inst,:) = vector_lr_excludeedge - vector_mean;
                patch_hr = img_hr(rh:rh1,ch:ch1);
                diff_hr = patch_hr - vector_mean;
                targetvalue_accu(idx_inst,:) = reshape(diff_hr,[featurelength_hr,1]);
            end
        end
        if idx_inst >= thd_sufficient
            break   %break the idx_image loop
        end
    end
    %train the regressor
    A = [feature_accu ones(idx_inst,1)];
    if ~isempty(A)
        for j=1:featurelength_hr
            B = targetvalue_accu(:,j);
            coef = A\B;                         %I need to control here
            coef_matrix{j} = coef;
        end
    else
        %it is possible that the k-mean method generates 4097 cluster centers
        for j=1:featurelength_hr
            coef_matrix{j} = zeros(featurelength_lr+1,1);
        end
    end
    %save this regressor
    num_inst = idx_inst;
    save(fullfile(folder_regressor,fn_regressor),'coef_matrix','num_inst');
    fn_save = sprintf('num_inst_%d.mat',idx_label);
    save(fullfile(folder_num_inst,fn_save),'num_inst');
    
end

