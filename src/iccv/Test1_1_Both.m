%Chih-Yuan Yang
%12/14/13
%Run Yang13's code

clc
clear
close all

folder_test = 'Test1_1';
str_appendix = '1_1';
str_method = 'Yang13';
folder_yang13 = pwd;
folder_code = fileparts(folder_yang13);
folder_project = fileparts(folder_code);
folder_lib = fullfile(folder_project,'Lib');
addpath(genpath(folder_lib));
folder_dataset = fullfile(folder_project,'Dataset');
folder_cluster_root =  fullfile(folder_yang13,'Cluster');
folder_coef_root =   fullfile(folder_yang13,'Coef');


%load filelist
folder_filenamelist = fullfile(folder_dataset,'FileList');

arr_sf =    [4];
arr_sigma = [1.6];
num_dataset = 2;
num_setting = length(arr_sf);
num_sigma = length(arr_sigma);
if num_setting ~= num_sigma
    error('num_sf should equal num_sigma');
end

%load the dictionary for all setting, but is this fair? If we know the
%simga is different, the dicionary should be training differently, right?
%Right, the dictionary matters.
for idx_dataset = 1:num_dataset
    if idx_dataset == 1
        fn_filenamelist = 'BSD200_png.txt';
        subfolder_dataset = 'BSD200_Input';
        name_dataset = 'BSD200';
    elseif idx_dataset == 2
        fn_filenamelist = 'Benchmark_png.txt';
        subfolder_dataset = 'Benchmark_Input';
        name_dataset = 'Benchmark';
    end
    list_filename = U5_ReadFileNameList(fullfile(folder_filenamelist,fn_filenamelist));
    num_file = length(list_filename);

    for idx_setting = 1:num_setting
        sf = arr_sf(idx_setting);
        foldername_sf = sprintf('sf%d',sf);
        sigma = arr_sigma(idx_setting);
        foldername_sigma = sprintf('sigma%0.1f',sigma);
        %load cluster center and coef_matrix
        folder_cluster = fullfile(folder_cluster_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
        folder_coef = fullfile(folder_coef_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
        fn_clustercenter = sprintf('ClusterCenter_sf%d_sigma%.1f.mat',sf,sigma);
        loaddata = load(fullfile(folder_cluster, fn_clustercenter),'clustercenter');
        clustercenter = loaddata.clustercenter';        %transpose, to make each feature as a column

        fn_coef_matrix = sprintf('coef_matrix_sf%d_sigma%.1f.mat',sf,sigma);
        loaddata = load(fullfile(folder_coef, fn_coef_matrix),'coef_matrix');
        coef_matrix = loaddata.coef_matrix;

        folder_source = fullfile(folder_dataset,subfolder_dataset,foldername_sf,foldername_sigma);
        folder_write = fullfile(folder_test,name_dataset,foldername_sf,foldername_sigma);
        if ~exist(folder_write,'dir')
            U22_makeifnotexist(folder_write);
            fprintf('create %s\n', folder_write);
        end
        for idx_file = 1:num_file
            fn_name = list_filename{idx_file};
            fn_short = fn_name(1:end-4);
            fn_write = sprintf('%s_%s%s.png',fn_short,str_method,str_appendix);
            fn_full = fullfile(folder_write,fn_write); 
            if exist(fn_full,'file')
                fprintf('skip %s\n', fn_full);
                continue
            else
                %create an empty file
                fid = fopen(fn_full,'w+');
                fclose(fid);

                fn_read = fn_name;
                fprintf('running %s\n',fn_full);
                img_rgb = im2double(imread(fullfile(folder_source,fn_read)));
                if size(img_rgb,3) == 3
                    img_yiq = RGB2YIQ(img_rgb);
                    img_y = img_yiq(:,:,1);
                    img_iq = img_yiq(:,:,2:3);
                    %img_hr = M1_GenerateImageYang13(img_y,sf,clustercenter,coef_matrix);
                    %M1_GenerateImageYang13
                    M1a_GenerateImageYang13_PreventBadCoef
                    %generate files here
                    img_yiq_hr = img_hr;
                    img_yiq_hr(:,:,2:3) = imresize(img_iq,sf);
                    img_rgb_hr = YIQ2RGB(img_yiq_hr);
                    imwrite(img_rgb_hr,fn_full);
                else
                    img_y = img_rgb;
                    M1a_GenerateImageYang13_PreventBadCoef
                    imwrite(img_hr,fn_full);
                end
            end
        end            
    end        
end
