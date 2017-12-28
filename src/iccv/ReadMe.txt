Chih-Yuan Yang
Email address: cyang35 [at] ucmerced [dot] edu
Project: Generic Single-Image Super-Resolution
09/01/2013 v1.0 first release
09/06/2013 v1.1 we add a missing file F14c_Img2Grad_fast_suppressboundary
12/12/2013 v1.2 we re-organize the code and training images, release training 
code, update the released coefficients
05/03/2014 v1.3 we release pre-trained priors for scaling factors 2, 3, 4, 5,
6, 8, and sigma values 0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0
06/30/2014 v1.4 we release the generated low-resolution test images for scaling factors 2, 3, 4, 5,
6, 8, and sigma values 0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0

==================================================
Reproduce the reported experimental results
==================================================
In order to generate SR images, a set of files is required including the cluster
centers and the regression coefficients.
The pre-trained priors are in the two folders Code\Yang13\Cluster and Code\Yang13\Coef.

The demo file is the Test1_1_Both.m, which will run two sets of images, the 
BSD200 dataset and three widely used test images: Child, Lena, and Babara.

==================================================
Training set and Pre-trained Priors
==================================================
The training image set is at Dataset\AllFive, where 6152 images are contained in total 7.6 GB. 
The pre-trained priors are 16.2 GB large covering scaling factors 2, 3, 4, 5, 6, and 8, and 
sigma values 0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, and 2.0.

==================================================
Training your own cluster centers and regression coefficients
==================================================
The set of files can generate priors using your own training set.
PP1_GenerateFileNameList.m
PP2_ExtractPosition.m
PP3_RandomSelect.m
PP4_ExtractFeatureForClustering.m
PP5_TrainClusterCenter.m
PP6_LabelFeature.m
PP7_TrainMappingFunction.m
PP8_MergeCoefMatrix.m
After running them sequentially, you should generate two files to recored 
cluster centers and regression coefficients.

Brief explanations for each file:
step(1) Run the file PP1_GenerateFileNameList.m
	A file "AllFive.txt" should be generated in the sub-folder Dataset\FileList.
	You can skip this step because I have generated and save the list file.
step(2) Run the file PP2_ExtractPosition.m
	6152 files will be generated in the sub-folder 
	Code\Yang13\Position\sf4\sigma1.6. 	These files indicate the locations of 
	non-smooth LR patches. I do not extract features at this step because it is 
	time consuming. In order to compute the cluster centers using a randomly 
	selected subset, I record the locations of LR patches only. If you have 
	multiple machines with MATLAB, you can make the folder v1.2 as a share 
	folder, and run this file from remote machines to increase the throughput. 
	Remember to set correct share folder address on line 14 for Windows or line 
	16 for Linux.
step(3) Run the file PP3_RandomSelect.m
	The randomly selected subset of LR patches will be saved as the file
	Cluster\sf4\sigma1.6\record_patch_for_cluster_sf4_sigma1.6.mat
step(4) Run the file PP4_ExtractFeatureForClustering.m
	The LR patch features for training cluster centers will be extracted and 
	saved in the sub-folder Feature\sf4\sigma1.6. Similar to 
	PP2_ExtractPosition.m, this file can be executed in parallel by multiple 
	MATLAB instances using a sharing folder to increase the throughput.
step(5) Run the file PP5_TrainClusterCenter.m. Ensure sufficient memory to run 
	the K-means function in this step such as 24G. Avoid virtual memory. 
	Otherwise it runs very slowly. The learned cluster centers will be saved as 
	the file Cluster\sf4\sigma1.6\ClusterResults_sf4_sigma1.6.mat
step(6) Run the file PP6_LabelFeature.m. This file extracts all LR patches and 
	label the closet cluster centers in the LR feature space. I only save labels
	rather than features in order to save the disk space. The saved labels are 
	in the sub-folder Label\sf4\sigma1.6. This step requires intensive 
	computational load to label all training files. It is best to run the file 
	by multiple MATLAB instances from many machines to increase the throughput.
step(7) Run the file PP7_TrainMappingFunction.m to training the regression 
	coefficients for each cluster center.
step(8) Run the file PP8_MergeCoefMatrix.m to merge all coefficients into a 
	single file as the Regressor\sf4\sigma1.6\coef_matrix_sf4_sigma1.6.mat.



==================================================
Tested platforms
==================================================
This package is test on a machine.
Machine 1
OS: Windows 7 64 bits
MATLAB version: MATLAB 2013b
CPU: Intel i7 920 2.67GHz
Memory: 24GB

