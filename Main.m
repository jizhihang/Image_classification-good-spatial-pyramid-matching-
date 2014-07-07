% this code is for image classification using the bag of word model
% spatial pyramid pooling is used to generate the image signature
image_dir = 'image/test';
data_dir = 'data/test';
skip_sift = false;
skip_idx_sig = false;

%------------- calculate the sift feature for the image ------------------%
feature_option.max_size = 1000;
feature_option.suffix = '_sift';
if ~skip_sift
    database = calculateImageFeature(image_dir,data_dir,feature_option);
else
    database = retrievalDatabase(data_dir,'_sift');
end

%------------ using cluster to get a visual word dictionary --------------%
dic_option.max_num = 100000;
dic_option.dic_img_num = 50;
dic_option.k = 200;
dic_option.max_iters = 50;
dictionary = generateDictionary(database,dic_option);

%------------ compute the index for every visual feature -----------------%
assignment_option.dictionary = dictionary;
assignment_option.suffix = '_idx';
if ~skip_idx_sig
    idx_database = assignmentIndexFeature(database,data_dir,assignment_option);
else
    idx_database = retrievalDatabase(data_dir,'_idx');
end

%------------ spatial pyramid pooling for the image ----------------------%
pooling_option.pyramid = 1;
pooling_option.dic_dim = 200;
pooling_sig = poolingImage(idx_database,pooling_option);
labels = idx_database.label;

%------------ svm training and test --------------------------------------%
% select the training and testing data
tr_num_per_class = 30;   % training size per class
[num_sig,sig_dim] = size(pooling_sig);
train_data = zeros(tr_num_per_class*idx_database.num_class,sig_dim);
test_data = zeros(num_sig-tr_num_per_class*idx_database.num_class,sig_dim);
train_label = zeros(tr_num_per_class*idx_database.num_class,1);
test_label = zeros(num_sig-tr_num_per_class*idx_database.num_class,1);

ts_idx = 1;
for i = 1:idx_database.num_class
    class_idx = labels==i;
    class_data = pooling_sig(class_idx,:);
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
model = svmtrain(train_label,train_data,'-c 1 -g 0.07');
[predict_label,accuracy,dec_values] = svmpredict(test_label,test_data,model);





