% this code is for image classification using the bag of word model
% spatial pyramid pooling is used to generate the image signature
clear;clc;  % clear

image_dir = 'image';
data_dir = 'data';
dataname = 'scene_categories';
image_dir = fullfile(image_dir,dataname);
data_dir = fullfile(data_dir,dataname);
dic_dir = 'data/dic';

skip_sift = true;
skip_idx_sig = true;
skip_dic_training = true;
skip_spm_sig = true;

%------------- calculate the sift feature for the image ------------------%
fprintf('The feature extraction...\n');
feature_option.max_size = 1000;
feature_option.suffix = '_sift';
if ~skip_sift
    database = calculateImageFeature(image_dir,data_dir,feature_option);
else
    database = retrievalDatabase(data_dir,feature_option.suffix);
end

%------------ using cluster to get a visual word dictionary --------------%
fprintf('The dictionary training...\n');
dic_option.max_num = 100000;
dic_option.dic_img_num = 50;
dic_option.k = 200;
dic_option.max_iters = 50;
dic_path = fullfile(dic_dir,[dataname,'_',num2str(dic_option.max_num),'_',num2str(dic_option.k),feature_option.suffix,'.mat']);
if ~isdir(dic_dir)
    mkdir(dic_dir);
end
if ~skip_dic_training
    dictionary = generateDictionary(database,dic_option);
    save(dic_path,'dictionary');
else
    load(dic_path);
end
%------------ compute the index for every visual feature -----------------%
fprintf('The index assignment...\n');
assignment_option.dictionary = dictionary;
assignment_option.suffix = '_idx';
if ~skip_idx_sig
    idx_database = assignmentIndexFeature(database,data_dir,assignment_option);
else
    idx_database = retrievalDatabase(data_dir,assignment_option.suffix);
end

%%%%%%%%%%%%%%%%%%%%%%% Deprecated pooling method %%%%%%%%%%%%%%%%%%%%%%%%%
%------------ spatial pyramid pooling for the image ----------------------%
% pooling_option.pyramid = [1 2 4];
% pooling_option.dic_dim = 200;
% spm_sig = poolingImage(idx_database,pooling_option);
% labels = idx_database.label;
% % debug_sig = spm_sig;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compile the spatial pyramid for the image
fprintf('The spm signature computing...\n');
spm.suffix = '_spm';
spm.pyramid_level = 3;
spm.dic_wc = 200;
if ~skip_spm_sig
    [spm_sig,labels] = computeSPM(idx_database,spm);
else
    spm_database = retrievalDatabase(data_dir,spm.suffix);
    labels = spm_database.label;
    spm_dim = spm.dic_wc*getBinsFromPyramidLevel(spm.pyramid_level);
    spm_sig = zeros(length(spm_database.feature_path),spm_dim);
    for i = 1:length(spm_database.feature_path)
        load(spm_database.feature_path{i});
        spm_sig(i,:) = SPM_histogram;
    end
end

%------------ svm training and test --------------------------------------%
% select the training and testing data
fprintf('The classifier training...\n');
tr_num_per_class = 100;   % training size per class
[num_sig,sig_dim] = size(spm_sig);
train_data = zeros(tr_num_per_class*idx_database.num_class,sig_dim);
test_data = zeros(num_sig-tr_num_per_class*idx_database.num_class,sig_dim);
train_label = zeros(tr_num_per_class*idx_database.num_class,1);
test_label = zeros(num_sig-tr_num_per_class*idx_database.num_class,1);

ts_idx = 1;
for i = 1:idx_database.num_class
    class_idx = labels==i;
    class_data = spm_sig(class_idx,:);
    class_label = labels(class_idx,:);
    len = length(class_label);
    rnd_idx = randperm(len);
    train_data((i-1)*tr_num_per_class+1:i*tr_num_per_class,:) = class_data(rnd_idx(1:tr_num_per_class),:);
    train_label((i-1)*tr_num_per_class+1:i*tr_num_per_class,:) = class_label(rnd_idx(1:tr_num_per_class),:);
    ts_end = ts_idx+len-tr_num_per_class;
    test_data(ts_idx:ts_end-1,:) = class_data(rnd_idx(tr_num_per_class+1:end),:);
    test_label(ts_idx:ts_end-1,:) = class_label(rnd_idx(tr_num_per_class+1:end),:);
    ts_idx = ts_end;
end

%--------------- train and test the svm ----------------------------------%
tr_num = size(train_data,1);
ts_num = size(test_data,1);
tr_tr_kernel_mat = computeKernelMat(train_data,train_data);
ts_tr_kernel_mat = computeKernelMat(test_data,train_data);
model = svmtrain(train_label,[(1:tr_num)',tr_tr_kernel_mat],'-t 4');

fprintf('The test running...\n');
[predict_label,accuracy,dec_values] = svmpredict(test_label,[(1:ts_num)',ts_tr_kernel_mat],model);





