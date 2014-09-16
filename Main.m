% this code is for image classification using the bag of word model
% spatial pyramid pooling is used to generate the image signature
clear;clc;  % clear

Setup
fprintf('add the libsvm and vl_feat lib in!\n');
%---the diary file
if ~exist('logs','dir')
    mkdir('logs');
end
log_date = date;
log_file = fullfile('logs',[log_date,'.log']);
diary(log_file);
diary on

image_dir = 'image';
data_dir = 'data';
dataname = 'scene_categories';
image_dir = fullfile(image_dir,dataname);
data_dir = fullfile(data_dir,dataname);
dic_dir = 'data/dic';

% the flag for whether to do the period or not
skip_sift = true;
skip_idx_sig = true;
skip_dic_training = true;


feature_selection = false;   % add the feature selection period,if true then the spm should re-compute
skip_spm_sig = false;

%------------- calculate the sift feature for the image ------------------%
fprintf('The feature extraction...\n');
feature_option.max_size = 1000;
feature_option.suffix = '_dsift';
tic
if ~skip_sift
    database = calculateImageFeature(image_dir,data_dir,feature_option);
else
    database = retrievalDatabase(data_dir,feature_option.suffix);
end
toc

%------------ using cluster to get a visual word dictionary --------------%
fprintf('The dictionary training...\n');
tic
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
toc

%------------ compute the index for every visual feature -----------------%
fprintf('The index assignment...\n');
tic
assignment_option.dictionary = dictionary;
assignment_option.suffix = '_idx';
if ~skip_idx_sig
    idx_database = assignmentIndexFeature(database,data_dir,assignment_option);
else
    idx_database = retrievalDatabase(data_dir,assignment_option.suffix);
end
toc

%------------------ select the right visual words for class --------------%
visual_dic_size = dic_option.k;
select_per_class = 10;

if feature_selection,
    % add the feature selection period here
    idx_paths = idx_database.feature_path;
    idx_labels = idx_database.label;
    total_pic = length(idx_labels);
    wordsAll = zeros(200,total_pic);
    for i = 1:length(idx_paths)
        % here the image is a image that every feature is a dictionary word
        load(idx_paths{i});
        wordsFreq = hist(idx_sig.data,1:visual_dic_size);
        wordsAll(:,i) = wordsFreq';
    end
    select_word_ids = featureSelection(wordsAll,idx_labels,select_per_class);
else
    select_word_ids = [1:dic_option.k];
end


%---------------- compile the spatial pyramid for the image --------------%
fprintf('The spm signature computing...\n');
tic
spm.suffix = '_spm';
spm.pyramid_level = 1;
spm.dic_wc = length(select_word_ids);
spm.dic_word_id = select_word_ids;
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
toc

%------------ svm training and test --------------------------------------%
% select the training and testing data
fprintf('prepare the svm data...\n');
tic
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
toc

%--------------- train and test the svm ----------------------------------%
fprintf('svm training...\n');
tic
tr_num = size(train_data,1);
ts_num = size(test_data,1);
tr_tr_kernel_mat = computeKernelMat(train_data,train_data);
ts_tr_kernel_mat = computeKernelMat(test_data,train_data);
model = svmtrain(train_label,[(1:tr_num)',tr_tr_kernel_mat],'-t 4');
toc

fprintf('svm testing...\n');
tic
[predict_label,accuracy,dec_values] = svmpredict(test_label,[(1:ts_num)',ts_tr_kernel_mat],model);
toc

% tic
% fprintf('svm linear training and testing...\n');
% model = svmtrain(train_label, train_data, '-c 1 -g 0.07');
% [predict_label, accuracy, prob_estimates] = svmpredict(test_label, test_data, model);
% toc

diary off





