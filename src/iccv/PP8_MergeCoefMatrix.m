%Chih-Yuan Yang
%10/11/13

clear
clc
close all


arr_sf = [4];
arr_sigma = [1.6];


folder_yang13 = pwd;
folder_code = fileparts(folder_yang13);
folder_thisproject = fileparts(folder_code);
folder_dataset = fullfile(folder_thisproject,'Dataset');
folder_filelist = fullfile(folder_dataset,'FileList');
folder_feature_root = fullfile(folder_yang13,'Feature');
folder_label_root =  fullfile(folder_yang13,'Label');
folder_cluster_root =  fullfile(folder_yang13,'Cluster');
folder_regressor_root =  fullfile(folder_yang13,'Regressor');
folder_coef_root =   fullfile(folder_yang13,'Coef');
folder_num_inst_root =  fullfile(folder_yang13,'Num_Inst');
folder_image = fullfile(folder_dataset,'AllFive');
arr_filelist = U5_ReadFileNameList(fullfile(folder_filelist,'AllFive.txt'));
num_files = length(arr_filelist);

sf = arr_sf(1);
sigma = arr_sigma(1);

folder_feature = fullfile(folder_feature_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
folder_label = fullfile(folder_label_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
folder_cluster = fullfile(folder_cluster_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
folder_regressor = fullfile(folder_regressor_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
folder_num_inst = fullfile(folder_num_inst_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
folder_coef = fullfile(folder_coef_root,sprintf('sf%d',sf),sprintf('sigma%.1f',sigma));
U22_makeifnotexist(folder_coef);

fn_save = sprintf('coef_matrix_sf%d_sigma%.1f.mat',sf,sigma);
length_targetfeature = (sf*3)^2;
coef_matrix = zeros(length_targetfeature,45+1,4096);
for idx_label = 1:4096
    fprintf('idx %d\n',idx_label);
    fn_regressor_single = sprintf('Regressor_%d.mat',idx_label);
    if exist(fullfile(folder_regressor,fn_regressor_single),'file')
        loaddata = load(fullfile(folder_regressor,fn_regressor_single),'coef_matrix');
        for i=1:length_targetfeature
            coef_matrix(i,:,idx_label) = loaddata.coef_matrix{i}';
        end
    end
end
save(fullfile(folder_coef,fn_save),'coef_matrix');
