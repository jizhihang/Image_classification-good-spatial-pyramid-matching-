% this code is for image classification using the bag of word model
% spatial pyramid pooling is used to generate the image signature
clear;clc;  % clear

% Setup
% fprintf('add the libsvm and vl_feat lib in!\n');
% %---the diary file
% if ~exist('logs','dir')
%     mkdir('logs');
% end
% log_date = date;
% log_file = fullfile('logs',[log_date,'.log']);
% diary(log_file);
% diary on

image_dir = 'image';
data_dir = 'data';
dataname = 'test';
image_dir = fullfile(image_dir,dataname);
data_dir = fullfile(data_dir,dataname);
% dic_dir = 'data/dic';

% the flag for whether to do the period or not
skip_feat = false;
skip_idx_sig = false;
% skip_dic_training = true;
skip_spm_sig = false;

%------------- calculate the sift feature for the image ------------------%
fprintf('The feature extraction...\n');
feature_option.max_size = 1000;
feature_option.suffix = '_lbp';
tic
if ~skip_feat
    database = calculateImageFeature(image_dir,data_dir,feature_option);
else
    database = retrievalDatabase(data_dir,feature_option.suffix);
end
toc


%------------ compute the index for every visual feature -----------------%
% fprintf('The index assignment...\n');
% tic
% assignment_option.dictionary = dictionary;
% assignment_option.suffix = '_idx';
% if ~skip_idx_sig
%     idx_database = assignmentIndexFeature(database,data_dir,assignment_option);
% else
%     idx_database = retrievalDatabase(data_dir,assignment_option.suffix);
% end
% toc

%%%%%%%%%%%%%%%%%%%%%%% Deprecated pooling method %%%%%%%%%%%%%%%%%%%%%%%%%
%------------ spatial pyramid pooling for the image ----------------------%
% pooling_option.pyramid = [1 2 4];
% pooling_option.dic_dim = 200;
% spm_sig = poolingImage(idx_database,pooling_option);
% labels = idx_database.label;
% % debug_sig = spm_sig;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compile the spatial pyramid for the image
% fprintf('The spm signature computing...\n');
% tic
% spm.suffix = '_spm';
% spm.pyramid_level = 3;
% spm.dic_wc = 200;
% if ~skip_spm_sig
%     [spm_sig,labels] = computeSPM(idx_database,spm);
% else
%     spm_database = retrievalDatabase(data_dir,spm.suffix);
%     labels = spm_database.label;
%     spm_dim = spm.dic_wc*getBinsFromPyramidLevel(spm.pyramid_level);
%     spm_sig = zeros(length(spm_database.feature_path),spm_dim);
%     for i = 1:length(spm_database.feature_path)
%         load(spm_database.feature_path{i});
%         spm_sig(i,:) = SPM_histogram;
%     end
% end
% toc
% 
% %------------ svm training and test --------------------------------------%
% % select the training and testing data
% fprintf('prepare the svm data...\n');
% tic
% tr_num_per_class = 100;   % training size per class
% [num_sig,sig_dim] = size(spm_sig);
% train_data = zeros(tr_num_per_class*idx_database.num_class,sig_dim);
% test_data = zeros(num_sig-tr_num_per_class*idx_database.num_class,sig_dim);
% train_label = zeros(tr_num_per_class*idx_database.num_class,1);
% test_label = zeros(num_sig-tr_num_per_class*idx_database.num_class,1);
% 
% ts_idx = 1;
% for i = 1:idx_database.num_class
%     class_idx = labels==i;
%     class_data = spm_sig(class_idx,:);
%     class_label = labels(class_idx,:);
%     len = length(class_label);
%     rnd_idx = randperm(len);
%     train_data((i-1)*tr_num_per_class+1:i*tr_num_per_class,:) = class_data(rnd_idx(1:tr_num_per_class),:);
%     train_label((i-1)*tr_num_per_class+1:i*tr_num_per_class,:) = class_label(rnd_idx(1:tr_num_per_class),:);
%     ts_end = ts_idx+len-tr_num_per_class;
%     test_data(ts_idx:ts_end-1,:) = class_data(rnd_idx(tr_num_per_class+1:end),:);
%     test_label(ts_idx:ts_end-1,:) = class_label(rnd_idx(tr_num_per_class+1:end),:);
%     ts_idx = ts_end;
% end
% toc
% 
% %--------------- train and test the svm ----------------------------------%
% fprintf('svm training...\n');
% tic
% tr_num = size(train_data,1);
% ts_num = size(test_data,1);
% tr_tr_kernel_mat = computeKernelMat(train_data,train_data);
% ts_tr_kernel_mat = computeKernelMat(test_data,train_data);
% model = svmtrain(train_label,[(1:tr_num)',tr_tr_kernel_mat],'-t 4');
% toc
% 
% fprintf('svm testing...\n');
% tic
% [predict_label,accuracy,dec_values] = svmpredict(test_label,[(1:ts_num)',ts_tr_kernel_mat],model);
% toc
% diary off
